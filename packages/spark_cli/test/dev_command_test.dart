import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:spark_cli/src/commands/dev_command.dart';
import 'package:spark_cli/src/io/process_runner.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';
import 'package:watcher/watcher.dart';

void main() {
  group('DevCommand', () {
    late MockProcessRunner processRunner;
    late CommandRunner<void> runner;
    late MockProcess buildRunnerProcess;
    late MockProcess serverProcess;
    late MockVmService vmService;
    late Directory tempDir;

    // Track active watcher to close it
    MockWatcher? activeWatcher;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('spark_dev_test');
      processRunner = MockProcessRunner();
      buildRunnerProcess = MockProcess();
      serverProcess = MockProcess();
      vmService = MockVmService();

      processRunner.processes['build_runner'] = buildRunnerProcess;
      processRunner.processes['server'] = serverProcess;

      runner = CommandRunner<void>('spark', 'Spark CLI')
        ..addCommand(
          DevCommand(
            processRunner: processRunner,
            vmServiceConnector: (uri) async => vmService,
            workingDirectory: tempDir,
            watcherFactory: (path) {
              activeWatcher = MockWatcher(path);
              return activeWatcher!;
            },
          ),
        );
    });

    tearDown(() async {
      await activeWatcher?.close();
      activeWatcher = null;

      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('starts build_runner and server', () async {
      // We need to manage the async checks carefully.
      // The command waits for output. We should simulate output.

      // Create a dummy file to ensure DirectoryWatcher has something to watch/dir is valid
      File(
        p.join(tempDir.path, 'main.dart'),
      ).writeAsStringSync('void main() {}');

      // Use runZoned to suppress print output from ConsoleOutput
      runZoned(
        () {
          return runner.run(['dev']);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {},
        ),
      );

      // 1. build_runner starts
      await Future.delayed(const Duration(milliseconds: 100));
      expect(
        processRunner.calls,
        contains(
          'dart run build_runner watch --delete-conflicting-outputs --output web:build/web',
        ),
      );

      // Simulate build success
      buildRunnerProcess.stdoutController.add(
        utf8.encode('[INFO] Succeeded after 1.0s\n'),
      );

      // 2. server starts
      await Future.delayed(const Duration(milliseconds: 100));
      expect(
        processRunner.calls,
        contains('dart run --enable-vm-service=0 bin/server.dart'),
      );

      // Simulate VM service URI from server
      serverProcess.stdoutController.add(
        utf8.encode(
          'The Dart VM service is listening on http://127.0.0.1:8181/auth_code/\n',
        ),
      );

      // Clean up manually since the command is still running "forever" in the future
      processRunner.processes.clear();
    });

    test(
      'starts server when build_runner reports no actions completed',
      () async {
        File(
          p.join(tempDir.path, 'main.dart'),
        ).writeAsStringSync('void main() {}');

        runZoned(
          () {
            return runner.run(['dev']);
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) {},
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));

        // Simulate "No actions completed"
        buildRunnerProcess.stdoutController.add(
          utf8.encode('[INFO] No actions completed. \n'),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        expect(
          processRunner.calls,
          contains('dart run --enable-vm-service=0 bin/server.dart'),
        );

        processRunner.processes.clear();
      },
    );

    test('accepts --verbose flag and shows INFO logs', () async {
      File(
        p.join(tempDir.path, 'main.dart'),
      ).writeAsStringSync('void main() {}');

      final printedLines = <String>[];

      runZoned(
        () {
          return runner.run(['dev', '--verbose']);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            printedLines.add(line);
          },
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate an [INFO] log line from build_runner
      buildRunnerProcess.stdoutController.add(
        utf8.encode('[INFO] Running build...\n'),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // In verbose mode, [INFO] lines should NOT be suppressed and should
      // appear in output via BuildRunnerUtils._pipeStream (printed as gray).
      // The onLog callback also receives the line but since it doesn't match
      // any known pattern it falls through without being suppressed.
      expect(
        printedLines.any((line) => line.contains('[INFO] Running build...')),
        isTrue,
        reason: 'INFO logs should be visible in verbose mode',
      );

      processRunner.processes.clear();
    });

    test('suppresses INFO logs without --verbose', () async {
      File(
        p.join(tempDir.path, 'main.dart'),
      ).writeAsStringSync('void main() {}');

      final printedLines = <String>[];

      runZoned(
        () {
          return runner.run(['dev']);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            printedLines.add(line);
          },
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Simulate an [INFO] log line from build_runner
      buildRunnerProcess.stdoutController.add(
        utf8.encode('[INFO] Running build...\n'),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Without verbose, [INFO] lines from onLog should be suppressed.
      // BuildRunnerUtils._pipeStream also won't print because verbose=false.
      expect(
        printedLines.any((line) => line.contains('[INFO] Running build...')),
        isFalse,
        reason: 'INFO logs should be suppressed without --verbose',
      );

      processRunner.processes.clear();
    });

    test('deletes existing build folder on startup', () async {
      // Setup using shared tempDir
      final buildDir = Directory(p.join(tempDir.path, 'build'));
      buildDir.createSync();
      File(p.join(buildDir.path, 'test_file.txt')).writeAsStringSync('test');

      runZoned(
        () {
          return runner.run(['dev']);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {},
        ),
      );

      await Future.delayed(Duration(milliseconds: 50));
      expect(buildDir.existsSync(), isFalse);
    });

    test('uses polling watcher when --poll flag is passed', () async {
      File(
        p.join(tempDir.path, 'main.dart'),
      ).writeAsStringSync('void main() {}');

      // Run with --poll flag
      runZoned(
        () {
          return runner.run(['dev', '--poll']);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {},
        ),
      );

      await Future.delayed(const Duration(milliseconds: 200));

      // The watcherFactory should NOT have been called, so activeWatcher should be null
      expect(
        activeWatcher,
        isNull,
        reason:
            'Should use PollingDirectoryWatcher instead of injected factory',
      );

      processRunner.processes.clear();
    });
  });
}

// Mocks

class MockWatcher implements Watcher {
  final String path;
  final StreamController<WatchEvent> _controller =
      StreamController<WatchEvent>.broadcast();

  MockWatcher(this.path);

  Future<void> close() => _controller.close();

  @override
  Stream<WatchEvent> get events => _controller.stream;

  @override
  bool get isReady => true;

  @override
  Future<void> get ready => Future.value();
}

class MockProcessRunner implements ProcessRunner {
  // Map identifying keywords to mock processes
  Map<String, MockProcess> processes = {};
  List<String> calls = [];

  @override
  Future<Process> start(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    final command = '$executable ${arguments.join(' ')}';
    calls.add(command);

    if (arguments.contains('build_runner')) {
      return processes['build_runner']!;
    }
    if (arguments.contains('bin/server.dart')) {
      return processes['server']!;
    }
    return MockProcess();
  }

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding? stdoutEncoding = systemEncoding,
    Encoding? stderrEncoding = systemEncoding,
  }) {
    throw UnimplementedError();
  }
}

class MockProcess implements Process {
  final StreamController<List<int>> stdoutController = StreamController();
  final StreamController<List<int>> stderrController = StreamController();
  final Completer<int> exitCodeCompleter = Completer();

  @override
  Stream<List<int>> get stdout => stdoutController.stream;

  @override
  Stream<List<int>> get stderr => stderrController.stream;

  @override
  Future<int> get exitCode => exitCodeCompleter.future;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    exitCodeCompleter.complete(0);
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockVmService implements VmService {
  @override
  Future<void> dispose() async {}

  @override
  Future<VM> getVM() async {
    return VM(isolates: [IsolateRef(id: '123')]);
  }

  @override
  Future<ReloadReport> reloadSources(
    String isolateId, {
    bool? force,
    bool? pause,
    String? rootLibUri,
    String? packagesUri,
  }) async {
    return ReloadReport(success: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
