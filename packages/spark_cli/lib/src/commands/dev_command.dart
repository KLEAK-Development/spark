import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:watcher/watcher.dart';

import '../console/console_output.dart';
import '../errors/dev_error.dart';
import '../errors/dev_error_collector.dart';
import '../errors/dev_error_type.dart';
import '../io/process_runner.dart';
import '../utils/build_runner_utils.dart';
import '../utils/directory_utils.dart';

typedef VmServiceConnector = Future<VmService> Function(String uri);
typedef WatcherFactory = Watcher Function(String path);

class DevCommand extends Command<void> {
  @override
  String get name => 'dev';

  @override
  String get description => 'Start the development server with hot reload.';

  // Configuration
  static const Duration _buildTimeout = Duration(minutes: 2);
  static const Duration _serverStartTimeout = Duration(seconds: 30);
  static const Duration _vmServiceConnectTimeout = Duration(seconds: 10);

  final ProcessRunner _processRunner;
  final VmServiceConnector _vmServiceConnector;
  final Directory _workingDirectory;
  final WatcherFactory _watcherFactory;

  DevCommand({
    ProcessRunner processRunner = const ProcessRunnerImpl(),
    VmServiceConnector? vmServiceConnector,
    Directory? workingDirectory,
    WatcherFactory? watcherFactory,
  }) : _processRunner = processRunner,
       _vmServiceConnector = vmServiceConnector ?? vmServiceConnectUri,
       _workingDirectory = workingDirectory ?? Directory.current,
       _watcherFactory = watcherFactory ?? ((path) => DirectoryWatcher(path)) {
    _buildUtils = BuildRunnerUtils(
      processRunner: processRunner,
      console: _console,
      workingDirectory: _workingDirectory,
    );
    argParser.addFlag('verbose', abbr: 'v', help: 'Show verbose log output.');
    argParser.addFlag(
      'poll',
      help: 'Use polling watcher (useful for WSL/Docker).',
      negatable: false,
    );
  }

  late final BuildRunnerUtils _buildUtils;
  Process? _buildRunnerProcess;
  Process? _serverProcess;
  VmService? _vmService;
  StreamSubscription? _sigintSubscription;
  StreamSubscription? _fileWatcherSubscription;

  // Track router file hash to detect structural changes requiring restart
  String? _lastRouterHash;
  String get _routerFilePath =>
      p.join(_workingDirectory.path, 'lib', 'spark_router.g.dart');

  // Verbose logging flag
  bool _verbose = false;
  // Polling watcher flag
  bool _usePolling = false;

  // Error handling components
  final ConsoleOutput _console = ConsoleOutput();
  final DevErrorCollector _errorCollector = DevErrorCollector();

  // Completion tracking
  Completer<void>? _mainCompleter;
  bool _isShuttingDown = false;

  @override
  Future<void> run() async {
    _verbose = argResults!['verbose'] as bool;
    _usePolling = argResults!['poll'] as bool;
    _console.printInfo('Starting development environment...');

    await DirectoryUtils.cleanDirectory(
      p.join(_workingDirectory.path, 'build'),
      _console,
      message: 'Cleaning build folder',
    );

    _mainCompleter = Completer<void>();
    _setupSignalHandling();

    try {
      await _startBuildRunner();
      await _startServer();
      _startFileWatcher();

      // Keep the command running
      await _mainCompleter!.future;
    } catch (e, st) {
      _errorCollector.add(
        DevError.server(
          message: 'Development environment failed to start: $e',
          error: e,
          stackTrace: st,
        ),
      );
      _errorCollector.printSummary();
      await _cleanup();
      exit(1);
    }
  }

  void _setupSignalHandling() {
    _sigintSubscription = ProcessSignal.sigint.watch().listen((_) async {
      _console.printLine();
      _console.printInfo('Stopping development environment...');
      _isShuttingDown = true;
      await _cleanup();
      exit(0);
    });
  }

  Future<void> _cleanup() async {
    _debounceTimer?.cancel();
    _fileWatcherSubscription?.cancel();
    _sigintSubscription?.cancel();
    _buildRunnerProcess?.kill();
    _serverProcess?.kill();
    _vmService?.dispose();
    _liveReloadServer?.close(force: true);
    _console.printGray('Cleaned up processes.');
  }

  Future<void> _startBuildRunner() async {
    final completer = Completer<void>();
    var hasCompleted = false;

    _buildRunnerProcess = await _buildUtils.startWatch(
      verbose: _verbose,
      extraArgs: ['--output', 'web:build/web'],
      onLog: (line) {
        if (line.contains('Succeeded after') ||
            line.contains('Built with') ||
            line.contains('No actions completed') ||
            line.contains('wrote 0 outputs')) {
          _buildUtils.parser.finalize();

          // Show errors from this build if any
          if (_buildUtils.parser.errors.isNotEmpty) {
            _errorCollector.clearType(DevErrorType.build);
            _errorCollector.addAll(_buildUtils.parser.errors);
            _errorCollector.printSummary(clearAfter: true);
            _buildUtils.parser.clear();
          }

          _console.printSuccess('Build completed.');
          if (!completer.isCompleted) {
            hasCompleted = true;
            // Store initial router hash
            _computeRouterHash().then((hash) => _lastRouterHash = hash);
            completer.complete();
          } else {
            // Rebuild completed, check if router changed
            _handleBuildComplete();
          }
        } else if (line.contains('Failed after')) {
          _buildUtils.parser.finalize();
          _errorCollector.clearType(DevErrorType.build);
          _errorCollector.addAll(_buildUtils.parser.errors);
          _errorCollector.printSummary();
          _buildUtils.parser.clear();

          // Don't complete with error on rebuild failures, only on initial build
          if (!completer.isCompleted) {
            hasCompleted = true;
            completer.completeError(StateError('Initial build failed'));
          }
        } else if (line.contains('[INFO]') && !_verbose) {
          // Suppress INFO logs unless verbose
        } else if (line.contains('Building...')) {
          _console.clear();
          _buildUtils.parser.clear();
          _console.printWarning('Building...');
        }
      },
    );

    // Monitor process exit
    _buildRunnerProcess!.exitCode.then((exitCode) {
      if (!hasCompleted && !_isShuttingDown) {
        _errorCollector.add(
          DevError.server(
            message: 'build_runner exited unexpectedly',
            exitCode: exitCode,
          ),
        );
        if (!completer.isCompleted) {
          completer.completeError(
            StateError('build_runner exited with code $exitCode'),
          );
        }
      }
    });

    _console.printGray('Waiting for first build to complete...');

    // Add timeout for initial build
    try {
      await completer.future.timeout(
        _buildTimeout,
        onTimeout: () {
          _errorCollector.add(
            DevError.timeout(
              message: 'build_runner did not complete initial build',
              duration: _buildTimeout,
            ),
          );
          throw TimeoutException('Build timed out', _buildTimeout);
        },
      );
    } on TimeoutException {
      _errorCollector.printSummary();
      rethrow;
    }
  }

  HttpServer? _liveReloadServer;
  final List<WebSocket> _liveReloadSockets = [];
  int? _liveReloadPort;

  Future<void> _startLiveReloadServer() async {
    try {
      _liveReloadServer = await HttpServer.bind('localhost', 0);
      _liveReloadPort = _liveReloadServer!.port;
      _console.printGray(
        'Live Reload server listening on port $_liveReloadPort',
      );

      _liveReloadServer!.transform(WebSocketTransformer()).listen((webSocket) {
        _liveReloadSockets.add(webSocket);
        webSocket.listen(
          (message) {},
          onDone: () => _liveReloadSockets.remove(webSocket),
          onError: (e) => _liveReloadSockets.remove(webSocket),
        );
      });
    } catch (e, st) {
      _errorCollector.add(
        DevError.liveReload(
          message: 'Failed to start Live Reload server',
          error: e,
          stackTrace: st,
        ),
      );
      _errorCollector.printSummary();
    }
  }

  void _triggerLiveReload() {
    _console.printInfo('Triggering Browser Reload...');
    for (final socket in List.of(_liveReloadSockets)) {
      try {
        socket.add('reload');
      } catch (_) {
        _liveReloadSockets.remove(socket);
      }
    }
  }

  Future<void> _startServer() async {
    if (_liveReloadPort == null) await _startLiveReloadServer();

    _console.printInfo('Starting server...');

    final vmServiceCompleter = Completer<String>();

    _serverProcess = await _processRunner.start(
      'dart',
      ['run', '--enable-vm-service=0', 'bin/server.dart'],
      workingDirectory: _workingDirectory.path,
      environment: {
        if (_liveReloadPort != null)
          'SPARK_DEV_RELOAD_PORT': _liveReloadPort.toString(),
      },
    );

    // Monitor server process exit
    _serverProcess!.exitCode.then((exitCode) {
      if (!_isShuttingDown && !_isRestarting) {
        _errorCollector.add(
          DevError.server(
            message: 'Server process exited unexpectedly',
            exitCode: exitCode,
          ),
        );
        _errorCollector.printSummary();

        // Attempt to restart server
        _console.printWarning('Attempting to restart server...');
        _restartServer();
      }
    });

    _serverProcess!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          if (line.contains('The Dart VM service is listening on')) {
            final uri = _extractVmServiceUri(line);
            if (uri != null && !vmServiceCompleter.isCompleted) {
              vmServiceCompleter.complete(uri);
            }
          } else if (line.contains('Server running at')) {
            _console.printSuccess(line);
          } else if ((line.contains('The Dart DevTools') ||
                  line.contains('Connecting to VM Service')) &&
              !_verbose) {
            // Suppress noise unless verbose
          } else {
            _console.printGray('[Server] $line');
          }
        });

    _serverProcess!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          _errorCollector.add(DevError.server(message: line));
          _console.printError('[Server Error] $line');
        });

    // Wait for VM service URI with timeout
    try {
      final uri = await vmServiceCompleter.future.timeout(
        _serverStartTimeout,
        onTimeout: () {
          throw TimeoutException('Server did not start', _serverStartTimeout);
        },
      );
      await _connectToVmService(uri);
    } on TimeoutException catch (e) {
      _errorCollector.add(
        DevError.timeout(
          message: 'Server did not expose VM service URI',
          duration: _serverStartTimeout,
        ),
      );
      _errorCollector.printSummary();
      throw e;
    }
  }

  bool _isRestarting = false;

  Future<void> _restartServer() async {
    if (_isRestarting) return;
    _isRestarting = true;

    _vmService?.dispose();
    _vmService = null;

    if (_serverProcess != null) {
      _serverProcess?.kill();
      // Wait for process to exit to ensure port is released
      try {
        await _serverProcess!.exitCode;
      } catch (_) {
        // Ignore errors waiting for exit
      }
    }

    // Brief delay to ensure OS releases resources
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_isShuttingDown) {
      try {
        await _startServer();
      } catch (e) {
        _console.printError('Failed to restart server: $e');
      }
    }

    _isRestarting = false;
  }

  String? _extractVmServiceUri(String line) {
    final match = RegExp(r'(http://[a-zA-Z0-9.:/=_=%&-]+)').firstMatch(line);
    return match?.group(0);
  }

  Future<void> _connectToVmService(String uri) async {
    try {
      var wsUri = uri.replaceFirst('http', 'ws');
      if (!wsUri.endsWith('/')) {
        wsUri += '/';
      }
      wsUri += 'ws';

      _vmService = await _vmServiceConnector(wsUri).timeout(
        _vmServiceConnectTimeout,
        onTimeout: () {
          throw TimeoutException(
            'VM Service connection timed out',
            _vmServiceConnectTimeout,
          );
        },
      );
      _console.printSuccess('Connected to VM Service for Hot Reload.');
    } on TimeoutException catch (e) {
      _errorCollector.add(
        DevError.timeout(
          message: 'Could not connect to VM Service',
          duration: _vmServiceConnectTimeout,
        ),
      );
      _errorCollector.printSummary();
      throw e;
    } catch (e, st) {
      _errorCollector.add(
        DevError.vmService(
          message: 'Failed to connect to VM Service',
          error: e,
          stackTrace: st,
        ),
      );
      _errorCollector.printSummary();
      rethrow;
    }
  }

  Timer? _debounceTimer;

  void _startFileWatcher() {
    _console.printGray('Watching for file changes...');
    final watcher = _usePolling
        ? PollingDirectoryWatcher(_workingDirectory.path)
        : _watcherFactory(_workingDirectory.path);
    _fileWatcherSubscription = watcher.events.listen((event) {
      if (_verbose) {
        _console.printGray('[Watcher] ${event.type}: ${event.path}');
      }
      if (event.path.endsWith('.dart') &&
          !event.path.endsWith('.g.dart') &&
          !event.path.contains('${p.separator}.dart_tool') &&
          !event.path.contains('${p.separator}build${p.separator}') &&
          !event.path.contains('${p.separator}web${p.separator}')) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 600), () {
          _console.clear();
          _console.printWarning('File changed: ${p.relative(event.path)}');
          _performHotReload();
        });
      }
    });
  }

  /// Computes MD5 hash of the router file to detect structural changes.
  Future<String?> _computeRouterHash() async {
    final file = File(_routerFilePath);
    if (!await file.exists()) return null;
    final content = await file.readAsBytes();
    return md5.convert(content).toString();
  }

  /// Checks if router file changed and decides between hot reload or restart.
  Future<void> _handleBuildComplete() async {
    final newHash = await _computeRouterHash();

    if (_lastRouterHash != null && newHash != _lastRouterHash) {
      // Router structure changed (new routes/pages), need full restart
      _console.printWarning('Router changed - restarting server...');
      _lastRouterHash = newHash;
      await _restartServer();
      _triggerLiveReload();
    } else {
      // No structural changes, hot reload is sufficient
      _lastRouterHash = newHash;
      _performHotReload();
      _triggerLiveReload();
    }
  }

  Future<void> _performHotReload() async {
    if (_vmService == null) {
      _console.printWarning(
        'Hot reload unavailable - VM Service not connected',
      );
      return;
    }

    _console.printInfo('Reloading...');
    try {
      final vm = await _vmService!.getVM();
      final isolateId = vm.isolates?.first.id;
      if (isolateId != null) {
        final result = await _vmService!.reloadSources(isolateId);
        if (result.success == true) {
          _console.printSuccess('Hot reload complete.');
          _triggerLiveReload();
        } else {
          _errorCollector.add(
            DevError.hotReload(message: 'Hot reload returned unsuccessful'),
          );
          _errorCollector.printSummary(clearAfter: true);
        }
      } else {
        _errorCollector.add(
          DevError.hotReload(message: 'No isolate found for hot reload'),
        );
        _errorCollector.printSummary(clearAfter: true);
      }
    } catch (e, st) {
      _errorCollector.add(
        DevError.hotReload(
          message: 'Hot reload failed',
          error: e,
          stackTrace: st,
        ),
      );
      _errorCollector.printSummary(clearAfter: true);
    }
  }
}
