@TestOn('vm')
library;

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:spark_cli/src/commands/init_command.dart';
import 'package:args/command_runner.dart';

void main() {
  group('InitCommand Content', () {
    late Directory tempDir;
    late Directory originalCwd;
    late CommandRunner<void> runner;

    setUp(() {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('spark_cli_content_test_');
      Directory.current = tempDir;
      runner = CommandRunner<void>('spark', 'Spark CLI')
        ..addCommand(InitCommand());
    });

    tearDown(() {
      Directory.current = originalCwd;
      tempDir.deleteSync(recursive: true);
    });

    test('generates files with correct typed style content', () async {
      final projectName = 'content_test_app';
      await runZoned(
        () async {
          await runner.run(['init', projectName]);
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {},
        ),
      );

      final projectPath = p.join(tempDir.path, projectName);

      // Check counter.dart (conditional export)
      final counterFile = File(
        p.join(projectPath, 'lib/components/counter.dart'),
      );
      expect(counterFile.existsSync(), isTrue);

      // Check counter_base.dart (actual class definition)
      final counterBaseFile = File(
        p.join(projectPath, 'lib/components/counter_base.dart'),
      );
      expect(counterBaseFile.existsSync(), isTrue);
      final counterContent = counterBaseFile.readAsStringSync();

      expect(counterContent, contains('class Counter'));
      expect(counterContent, contains('@Attribute()'));
      expect(counterContent, contains('css({'));
      expect(counterContent, contains('.typed('));
      expect(counterContent, contains('onClick: (_) {'));

      // Check home_page.dart
      final homePageFile = File(
        p.join(projectPath, 'lib/pages/home_page.dart'),
      );
      expect(homePageFile.existsSync(), isTrue);
      final homePageContent = homePageFile.readAsStringSync();

      expect(homePageContent, contains("import '../components/counter.dart';"));
      expect(
        homePageContent,
        contains('Element render(HomePageState state, PageRequest request)'),
      );
      expect(
        homePageContent,
        contains("Counter(count: 10, label: 'My Counter').render()"),
      );
      expect(
        homePageContent,
        contains('Stylesheet? get inlineStyles => css({'),
      );
      expect(homePageContent, contains('.typed('));
    });
  });
}
