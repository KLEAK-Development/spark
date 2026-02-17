@TestOn('vm')
library;

import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('Live Reload Injection', () {
    late Directory tempDir;
    late File script;
    late File packageConfig;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('live_reload_test');
      script = File(p.join(tempDir.path, 'check_live_reload.dart'));

      // Locate package_config.json
      final current = Directory.current;
      final candidates = [
        p.join(current.path, '.dart_tool', 'package_config.json'),
        p.join(current.path, '..', '..', '.dart_tool', 'package_config.json'),
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

    test(
      'injects live reload script when SPARK_DEV_RELOAD_PORT is set',
      () async {
        await script.writeAsString('''
        import 'package:spark_framework/src/server/render_page.dart';
        void main() {
          print(renderPage(title: 'Test', content: 'Content'));
        }
      ''');

        final result = await Process.run(
          'dart',
          ['run', '--packages=${packageConfig.absolute.path}', script.path],
          environment: {'SPARK_DEV_RELOAD_PORT': '1234'},
        );

        if (result.exitCode != 0) {
          fail('Script failed: ${result.stderr}');
        }

        expect(
          result.stdout.toString(),
          contains("new WebSocket('ws://localhost:1234')"),
        );
      },
    );
  });
}
