import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spark_generator/src/endpoint_generator.dart';
import 'package:test/test.dart';

import 'dart:convert';

class SimpleBuildStep implements BuildStep {
  @override
  final AssetId inputId;
  SimpleBuildStep(this.inputId);

  @override
  Future<String> readAsString(AssetId id, {Encoding encoding = utf8}) async {
    throw UnimplementedError();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('EndpointGenerator Validation', () {
    test('generates structural validation for non-nullable fields', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
          class Endpoint {
            final String path;
            final String method;
            const Endpoint({required this.path, required this.method});
          }
        ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
          abstract class SparkEndpointWithBody<T> {
            Future<dynamic> handler(dynamic request, T body);
            List<dynamic> get middleware => [];
          }
        ''',
          'spark|lib/spark.dart': '''
          library spark;
          export 'src/annotations/endpoint.dart';
          export 'src/endpoint/spark_endpoint.dart';
          export 'src/errors/errors.dart';
        ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkValidationException implements Exception {
              final Map<String, dynamic> errors;
              SparkValidationException(this.errors);
            }
          ''',
          'a|lib/test_lib.dart': '''
          library a;
          import 'package:spark/spark.dart';

          class UserDto {
            final String name;
            final int age;
            final String? bio;
            UserDto({required this.name, required this.age, this.bio});
          }

          @Endpoint(path: '/api/users', method: 'POST')
          class CreateUserEndpoint extends SparkEndpointWithBody<UserDto> {
            @override
            Future<dynamic> handler(dynamic request, UserDto body) async {
              return body;
            }
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final createUserClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'CreateUserEndpoint');

          final annotations = createUserClass.metadata.annotations;
          final annotation = annotations.firstWhere(
            (a) => a.element?.enclosingElement?.name == 'Endpoint',
          );
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            createUserClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          // Required checks
          expect(output, contains('if (map["name"] == null)'));
          expect(output, contains("'code': 'VALIDATION_REQUIRED'"));
          expect(output, contains("Field 'name' is required"));

          expect(output, contains('if (map["age"] == null)'));
          expect(output, contains("Field 'age' is required"));

          // Optional field should NOT have required check
          expect(output, isNot(contains('if (map["bio"] == null)')));

          // Type checks
          expect(output, contains('if (map["name"] is! String)'));
          expect(output, contains("Field 'name' must be a String"));

          expect(
            output,
            contains(
              'if (map["age"] is! int && int.tryParse(map["age"].toString()) == null)',
            ),
          );
          expect(output, contains("Field 'age' must be an integer"));
        },
      );
    });

    test('generates recursive validation for nested DTOs', () async {
      await resolveSources(
        {
          'spark|lib/spark.dart': '''
            library spark;
            export 'src/annotations/endpoint.dart';
            export 'src/endpoint/spark_endpoint.dart';
            export 'src/errors/errors.dart';
          ''',
          'spark|lib/src/annotations/endpoint.dart':
              'class Endpoint { final String path; final String method; const Endpoint({required this.path, required this.method}); }',
          'spark|lib/src/endpoint/spark_endpoint.dart':
              'abstract class SparkEndpointWithBody<T> { Future<dynamic> handler(dynamic request, T body); List<dynamic> get middleware => []; }',
          'spark|lib/src/errors/errors.dart':
              'class SparkValidationException implements Exception { final Map<String, dynamic> errors; SparkValidationException(this.errors); }',
          'a|lib/test_lib.dart': '''
          library a;
          import 'package:spark/spark.dart';

          class AddressDto {
            final String street;
            AddressDto({required this.street});
          }

          class UserDto {
            final String name;
            final AddressDto address;
            UserDto({required this.name, required this.address});
          }

          @Endpoint(path: '/api/users', method: 'POST')
          class CreateUserEndpoint extends SparkEndpointWithBody<UserDto> {
            @override
            Future<dynamic> handler(dynamic request, UserDto body) async {
              return body;
            }
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final createUserClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'CreateUserEndpoint');

          final annotation = createUserClass.metadata.annotations.first;
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            createUserClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          // Top level
          expect(output, contains('if (map["name"] == null)'));
          expect(output, contains('if (map["address"] == null)'));

          // Nested
          expect(output, contains('map["street"] == null'));
          expect(output, contains("validationErrors['address.street'] = {"));
          expect(output, contains("Field 'address.street' is required"));
        },
      );
    });

    test('supports DateTime validation and parsing', () async {
      await resolveSources(
        {
          'spark|lib/spark.dart': '''
            library spark;
            export 'src/annotations/endpoint.dart';
            export 'src/endpoint/spark_endpoint.dart';
            export 'src/errors/errors.dart';
          ''',
          'spark|lib/src/annotations/endpoint.dart':
              'class Endpoint { final String path; final String method; const Endpoint({required this.path, required this.method}); }',
          'spark|lib/src/endpoint/spark_endpoint.dart':
              'abstract class SparkEndpointWithBody<T> { Future<dynamic> handler(dynamic request, T body); List<dynamic> get middleware => []; }',
          'spark|lib/src/errors/errors.dart':
              'class SparkValidationException implements Exception { final Map<String, dynamic> errors; SparkValidationException(this.errors); }',
          'a|lib/test_lib.dart': '''
          library a;
          import 'package:spark/spark.dart';

          class EventDto {
            final DateTime date;
            EventDto({required this.date});
          }

          @Endpoint(path: '/api/events', method: 'POST')
          class CreateEventEndpoint extends SparkEndpointWithBody<EventDto> {
            @override
            Future<dynamic> handler(dynamic request, EventDto body) async {
              return body;
            }
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final createUserClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'CreateEventEndpoint');

          final annotation = createUserClass.metadata.annotations.first;
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            createUserClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          // Structural validation
          expect(
            output,
            contains('if (DateTime.tryParse(map["date"].toString()) == null)'),
          );
          expect(
            output,
            contains("Field 'date' must be a valid ISO8601 date string"),
          );

          // Parsing
          expect(
            output,
            contains(
              'EventDto(date: DateTime.parse((rawBody as Map<String, dynamic>)["date"].toString()))',
            ),
          );
        },
      );
    });

    test('supports List validation', () async {
      await resolveSources(
        {
          'spark|lib/spark.dart': '''
            library spark;
            export 'src/annotations/endpoint.dart';
            export 'src/endpoint/spark_endpoint.dart';
            export 'src/errors/errors.dart';
          ''',
          'spark|lib/src/annotations/endpoint.dart':
              'class Endpoint { final String path; final String method; const Endpoint({required this.path, required this.method}); }',
          'spark|lib/src/endpoint/spark_endpoint.dart':
              'abstract class SparkEndpointWithBody<T> { Future<dynamic> handler(dynamic request, T body); List<dynamic> get middleware => []; }',
          'spark|lib/src/errors/errors.dart':
              'class SparkValidationException implements Exception { final Map<String, dynamic> errors; SparkValidationException(this.errors); }',
          'a|lib/test_lib.dart': '''
          library a;
          import 'package:spark/spark.dart';

          class UserDto {
            final List<String> tags;
            UserDto({required this.tags});
          }

          @Endpoint(path: '/api/users', method: 'POST')
          class CreateUserEndpoint extends SparkEndpointWithBody<UserDto> {
            @override
            Future<dynamic> handler(dynamic request, UserDto body) async {
              return body;
            }
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final createUserClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'CreateUserEndpoint');

          final annotation = createUserClass.metadata.annotations.first;
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            createUserClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          expect(output, contains('if (map["tags"] is! List)'));
          expect(output, contains("for (var i = 0; i < list.length; i++)"));
          expect(output, contains("if (element is! String)"));
          expect(output, contains("validationErrors[subPath] = {"));
        },
      );
    });
  });
}
