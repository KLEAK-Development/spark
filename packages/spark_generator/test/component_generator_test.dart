import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spark_generator/src/component_generator.dart';
import 'package:test/test.dart';
import 'dart:convert';

class SimpleBuildStep implements BuildStep {
  @override
  final AssetId inputId;
  final Map<String, String> sources;
  SimpleBuildStep(this.inputId, this.sources);

  @override
  Future<String> readAsString(AssetId id, {Encoding encoding = utf8}) async {
    final key = '${id.package}|${id.path}';
    if (sources.containsKey(key)) return sources[key]!;
    // Fallback for resolveSources internal structure if needed
    final altKey = id.path;
    if (sources.containsKey(altKey)) return sources[altKey]!;
    throw AssetNotFoundException(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ComponentGenerator', () {
    test(
      'generates complete reactive class with private fields and setters',
      () async {
        final sources = {
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
        };

        await resolveSources(sources, (resolver) async {
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
          final output = await generator.generateForAnnotatedElement(
            counterClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
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
        });
      },
    );

    test('generates syncAttributes using field access', () async {
      final sources = {
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
      };

      await resolveSources(sources, (resolver) async {
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
        final output = await generator.generateForAnnotatedElement(
          counterClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
        );

        // syncAttributes should use field access
        expect(output, contains("setAttr('value', value.toString());"));
      });
    });

    test('generates dumpedAttributes map', () async {
      final sources = {
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
      };

      await resolveSources(sources, (resolver) async {
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
        final output = await generator.generateForAnnotatedElement(
          counterClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
        );

        // dumpedAttributes should be a map
        expect(
          output,
          contains("Map<String, String> get dumpedAttributes => {"),
        );
        expect(output, contains("'value': value.toString(),"));
      });
    });

    test('attributeChangedCallback sets private field directly', () async {
      final sources = {
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
      };

      await resolveSources(sources, (resolver) async {
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
        final output = await generator.generateForAnnotatedElement(
          counterClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
        );

        // attributeChangedCallback should set the private field directly
        expect(output, contains("case 'value':"));
        expect(output, contains("_value = int.tryParse(newValue ?? '') ?? 0;"));
      });
    });

    test('requires file to end with _base.dart', () async {
      final sources = {
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
      };

      await resolveSources(sources, (resolver) async {
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
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart'), sources),
          ),
          throwsA(isA<InvalidGenerationSourceError>()),
        );
      });
    });

    test('supports custom attribute names', () async {
      final sources = {
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
      };

      await resolveSources(sources, (resolver) async {
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
        final output = await generator.generateForAnnotatedElement(
          counterClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
        );

        // observedAttributes should use custom name
        expect(output, contains("const ['counter-value']"));

        // attributeChangedCallback should use custom name
        expect(output, contains("case 'counter-value':"));
      });
    });

    test('handles multiple attributes', () async {
      final sources = {
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
      };

      await resolveSources(sources, (resolver) async {
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
        final output = await generator.generateForAnnotatedElement(
          counterClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
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
      });
    });

    test('preserves non-@Attribute fields with fallback declaration', () async {
      final sources = {
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

              int _clickCount = 0;

              Element render() {
                return div([]);
              }
            }

            class Element {}
            Element div(List children) => Element();
          ''',
      };

      await resolveSources(sources, (resolver) async {
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
        final output = await generator.generateForAnnotatedElement(
          counterClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
        );

        // Non-@Attribute field should be preserved (fallback declaration)
        // Note: default values may not be available via computeConstantValue()
        // in test context, so the field is emitted without initializer
        expect(output, contains('String label'));

        // Private non-@Attribute field should also be preserved
        expect(output, contains('int _clickCount'));

        // Non-@Attribute fields should NOT get reactive getter/setter
        expect(output, isNot(contains('String get label =>')));
        expect(output, isNot(contains('set label(String v)')));
        expect(output, isNot(contains('int get _clickCount =>')));

        // @Attribute field should still have reactive getter/setter
        expect(output, contains('int get value => _value'));
        expect(output, contains('set value(int v)'));
      });
    });

    test('preserves user-defined getters and setters', () async {
      final sources = {
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

            @Component(tag: 'my-widget')
            class MyWidget {
              static const tag = 'my-widget';

              @Attribute()
              int value = 0;

              @Attribute()
              String label = 'Count';

              String get displayText => label;

              bool get _isValid => value > 0;

              set customValue(int v) {
                value = v;
              }

              Element render() {
                return div([]);
              }
            }

            class Element {}
            Element div(List children) => Element();
          ''',
      };

      await resolveSources(sources, (resolver) async {
        final libraryElement = await resolver.libraryFor(
          AssetId('a', 'lib/test_lib_base.dart'),
        );

        final widgetClass = libraryElement.children
            .whereType<ClassElement>()
            .firstWhere((e) => e.name == 'MyWidget');

        final annotations = widgetClass.metadata.annotations;
        final annotation = annotations.firstWhere((a) {
          final element = a.element;
          final enclosing = element?.enclosingElement;
          return enclosing?.name == 'Component';
        });
        final constantReader = ConstantReader(
          annotation.computeConstantValue(),
        );

        final generator = ComponentGenerator();
        final output = await generator.generateForAnnotatedElement(
          widgetClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
        );

        // Generator should NOT crash when processing user getters/setters
        expect(output, contains('class MyWidget extends SparkComponent'));

        // @Attribute getters/setters should be generated (reactive)
        expect(output, contains('int get value => _value'));
        expect(output, contains('set value(int v)'));
        expect(output, contains('String get label => _label'));
        expect(output, contains('set label(String v)'));

        // There should be exactly one getter for each @Attribute
        final valueGetterCount = RegExp(
          r'get value\b',
        ).allMatches(output).length;
        expect(
          valueGetterCount,
          equals(1),
          reason: 'Should have exactly one getter for value',
        );

        final valueSetterCount = RegExp(
          r'set value\b',
        ).allMatches(output).length;
        expect(
          valueSetterCount,
          equals(1),
          reason: 'Should have exactly one setter for value',
        );

        // tagName should appear exactly once (generated, not duplicated)
        final tagNameCount = RegExp(r'get tagName\b').allMatches(output).length;
        expect(
          tagNameCount,
          equals(1),
          reason: 'Should have exactly one tagName getter',
        );
      });
    });

    test('constructor forwards non-@Attribute params to fields', () async {
      final sources = {
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

              Counter({
                this.value = 0,
                this.label = 'Count',
              });

              @Attribute()
              int value;

              String label;

              Element render() {
                return div([]);
              }
            }

            class Element {}
            Element div(List children) => Element();
          ''',
      };

      await resolveSources(sources, (resolver) async {
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
        final output = await generator.generateForAnnotatedElement(
          counterClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
        );

        // @Attribute field should use private backing field
        expect(output, contains('_value = value'));

        // Non-@Attribute field should be forwarded directly
        expect(output, contains('this.label = label'));

        // Constructor should include both params
        expect(output, contains('int value'));
        expect(output, contains('String label'));
      });
    });

    test('does not preserve reserved method names', () async {
      final sources = {
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

              void customMethod() {}

              Element render() {
                return div([]);
              }
            }

            class Element {}
            Element div(List children) => Element();
          ''',
      };

      await resolveSources(sources, (resolver) async {
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
        final output = await generator.generateForAnnotatedElement(
          counterClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
        );

        // Generator should complete without error
        expect(output, contains('class Counter extends SparkComponent'));

        // Generated methods should appear exactly once
        expect(
          RegExp(r'void syncAttributes\(\)').allMatches(output).length,
          equals(1),
          reason: 'syncAttributes should appear once',
        );
        expect(
          RegExp(r'void attributeChangedCallback\(').allMatches(output).length,
          equals(1),
          reason: 'attributeChangedCallback should appear once',
        );
      });
    });

    test('does not emit synthetic field for explicit getter', () async {
      final sources = {
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

            @Component(tag: 'my-widget')
            class MyWidget {
              static const tag = 'my-widget';

              @Attribute()
              int value = 0;

              String get displayText => 'hello';

              Element render() {
                return div([]);
              }
            }

            class Element {}
            Element div(List children) => Element();
          ''',
      };

      await resolveSources(sources, (resolver) async {
        final libraryElement = await resolver.libraryFor(
          AssetId('a', 'lib/test_lib_base.dart'),
        );

        final widgetClass = libraryElement.children
            .whereType<ClassElement>()
            .firstWhere((e) => e.name == 'MyWidget');

        final annotations = widgetClass.metadata.annotations;
        final annotation = annotations.firstWhere((a) {
          final element = a.element;
          final enclosing = element?.enclosingElement;
          return enclosing?.name == 'Component';
        });
        final constantReader = ConstantReader(
          annotation.computeConstantValue(),
        );

        final generator = ComponentGenerator();
        final output = await generator.generateForAnnotatedElement(
          widgetClass,
          constantReader,
          SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
        );

        // Should NOT emit a bare field declaration for a getter-backed property
        // The analyzer creates synthetic FieldElement for explicit getters, and
        // the generator must skip those to avoid "already declared" errors.
        expect(
          output,
          isNot(contains('String displayText;')),
          reason: 'Should not emit synthetic field for explicit getter',
        );

        // Should still generate the class correctly
        expect(output, contains('class MyWidget extends SparkComponent'));
      });
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
        r'(?:^|\n)\s*'
        r'(?:@[\w\.]+\s*(?:\([^)]*\))?\s+)*'
        r'(?:'
        r'(?:(?:static|const|final|late|override)\s+)+'
        r'|'
        r'(?:(?!(?:if|else|for|while|switch|return)\b)[a-zA-Z_]\w*(?:<[^>]+>)?(?:\?)?\s+)'
        r')'
        '\\b${RegExp.escape('_handleSubmit')}\\b'
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

    test('setter regex pattern matches setter declarations', () {
      const testCode = '''
class MyWidget {
  int _value = 0;

  set customValue(int v) {
    _value = v;
  }

  set arrowSetter(int v) => _value = v;

  void someMethod() {
    customValue = 42;
  }
}
''';

      final setterPattern = RegExp(
        r'\bset\s+' + RegExp.escape('customValue') + r'\s*\(',
        multiLine: true,
      );

      final matches = setterPattern.allMatches(testCode);

      // Should match exactly once - the setter declaration
      expect(
        matches.length,
        equals(1),
        reason: 'Should match the setter declaration',
      );

      // Verify it matches the declaration, not the assignment
      final match = matches.first;
      final matchedText = testCode.substring(match.start, match.end);
      expect(matchedText, contains('set customValue('));

      // Arrow setter should also be matchable
      final arrowPattern = RegExp(
        r'\bset\s+' + RegExp.escape('arrowSetter') + r'\s*\(',
        multiLine: true,
      );

      expect(
        arrowPattern.allMatches(testCode).length,
        equals(1),
        reason: 'Should match the arrow setter declaration',
      );
    });

    test('field regex pattern matches field declarations', () {
      const testCode = '''
class MyWidget {
  int counter = 0;
  String _name = 'default';
  late bool isReady;
  final List<String> items = [];
  double? nullableField;

  void someMethod() {
    counter = 42;
    _name = 'updated';
  }
}
''';

      // Test matching a simple field
      final counterPattern = RegExp(
        r'(?:^|\n)\s*'
        r'(?:(?:late|final|const)\s+)*'
        r'(?:\w+(?:<[^>]*>)?(?:\?)?\s+)'
        '${RegExp.escape('counter')}'
        r'\s*[;=]',
        multiLine: true,
      );

      expect(
        counterPattern.allMatches(testCode).length,
        equals(1),
        reason: 'Should match the int counter field declaration',
      );

      // Test matching a private field
      final namePattern = RegExp(
        r'(?:^|\n)\s*'
        r'(?:(?:late|final|const)\s+)*'
        r'(?:\w+(?:<[^>]*>)?(?:\?)?\s+)'
        '${RegExp.escape('_name')}'
        r'\s*[;=]',
        multiLine: true,
      );

      expect(
        namePattern.allMatches(testCode).length,
        equals(1),
        reason: 'Should match the private String _name field declaration',
      );

      // Test matching a late field
      final latePattern = RegExp(
        r'(?:^|\n)\s*'
        r'(?:(?:late|final|const)\s+)*'
        r'(?:\w+(?:<[^>]*>)?(?:\?)?\s+)'
        '${RegExp.escape('isReady')}'
        r'\s*[;=]',
        multiLine: true,
      );

      expect(
        latePattern.allMatches(testCode).length,
        equals(1),
        reason: 'Should match the late bool isReady field declaration',
      );

      // Test matching a generic field
      final genericPattern = RegExp(
        r'(?:^|\n)\s*'
        r'(?:(?:late|final|const)\s+)*'
        r'(?:\w+(?:<[^>]*>)?(?:\?)?\s+)'
        '${RegExp.escape('items')}'
        r'\s*[;=]',
        multiLine: true,
      );

      expect(
        genericPattern.allMatches(testCode).length,
        equals(1),
        reason: 'Should match the final List<String> items field declaration',
      );

      // Test matching a nullable field
      final nullablePattern = RegExp(
        r'(?:^|\n)\s*'
        r'(?:(?:late|final|const)\s+)*'
        r'(?:\w+(?:<[^>]*>)?(?:\?)?\s+)'
        '${RegExp.escape('nullableField')}'
        r'\s*[;=]',
        multiLine: true,
      );

      expect(
        nullablePattern.allMatches(testCode).length,
        equals(1),
        reason: 'Should match the double? nullableField declaration',
      );
    });

    test(
      'Regression: does not mis-extract methods when calls are at start of line',
      () async {
        final sources = {
          'spark|lib/src/annotations/component.dart': '''
            class Component {
              final String tag;
              const Component({required this.tag});
            }
            class Attribute {
              final String? name;
              const Attribute({this.name});
            }
          ''',
          'spark|lib/src/component/spark_component.dart': '''
            abstract class SparkComponent {
              void scheduleUpdate() {}
              String get tagName;
              List<String> get observedAttributes => const [];
              void syncAttributes() {}
              Map<String, String> get dumpedAttributes => {};
              void attributeChangedCallback(String name, String? oldValue, String? newValue) {}
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

            @Component(tag: 'oauth-apps-card')
            class OAuthAppsCard {
              static const tag = 'oauth-apps-card';

              Element render() {
                final activeTab = 'connected';
                final grants = [];
                final apps = [];

                return div([
                  if (activeTab == 'connected')
                    _renderConnectedTab(grants)
                  else
                    _renderMyAppsTab(apps),
                ]);
              }

              Element _renderConnectedTab(List grants) {
                return div(['Connected']);
              }

              Element _renderMyAppsTab(List apps) {
                return div(['My Apps']);
              }
            }

            class Element {}
            Element div(List children) => Element();
          ''',
        };

        await resolveSources(sources, (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib_base.dart'),
          );

          final cardClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'OAuthAppsCard');

          final annotations = cardClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Component';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = ComponentGenerator();
          final output = await generator.generateForAnnotatedElement(
            cardClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib_base.dart'), sources),
          );

          final connectedTabCount = RegExp(
            r'Element _renderConnectedTab\(',
          ).allMatches(output).length;
          expect(
            connectedTabCount,
            equals(1),
            reason:
                'Should have exactly one declaration of _renderConnectedTab',
          );

          final myAppsTabCount = RegExp(
            r'Element _renderMyAppsTab\(',
          ).allMatches(output).length;
          expect(
            myAppsTabCount,
            equals(1),
            reason: 'Should have exactly one declaration of _renderMyAppsTab',
          );

          expect(
            output,
            contains('else\n                    _renderMyAppsTab(apps),'),
          );
        });
      },
    );
  });
}
