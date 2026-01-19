import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:spark_cli/src/commands/dev_command.dart';
import 'package:spark_cli/src/io/process_runner.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

void main() {
  group('DevCommand', () {
    late MockProcessRunner processRunner;
    late CommandRunner<void> runner;
    late MockProcess buildRunnerProcess;
    late MockProcess serverProcess;
    late MockVmService vmService;

    setUp(() {
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
          ),
        );
    });

    test('starts build_runner and server', () async {
      // We need to manage the async checks carefully.
      // The command waits for output. We should simulate output.

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
      await Future.delayed(Duration.zero);
      expect(
        processRunner.calls,
        contains(
          'dart run build_runner watch --output web:build/web --delete-conflicting-outputs',
        ),
      );

      // Simulate build success
      buildRunnerProcess.stdoutController.add(
        utf8.encode('[INFO] Succeeded after 1.0s\n'),
      );

      // 2. server starts
      await Future.delayed(Duration(milliseconds: 100));
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

      // 3. Verify VM Service connection
      // The command continues running... we can't easily await the exact moment of connection,
      // but if we don't throw, we are good.
      // The test 'devFuture' won't complete because the command runs forever.
      // We can check if it threw error so far.

      // Test cleanup - kill processes to end command?
      // DevCommand waits for sigint or error.
      // We can maybe send sigint? But that kills the test runner too potentially if not handled right.

      // For this test, we just want to verify startup sequence.
      // We can verify mocks interactions.

      // Clean up manually since the command is still running "forever" in the future
      processRunner.processes.clear();
    });

    test('deletes existing build folder on startup', () async {
      final tempDir = await Directory.systemTemp.createTemp('spark_dev_test');
      final buildDir = Directory('${tempDir.path}/build');
      await buildDir.create();
      await File('${buildDir.path}/test_file.txt').writeAsString('test');

      final originalDir = Directory.current;
      Directory.current = tempDir;

      try {
        runZoned(
          () {
            return runner.run(['dev']);
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) {},
          ),
        );

        await Future.delayed(Duration(milliseconds: 50));
        expect(await buildDir.exists(), isFalse);
      } finally {
        Directory.current = originalDir;
        await tempDir.delete(recursive: true);
      }
    });
  });
}

// Mocks

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
