import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:spark_cli/src/commands/build_command.dart';
import 'package:test/test.dart';

import 'build_command_test.dart'; // Reuse MockProcessRunner and MockProcess

void main() {
  group('BuildCommand Hidden Files Regression', () {
    late MockProcessRunner processRunner;
    late CommandRunner<void> runner;
    late MockProcess buildRunnerProcess;
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('spark_build_repro_test');
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

    test(
      'copies hidden files and directories from web/ to build/web/',
      () async {
        // Create web directory
        final webDir = Directory(p.join(tempDir.path, 'web'));
        webDir.createSync();

        // Create a standard file
        File(p.join(webDir.path, 'main.dart')).createSync();

        // Create a hidden file
        final hiddenFile = File(p.join(webDir.path, '.hidden_config'));
        hiddenFile.writeAsStringSync('secret=true');

        // Create a hidden directory with a file inside
        final hiddenDir = Directory(p.join(webDir.path, '.well-known'));
        hiddenDir.createSync();
        final fileInHiddenDir = File(p.join(hiddenDir.path, 'assetlinks.json'));
        fileInHiddenDir.writeAsStringSync('{"foo": "bar"}');

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

        // Verify .hidden_config is copied
        final builtHiddenFile = File(
          p.join(tempDir.path, 'build', 'web', '.hidden_config'),
        );
        expect(
          builtHiddenFile.existsSync(),
          isTrue,
          reason: '.hidden_config should be copied',
        );

        // Verify .well-known/assetlinks.json is copied
        final builtFileInHiddenDir = File(
          p.join(
            tempDir.path,
            'build',
            'web',
            '.well-known',
            'assetlinks.json',
          ),
        );
        expect(
          builtFileInHiddenDir.existsSync(),
          isTrue,
          reason: '.well-known/assetlinks.json should be copied',
        );
      },
    );
  });
}
