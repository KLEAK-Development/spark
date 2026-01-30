@TestOn('vm')
import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Minification Integration', () {
    late Directory tempDir;

    late File packageConfig;
    late File script;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('spark_minify_test');
      script = File(p.join(tempDir.path, 'check_minify.dart'));

      // Locate package_config.json
      final current = Directory.current;
      final candidates = [
        p.join(
          current.path,
          '.dart_tool',
          'package_config.json',
        ), // From workspace root
        p.join(
          current.path,
          '..',
          '..',
          '.dart_tool',
          'package_config.json',
        ), // From packages/spark
      ];

      packageConfig = candidates
          .map((path) => File(path))
          .firstWhere(
            (f) => f.existsSync(),
            orElse: () =>
                throw StateError('Could not find package_config.json'),
          );
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('minifies when dart.vm.product is true', () async {
      await script.writeAsString('''
        import 'package:spark_framework/spark.dart';
        void main() {
          print(Style(color: 'red').toCss());
        }
      ''');

      final result = await Process.run('dart', [
        'run',
        '--packages=${packageConfig.absolute.path}',
        '-Ddart.vm.product=true',
        script.path,
      ], workingDirectory: Directory.current.path);

      if (result.exitCode != 0) {
        fail('Script failed: ${result.stderr}');
      }

      // Expect minified: "color:red;" (no spaces/newlines)
      expect(result.stdout.toString().trim(), 'color:red;');
    });

    test('does not minify when dart.vm.product is false', () async {
      await script.writeAsString('''
        import 'package:spark_framework/spark.dart';
        void main() {
          print(Style(color: 'red').toCss());
        }
      ''');

      final result = await Process.run(
        'dart',
        [
          'run',
          '--packages=${packageConfig.absolute.path}',
          script.path,
        ], // No flag
        workingDirectory: Directory.current.path,
      );

      if (result.exitCode != 0) {
        fail('Script failed: ${result.stderr}');
      }

      // Expect unminified with indentation
      expect(result.stdout.toString(), contains('  color: red;'));
    });
  });
}
