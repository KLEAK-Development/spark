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
  group('EndpointGenerator List Parsing', () {
    test(
      'generates correct parsing for List<String>, List<int>? and List<NestedDto>',
      () async {
        await resolveSources(
          {
            'spark|lib/src/annotations/endpoint.dart': '''
            class Endpoint {
              final String path;
              final String method;
              final List<String>? contentTypes;
              // OpenApiPath fields
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

              const Endpoint({required this.path, required this.method, this.contentTypes, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody});
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
            }

            class SparkRequest {
              final Request shelfRequest;
              final Map<String, String> pathParams;
              SparkRequest({required this.shelfRequest, required this.pathParams});
            }

            class NestedDto {
              final String name;
              NestedDto({required this.name});
            }

            class ListDto {
              final List<String> tags;
              final List<int>? scores;
              final List<String>? nullableTags;
              final List<NestedDto> users;

              ListDto({required this.tags, this.scores, this.nullableTags, required this.users});
            }

            @Endpoint(path: '/api/lists', method: 'POST')
            class ListEndpoint extends SparkEndpointWithBody<ListDto> {
              @override
              Future<String> handler(SparkRequest request, ListDto body) async {
                return 'ok';
              }
            }
          ''',
          },
          (resolver) async {
            final libraryElement = await resolver.libraryFor(
              AssetId('a', 'lib/test_lib.dart'),
            );

            final listEndpointClass = libraryElement.children
                .whereType<ClassElement>()
                .firstWhere((e) => e.name == 'ListEndpoint');

            final annotations = listEndpointClass.metadata.annotations;
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
              listEndpointClass,
              constantReader,
              SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
            );

            print(output);

            // Verify List<String> tags
            expect(
              output,
              contains(
                'tags: ((rawBody as Map<String, dynamic>)["tags"] as List).map((e) => e.toString()).toList()',
              ),
            );

            // Verify List<int>? scores
            expect(
              output,
              contains(
                'scores: (rawBody as Map<String, dynamic>)["scores"] == null ? null : ((rawBody as Map<String, dynamic>)["scores"] as List).map((e) => int.parse(e.toString())).toList()',
              ),
            );

            // Verify List<String>? nullableTags
            expect(
              output,
              contains(
                'nullableTags: (rawBody as Map<String, dynamic>)["nullable_tags"] == null ? null : ((rawBody as Map<String, dynamic>)["nullable_tags"] as List).map((e) => e.toString()).toList()',
              ),
            );

            // Verify List<NestedDto> users
            // Matches structure: users: ((rawBody as Map<String, dynamic>)["users"] as List).map((e) => NestedDto(name: (e as Map<String, dynamic>)["name"].toString())).toList()
            expect(
              output,
              contains(
                'users: ((rawBody as Map<String, dynamic>)["users"] as List).map((e) => NestedDto(name: (e as Map<String, dynamic>)["name"].toString())).toList()',
              ),
            );
          },
        );
      },
    );
  });
}
