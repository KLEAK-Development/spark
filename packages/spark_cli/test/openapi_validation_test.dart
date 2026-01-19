import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:spark_cli/src/commands/openapi_command.dart';
import 'package:test/test.dart';

void main() {
  group('OpenApiCommand Validation', () {
    late Directory tempDir;
    late Directory originalCwd;
    late CommandRunner<void> runner;
    late String sparkPackagePath;
    late String sparkPackageName;

    setUp(() async {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync(
        'spark_openapi_validation_test_',
      );
      Directory.current = tempDir;
      runner = CommandRunner<void>('spark', 'Spark CLI')
        ..addCommand(OpenApiCommand());

      // Create project structure
      Directory(
        p.join(tempDir.path, 'lib', 'endpoints'),
      ).createSync(recursive: true);
      Directory(p.join(tempDir.path, 'bin')).createSync(recursive: true);

      // Default to monorepo structure detection (copied from openapi_command_test.dart)
      var possiblePath = p.absolute(
        p.join(originalCwd.path, 'packages', 'spark_framework', 'spark'),
      );

      if (!File(p.join(possiblePath, 'pubspec.yaml')).existsSync()) {
        possiblePath = p.absolute(p.join(originalCwd.path, '..', 'spark'));
      }

      if (!File(p.join(possiblePath, 'pubspec.yaml')).existsSync()) {
        possiblePath = p.absolute(
          p.join(originalCwd.path, 'packages', 'spark'),
        );
      }

      // Fallback relative to spark_cli if tests run from inside packages/spark_framework/spark_cli
      if (!File(p.join(possiblePath, 'pubspec.yaml')).existsSync()) {
        possiblePath = p.absolute(p.join(originalCwd.path, '../../spark'));
      }

      sparkPackagePath = possiblePath;

      // Read package name from found pubspec
      final pubspecContent = File(
        p.join(sparkPackagePath, 'pubspec.yaml'),
      ).readAsStringSync();
      final nameMatch = RegExp(
        r'^name:\s+(.+)$',
        multiLine: true,
      ).firstMatch(pubspecContent);
      if (nameMatch != null) {
        sparkPackageName = nameMatch.group(1)!.trim();
      } else {
        sparkPackageName = 'spark_framework'; // Fallback
      }

      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_project
environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  $sparkPackageName:
    path: $sparkPackagePath
''');

      // Run pub get
      final result = await Process.run('dart', [
        'pub',
        'get',
      ], workingDirectory: tempDir.path);

      if (result.exitCode != 0) {
        fail('Failed to run dart pub get in temp dir:\n${result.stderr}');
      }
    });

    tearDown(() {
      Directory.current = originalCwd;
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    Future<Map<String, dynamic>> runOpenApiCommand() async {
      await runner.run(['openapi']);
      final outputFile = File(p.join(tempDir.path, 'openapi.json'));
      expect(
        outputFile.existsSync(),
        isTrue,
        reason: 'openapi.json should be generated',
      );
      return jsonDecode(outputFile.readAsStringSync()) as Map<String, dynamic>;
    }

    test('extracts validation annotations to schema properties', () async {
      File(
        p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
      ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class ValidatedDto {
  @NotEmpty()
  @Length(min: 3, max: 50)
  final String username;

  @Email()
  final String email;

  @Min(18)
  @Max(100)
  final int age;

  @Pattern(r"^[0-9]+\$")
  final String numericString;
  
  @IsBooleanString()
  final String isEnabled;

  ValidatedDto(this.username, this.email, this.age, this.numericString, this.isEnabled);
}

@Endpoint(
  path: '/create',
  method: 'POST',
  summary: 'Create',
)
class CreateEndpoint extends SparkEndpointWithBody<ValidatedDto> {
  @override
  Future<dynamic> handler(SparkRequest request, ValidatedDto body) async => 'ok';
}
''');

      final content = await runOpenApiCommand();
      final schemas = content['components']['schemas'] as Map;

      expect(schemas.containsKey('ValidatedDto'), isTrue);
      final dto = schemas['ValidatedDto']['properties'];

      // Check username validations
      expect(dto['username']['type'], 'string');
      expect(
        dto['username']['minLength'],
        3,
        reason: 'Should have minLength from @Length(min: 3)',
      );
      expect(dto['username']['maxLength'], 50);
      // @NotEmpty validation (minLength: 1) is overridden by @Length(min: 3) or merged?
      // Current implementation sets keys. Map behavior creates overlapping keys depending on iteration order.
      // @Length adds 'minLength'. @NotEmpty adds 'minLength'. Last one wins or checks.
      // In the implementation: NotEmpty sets minLength=1. Length sets minLength=3.
      // Iteration order of metadata matters.
      // But 3 is safer than 1.

      // Check email
      expect(dto['email']['format'], 'email');

      // Check age
      expect(dto['age']['minimum'], 18);
      expect(dto['age']['maximum'], 100);

      // Check Pattern
      expect(dto['numericString']['pattern'], r"^[0-9]+$");

      // Check IsBooleanString
      expect(dto['isEnabled']['enum'], ['true', 'false', '1', '0']);
    });

    test('extracts list validation', () async {
      File(
        p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
      ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class Wrapper {
  @NotEmpty()
  final List<String> tags;

  Wrapper(this.tags);
}

@Endpoint(
  path: '/tags', 
  method: 'POST', 
)
class TagEndpoint extends SparkEndpointWithBody<Wrapper> {
  @override
  Future<dynamic> handler(SparkRequest request, Wrapper body) async => 'ok';
}
''');
      final content = await runOpenApiCommand();
      final schemas = content['components']['schemas'] as Map;
      final props = schemas['Wrapper']['properties'];

      expect(props['tags']['type'], 'array');
      expect(props['tags']['minItems'], 1);
    });
  });
}
