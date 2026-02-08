import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:spark_cli/src/commands/create/create_command.dart';

void main() {
  group('CreateComponentCommand', () {
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

    test('creates component files from snake_case input', () async {
      await _suppressOutput(
        () => runner.run(['create', 'component', 'my_counter']),
      );

      final exportPath = p.join(
        tempDir.path,
        'lib',
        'components',
        'my_counter.dart',
      );
      final basePath = p.join(
        tempDir.path,
        'lib',
        'components',
        'my_counter_base.dart',
      );

      expect(
        File(exportPath).existsSync(),
        isTrue,
        reason: 'my_counter.dart should exist',
      );
      expect(
        File(basePath).existsSync(),
        isTrue,
        reason: 'my_counter_base.dart should exist',
      );

      final exportContent = File(exportPath).readAsStringSync();
      expect(exportContent, contains("export 'my_counter_base.dart'"));
      expect(exportContent, contains("'my_counter_base.impl.dart'"));

      final baseContent = File(basePath).readAsStringSync();
      expect(baseContent, contains("class MyCounter"));
      expect(baseContent, contains("static const tag = 'my-counter'"));
      expect(baseContent, contains("@Component(tag: MyCounter.tag)"));
    });

    test('creates component files from PascalCase input', () async {
      await _suppressOutput(
        () => runner.run(['create', 'component', 'MyCounter']),
      );

      final exportPath = p.join(
        tempDir.path,
        'lib',
        'components',
        'my_counter.dart',
      );
      final basePath = p.join(
        tempDir.path,
        'lib',
        'components',
        'my_counter_base.dart',
      );

      expect(File(exportPath).existsSync(), isTrue);
      expect(File(basePath).existsSync(), isTrue);

      final baseContent = File(basePath).readAsStringSync();
      expect(baseContent, contains("class MyCounter"));
      expect(baseContent, contains("static const tag = 'my-counter'"));
    });

    test('MyCounter and my_counter produce identical output', () async {
      // Create with PascalCase
      final tempDir1 = Directory.systemTemp.createTempSync(
        'spark_test_pascal_',
      );
      Directory.current = tempDir1;
      await _suppressOutput(
        () => runner.run(['create', 'component', 'MyCounter']),
      );
      final pascalExport = File(
        p.join(tempDir1.path, 'lib', 'components', 'my_counter.dart'),
      ).readAsStringSync();
      final pascalBase = File(
        p.join(tempDir1.path, 'lib', 'components', 'my_counter_base.dart'),
      ).readAsStringSync();

      // Create with snake_case
      final tempDir2 = Directory.systemTemp.createTempSync('spark_test_snake_');
      Directory.current = tempDir2;
      await _suppressOutput(
        () => runner.run(['create', 'component', 'my_counter']),
      );
      final snakeExport = File(
        p.join(tempDir2.path, 'lib', 'components', 'my_counter.dart'),
      ).readAsStringSync();
      final snakeBase = File(
        p.join(tempDir2.path, 'lib', 'components', 'my_counter_base.dart'),
      ).readAsStringSync();

      expect(pascalExport, equals(snakeExport));
      expect(pascalBase, equals(snakeBase));

      // Cleanup
      Directory.current = tempDir;
      tempDir1.deleteSync(recursive: true);
      tempDir2.deleteSync(recursive: true);
    });

    test('rejects single word component name (no hyphen possible)', () async {
      final output = <String>[];
      await _captureOutput(
        () => runner.run(['create', 'component', 'counter']),
        output,
      );

      expect(
        output.any((line) => line.contains('Invalid component name')),
        isTrue,
        reason: 'Should reject single-word name "counter"',
      );
      expect(
        output.any((line) => line.contains('must contain a hyphen')),
        isTrue,
      );

      // Ensure no files were created
      final exportPath = p.join(
        tempDir.path,
        'lib',
        'components',
        'counter.dart',
      );
      expect(File(exportPath).existsSync(), isFalse);
    });

    test('rejects other single word names', () async {
      for (final name in ['button', 'dialog', 'card']) {
        final output = <String>[];
        await _captureOutput(
          () => runner.run(['create', 'component', name]),
          output,
        );

        expect(
          output.any((line) => line.contains('Invalid component name')),
          isTrue,
          reason: 'Should reject single-word name "$name"',
        );
      }
    });

    test('file naming follows snake_case pattern', () async {
      await _suppressOutput(
        () => runner.run(['create', 'component', 'NavBar']),
      );

      // Files should be snake_case
      final exportPath = p.join(
        tempDir.path,
        'lib',
        'components',
        'nav_bar.dart',
      );
      final basePath = p.join(
        tempDir.path,
        'lib',
        'components',
        'nav_bar_base.dart',
      );

      expect(File(exportPath).existsSync(), isTrue);
      expect(File(basePath).existsSync(), isTrue);
    });

    test('class follows PascalCase pattern', () async {
      await _suppressOutput(
        () => runner.run(['create', 'component', 'nav_bar']),
      );

      final basePath = p.join(
        tempDir.path,
        'lib',
        'components',
        'nav_bar_base.dart',
      );
      final content = File(basePath).readAsStringSync();

      expect(content, contains('class NavBar'));
    });

    test('tag follows kebab-case pattern', () async {
      await _suppressOutput(
        () => runner.run(['create', 'component', 'NavBar']),
      );

      final basePath = p.join(
        tempDir.path,
        'lib',
        'components',
        'nav_bar_base.dart',
      );
      final content = File(basePath).readAsStringSync();

      expect(content, contains("static const tag = 'nav-bar'"));
    });

    test('does not overwrite existing files', () async {
      final dir = Directory(p.join(tempDir.path, 'lib', 'components'));
      dir.createSync(recursive: true);
      final file = File(p.join(dir.path, 'my_counter.dart'));
      file.writeAsStringSync('existing content');

      await _suppressOutput(
        () => runner.run(['create', 'component', 'my_counter']),
      );

      expect(file.readAsStringSync(), equals('existing content'));
    });

    test('prints error when no name provided', () async {
      final output = <String>[];
      await _captureOutput(() => runner.run(['create', 'component']), output);

      expect(
        output.any((line) => line.contains('Please provide a component name')),
        isTrue,
      );
    });

    test('creates component with three-word name', () async {
      await _suppressOutput(
        () => runner.run(['create', 'component', 'MyBigComponent']),
      );

      final basePath = p.join(
        tempDir.path,
        'lib',
        'components',
        'my_big_component_base.dart',
      );
      final content = File(basePath).readAsStringSync();

      expect(content, contains('class MyBigComponent'));
      expect(content, contains("static const tag = 'my-big-component'"));
    });
  });
}

Future<void> _suppressOutput(Future<void> Function() fn) async {
  await runZoned(
    fn,
    zoneSpecification: ZoneSpecification(print: (self, parent, zone, line) {}),
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
