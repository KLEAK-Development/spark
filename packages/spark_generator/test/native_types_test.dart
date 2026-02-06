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
  group('ComponentGenerator Native Types', () {
    test('supports List and Map types (core and custom)', () async {
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

            class User {
              final String name;
              User(this.name);
              factory User.fromJson(Map<String, dynamic> json) => User(json['name']);
              Map<String, dynamic> toJson() => {'name': name};
            }

            @Component(tag: 'my-component')
            class MyComponent {
              static const tag = 'my-component';

              @Attribute()
              List<String> tags = [];

              @Attribute()
              List<int> numbers = [];

              @Attribute()
              Map<String, int> scores = {};
              
              @Attribute()
              List<User> users = [];

              @Attribute()
              Map<String, User> userMap = {};

              @Attribute()
              User? activeUser;

              Element render() => div([]);
            }

            class Element {}
            Element div(List children) => Element();
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib_base.dart'),
          );

          final componentClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'MyComponent');

          final annotations = componentClass.metadata.annotations;
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
            componentClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart')),
          );

          // Serialization checks
          expect(output, contains("setAttr('tags', jsonEncode(tags));"));
          expect(output, contains("setAttr('numbers', jsonEncode(numbers));"));
          expect(output, contains("setAttr('scores', jsonEncode(scores));"));
          expect(
            output,
            contains("setAttr('users', jsonEncode(users));"),
          ); // List<Custom> should verify toJson is called by jsonEncode
          expect(output, contains("setAttr('usermap', jsonEncode(userMap));"));
          expect(
            output,
            contains("setAttr('activeuser', jsonEncode(activeUser.toJson()));"),
          );

          // Deserialization checks

          // List<String>
          expect(output, contains("case 'tags':"));
          expect(
            output,
            contains(
              "(jsonDecode(newValue ?? '[]') as List).cast<String>().toList()",
            ),
          );

          // List<int>
          expect(output, contains("case 'numbers':"));
          expect(
            output,
            contains(
              "(jsonDecode(newValue ?? '[]') as List).cast<int>().toList()",
            ),
          );

          // Map<String, int>
          expect(output, contains("case 'scores':"));
          expect(
            output,
            contains(
              "(jsonDecode(newValue ?? '{}') as Map).cast<String, int>()",
            ),
          );

          // List<User> - Custom Type
          expect(output, contains("case 'users':"));
          expect(
            output,
            contains(
              "(jsonDecode(newValue ?? '[]') as List).map((e) => User.fromJson(e)).toList()",
            ),
          );

          // Map<String, User> - Custom Type
          expect(output, contains("case 'usermap':"));
          expect(
            output,
            contains(
              "(jsonDecode(newValue ?? '{}') as Map).map((k, v) => MapEntry(k as String, User.fromJson(v)))",
            ),
          );

          // Single User - Custom Type (existing behavior check)
          expect(output, contains("case 'activeuser':"));
          expect(output, contains("User?.fromJson(jsonDecode(newValue));"));
        },
      );
    });
  });
}
