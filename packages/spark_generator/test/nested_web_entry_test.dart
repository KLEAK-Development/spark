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

  MockBuildStep(this.inputId, this._resolver);

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
  group('WebEntryBuilder Nested & Imports', () {
    test('generates web entry for nested page with correct path and imports', () async {
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
          'spark_framework|lib/spark.dart': '''
          library spark;
          export 'src/annotations/page.dart';
          export 'src/annotations/component.dart';
          export 'src/page/spark_page.dart';
          export 'src/component/spark_component.dart';
        ''',
          // A component using _base.dart convention
          'a|lib/components/nested/counter_base.dart': '''
          import 'package:spark_framework/spark.dart';

          @Component(tag: Counter.tag)
          class Counter {
            static const tag = 'nested-counter';
          }
        ''',
          // A page in a nested directory using the component
          'a|lib/pages/docs/intro.dart': '''
          import 'package:spark_framework/spark.dart';
          import '../../components/nested/counter_base.dart';

          class ComponentInfo {
             final String tag;
             final Function factory;
             const ComponentInfo(this.tag, this.factory);
          }

          @Page(path: '/docs/intro')
          class IntroPage extends SparkPage<void> {
            @override
            List<ComponentInfo> get components => [ComponentInfo(Counter.tag, () {})];
          }
        ''',
        },
        (resolver) async {
          final inputId = AssetId('a', 'lib/pages/docs/intro.dart');
          final buildStep = MockBuildStep(inputId, resolver);
          final builder = WebEntryBuilder();

          await builder.build(buildStep);

          // Expect output to be in web/docs/intro.dart (preserving structure)
          final outputId = AssetId('a', 'web/docs/intro.dart');

          // Debug prints if it fails
          if (!buildStep.outputs.containsKey(outputId)) {
            print('Actual outputs: ${buildStep.outputs.keys}');
          }

          expect(buildStep.outputs, contains(outputId));

          final output = buildStep.outputs[outputId]!;

          // Check that it imports the .impl.dart version of the component
          // The source was counter_base.dart, so we expect counter.impl.dart or counter_base.impl.dart
          // Based on component_generator, it generates .impl.dart extension on imports
          // Wait, component_generator generates extensions on the FILE.
          // If file is `counter_base.dart`, build.yaml says it outputs `.impl.dart`.
          // And traditionally simple imports might be replacing `_base.dart` with `.impl.dart`.
          // Let's assert we see `.impl.dart` and NOT `_base.dart`

          expect(
            output,
            contains(
              "import 'package:a/components/nested/counter_base.impl.dart';",
            ),
            reason: 'Should import the implementation file, not the base file',
          );

          expect(
            output,
            isNot(contains("counter_base.dart")),
            reason: 'Should NOT import the base file directly',
          );
        },
      );
    });
  });
}
