import 'dart:async';
import 'dart:convert';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:spark_generator/src/web_entry_builder.dart';
import 'package:test/test.dart';
import 'package:analyzer/dart/element/element.dart';

class MockBuildStep implements BuildStep {
  @override
  final AssetId inputId;

  final Map<AssetId, String> outputs = {};

  // ignore: unused_field
  final Resolver _resolver;
  @override
  final Iterable<AssetId> allowedOutputs;

  MockBuildStep(this.inputId, this._resolver, {this.allowedOutputs = const []});

  @override
  Future<void> writeAsString(
    AssetId id,
    FutureOr<String> contents, {
    Encoding encoding = utf8,
  }) async {
    outputs[id] = await contents;
  }

  @override
  Resolver get resolver => _resolver;

  // Implement inputLibrary to return the library matching inputId
  @override
  Future<LibraryElement> get inputLibrary async {
    if (await resolver.isLibrary(inputId)) {
      return await resolver.libraryFor(inputId);
    }
    throw StateError('Not a library');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('WebEntryBuilder', () {
    test('generates web entry for page with @Component classes', () async {
      await resolveSources(
        {
          'spark_framework|lib/src/annotations/page.dart': '''
          class Page {
            const Page({required String path});
          }
        ''',
          'spark_framework|lib/src/annotations/component.dart': '''
          class Component {
            final String tag;
            const Component({required this.tag});
          }

          class Attribute {
            final String? name;
            final bool observable;
            const Attribute({this.name, this.observable = true});
          }
        ''',
          'spark_framework|lib/src/page/spark_page.dart': '''
           abstract class SparkPage<T> {
             List<dynamic> get components => [];
          }
        ''',
          'spark_framework|lib/src/component/spark_component.dart': '''
          abstract class SparkComponent {}
        ''',
          'spark_framework|lib/src/html/dsl.dart': '''
          class Element {}
        ''',
          'spark_framework|lib/src/style/style.dart': '''
          class Stylesheet {}
        ''',
          'spark_framework|lib/spark.dart': '''
          library spark;
          export 'src/annotations/page.dart';
          export 'src/annotations/component.dart';
          export 'src/page/spark_page.dart';
          export 'src/component/spark_component.dart';
          export 'src/html/dsl.dart';
          export 'src/style/style.dart';
        ''',
          'a|lib/components/counter.dart': '''
          import 'package:spark_framework/spark.dart';

          @Component(tag: Counter.tag)
          class Counter {
            static const tag = 'my-counter';

            @Attribute()
            int value = 0;

            Element render() => Element();
          }
        ''',
          'a|lib/pages/home_page.dart': '''
          import 'package:spark_framework/spark.dart';
          import '../components/counter.dart';

          class ComponentInfo {
             final String tag;
             final Function factory;
             const ComponentInfo(this.tag, this.factory);
          }

          @Page(path: '/')
          class HomePage extends SparkPage<void> {
            @override
            List<ComponentInfo> get components => [ComponentInfo(Counter.tag, () {})];
          }
        ''',
        },
        (resolver) async {
          final inputId = AssetId('a', 'lib/pages/home_page.dart');
          final outputId = AssetId('a', 'web/home_page.dart');
          final buildStep = MockBuildStep(
            inputId,
            resolver,
            allowedOutputs: [outputId],
          );
          final builder = WebEntryBuilder();

          await builder.build(buildStep);

          expect(buildStep.outputs, contains(outputId));

          final output = buildStep.outputs[outputId]!;

          // Check that it imports spark framework
          expect(output, contains('package:spark_framework/spark.dart'));

          // Check that it DOES NOT import the page
          expect(output, isNot(contains('package:a/pages/home_page.dart')));

          // Check that it has hydrateComponents call
          expect(output, contains('hydrateComponents'));

          // Check that it creates a main function
          expect(output, contains('void main()'));
        },
      );
    });

    test('does NOT generate web entry for page without components', () async {
      await resolveSources(
        {
          'spark_framework|lib/src/annotations/page.dart': '''
          class Page {
            const Page({required String path});
          }
        ''',
          'spark_framework|lib/src/page/spark_page.dart': '''
           abstract class SparkPage<T> {
             List<dynamic> get components => [];
          }
        ''',
          'spark_framework|lib/spark.dart': '''
          library spark;
          export 'src/annotations/page.dart';
          export 'src/page/spark_page.dart';
        ''',
          'a|lib/pages/simple_page.dart': '''
          import 'package:spark_framework/spark.dart';

          @Page(path: '/')
          class SimplePage extends SparkPage<void> {
             // No components override
          }
        ''',
        },
        (resolver) async {
          final inputId = AssetId('a', 'lib/pages/simple_page.dart');
          final buildStep = MockBuildStep(
            inputId,
            resolver,
            allowedOutputs: [AssetId('a', 'web/simple_page.dart')],
          );
          final builder = WebEntryBuilder();

          await builder.build(buildStep);

          // Should not generate output for pages without components
          expect(buildStep.outputs, isEmpty);
        },
      );
    });

    test('generates web entry with hydration logic', () async {
      await resolveSources(
        {
          'spark_framework|lib/src/annotations/page.dart': '''
          class Page {
            const Page({required String path});
          }
        ''',
          'spark_framework|lib/src/annotations/component.dart': '''
          class Component {
            final String tag;
            const Component({required this.tag});
          }

          class Attribute {
            final String? name;
            final bool observable;
            const Attribute({this.name, this.observable = true});
          }
        ''',
          'spark_framework|lib/src/page/spark_page.dart': '''
           abstract class SparkPage<T> {
             List<dynamic> get components => [];
          }
        ''',
          'spark_framework|lib/src/component/spark_component.dart': '''
          abstract class SparkComponent {}
        ''',
          'spark_framework|lib/src/html/dsl.dart': '''
          class Element {}
        ''',
          'spark_framework|lib/src/style/style.dart': '''
          class Stylesheet {}
        ''',
          'spark_framework|lib/spark.dart': '''
          library spark;
          export 'src/annotations/page.dart';
          export 'src/annotations/component.dart';
          export 'src/page/spark_page.dart';
          export 'src/component/spark_component.dart';
          export 'src/html/dsl.dart';
          export 'src/style/style.dart';
        ''',
          'a|lib/components/reactive_counter.dart': '''
          import 'package:spark_framework/spark.dart';

          @Component(tag: ReactiveCounter.tag)
          class ReactiveCounter {
            static const tag = 'reactive-counter';

            @Attribute()
            int count = 0;

            @Attribute(name: 'step-size')
            int step = 1;

            Element render() => Element();
          }
        ''',
          'a|lib/pages/reactive_page.dart': '''
          import 'package:spark_framework/spark.dart';
          import '../components/reactive_counter.dart';

          class ComponentInfo {
             final String tag;
             final Function factory;
             const ComponentInfo(this.tag, this.factory);
          }

          @Page(path: '/reactive')
          class ReactivePage extends SparkPage<void> {
            @override
            List<ComponentInfo> get components => [ComponentInfo(ReactiveCounter.tag, () {})];
          }
        ''',
        },
        (resolver) async {
          final inputId = AssetId('a', 'lib/pages/reactive_page.dart');
          final outputId = AssetId('a', 'web/reactive_page.dart');
          final buildStep = MockBuildStep(
            inputId,
            resolver,
            allowedOutputs: [outputId],
          );
          final builder = WebEntryBuilder();

          await builder.build(buildStep);

          expect(buildStep.outputs, contains(outputId));

          final output = buildStep.outputs[outputId]!;

          // Check for main hydration structure
          expect(output, contains('hydrateComponents'));
          // expect(output, contains('Map.fromEntries')); // Legacy
          // expect(output, contains('ReactivePage().components')); // Legacy
          // expect(output, contains('MapEntry(c.tag, c.factory)')); // Legacy
          expect(output, contains("'reactive-counter': ReactiveCounter.new"));
          // Wait, the hydration map only contains tag -> factory. Attributes are handled inside component.
          // Check imports
          expect(
            output,
            contains("import 'package:a/components/reactive_counter.dart';"),
          );
          expect(
            output,
            contains("import 'package:spark_framework/spark.dart';"),
          );
        },
      );
    });

    test('generates web entry with proper imports', () async {
      await resolveSources(
        {
          'spark_framework|lib/src/annotations/page.dart': '''
          class Page {
            const Page({required String path});
          }
        ''',
          'spark_framework|lib/src/annotations/component.dart': '''
          class Component {
            final String tag;
            const Component({required this.tag});
          }

          class Attribute {
            final String? name;
            final bool observable;
            const Attribute({this.name, this.observable = true});
          }
        ''',
          'spark_framework|lib/src/page/spark_page.dart': '''
           abstract class SparkPage<T> {
             List<dynamic> get components => [];
          }
        ''',
          'spark_framework|lib/src/component/spark_component.dart': '''
          abstract class SparkComponent {}
        ''',
          'spark_framework|lib/src/html/dsl.dart': '''
          class Element {}
        ''',
          'spark_framework|lib/src/style/style.dart': '''
          class Stylesheet {}
        ''',
          'spark_framework|lib/spark.dart': '''
          library spark;
          export 'src/annotations/page.dart';
          export 'src/annotations/component.dart';
          export 'src/page/spark_page.dart';
          export 'src/component/spark_component.dart';
          export 'src/html/dsl.dart';
          export 'src/style/style.dart';
        ''',
          'a|lib/components/styled_component.dart': '''
          import 'package:spark_framework/spark.dart';

          @Component(tag: StyledComponent.tag)
          class StyledComponent {
            static const tag = 'styled-component';

            Stylesheet get adoptedStyleSheets => Stylesheet();
            Element render() => Element();
          }
        ''',
          'a|lib/pages/styled_page.dart': '''
          import 'package:spark_framework/spark.dart';
          import '../components/styled_component.dart';

          class ComponentInfo {
             final String tag;
             final Function factory;
             const ComponentInfo(this.tag, this.factory);
          }

          @Page(path: '/styled')
          class StyledPage extends SparkPage<void> {
            @override
            List<ComponentInfo> get components => [ComponentInfo(StyledComponent.tag, () {})];
          }
        ''',
        },
        (resolver) async {
          final inputId = AssetId('a', 'lib/pages/styled_page.dart');
          final outputId = AssetId('a', 'web/styled_page.dart');
          final buildStep = MockBuildStep(
            inputId,
            resolver,
            allowedOutputs: [outputId],
          );
          final builder = WebEntryBuilder();

          await builder.build(buildStep);

          expect(buildStep.outputs, contains(outputId));

          final output = buildStep.outputs[outputId]!;

          // Check for proper imports
          expect(
            output,
            contains("import 'package:spark_framework/spark.dart'"),
          );
          expect(
            output,
            isNot(contains("import 'package:a/pages/styled_page.dart'")),
          );

          // Check for generated code header
          expect(output, contains('// GENERATED CODE'));
        },
      );
    });

    test(
      'generates web entry for page using dart:io without crashing',
      () async {
        await resolveSources(
          {
            'spark_framework|lib/src/annotations/page.dart': '''
            class Page {
              const Page({required String path});
            }
          ''',
            'spark_framework|lib/src/annotations/component.dart': '''
            class Component {
              final String tag;
              const Component({required this.tag});
            }
          ''',
            'spark_framework|lib/src/page/spark_page.dart': '''
            abstract class SparkPage<T> {
              List<dynamic> get components => [];
            }
          ''',
            'spark_framework|lib/src/component/spark_component.dart': '''
            abstract class SparkComponent {}
          ''',
            'spark_framework|lib/src/html/dsl.dart': '''
            class Element {}
          ''',
            'spark_framework|lib/src/style/style.dart': '''
            class Stylesheet {}
          ''',
            'spark_framework|lib/spark.dart': '''
            library spark;
            export 'src/annotations/page.dart';
            export 'src/annotations/component.dart';
            export 'src/page/spark_page.dart';
            export 'src/component/spark_component.dart';
            export 'src/html/dsl.dart';
            export 'src/style/style.dart';
          ''',
            'a|lib/components/safe_component.dart': '''
            import 'package:spark_framework/spark.dart';

            @Component(tag: SafeComponent.tag)
            class SafeComponent {
              static const tag = 'safe-component';
              Element render() => Element();
            }
          ''',
            'a|lib/pages/io_page.dart': '''
            import 'package:spark_framework/spark.dart';
            import 'dart:io'; // This should not poison the web entry
            import '../components/safe_component.dart';

            class ComponentInfo {
               final String tag;
               final Function factory;
               const ComponentInfo(this.tag, this.factory);
            }

            @Page(path: '/io')
            class IoPage extends SparkPage<void> {
              @override
              List<ComponentInfo> get components => [ComponentInfo(SafeComponent.tag, () {})];

              void doServerStuff() {
                File('foo.txt').readAsStringSync();
              }
            }
          ''',
          },
          (resolver) async {
            final inputId = AssetId('a', 'lib/pages/io_page.dart');
            final outputId = AssetId('a', 'web/io_page.dart');
            final buildStep = MockBuildStep(
              inputId,
              resolver,
              allowedOutputs: [outputId],
            );
            final builder = WebEntryBuilder();

            await builder.build(buildStep);

            expect(buildStep.outputs, contains(outputId));

            final output = buildStep.outputs[outputId]!;

            // Check that it imports spark framework
            expect(
              output,
              contains("import 'package:spark_framework/spark.dart';"),
            );

            // Check that it imports the component
            expect(
              output,
              contains("import 'package:a/components/safe_component.dart';"),
            );

            // Check that it DOES NOT import dart:io
            expect(output, isNot(contains("import 'dart:io'")));

            // Check that it DOES NOT import the page
            expect(
              output,
              isNot(contains("import 'package:a/pages/io_page.dart'")),
            );

            // Check that main exists
            expect(output, contains('void main()'));
          },
        );
      },
    );
  });
}
