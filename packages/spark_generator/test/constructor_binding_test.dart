import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spark_generator/src/endpoint_generator.dart';
import 'package:test/test.dart';

class SimpleBuildStep implements BuildStep {
  @override
  final AssetId inputId;
  SimpleBuildStep(this.inputId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('EndpointGenerator Constructor Binding', () {
    test('binds request body to DTO constructor and serializes fields', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
            class Endpoint {
              final String path;
              final String method;
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;
              final List<String>? contentTypes;

            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody, this.contentTypes});
            }
          ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
            abstract class SparkEndpoint {
              Future<dynamic> handler(dynamic request);
              List<dynamic> get middleware => [];
            }
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
              final String message;
              SparkValidationException(this.errors, {this.message = 'Validation Failed'});
            }
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
             class Response {
               static Response ok(String body, {Map<String, dynamic>? headers}) => Response(200);
               Response(int statusCode, {String? body, Map<String, dynamic>? headers});
            }
          ''',
          'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/spark.dart';

            class Request {
               Future<String> readAsString() async => '';
               Map<String, String> get headers => {};
            }

            class SparkRequest {
              final Request shelfRequest;
              final Map<String, String> pathParams;
              SparkRequest({required this.shelfRequest, required this.pathParams});
              Stream<dynamic> get multipart => Stream.empty();
            }

            class AddressDto {
                final String street;
                final String city;
                AddressDto({required this.street, required this.city});
            }

            class UserDto {
              final String name;
              final int age;
              final AddressDto address;
              
              UserDto({required this.name, required this.age, required this.address});
            }

            @Endpoint(path: '/api/users', method: 'POST')
            class CreateUserEndpoint extends SparkEndpointWithBody<UserDto> {
              @override
              Future<UserDto> handler(SparkRequest request, UserDto body) async {
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
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            createUserClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          // Test Parsing Logic

          // Should extract name from map
          expect(
            output,
            contains(
              'name: (rawBody as Map<String, dynamic>)["name"].toString()',
            ),
          );

          // Should extract age from map
          expect(
            output,
            contains(
              'age: int.parse((rawBody as Map<String, dynamic>)["age"].toString())',
            ),
          );

          // Should recursively parse AddressDto
          expect(
            output,
            contains(
              'AddressDto(street: ((rawBody as Map<String, dynamic>)["address"] as Map<String, dynamic>)["street"].toString(), city: ((rawBody as Map<String, dynamic>)["address"] as Map<String, dynamic>)["city"].toString())',
            ),
          );

          // Test Serialization Logic

          // Should serialize name
          expect(output, contains("'name': result.name"));

          // Should serialize age
          expect(output, contains("'age': result.age"));

          // Should serialize address recursively
          expect(
            output,
            contains(
              "'address': {'street': result.address.street, 'city': result.address.city}",
            ),
          );
        },
      );
    });
  });
}
