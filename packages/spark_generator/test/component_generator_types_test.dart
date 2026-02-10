import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spark_generator/src/component_generator.dart';
import 'package:test/test.dart';

class SimpleBuildStep implements BuildStep {
  @override
  final AssetId inputId;
  SimpleBuildStep(this.inputId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ComponentGenerator Attribute Types', () {
    test('generates correct deserialization for various types', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/component.dart': '''
            class Component {
              final String tag;
              const Component({required this.tag});
            }
            class Attribute {
              final String? name;
              final bool observable;
              const Attribute({this.name, this.observable = false});
            }
          ''',
          'spark|lib/src/component/spark_component.dart': '''
            abstract class SparkComponent {
              void syncAttributes() {}
              void scheduleUpdate() {}
              void setAttr(String name, String value) {}
              Map<String, String> get dumpedAttributes;
              List<String> get observedAttributes => const [];
              void attributeChangedCallback(String name, String? oldValue, String? newValue) {}
              String get tagName;
            }
          ''',
          'spark|lib/server.dart': '''
            library spark;
            export 'src/annotations/component.dart';
            export 'src/component/spark_component.dart';
          ''',
          'a|lib/test_lib_base.dart': '''
            library a;
            import 'package:spark/server.dart';
            import 'dart:convert';

            class CustomType {
              final String name;
              CustomType(this.name);
              factory CustomType.fromJson(Map<String, dynamic> json) => CustomType(json['name']);
              Map<String, dynamic> toJson() => {'name': name};
            }

            @Component(tag: 'my-element')
            class MyElement {
              static const tag = 'my-element';

              @Attribute()
              int intAttr = 0;

              @Attribute()
              double doubleAttr = 0.0;

              @Attribute()
              bool boolAttr = false;

              @Attribute()
              String stringAttr = '';

              @Attribute()
              List<String> listStringAttr = [];

              @Attribute()
              Map<String, int> mapIntAttr = {};

              @Attribute()
              CustomType customAttr = CustomType('');

              @Attribute()
              List<CustomType> listCustomAttr = [];

              @Attribute()
              Map<String, CustomType> mapCustomAttr = {};

              Element render() {
                return div([]);
              }
            }

            class Element {}
            Element div(List children) => Element();
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib_base.dart'),
          );

          final classElement = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'MyElement');

          final annotations = classElement.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Component';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = ComponentGenerator();
          final output = generator.generateForAnnotatedElement(
            classElement,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart')),
          );

          // Verify int deserialization
          expect(output, contains("case 'intattr':"));
          expect(
            output,
            contains("_intAttr = int.tryParse(newValue ?? '') ?? 0;"),
          );

          // Verify double deserialization
          expect(output, contains("case 'doubleattr':"));
          expect(
            output,
            contains("_doubleAttr = double.tryParse(newValue ?? '') ?? 0.0;"),
          );

          // Verify bool deserialization
          expect(output, contains("case 'boolattr':"));
          expect(
            output,
            contains("_boolAttr = newValue != null && newValue != 'false';"),
          );

          // Verify string deserialization
          expect(output, contains("case 'stringattr':"));
          expect(output, contains("_stringAttr = newValue ?? '';"));

          // Verify List<String> deserialization
          expect(output, contains("case 'liststringattr':"));
          expect(
            output,
            contains(
              "_listStringAttr = (jsonDecode(newValue ?? '[]') as List).cast<String>().toList();",
            ),
          );

          // Verify Map<String, int> deserialization
          expect(output, contains("case 'mapintattr':"));
          expect(
            output,
            contains(
              "_mapIntAttr = (jsonDecode(newValue ?? '{}') as Map).cast<String, int>();",
            ),
          );

          // Verify CustomType deserialization
          expect(output, contains("case 'customattr':"));
          expect(
            output,
            contains(
              "_customAttr = CustomType.fromJson(jsonDecode(newValue));",
            ),
          );

          // Verify List<CustomType> deserialization
          expect(output, contains("case 'listcustomattr':"));
          expect(
            output,
            contains(
              "_listCustomAttr = (jsonDecode(newValue ?? '[]') as List).map((e) => CustomType.fromJson(e)).toList();",
            ),
          );

          // Verify Map<String, CustomType> deserialization
          expect(output, contains("case 'mapcustomattr':"));
          expect(
            output,
            contains(
              "_mapCustomAttr = (jsonDecode(newValue ?? '{}') as Map).map((k, v) => MapEntry(k as String, CustomType.fromJson(v)));",
            ),
          );
        },
      );
    });
  });
}
