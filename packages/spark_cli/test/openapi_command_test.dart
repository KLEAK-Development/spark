import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:spark_cli/src/commands/openapi_command.dart';
import 'package:test/test.dart';

void main() {
  group('OpenApiCommand', () {
    late Directory tempDir;
    late Directory originalCwd;
    late CommandRunner<void> runner;
    late String sparkPackagePath;
    late String sparkPackageName;

    setUp(() async {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('spark_openapi_test_');
      // No longer setting Directory.current = tempDir;
      runner = CommandRunner<void>('spark', 'Spark CLI')
        ..addCommand(OpenApiCommand(workingDirectory: tempDir));

      // Create project structure
      Directory(
        p.join(tempDir.path, 'lib', 'endpoints'),
      ).createSync(recursive: true);
      Directory(p.join(tempDir.path, 'bin')).createSync(recursive: true);

      // 1. Try packages/spark (if running from repo root)
      var possiblePath = p.absolute(
        p.join(originalCwd.path, 'packages', 'spark'),
      );

      if (!File(p.join(possiblePath, 'pubspec.yaml')).existsSync()) {
        // 2. Try sibling ../spark (if running from packages/spark_cli)
        possiblePath = p.absolute(p.join(originalCwd.path, '..', 'spark'));
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

dependency_overrides:
  spark_web:
    path: ${p.join(p.dirname(sparkPackagePath), 'spark_web')}
''');
    });

    tearDown(() {
      // Directory.current = originalCwd; // No longer needed
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

    group('endpoint filtering', () {
      test(
        'includes all endpoints, even without specific OpenAPI fields',
        () async {
          File(
            p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
          ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/simple', method: 'GET')
class SimpleEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'simple';
}

@Endpoint(path: '/documented', method: 'GET', summary: 'Documented endpoint')
class DocumentedEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'documented';
}
''');

          final content = await runOpenApiCommand();
          final paths = content['paths'] as Map;

          expect(
            paths.containsKey('/simple'),
            isTrue,
            reason:
                'Endpoint without summary/description should still be included',
          );
          expect(
            paths.containsKey('/documented'),
            isTrue,
            reason: 'Endpoint with summary should be included',
          );
        },
      );
    });

    group('tags', () {
      test('does not add default tags when not specified', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/no-tags', method: 'GET', summary: 'No tags endpoint')
class NoTagsEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final getOp = content['paths']['/no-tags']['get'];

        expect(
          getOp.containsKey('tags'),
          isFalse,
          reason: 'Tags should not be added when not specified',
        );
      });

      test('includes tags when explicitly specified', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(
  path: '/with-tags',
  method: 'GET',
  summary: 'With tags endpoint',
  tags: ['Users', 'Admin'],
)
class WithTagsEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final getOp = content['paths']['/with-tags']['get'];

        expect(getOp['tags'], equals(['Users', 'Admin']));
      });
    });

    group('request body', () {
      test(
        'does not add requestBody when not specified in annotation',
        () async {
          File(
            p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
          ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/no-body', method: 'POST', summary: 'No body endpoint')
class NoBodyEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

          final content = await runOpenApiCommand();
          final postOp = content['paths']['/no-body']['post'];

          expect(
            postOp.containsKey('requestBody'),
            isFalse,
            reason: 'requestBody should not be added when not specified',
          );
        },
      );

      test(
        'infers required body from SparkEndpointWithBody (required)',
        () async {
          File(
            p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
          ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class Dto { final String id; Dto(this.id); }

@Endpoint(path: '/required', method: 'POST', contentTypes: ['application/json'])
class RequiredBodyEndpoint extends SparkEndpointWithBody<Dto> {
  @override
  Future<dynamic> handler(SparkRequest request, Dto body) async => 'ok';
}
''');
          final content = await runOpenApiCommand();
          final op = content['paths']['/required']['post'];
          expect(op['requestBody']['required'], isTrue);
          expect(
            op['requestBody']['content'].containsKey('application/json'),
            isTrue,
          );
        },
      );

      test(
        'infers optional body from SparkEndpointWithBody (nullable)',
        () async {
          File(
            p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
          ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class Dto { final String id; Dto(this.id); }

@Endpoint(path: '/optional', method: 'POST', contentTypes: ['application/json'])
class OptionalBodyEndpoint extends SparkEndpointWithBody<Dto> {
  @override
  Future<dynamic> handler(SparkRequest request, Dto? body) async => 'ok';
}
''');
          final content = await runOpenApiCommand();
          final op = content['paths']['/optional']['post'];
          expect(op['requestBody']['required'], isFalse);
        },
      );

      test('uses contentTypes from annotation', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class Dto { final String id; Dto(this.id); }

@Endpoint(path: '/xml', method: 'POST', contentTypes: ['application/xml', 'application/json'])
class XmlEndpoint extends SparkEndpointWithBody<Dto> {
  @override
  Future<dynamic> handler(SparkRequest request, Dto body) async => 'ok';
}
''');
        final content = await runOpenApiCommand();
        final op = content['paths']['/xml']['post'];
        final contentMap = op['requestBody']['content'] as Map;
        expect(contentMap.containsKey('application/xml'), isTrue);
        expect(contentMap.containsKey('application/json'), isTrue);
      });
    });

    group('responses', () {
      test('includes default 200 response', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/default', method: 'GET', summary: 'Default response')
class DefaultResponseEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final getOp = content['paths']['/default']['get'];

        expect(getOp['responses']['200'], isNotNull);
        expect(
          getOp['responses']['200']['description'],
          'Successful operation',
        );
      });

      test('infers 201 for POST requests', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/create', method: 'POST', summary: 'Create resource')
class CreateEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'created';
}
''');

        final content = await runOpenApiCommand();
        final postOp = content['paths']['/create']['post'];

        expect(postOp['responses']['201'], isNotNull);
        expect(
          postOp['responses']['201']['description'],
          'Successful operation',
        );
      });

      test('uses overridden statusCode', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(
  path: '/accepted',
  method: 'POST',
  summary: 'Accepted resource',
  statusCode: 202,
)
class AcceptedEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'accepted';
}
''');

        final content = await runOpenApiCommand();
        final postOp = content['paths']['/accepted']['post'];

        expect(postOp['responses']['202'], isNotNull);
        expect(postOp['responses']['201'], isNull); // Should not have default
      });

      test('infers schema from handler return type', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class User {
  final String name;
  User(this.name);
}

@Endpoint(path: '/user', method: 'GET', summary: 'Get user')
class GetUserEndpoint extends SparkEndpoint {
  @override
  Future<User> handler(SparkRequest request) async {
    return User('Alice');
  }
}
''');

        final content = await runOpenApiCommand();
        final getOp = content['paths']['/user']['get'];
        final response = getOp['responses']['200'];

        expect(response, isNotNull);
        final jsonContent = response['content']['application/json'];
        expect(jsonContent['schema']['\$ref'], '#/components/schemas/User');
      });
    });

    group('path parameters', () {
      test('extracts path parameters from route', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/users/:userId/posts/:postId', method: 'GET', summary: 'Get user post')
class GetUserPostEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final paths = content['paths'] as Map;

        // Verify path is converted to OpenAPI format
        expect(paths.containsKey('/users/{userId}/posts/{postId}'), isTrue);

        final getOp = paths['/users/{userId}/posts/{postId}']['get'];
        final params = getOp['parameters'] as List;

        expect(params.length, 2);
        expect(params[0]['name'], 'userId');
        expect(params[0]['in'], 'path');
        expect(params[0]['required'], true);
        expect(params[1]['name'], 'postId');
        expect(params[1]['in'], 'path');
        expect(params[1]['required'], true);
      });
    });

    group('custom parameters', () {
      test('includes custom query parameters', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(
  path: '/search',
  method: 'GET',
  summary: 'Search',
  parameters: [
    Parameter(
      name: 'q',
      inLocation: 'query',
      description: 'Search query',
      required: true,
    ),
    Parameter(
      name: 'limit',
      inLocation: 'query',
      description: 'Max results',
      required: false,
      type: int,
    ),
  ],
)
class SearchEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final getOp = content['paths']['/search']['get'];
        final params = getOp['parameters'] as List;

        expect(params.length, 2);

        final qParam = params.firstWhere((p) => p['name'] == 'q');
        expect(qParam['in'], 'query');
        expect(qParam['description'], 'Search query');
        expect(qParam['required'], true);

        final limitParam = params.firstWhere((p) => p['name'] == 'limit');
        expect(limitParam['in'], 'query');
        expect(limitParam['description'], 'Max results');
        expect(limitParam['required'], false);
        expect(limitParam['schema']['type'], 'integer');
      });
    });

    group('operation metadata', () {
      test('includes operationId when specified', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(
  path: '/op-id',
  method: 'GET',
  summary: 'With operation ID',
  operationId: 'getWithOperationId',
)
class OpIdEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final getOp = content['paths']['/op-id']['get'];

        expect(getOp['operationId'], 'getWithOperationId');
      });

      test('includes deprecated flag when true', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(
  path: '/deprecated',
  method: 'GET',
  summary: 'Deprecated endpoint',
  deprecated: true,
)
class DeprecatedEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final getOp = content['paths']['/deprecated']['get'];

        expect(getOp['deprecated'], true);
      });

      test('includes security overrides', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(
  path: '/secure',
  method: 'GET',
  summary: 'Secure endpoint',
  security: [
    {'BearerAuth': []},
    {'ApiKey': ['read', 'write']},
  ],
)
class SecureEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final getOp = content['paths']['/secure']['get'];
        final security = getOp['security'] as List;

        expect(security.length, 2);
        expect(security[0]['BearerAuth'], isEmpty);
        expect(security[1]['ApiKey'], equals(['read', 'write']));
      });

      test('includes external documentation', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(
  path: '/external-docs',
  method: 'GET',
  summary: 'With external docs',
  externalDocs: ExternalDocumentation(
    url: 'https://docs.example.com/guide',
    description: 'Extended documentation',
  ),
)
class ExternalDocsEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final getOp = content['paths']['/external-docs']['get'];

        expect(getOp['externalDocs']['url'], 'https://docs.example.com/guide');
        expect(getOp['externalDocs']['description'], 'Extended documentation');
      });
    });

    group('global configuration', () {
      test('includes global OpenApi metadata', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/test', method: 'GET', summary: 'Test')
class TestEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        File(p.join(tempDir.path, 'bin', 'server.dart')).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@OpenApi(
  title: 'My API',
  version: '2.0.0',
  description: 'API description',
  servers: ['https://api.example.com', 'https://staging.api.example.com'],
)
void main() {}
''');

        final content = await runOpenApiCommand();

        expect(content['openapi'], '3.0.0');
        expect(content['info']['title'], 'My API');
        expect(content['info']['version'], '2.0.0');
        expect(content['info']['description'], 'API description');

        final servers = content['servers'] as List;
        expect(servers.length, 2);
        expect(servers[0]['url'], 'https://api.example.com');
        expect(servers[1]['url'], 'https://staging.api.example.com');
      });

      test('includes security schemes', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/test', method: 'GET', summary: 'Test')
class TestEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        File(p.join(tempDir.path, 'bin', 'server.dart')).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@OpenApi(
  title: 'Secure API',
  version: '1.0.0',
  securitySchemes: {
    'BearerAuth': SecurityScheme.http(
      scheme: 'bearer',
      bearerFormat: 'JWT',
      description: 'JWT token authentication',
    ),
    'ApiKeyAuth': SecurityScheme.apiKey(
      name: 'X-API-Key',
      inLocation: 'header',
      description: 'API key header',
    ),
  },
)
void main() {}
''');

        final content = await runOpenApiCommand();
        final securitySchemes = content['components']['securitySchemes'] as Map;

        expect(securitySchemes['BearerAuth']['type'], 'http');
        expect(securitySchemes['BearerAuth']['scheme'], 'bearer');
        expect(securitySchemes['BearerAuth']['bearerFormat'], 'JWT');
        expect(
          securitySchemes['BearerAuth']['description'],
          'JWT token authentication',
        );

        expect(securitySchemes['ApiKeyAuth']['type'], 'apiKey');
        expect(securitySchemes['ApiKeyAuth']['name'], 'X-API-Key');
        expect(securitySchemes['ApiKeyAuth']['in'], 'header');
      });
    });

    group('schema generation', () {
      test('generates schemas for nested types', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class Address {
  final String street;
  final String city;
  Address(this.street, this.city);
}

class Person {
  final String name;
  final Address address;
  Person(this.name, this.address);
}

@Endpoint(
  path: '/person',
  method: 'GET',
  summary: 'Get person',
)
class GetPersonEndpoint extends SparkEndpoint {
  @override
  Future<Person> handler(SparkRequest request) async {
    return Person('Bob', Address('123 Main', 'City'));
  }
}
''');

        final content = await runOpenApiCommand();
        final schemas = content['components']['schemas'] as Map;

        expect(schemas.containsKey('Person'), isTrue);
        expect(schemas.containsKey('Address'), isTrue);

        expect(schemas['Person']['properties']['name']['type'], 'string');
        expect(
          schemas['Person']['properties']['address']['\$ref'],
          '#/components/schemas/Address',
        );

        expect(schemas['Address']['properties']['street']['type'], 'string');
        expect(schemas['Address']['properties']['city']['type'], 'string');
      });

      test('handles list types correctly', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class Item {
  final String id;
  Item(this.id);
}

class ItemList {
  final List<Item> items;
  final List<String> tags;
  ItemList(this.items, this.tags);
}

@Endpoint(
  path: '/items',
  method: 'GET',
  summary: 'Get items',
)
class GetItemsEndpoint extends SparkEndpoint {
  @override
  Future<ItemList> handler(SparkRequest request) async {
    return ItemList([], []);
  }
}
''');

        final content = await runOpenApiCommand();
        final schemas = content['components']['schemas'] as Map;

        expect(schemas['ItemList']['properties']['items']['type'], 'array');
        expect(
          schemas['ItemList']['properties']['items']['items']['\$ref'],
          '#/components/schemas/Item',
        );

        expect(schemas['ItemList']['properties']['tags']['type'], 'array');
        expect(
          schemas['ItemList']['properties']['tags']['items']['type'],
          'string',
        );
      });

      test('handles primitive types correctly', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

class AllTypes {
  final String stringField;
  final int intField;
  final double doubleField;
  final bool boolField;
  final DateTime dateTimeField;
  AllTypes(this.stringField, this.intField, this.doubleField, this.boolField, this.dateTimeField);
}

@Endpoint(
  path: '/types',
  method: 'GET',
  summary: 'All types',
)
class AllTypesEndpoint extends SparkEndpoint {
  @override
  Future<AllTypes> handler(SparkRequest request) async {
    return AllTypes('s', 1, 1.0, true, DateTime.now());
  }
}
''');

        final content = await runOpenApiCommand();
        final schemas = content['components']['schemas'] as Map;
        final props = schemas['AllTypes']['properties'] as Map;

        expect(props['stringField']['type'], 'string');
        expect(props['intField']['type'], 'integer');
        expect(props['doubleField']['type'], 'number');
        expect(props['boolField']['type'], 'boolean');
        expect(props['dateTimeField']['type'], 'string');
        expect(props['dateTimeField']['format'], 'date-time');
      });
    });

    group('HTTP methods', () {
      test('supports all HTTP methods', () async {
        File(
          p.join(tempDir.path, 'lib', 'endpoints', 'endpoints.dart'),
        ).writeAsStringSync('''
import 'package:$sparkPackageName/spark.dart';

@Endpoint(path: '/resource', method: 'GET', summary: 'Get resource')
class GetEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}

@Endpoint(path: '/resource', method: 'POST', summary: 'Create resource')
class PostEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}

@Endpoint(path: '/resource', method: 'PUT', summary: 'Update resource')
class PutEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}

@Endpoint(path: '/resource', method: 'PATCH', summary: 'Patch resource')
class PatchEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}

@Endpoint(path: '/resource', method: 'DELETE', summary: 'Delete resource')
class DeleteEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}
''');

        final content = await runOpenApiCommand();
        final resource = content['paths']['/resource'] as Map;

        expect(resource['get']['summary'], 'Get resource');
        expect(resource['post']['summary'], 'Create resource');
        expect(resource['put']['summary'], 'Update resource');
        expect(resource['patch']['summary'], 'Patch resource');
        expect(resource['delete']['summary'], 'Delete resource');
      });
    });
  });
}
