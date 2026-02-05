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
  group('EndpointGenerator Snake Case Conversion', () {
    test('converts camelCase fields to snake_case keys', () async {
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
          ''',
          'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/spark.dart';

            class Response {
               static Response ok(String body, {Map<String, dynamic>? headers}) => Response();
            }

            class Request {
               Future<String> readAsString() async => '';
               Map<String, String> get headers => {};
            }

            class SparkRequest {
              final Request shelfRequest;
              final Map<String, String> pathParams;
              SparkRequest({required this.shelfRequest, required this.pathParams});
            }

            class ProjectDto {
              final String projectType;
              final String userProfileId;
              
              ProjectDto({required this.projectType, required this.userProfileId});
            }

            @Endpoint(path: '/api/projects', method: 'POST')
            class CreateProjectEndpoint extends SparkEndpointWithBody<ProjectDto> {
              @override
              Future<ProjectDto> handler(SparkRequest request, ProjectDto body) async {
                return body;
              }
            }
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final createProjectClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'CreateProjectEndpoint');

          final annotations = createProjectClass.metadata.annotations;
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
            createProjectClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          // Test Deserialization (Parsing)
          // Should look for "project_type" in the map to assign to projectType
          expect(
            output,
            contains(
              'projectType: (rawBody as Map<String, dynamic>)["project_type"]',
            ),
          );
          // Should look for "user_profile_id" in the map to assign to userProfileId
          expect(
            output,
            contains(
              'userProfileId: (rawBody as Map<String, dynamic>)["user_profile_id"]',
            ),
          );

          // Test Serialization (Response)
          // Should map projectType field to "project_type" key
          expect(output, contains("'project_type': result.projectType"));
          // Should map userProfileId field to "user_profile_id" key
          expect(output, contains("'user_profile_id': result.userProfileId"));
        },
      );
    });
  });
}
