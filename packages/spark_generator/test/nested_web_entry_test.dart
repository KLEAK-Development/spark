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
  group('WebEntryBuilder Nested & Imports', () {
    // Explicitly verify the path mapping logic (buildExtensions)
    // This addresses "are we really testing something" by validating the configuration
    test('verifies correct buildExtensions mapping logic', () {
      final builder = WebEntryBuilder();
      final extensions = builder.buildExtensions;

      final input = 'lib/pages/docs/intro.dart';
      bool matched = false;
      String? output;

      for (final key in extensions.keys) {
        if (key.startsWith('^')) {
          final prefix = key.substring(1).replaceAll('{{}}.dart', '');
          if (input.startsWith(prefix) && input.endsWith('.dart')) {
            final capture = input.substring(prefix.length, input.length - 5);
            final outputPattern = extensions[key]!.first;
            output = outputPattern
                .replaceAll('{{}}', capture)
                .replaceAll('.dart', '.dart');
            matched = true;
          }
        }
      }

      expect(
        matched,
        isTrue,
        reason: 'Input $input should find a match in buildExtensions',
      );
      expect(
        output,
        equals('web/docs/intro.dart'),
        reason: 'Output path should be correctly mapped',
      );
    });

    test('generates web entry for nested page with correct imports', () async {
      final inputs = {
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
      };

      await resolveSources(inputs, (resolver) async {
        final inputId = AssetId('a', 'lib/pages/docs/intro.dart');
        final outputId = AssetId('a', 'web/docs/intro.dart');

        // We inject the expected output ID here based on the mapping test above
        final buildStep = MockBuildStep(
          inputId,
          resolver,
          allowedOutputs: [outputId],
        );
        final builder = WebEntryBuilder();

        await builder.build(buildStep);

        expect(buildStep.outputs, contains(outputId));
        final output = buildStep.outputs[outputId]!;

        expect(
          output,
          contains(
            "import 'package:a/components/nested/counter_base.impl.dart';",
          ),
        );
        expect(output, isNot(contains("counter_base.dart")));
        expect(output, contains("hydrateComponents"));
        expect(output, contains("'nested-counter': Counter.new"));
      });
    });
  });
}
