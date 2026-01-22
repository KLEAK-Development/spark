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
  group('ComponentGenerator', () {
    test(
      'generates complete reactive class with private fields and setters',
      () async {
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

            @Component(tag: 'my-counter')
            class Counter {
              static const tag = 'my-counter';

              @Attribute()
              int value = 0;

              String label = 'Count';

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

            final counterClass = libraryElement.children
                .whereType<ClassElement>()
                .firstWhere((e) => e.name == 'Counter');

            final annotations = counterClass.metadata.annotations;
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
              counterClass,
              constantReader,
              SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart')),
            );

            // Should generate complete class extending SparkComponent
            expect(output, contains('class Counter extends SparkComponent {'));

            // Should generate static tag
            expect(output, contains('static const tag ='));

            // Should generate private field
            expect(output, contains('_value'));

            // Should generate reactive getter
            expect(output, contains('int get value => _value;'));

            // Should generate reactive setter with scheduleUpdate
            expect(output, contains('set value(int v) {'));
            expect(output, contains('if (_value != v) {'));
            expect(output, contains('_value = v;'));
            expect(output, contains('scheduleUpdate();'));
          },
        );
      },
    );

    test('generates syncAttributes using field access', () async {
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

            @Component(tag: 'my-counter')
            class Counter {
              static const tag = 'my-counter';

              @Attribute()
              int value = 0;

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

          final counterClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'Counter');

          final annotations = counterClass.metadata.annotations;
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
            counterClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart')),
          );

          // syncAttributes should use field access
          expect(output, contains("setAttr('value', value.toString());"));
        },
      );
    });

    test('generates dumpedAttributes map', () async {
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

            @Component(tag: 'my-counter')
            class Counter {
              static const tag = 'my-counter';

              @Attribute()
              int value = 0;

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

          final counterClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'Counter');

          final annotations = counterClass.metadata.annotations;
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
            counterClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart')),
          );

          // dumpedAttributes should be a map
          expect(
            output,
            contains("Map<String, String> get dumpedAttributes => {"),
          );
          expect(output, contains("'value': value.toString(),"));
        },
      );
    });

    test('attributeChangedCallback sets private field directly', () async {
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

            @Component(tag: 'my-counter')
            class Counter {
              static const tag = 'my-counter';

              @Attribute()
              int value = 0;

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

          final counterClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'Counter');

          final annotations = counterClass.metadata.annotations;
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
            counterClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart')),
          );

          // attributeChangedCallback should set the private field directly
          expect(output, contains("case 'value':"));
          expect(
            output,
            contains("_value = int.tryParse(newValue ?? '') ?? 0;"),
          );
        },
      );
    });

    test('requires file to end with _base.dart', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/component.dart': '''
            class Component {
              final String tag;
              const Component({required this.tag});
            }
          ''',
          'spark|lib/src/component/spark_component.dart': '''
            abstract class SparkComponent {
              String get tagName;
            }
          ''',
          'spark|lib/server.dart': '''
            library spark;
            export 'src/annotations/component.dart';
            export 'src/component/spark_component.dart';
          ''',
          'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/server.dart';

            @Component(tag: 'my-counter')
            class Counter {
              static const tag = 'my-counter';
            }
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final counterClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'Counter');

          final annotations = counterClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Component';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = ComponentGenerator();

          expect(
            () => generator.generateForAnnotatedElement(
              counterClass,
              constantReader,
              SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
            ),
            throwsA(isA<InvalidGenerationSourceError>()),
          );
        },
      );
    });

    test('supports custom attribute names', () async {
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

            @Component(tag: 'my-counter')
            class Counter {
              static const tag = 'my-counter';

              @Attribute(name: 'counter-value')
              int value = 0;

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

          final counterClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'Counter');

          final annotations = counterClass.metadata.annotations;
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
            counterClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart')),
          );

          // observedAttributes should use custom name
          expect(output, contains("const ['counter-value']"));

          // attributeChangedCallback should use custom name
          expect(output, contains("case 'counter-value':"));
        },
      );
    });

    test('handles multiple attributes', () async {
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

            @Component(tag: 'my-counter')
            class Counter {
              static const tag = 'my-counter';

              @Attribute()
              int count = 0;

              @Attribute()
              String label = 'Count';

              @Attribute()
              bool enabled = true;

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

          final counterClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'Counter');

          final annotations = counterClass.metadata.annotations;
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
            counterClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart')),
          );

          // Should generate reactive setters for all fields
          expect(output, contains('set count(int v)'));
          expect(output, contains('set label(String v)'));
          expect(output, contains('set enabled(bool v)'));

          // Each setter should call scheduleUpdate
          final scheduleUpdateCount = 'scheduleUpdate();'
              .allMatches(output)
              .length;
          expect(scheduleUpdateCount, greaterThanOrEqualTo(3));
        },
      );
    });

    test('regex pattern matches method declarations, not method calls', () {
      // This is a unit test for the fix where method calls like _handleSubmit()
      // inside other methods were incorrectly being matched as method definitions

      const testCode = '''
class ContactForm {
  bool isSubmitting = false;

  Element render() {
    return div([
      button(
        onClick: (_) => _handleSubmit(),
        [isSubmitting ? 'Sending...' : 'Send Message'],
      ),
    ]);
  }

  void _handleSubmit() {
    isSubmitting = true;
  }

  void anotherMethod() {
    _handleSubmit();
  }
}
''';

      // The pattern should match actual method declarations
      // Pattern must have at least one of: annotation, modifier, or return type before method name
      // This prevents matching method calls that happen to be at the start of a line
      final methodPattern = RegExp(
        // Match start of line, followed by whitespace
        r'(?:^|\n)\s*'
        // At least one of: annotation, modifier, or (return type + space)
        // Use a positive lookahead to ensure something is there before the method name
        r'(?=(?:@\w+\s+|(?:static|const|final|late|override)\s+|\w+(?:<[^>]+>)?(?:\?)?\s+))'
        // Now match the actual annotations/modifiers/return type
        r'(?:@\w+\s+)*(?:(?:static|const|final|late|override)\s+)*(?:\w+(?:<[^>]+>)?(?:\?)?\s+)?'
        '${RegExp.escape('_handleSubmit')}'
        r'\s*\(',
        multiLine: true,
      );

      final matches = methodPattern.allMatches(testCode);

      // Should match exactly once - the actual method definition "void _handleSubmit()"
      // Should NOT match the method calls inside render() or anotherMethod()
      expect(
        matches.length,
        equals(1),
        reason: 'Should only match the method definition, not method calls',
      );

      // Verify the match is the actual declaration
      final match = matches.first;
      final matchedText = testCode.substring(match.start, match.end);
      expect(matchedText.trim(), contains('void _handleSubmit('));
      expect(matchedText.trim(), isNot(contains('onClick')));
    });
  });
}
