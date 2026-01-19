import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

/// Builder that generates a web entry point for each @Page.
///
/// For a page class `HomePage`, generates `web/homepage.dart`
/// which registers and hydrates components.
class WebEntryBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    'lib/pages/{{name}}.dart': ['web/{{name}}.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;

    final lib = await buildStep.inputLibrary;
    final reader = LibraryReader(lib);

    final pages = reader.annotatedWith(
      TypeChecker.fromUrl(
        'package:spark_framework/src/annotations/page.dart#Page',
      ),
    );
    if (pages.isEmpty) return;

    for (final page in pages) {
      final element = page.element;
      final className = element.name;
      if (className == null) continue;

      // Check if the page overrides the components getter
      // Check if the page overrides the components getter
      // We want to generate the script if the page or any of its parents (except SparkPage)
      // defines components.
      final componentsGetter = (element as ClassElement).lookUpGetter(
        name: 'components',
        library: element.library,
      );

      final hasComponents =
          componentsGetter != null &&
          componentsGetter.enclosingElement.name != 'SparkPage';

      if (!hasComponents) {
        log.info(
          'Skipping ${element.name} - no components override found. Enclosing: ${(element).lookUpGetter(name: 'components', library: element.library)?.enclosingElement.name}',
        );
        continue;
      }
      log.info('Generating entry for ${element.name}');

      final inputId = buildStep.inputId;
      final relativePath = inputId.path.substring('lib/pages/'.length);
      // relativePath is like "docs/introduction.dart" or "home_page.dart"

      final outputId = AssetId(inputId.package, 'web/$relativePath');

      final content = _generateWebEntry(className, inputId.uri.toString());
      await buildStep.writeAsString(outputId, content);
    }
  }

  String _generateWebEntry(String className, String importPath) {
    final library = Library(
      (b) => b
        ..comments.add('GENERATED CODE - DO NOT MODIFY BY HAND')
        ..directives.addAll([
          Directive.import('package:spark_framework/spark.dart'),
          Directive.import(importPath),
        ])
        ..body.add(
          Method(
            (b) => b
              ..name = 'main'
              ..returns = refer('void')
              ..body = Block(
                (b) => b
                  ..statements.add(
                    Code('''
            // Register and hydrate all components used on this page.
            // This entry point is auto-generated for $className.
            hydrateComponents(
              // Instantiate the page to access its components getter
              Map.fromEntries(
                $className().components.map((c) => MapEntry(c.tag, c.factory))
              ),
            );
          '''),
                  ),
              ),
          ),
        ),
    );

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format('${library.accept(DartEmitter())}');
  }
}
