import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:spark_cli/src/commands/openapi_command.dart';
import 'package:test/test.dart';

void main() {
  group('OpenApiCommand Automation', () {
    late Directory tempDir;
    late Directory originalCwd;
    late CommandRunner<void> runner;
    late String sparkPackagePath;
    late String sparkPackageName;

    setUp(() async {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('spark_openapi_auto_test_');
      Directory.current = tempDir;
      runner = CommandRunner<void>('spark', 'Spark CLI')
        ..addCommand(OpenApiCommand());

      // Create project structure
      Directory(
        p.join(tempDir.path, 'lib', 'endpoints'),
      ).createSync(recursive: true);
      Directory(p.join(tempDir.path, 'bin')).createSync(recursive: true);

      // Locate spark package (assuming relative path for this test setup)
      // Locate spark package
      var possiblePath = p.absolute(
        p.join(originalCwd.path, 'packages', 'spark_framework', 'spark'),
      );

      if (!File(p.join(possiblePath, 'pubspec.yaml')).existsSync()) {
        possiblePath = p.absolute(p.join(originalCwd.path, '..', 'spark'));
      }

      if (!File(p.join(possiblePath, 'pubspec.yaml')).existsSync()) {
        // Try parallel sibling if running from spark_cli
        possiblePath = p.absolute(
          p.join(
            originalCwd.path,
            '..',
            '..',
            'packages',
            'spark_framework',
            'spark',
          ),
        );
      }

      if (!File(p.join(possiblePath, 'pubspec.yaml')).existsSync()) {
        possiblePath = p.absolute(
          p.join(originalCwd.path, 'packages', 'spark'),
        );
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
    });

    tearDown(() {
      Directory.current = originalCwd;
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    Future<Map<String, dynamic>> runOpenApiCommand() async {
      final result = await Process.run('dart', [
        'pub',
        'get',
      ], workingDirectory: tempDir.path);

      if (result.exitCode != 0) {
        fail('Failed to run dart pub get in temp dir:\n${result.stderr}');
      }

      await runner.run(['openapi']);

      final outputFile = File(p.join(tempDir.path, 'openapi.json'));
      expect(
        outputFile.existsSync(),
        isTrue,
        reason: 'openapi.json should be generated',
      );

      return jsonDecode(outputFile.readAsStringSync()) as Map<String, dynamic>;
    }

    test(
      'deduces 400 Bad Request from throws ApiError with code 400',
      () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/error-400', method: 'GET')
class Error400Endpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async {
    if (true) {
      throw ApiError(message: 'Bad Request', code: 'BAD_REQUEST', statusCode: 400);
    }
    return 'ok';
  }
}
''');

        final content = await runOpenApiCommand();
        final responses = content['paths']['/error-400']['get']['responses'];

        expect(responses, contains('400'));
        expect(responses['400']['description'], contains('Bad Request'));
      },
    );

    test(
      'deduces 500 Internal Server Error from throws ApiError (default)',
      () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/error-500', method: 'GET')
class Error500Endpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async {
    throw ApiError(message: 'Oops', code: 'INTERNAL');
  }
}
''');

        final content = await runOpenApiCommand();
        final responses = content['paths']['/error-500']['get']['responses'];

        expect(responses, contains('500'));
      },
    );

    test('deduces 404 Not Found from throws SparkHttpException', () async {
      File(
        p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
      ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/error-404', method: 'GET')
class Error404Endpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async {
    throw SparkHttpException(404, 'Not Found');
  }
}
''');

      final content = await runOpenApiCommand();
      final responses = content['paths']['/error-404']['get']['responses'];

      expect(responses, contains('404'));
      expect(responses['404']['description'], contains('Not Found'));
    });

    test('deduces 400 Bad Request from validation annotations', () async {
      File(
        p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
      ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class UserDto {
  @NotEmpty()
  final String name;

  UserDto(this.name);
}

@Endpoint(
  path: '/validate', 
  method: 'POST',
)
class ValidationEndpoint extends SparkEndpointWithBody<UserDto> {
  @override
  Future<dynamic> handler(SparkRequest request, UserDto body) async => 'ok';
}
''');

      final content = await runOpenApiCommand();
      final responses = content['paths']['/validate']['post']['responses'];

      expect(responses, contains('400'));
      expect(responses['400']['description'], contains('Validation Error'));
    });

    test('deduces 401 from middleware throwing ApiError', () async {
      File(p.join(tempDir.path, 'lib', 'middleware.dart')).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

Middleware authMiddleware() {
  return (innerHandler) {
    return (request) {
      if (true) {
        throw ApiError(message: 'Unauthorized', code: 'UNAUTHORIZED', statusCode: 401);
      }
      return innerHandler(request);
    };
  };
}
''');

      File(
        p.join(tempDir.path, 'lib', 'endpoints', 'middleware_endpoint.dart'),
      ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';
import '../middleware.dart';

@Endpoint(path: '/middleware-error', method: 'GET')
class MiddlewareEndpoint extends SparkEndpoint {
  @override
  List<Middleware> get middleware => [authMiddleware()];

  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

      final content = await runOpenApiCommand();
      final responses =
          content['paths']['/middleware-error']['get']['responses'];

      expect(responses, contains('401'));
      expect(responses['401']['description'], contains('Unauthorized'));
    });

    test('deduces multiple 500 errors as oneOf', () async {
      File(
        p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
      ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/multiple-errors', method: 'GET')
class MultipleErrorsEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async {
    if (true) {
      throw ApiError(message: 'Database Error', code: 'DATABASE_ERROR', statusCode: 500);
    }
    throw ApiError(message: 'Internal Error', code: 'INTERNAL_ERROR', statusCode: 500);
  }
}
''');

      final content = await runOpenApiCommand();
      final responses =
          content['paths']['/multiple-errors']['get']['responses'];

      expect(responses, contains('500'));
      final schema = responses['500']['content']['application/json']['schema'];
      expect(schema, contains('oneOf'));
      final oneOf = schema['oneOf'] as List;
      expect(oneOf.length, equals(2));

      final codes = oneOf
          .map((s) => s['properties']['code']['example'])
          .toList();
      expect(codes, contains('DATABASE_ERROR'));
      expect(codes, contains('INTERNAL_ERROR'));
    });

    test(
      'Middleware with nested closures (sqliteMiddleware pattern)',
      () async {
        final source =
            '''
        import 'package:$sparkPackageName/spark.dart';

        Middleware sqliteMiddleware() {
          return (Handler innerHandler) {
            return (Request request) async {
              try {
                // ...
              } catch (e) {
                print("Caught error");
                throw ApiError(
                  message: 'Impossible to get database from the pool',
                  code: 'DATABASE_ERROR',
                  statusCode: 500,
                );
              }
            };
          };
        }

        @Endpoint(path: '/my-endpoint', method: 'GET')
        class MyEndpoint extends SparkEndpoint {
          @override
          List<Middleware> get middleware => [sqliteMiddleware()];

          @override
          Future<String> handler(SparkRequest request) async {
            return 'ok';
          }
        }
      ''';

        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'middleware_nested.dart'),
        ).writeAsStringSync(source);

        final openApi = await runOpenApiCommand();
        final responses = openApi['paths']['/my-endpoint']['get']['responses'];

        expect(responses['500'], isNotNull, reason: 'Should have 500 response');
        final schema =
            responses['500']['content']['application/json']['schema'];

        bool found = false;
        if (schema.containsKey('oneOf')) {
          final oneOf = schema['oneOf'] as List;
          found = oneOf.any(
            (s) => s['properties']['code']['example'] == 'DATABASE_ERROR',
          );
        } else {
          found = schema['properties']['code']['example'] == 'DATABASE_ERROR';
        }
        expect(found, isTrue, reason: 'Should find DATABASE_ERROR in response');
      },
    );
    test('deduces multiple 400 errors as oneOf', () async {
      final source =
          '''
        import 'package:$sparkPackageName/spark.dart';

        @Endpoint(path: '/multi-400', method: 'GET')
        class Multi400Endpoint extends SparkEndpoint {
          @override
          Future<dynamic> handler(SparkRequest request) async {
            if (true) {
              throw ApiError(message: 'Validation failed', code: 'VALIDATION_ERROR', statusCode: 400);
            } else {
              throw ApiError(message: 'Bad format', code: 'BAD_FORMAT', statusCode: 400);
            }
          }
        }
      ''';

      File(
        p.join(tempDir.path, 'lib', 'endpoints', 'multi_400.dart'),
      ).writeAsStringSync(source);

      final openApi = await runOpenApiCommand();
      final responses = openApi['paths']['/multi-400']['get']['responses'];

      expect(responses['400'], isNotNull);
      final schema = responses['400']['content']['application/json']['schema'];

      expect(schema, contains('oneOf'));
      final oneOf = schema['oneOf'] as List;
      expect(oneOf.length, equals(2));

      final codes = oneOf
          .map((s) => s['properties']['code']['example'])
          .toList();
      expect(codes, contains('VALIDATION_ERROR'));
      expect(codes, contains('BAD_FORMAT'));
    });
  });
}
