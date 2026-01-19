import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:spark_cli/src/commands/init_command.dart';
import 'package:args/command_runner.dart';

void main() {
  group('InitCommand', () {
    late Directory tempDir;
    late Directory originalCwd;
    late CommandRunner<void> runner;

    setUp(() {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('spark_cli_test_');
      Directory.current = tempDir;
      runner = CommandRunner<void>('spark', 'Spark CLI')
        ..addCommand(InitCommand());
    });

    tearDown(() {
      Directory.current = originalCwd;
      tempDir.deleteSync(recursive: true);
    });

    test('creates a new project successfully', () async {
      final projectName = 'my_test_app';
      // Now we just pass the name, creating it in the tempDir (CWD)
      // Suppress logs
      await runZoned(
        () async {
          await runner.run(['init', projectName]);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            // Suppress
          },
        ),
      );

      final projectPath = p.join(tempDir.path, projectName);
      final dir = Directory(projectPath);
      expect(
        dir.existsSync(),
        isTrue,
        reason: 'Project directory should exist',
      );

      final files = [
        'pubspec.yaml',
        'analysis_options.yaml',
        'bin/server.dart',
        'lib/endpoints/endpoints.dart',
        'lib/components/counter.dart',
        'lib/pages/home_page.dart',
        '.gitignore',
      ];

      for (final file in files) {
        expect(
          File(p.join(projectPath, file)).existsSync(),
          isTrue,
          reason: '$file should exist',
        );
      }

      // Verify pubspec content
      final pubspecContent = File(
        p.join(projectPath, 'pubspec.yaml'),
      ).readAsStringSync();
      expect(pubspecContent, contains('name: $projectName'));
      expect(pubspecContent, contains('spark_framework:'));
    });

    test('does nothing if no project name provided', () async {
      await runZoned(
        () async {
          await runner.run(['init']);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            // Suppress
          },
        ),
      );
      // Should definitely not crash
    });
  });
}
