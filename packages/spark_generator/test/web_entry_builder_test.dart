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
    test('generates web entry for page with components', () async {
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
          'a|lib/pages/home_page.dart': '''
          import 'package:spark_framework/spark.dart';
          
          class Component {
             final String tag;
             final Function factory;
             const Component(this.tag, this.factory);
          }
          
          @Page(path: '/')
          class HomePage extends SparkPage<void> {
            @override
            List<Component> get components => [Component('test-comp', () {})];
          }
        ''',
        },
        (resolver) async {
          final inputId = AssetId('a', 'lib/pages/home_page.dart');
          final buildStep = MockBuildStep(inputId, resolver);
          final builder = WebEntryBuilder();

          await builder.build(buildStep);

          final outputId = AssetId('a', 'web/home_page.dart');
          expect(buildStep.outputs, contains(outputId));
          expect(buildStep.outputs[outputId], contains('hydrateComponents'));
          expect(
            buildStep.outputs[outputId],
            contains('HomePage().components'),
          );
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
          final buildStep = MockBuildStep(inputId, resolver);
          final builder = WebEntryBuilder();

          await builder.build(buildStep);

          final outputId = AssetId('a', 'web/simple_page.dart');
          expect(buildStep.outputs, isNot(contains(outputId)));
        },
      );
    });
    test('generates web entry for page inheriting components', () async {
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
          'a|lib/pages/inheritance_page.dart': '''
          import 'package:spark_framework/spark.dart';
          
          class Component {
             final String tag;
             final Function factory;
             const Component(this.tag, this.factory);
          }
          
          abstract class ParentPage extends SparkPage<void> {
            @override
            List<Component> get components => [Component('test-comp', () {})];
          }

          @Page(path: '/child')
          class ChildPage extends ParentPage {
             // Inherits components
          }
        ''',
        },
        (resolver) async {
          final inputId = AssetId('a', 'lib/pages/inheritance_page.dart');
          final buildStep = MockBuildStep(inputId, resolver);
          final builder = WebEntryBuilder();

          await builder.build(buildStep);

          final outputId = AssetId('a', 'web/inheritance_page.dart');
          expect(buildStep.outputs, contains(outputId));
          expect(
            buildStep.outputs[outputId],
            contains('ChildPage().components'),
          );
        },
      );
    });
  });
}
