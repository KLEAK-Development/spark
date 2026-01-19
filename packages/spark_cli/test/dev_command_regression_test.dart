import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:spark_cli/src/commands/dev_command.dart';
import 'package:spark_cli/src/io/process_runner.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

// Copy of mocks to isolate test
class MockProcessRunner implements ProcessRunner {
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
      final p = MockProcess();
      processes['build_runner'] = p;
      return p;
    }
    if (arguments.contains('bin/server.dart')) {
      final p = MockProcess();
      // Store the process so we can access it later to simulate outputs
      // If we are restarting, we might be creating a new one.
      // We'll store it in a list or just overwrite if we assume sequential.
      // For this test, let's keep track of all server processes.
      processes['server_${processes.length}'] = p;
      processes['server_latest'] = p;
      return p;
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

  // Helper to determine if kill was called
  bool killCalled = false;

  @override
  Stream<List<int>> get stdout => stdoutController.stream;

  @override
  Stream<List<int>> get stderr => stderrController.stream;

  @override
  Future<int> get exitCode => exitCodeCompleter.future;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killCalled = true;
    if (!exitCodeCompleter.isCompleted) {
      exitCodeCompleter.complete(0);
    }
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockVmService implements VmService {
  bool disposed = false;

  @override
  Future<void> dispose() async {
    disposed = true;
  }

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

void main() {
  group('DevCommand Regression Tests', () {
    late MockProcessRunner processRunner;
    late CommandRunner<void> runner;
    late MockVmService vmService;
    late Directory tempDir;

    setUp(() async {
      processRunner = MockProcessRunner();
      vmService = MockVmService();

      // Setup temp directory for router check
      tempDir = await Directory.systemTemp.createTemp('spark_dev_regression');
      // No global state mutation!

      // Create dummy router file
      final routerFile = File(
        p.join(tempDir.path, 'lib', 'spark_router.g.dart'),
      );
      await routerFile.create(recursive: true);
      await routerFile.writeAsString('initial content');

      runner = CommandRunner<void>('spark', 'Spark CLI')
        ..addCommand(
          DevCommand(
            processRunner: processRunner,
            vmServiceConnector: (uri) async => vmService,
            workingDirectory: tempDir, // Explicitly pass working directory
          ),
        );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'restarts server exactly once when router changes (prevents race condition)',
      () async {
        // 1. Start dev command
        // Run it in a zoned guard to suppress output and errors
        unawaited(
          runZoned(
            () => runner.run(['dev']),
            zoneSpecification: ZoneSpecification(
              print: (self, parent, zone, line) {},
            ),
          ),
        );

        // Wait for build runner to start
        await Future.delayed(Duration(milliseconds: 100));
        expect(processRunner.processes.containsKey('build_runner'), isTrue);

        final buildProc = processRunner.processes['build_runner']!;

        // 2. Simulate initial build success
        buildProc.stdoutController.add(
          utf8.encode('[INFO] Succeeded after 1.0s\n'),
        );

        // Wait for server to start
        await Future.delayed(Duration(milliseconds: 100));
        expect(processRunner.processes.containsKey('server_latest'), isTrue);
        final firstServerProc = processRunner.processes['server_latest']!;

        // Simulate VM service emission
        firstServerProc.stdoutController.add(
          utf8.encode(
            'The Dart VM service is listening on http://127.0.0.1:8181/\n',
          ),
        );

        // Wait a bit
        await Future.delayed(Duration(milliseconds: 100));

        // Verify initial state
        // We expect 1 server start
        var serverStartCount = processRunner.calls
            .where((c) => c.contains('bin/server.dart'))
            .length;
        expect(serverStartCount, equals(1));

        // 3. Update router file to trigger restart logic on next build
        final routerFile = File(
          p.join(tempDir.path, 'lib', 'spark_router.g.dart'),
        );
        await routerFile.writeAsString('updated content');

        // 4. Simulate build success again
        buildProc.stdoutController.add(
          utf8.encode('[INFO] Succeeded after 0.5s\nUpdated content\n'),
        );

        // We need to wait for the restart delay (500ms in code) plus some buffer
        await Future.delayed(Duration(milliseconds: 1000));

        // 5. Verify restart behavior

        // The first server process should have been killed
        expect(
          firstServerProc.killCalled,
          isTrue,
          reason: 'First server should be killed',
        );

        // We expect exactly 2 server starts in total (1 initial + 1 restart)
        serverStartCount = processRunner.calls
            .where((c) => c.contains('bin/server.dart'))
            .length;

        expect(
          serverStartCount,
          equals(2),
          reason:
              'Server should have been started exactly twice (initial + restart)',
        );
      },
    );
  });
}
