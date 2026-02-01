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
  test('EndpointGenerator correctly serializes nullable Map in DTO', () async {
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
        }

        class SparkRequest {
          final Request shelfRequest;
          final Map<String, String> pathParams;
          SparkRequest({required this.shelfRequest, required this.pathParams});
        }

        class TierDto {
          final Map<String, dynamic>? nextTier;
          final String? name;
          TierDto({this.nextTier, this.name});
        }

        @Endpoint(path: '/api/tier', method: 'GET')
        class GetTierEndpoint extends SparkEndpoint {
          @override
          Future<TierDto> handler(SparkRequest request) async {
            return TierDto();
          }
        }
      ''',
      },
      (resolver) async {
        final libraryElement = await resolver.libraryFor(
          AssetId('a', 'lib/test_lib.dart'),
        );
        final endpointClass = libraryElement.children
            .whereType<ClassElement>()
            .firstWhere((e) => e.name == 'GetTierEndpoint');

        final annotations = endpointClass.metadata.annotations;
        final annotation = annotations.firstWhere(
          (a) => a.element?.enclosingElement?.name == 'Endpoint',
        );

        final generator = EndpointGenerator();
        final output = generator.generateForAnnotatedElement(
          endpointClass,
          ConstantReader(annotation.computeConstantValue()),
          SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
        );

        // Verify nullable Map uses conditional entry
        expect(
          output,
          contains(
            "if (result.nextTier != null) 'nextTier': result.nextTier!.map((k, v) => MapEntry(k, v))",
          ),
        );

        // Verify nullable String uses conditional entry
        expect(
          output,
          contains("if (result.name != null) 'name': result.name!"),
        );
      },
    );
  });
}
