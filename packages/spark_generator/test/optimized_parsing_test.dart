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
  test('generates optimized body parsing for specific content types', () async {
    await resolveSources(
      {
        'spark|lib/src/annotations/endpoint.dart': '''
            class Endpoint {
              final String path;
              final String method;
              final String? summary;
              final List<String>? contentTypes;
              
              const Endpoint({required this.path, required this.method, this.summary, this.contentTypes});
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
          ''',
        'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/spark.dart';

            class UserDto {
              final String name;
              UserDto({required this.name});
            }

            @Endpoint(path: '/api/json-only', method: 'POST', contentTypes: ['application/json'])
            class JsonOnlyEndpoint extends SparkEndpointWithBody<UserDto> {
              @override
              Future<UserDto> handler(dynamic request, UserDto body) async {
                return body;
              }
            }
          ''',
      },
      (resolver) async {
        final libraryElement = await resolver.libraryFor(
          AssetId('a', 'lib/test_lib.dart'),
        );

        final jsonOnlyClass = libraryElement.children
            .whereType<ClassElement>()
            .firstWhere((e) => e.name == 'JsonOnlyEndpoint');

        final annotations = jsonOnlyClass.metadata.annotations;
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
          jsonOnlyClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
        );

        // Should check for json content type
        expect(output, contains("if (contentType == ContentType.json)"));

        // Should NOT generate multipart or formUrlEncoded checks
        expect(
          output,
          isNot(contains("if (contentType == ContentType.multipart)")),
        );
        expect(
          output,
          isNot(contains("if (contentType == ContentType.formUrlEncoded)")),
        );
      },
    );
  });
}
