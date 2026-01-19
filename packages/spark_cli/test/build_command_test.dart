import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:spark_cli/src/commands/build_command.dart';
import 'package:spark_cli/src/io/process_runner.dart';
import 'package:test/test.dart';

void main() {
  group('BuildCommand', () {
    late MockProcessRunner processRunner;
    late CommandRunner<void> runner;
    late MockProcess buildRunnerProcess;

    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('spark_build_test');
      processRunner = MockProcessRunner();
      buildRunnerProcess = MockProcess();

      // Setup default success behaviors
      processRunner.processes['build_runner'] = buildRunnerProcess;
      processRunner.defaultResult = ProcessResult(0, 0, '', '');

      runner = CommandRunner<void>('spark', 'Spark CLI')
        ..addCommand(
          BuildCommand(processRunner: processRunner, workingDirectory: tempDir),
        );
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        try {
          tempDir.deleteSync(recursive: true);
        } catch (_) {}
      }
    });

    test('runs full build sequence successfully', () async {
      // Use tempDir from setUp

      // Create dummy web asset
      final webDir = Directory(p.join(tempDir.path, 'web'));
      webDir.createSync();
      File(p.join(webDir.path, 'main.dart')).createSync();

      // Create dummy generated server binary for the build command to find/move
      // 'dart build cli' generates structure: <outputDir>/bundle/bin/<executable>
      // Here outputDir is 'build/server_build' (inside tempDir)
      final bundleBinDir = Directory(
        p.join(tempDir.path, 'build', 'server_build', 'bundle', 'bin'),
      );
      bundleBinDir.createSync(recursive: true);
      final binaryName = Platform.isWindows ? 'server.exe' : 'server';
      File(p.join(bundleBinDir.path, binaryName)).createSync();

      // Mock build_runner success
      Future.delayed(Duration(milliseconds: 10), () async {
        buildRunnerProcess.stdoutController.add(
          utf8.encode('[INFO] Succeeded after 1.0s\n'),
        );
        await buildRunnerProcess.stdoutController.close();
        await buildRunnerProcess.stderrController.close();
        buildRunnerProcess.exitCodeCompleter.complete(0);
      });

      // Suppress logs
      await runZoned(
        () async {
          await runner.run(['build', '--no-clean']);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {},
        ),
      );

      // Allow async _printBuildSummary to complete before cleanup
      await Future<void>.delayed(Duration(milliseconds: 100));

      // Verify sequence
      // 1. build_runner
      expect(processRunner.calls[0], contains('dart run build_runner build'));

      // 2. compile server
      final serverBuildDir = p.join(tempDir.path, 'build', 'server_build');
      expect(
        processRunner.calls[1],
        contains(
          'dart build cli --target=bin/server.dart --output=$serverBuildDir',
        ),
      );

      // 3. compile web assets
      final jsOutput = p.join(tempDir.path, 'build', 'web', 'main.dart.js');
      final jsInput = p.join(tempDir.path, 'web', 'main.dart');
      expect(
        processRunner.calls[2],
        allOf(
          contains('dart compile js'),
          contains('-o $jsOutput'),
          contains(jsInput),
        ),
      );
    });

    test(
      'compiles nested web entry points preserving directory structure',
      () async {
        // Use tempDir from setUp

        // Create nested web asset
        final webDir = Directory(p.join(tempDir.path, 'web'));
        final subDir = Directory(p.join(webDir.path, 'docs'));
        subDir.createSync(recursive: true);
        File(p.join(subDir.path, 'page.dart')).createSync();

        // Create dummy generated server binary
        final bundleBinDir = Directory(
          p.join(tempDir.path, 'build', 'server_build', 'bundle', 'bin'),
        );
        bundleBinDir.createSync(recursive: true);
        final binaryName = Platform.isWindows ? 'server.exe' : 'server';
        File(p.join(bundleBinDir.path, binaryName)).createSync();

        // Mock build_runner success
        Future.delayed(Duration(milliseconds: 10), () async {
          buildRunnerProcess.stdoutController.add(
            utf8.encode('[INFO] Succeeded after 1.0s\n'),
          );
          await buildRunnerProcess.stdoutController.close();
          await buildRunnerProcess.stderrController.close();
          buildRunnerProcess.exitCodeCompleter.complete(0);
        });

        // Suppress logs
        await runZoned(
          () async {
            await runner.run(['build', '--no-clean']);
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) {},
          ),
        );

        await Future<void>.delayed(Duration(milliseconds: 100));

        // Verify compilation of nested file
        final jsOutput = p.join(
          tempDir.path,
          'build',
          'web',
          'docs',
          'page.dart.js',
        );
        final jsInput = p.join(tempDir.path, 'web', 'docs', 'page.dart');

        expect(
          processRunner.calls.any(
            (call) =>
                call.contains('dart compile js') &&
                call.contains('-o $jsOutput') &&
                call.contains(jsInput),
          ),
          isTrue,
          reason: 'Should compile nested web asset to matching output path',
        );
      },
    );

    test(
      'copies native libraries from bundle/lib to output lib directory',
      () async {
        // Use tempDir from setUp

        // Create dummy web directory (required by build flow)
        final webDir = Directory(p.join(tempDir.path, 'web'));
        webDir.createSync();

        // Create dummy generated server binary
        final bundleBinDir = Directory(
          p.join(tempDir.path, 'build', 'server_build', 'bundle', 'bin'),
        );
        bundleBinDir.createSync(recursive: true);
        final binaryName = Platform.isWindows ? 'server.exe' : 'server';
        File(p.join(bundleBinDir.path, binaryName)).createSync();

        // Create native library in bundle/lib/
        final bundleLibDir = Directory(
          p.join(tempDir.path, 'build', 'server_build', 'bundle', 'lib'),
        );
        bundleLibDir.createSync(recursive: true);
        final nativeLibName = Platform.isWindows
            ? 'sqlite3.dll'
            : Platform.isMacOS
            ? 'libsqlite3.dylib'
            : 'libsqlite3.so';
        final nativeLibFile = File(p.join(bundleLibDir.path, nativeLibName));
        nativeLibFile.writeAsStringSync('fake native library content');

        // Mock build_runner success
        Future.delayed(Duration(milliseconds: 10), () async {
          buildRunnerProcess.stdoutController.add(
            utf8.encode('[INFO] Succeeded after 1.0s\n'),
          );
          await buildRunnerProcess.stdoutController.close();
          await buildRunnerProcess.stderrController.close();
          buildRunnerProcess.exitCodeCompleter.complete(0);
        });

        // Run build
        await runZoned(
          () async {
            await runner.run(['build', '--no-clean']);
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) {},
          ),
        );

        // Allow async _printBuildSummary to complete before cleanup
        await Future<void>.delayed(Duration(milliseconds: 100));

        // Verify native library was copied to build/lib/
        final copiedLib = File(
          p.join(tempDir.path, 'build', 'lib', nativeLibName),
        );
        expect(
          copiedLib.existsSync(),
          isTrue,
          reason: 'Native library should be copied to build/lib/',
        );
        expect(
          copiedLib.readAsStringSync(),
          equals('fake native library content'),
          reason: 'Native library content should match',
        );
      },
    );

    test(
      'copies nested native libraries preserving directory structure',
      () async {
        // Use tempDir from setUp

        // Create dummy web directory
        final webDir = Directory(p.join(tempDir.path, 'web'));
        webDir.createSync();

        // Create dummy generated server binary
        final bundleBinDir = Directory(
          p.join(tempDir.path, 'build', 'server_build', 'bundle', 'bin'),
        );
        bundleBinDir.createSync(recursive: true);
        final binaryName = Platform.isWindows ? 'server.exe' : 'server';
        File(p.join(bundleBinDir.path, binaryName)).createSync();

        // Create nested native libraries in bundle/lib/
        final bundleLibDir = Directory(
          p.join(tempDir.path, 'build', 'server_build', 'bundle', 'lib'),
        );
        bundleLibDir.createSync(recursive: true);

        // Create a nested subdirectory with a library
        final nestedDir = Directory(p.join(bundleLibDir.path, 'subdir'));
        nestedDir.createSync(recursive: true);
        File(
          p.join(nestedDir.path, 'nested_lib.so'),
        ).writeAsStringSync('nested lib content');

        // Also create a top-level library
        File(
          p.join(bundleLibDir.path, 'top_level.so'),
        ).writeAsStringSync('top level content');

        // Mock build_runner success
        Future.delayed(Duration(milliseconds: 10), () async {
          buildRunnerProcess.stdoutController.add(
            utf8.encode('[INFO] Succeeded after 1.0s\n'),
          );
          await buildRunnerProcess.stdoutController.close();
          await buildRunnerProcess.stderrController.close();
          buildRunnerProcess.exitCodeCompleter.complete(0);
        });

        // Run build
        await runZoned(
          () async {
            await runner.run(['build', '--no-clean']);
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) {},
          ),
        );

        // Allow async _printBuildSummary to complete before cleanup
        await Future<void>.delayed(Duration(milliseconds: 100));

        // Verify both libraries were copied with correct structure
        final topLevelLib = File(
          p.join(tempDir.path, 'build', 'lib', 'top_level.so'),
        );
        final nestedLib = File(
          p.join(tempDir.path, 'build', 'lib', 'subdir', 'nested_lib.so'),
        );

        expect(
          topLevelLib.existsSync(),
          isTrue,
          reason: 'Top-level library should be copied',
        );
        expect(
          nestedLib.existsSync(),
          isTrue,
          reason:
              'Nested library should be copied preserving directory structure',
        );
        expect(nestedLib.readAsStringSync(), equals('nested lib content'));
      },
    );

    test(
      'places server binary in build/bin/ for native lib resolution',
      () async {
        // Use tempDir from setUp

        // Create dummy web directory
        final webDir = Directory(p.join(tempDir.path, 'web'));
        webDir.createSync();

        // Create dummy generated server binary
        final bundleBinDir = Directory(
          p.join(tempDir.path, 'build', 'server_build', 'bundle', 'bin'),
        );
        bundleBinDir.createSync(recursive: true);
        final binaryName = Platform.isWindows ? 'server.exe' : 'server';
        File(
          p.join(bundleBinDir.path, binaryName),
        ).writeAsStringSync('binary content');

        // Create native library in bundle/lib/
        final bundleLibDir = Directory(
          p.join(tempDir.path, 'build', 'server_build', 'bundle', 'lib'),
        );
        bundleLibDir.createSync(recursive: true);
        final nativeLibName = Platform.isLinux
            ? 'libsqlite3.so'
            : 'libsqlite3.dylib';
        File(
          p.join(bundleLibDir.path, nativeLibName),
        ).writeAsStringSync('native lib');

        // Mock build_runner success
        Future.delayed(Duration(milliseconds: 10), () async {
          buildRunnerProcess.stdoutController.add(
            utf8.encode('[INFO] Succeeded after 1.0s\n'),
          );
          await buildRunnerProcess.stdoutController.close();
          await buildRunnerProcess.stderrController.close();
          buildRunnerProcess.exitCodeCompleter.complete(0);
        });

        // Run build
        await runZoned(
          () async {
            await runner.run(['build', '--no-clean']);
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) {},
          ),
        );

        await Future<void>.delayed(Duration(milliseconds: 100));

        // Verify server is in build/bin/ (not build/)
        final serverBinary = File(
          p.join(tempDir.path, 'build', 'bin', binaryName),
        );
        expect(
          serverBinary.existsSync(),
          isTrue,
          reason: 'Server binary should be at build/bin/server',
        );

        // Verify native library is at build/lib/ (sibling to bin/)
        // This ensures ../lib/ from build/bin/server resolves to build/lib/
        final nativeLib = File(
          p.join(tempDir.path, 'build', 'lib', nativeLibName),
        );
        expect(
          nativeLib.existsSync(),
          isTrue,
          reason: 'Native lib should be at build/lib/ (sibling to bin/)',
        );
      },
    );

    test('handles missing bundle/lib directory gracefully', () async {
      // Use tempDir from setUp

      // Create dummy web directory
      final webDir = Directory(p.join(tempDir.path, 'web'));
      webDir.createSync();

      // Create dummy generated server binary WITHOUT bundle/lib/
      final bundleBinDir = Directory(
        p.join(tempDir.path, 'build', 'server_build', 'bundle', 'bin'),
      );
      bundleBinDir.createSync(recursive: true);
      final binaryName = Platform.isWindows ? 'server.exe' : 'server';
      File(p.join(bundleBinDir.path, binaryName)).createSync();

      // Mock build_runner success
      Future.delayed(Duration(milliseconds: 10), () async {
        buildRunnerProcess.stdoutController.add(
          utf8.encode('[INFO] Succeeded after 1.0s\n'),
        );
        await buildRunnerProcess.stdoutController.close();
        await buildRunnerProcess.stderrController.close();
        buildRunnerProcess.exitCodeCompleter.complete(0);
      });

      // Run build - should not throw
      await runZoned(
        () async {
          await runner.run(['build', '--no-clean']);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {},
        ),
      );

      // Allow async _printBuildSummary to complete before cleanup
      await Future<void>.delayed(Duration(milliseconds: 100));

      // Verify build/lib/ was NOT created (no native libs to copy)
      final libDir = Directory(p.join(tempDir.path, 'build', 'lib'));
      expect(
        libDir.existsSync(),
        isFalse,
        reason: 'lib/ should not be created when no native libs exist',
      );
    });

    test('copies non-Dart static files from web/ to build/web/', () async {
      // Use tempDir from setUp

      // Create web directory with various assets
      final webDir = Directory(p.join(tempDir.path, 'web'));
      webDir.createSync();
      File(p.join(webDir.path, 'main.dart')).createSync(); // Should be compiled
      File(
        p.join(webDir.path, 'favicon.ico'),
      ).writeAsStringSync('icon'); // Should be copied
      File(
        p.join(webDir.path, 'styles.css'),
      ).writeAsStringSync('css'); // Should be copied

      // Create a subdirectory with assets
      final assetsDir = Directory(p.join(webDir.path, 'assets'));
      assetsDir.createSync();
      File(
        p.join(assetsDir.path, 'logo.png'),
      ).writeAsStringSync('png'); // Should be copied

      // Create another subdirectory (not 'assets') with files
      final otherDir = Directory(p.join(webDir.path, 'other'));
      otherDir.createSync();
      File(
        p.join(otherDir.path, 'data.json'),
      ).writeAsStringSync('json'); // Should be copied

      // Create dummy generated server binary
      final bundleBinDir = Directory(
        p.join(tempDir.path, 'build', 'server_build', 'bundle', 'bin'),
      );
      bundleBinDir.createSync(recursive: true);
      final binaryName = Platform.isWindows ? 'server.exe' : 'server';
      File(p.join(bundleBinDir.path, binaryName)).createSync();

      // Mock build_runner success
      Future.delayed(Duration(milliseconds: 10), () async {
        buildRunnerProcess.stdoutController.add(
          utf8.encode('[INFO] Succeeded after 1.0s\n'),
        );
        await buildRunnerProcess.stdoutController.close();
        await buildRunnerProcess.stderrController.close();
        buildRunnerProcess.exitCodeCompleter.complete(0);
      });

      // Run build
      await runZoned(
        () async {
          await runner.run(['build', '--no-clean']);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {},
        ),
      );

      await Future<void>.delayed(Duration(milliseconds: 100));

      // Verify favicon.ico is copied
      final favicon = File(p.join(tempDir.path, 'build', 'web', 'favicon.ico'));
      expect(
        favicon.existsSync(),
        isTrue,
        reason: 'favicon.ico should be copied',
      );

      // Verify styles.css is copied
      final styles = File(p.join(tempDir.path, 'build', 'web', 'styles.css'));
      expect(
        styles.existsSync(),
        isTrue,
        reason: 'styles.css should be copied',
      );

      // Verify nested assets are copied
      final logo = File(
        p.join(tempDir.path, 'build', 'web', 'assets', 'logo.png'),
      );
      expect(
        logo.existsSync(),
        isTrue,
        reason: 'assets/logo.png should be copied',
      );

      // Verify other nested files are copied
      final data = File(
        p.join(tempDir.path, 'build', 'web', 'other', 'data.json'),
      );
      expect(
        data.existsSync(),
        isTrue,
        reason: 'other/data.json should be copied',
      );

      // Verify Dart files are NOT copied (they are compiled)
      final mainDart = File(p.join(tempDir.path, 'build', 'web', 'main.dart'));
      expect(
        mainDart.existsSync(),
        isFalse,
        reason: 'main.dart should not be copied directly',
      );
    });
  });
}

class MockProcessRunner implements ProcessRunner {
  Map<String, MockProcess> processes = {};
  List<String> calls = [];
  ProcessResult? defaultResult;

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
  }) async {
    final command = '$executable ${arguments.join(' ')}';
    calls.add(command);

    return defaultResult ?? ProcessResult(0, 0, '', '');
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
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
