import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:spark_cli/src/commands/create/create_command.dart';

void main() {
  group('CreatePageCommand', () {
    late Directory tempDir;
    late Directory originalCwd;
    late CommandRunner<void> runner;

    setUp(() {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('spark_cli_test_');
      Directory.current = tempDir;
      runner = CommandRunner<void>('spark', 'Spark CLI')
        ..addCommand(CreateCommand());
    });

    tearDown(() {
      Directory.current = originalCwd;
      tempDir.deleteSync(recursive: true);
    });

    test('creates a page file with correct name and content', () async {
      await _suppressOutput(() => runner.run(['create', 'page', 'dashboard']));

      final filePath = p.join(tempDir.path, 'lib', 'pages', 'dashboard_page.dart');
      final file = File(filePath);

      expect(file.existsSync(), isTrue, reason: 'dashboard_page.dart should exist');

      final content = file.readAsStringSync();
      expect(content, contains("class DashboardPage extends SparkPage<void>"));
      expect(content, contains("@Page(path: '/dashboard')"));
      expect(content, contains("import 'package:spark_framework/spark.dart';"));
    });

    test('creates a page from PascalCase input', () async {
      await _suppressOutput(
        () => runner.run(['create', 'page', 'UserProfile']),
      );

      final filePath = p.join(
        tempDir.path,
        'lib',
        'pages',
        'user_profile_page.dart',
      );
      final file = File(filePath);

      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains("class UserProfilePage extends SparkPage<void>"));
      expect(content, contains("@Page(path: '/user-profile')"));
    });

    test('creates a page from snake_case input', () async {
      await _suppressOutput(
        () => runner.run(['create', 'page', 'user_profile']),
      );

      final filePath = p.join(
        tempDir.path,
        'lib',
        'pages',
        'user_profile_page.dart',
      );
      final file = File(filePath);

      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains("class UserProfilePage extends SparkPage<void>"));
      expect(content, contains("@Page(path: '/user-profile')"));
    });

    test('does not overwrite existing file', () async {
      // Create the file first
      final dir = Directory(p.join(tempDir.path, 'lib', 'pages'));
      dir.createSync(recursive: true);
      final file = File(p.join(dir.path, 'dashboard_page.dart'));
      file.writeAsStringSync('existing content');

      await _suppressOutput(() => runner.run(['create', 'page', 'dashboard']));

      expect(file.readAsStringSync(), equals('existing content'));
    });

    test('prints error when no name provided', () async {
      final output = <String>[];
      await _captureOutput(
        () => runner.run(['create', 'page']),
        output,
      );

      expect(output.any((line) => line.contains('Please provide a page name')), isTrue);
    });
  });
}

Future<void> _suppressOutput(Future<void> Function() fn) async {
  await runZoned(
    fn,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {},
    ),
  );
}

Future<void> _captureOutput(
  Future<void> Function() fn,
  List<String> output,
) async {
  await runZoned(
    fn,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) {
        output.add(line);
      },
    ),
  );
}
