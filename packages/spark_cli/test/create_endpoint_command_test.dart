import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:spark_cli/src/commands/create/create_command.dart';

void main() {
  group('CreateEndpointCommand', () {
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

    test('creates an endpoint file with correct name and content', () async {
      await _suppressOutput(
        () => runner.run(['create', 'endpoint', 'dashboard']),
      );

      final filePath = p.join(
        tempDir.path,
        'lib',
        'endpoints',
        'dashboard_endpoint.dart',
      );
      final file = File(filePath);

      expect(file.existsSync(), isTrue, reason: 'dashboard_endpoint.dart should exist');

      final content = file.readAsStringSync();
      expect(content, contains("class DashboardEndpoint extends SparkEndpoint"));
      expect(content, contains("@Endpoint(path: '/api/dashboard', method: 'GET')"));
      expect(content, contains("import 'package:spark_framework/spark.dart';"));
    });

    test('creates an endpoint from PascalCase input', () async {
      await _suppressOutput(
        () => runner.run(['create', 'endpoint', 'UserProfile']),
      );

      final filePath = p.join(
        tempDir.path,
        'lib',
        'endpoints',
        'user_profile_endpoint.dart',
      );
      final file = File(filePath);

      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains("class UserProfileEndpoint extends SparkEndpoint"));
      expect(content, contains("@Endpoint(path: '/api/user-profile', method: 'GET')"));
    });

    test('creates an endpoint from snake_case input', () async {
      await _suppressOutput(
        () => runner.run(['create', 'endpoint', 'user_profile']),
      );

      final filePath = p.join(
        tempDir.path,
        'lib',
        'endpoints',
        'user_profile_endpoint.dart',
      );
      final file = File(filePath);

      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      expect(content, contains("class UserProfileEndpoint extends SparkEndpoint"));
      expect(content, contains("@Endpoint(path: '/api/user-profile', method: 'GET')"));
    });

    test('does not overwrite existing file', () async {
      final dir = Directory(p.join(tempDir.path, 'lib', 'endpoints'));
      dir.createSync(recursive: true);
      final file = File(p.join(dir.path, 'dashboard_endpoint.dart'));
      file.writeAsStringSync('existing content');

      await _suppressOutput(
        () => runner.run(['create', 'endpoint', 'dashboard']),
      );

      expect(file.readAsStringSync(), equals('existing content'));
    });

    test('prints error when no name provided', () async {
      final output = <String>[];
      await _captureOutput(
        () => runner.run(['create', 'endpoint']),
        output,
      );

      expect(
        output.any((line) => line.contains('Please provide an endpoint name')),
        isTrue,
      );
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
