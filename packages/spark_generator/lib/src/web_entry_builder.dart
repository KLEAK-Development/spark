import 'dart:async';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

/// Builder that generates web entry points for @Page classes.
///
/// For a page class `HomePage` with components, generates:
/// - `web/home_page.dart` - The page entry point for hydration
///
/// This builder relies on component_generator.dart generating the `*$Component`
/// wrapper classes. It generates a simple main() that calls hydrateComponents()
/// using the page's components getter.
class WebEntryBuilder implements Builder {
  @override
  Map<String, List<String>> get buildExtensions => {
    'lib/pages/{{name}}.dart': ['web/{{name}}.dart'],
  };

  final _pageChecker = TypeChecker.fromUrl(
    'package:spark_framework/src/annotations/page.dart#Page',
  );

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;

    final lib = await buildStep.inputLibrary;
    final reader = LibraryReader(lib);

    final pages = reader.annotatedWith(_pageChecker);
    if (pages.isEmpty) return;

    for (final page in pages) {
      final element = page.element;
      final className = element.name;
      if (className == null) continue;

      // Check if the page overrides the components getter
      final componentsGetter = (element as ClassElement).lookUpGetter(
        name: 'components',
        library: element.library,
      );

      final hasComponents =
          componentsGetter != null &&
          componentsGetter.enclosingElement.name != 'SparkPage';

      if (!hasComponents) {
        log.info('Skipping ${element.name} - no components override found.');
        continue;
      }

      log.info('Generating web entry for ${element.name}');

      // Generate the web entry point
      final inputId = buildStep.inputId;
      final relativePath = inputId.path.substring('lib/pages/'.length);
      final outputId = AssetId(inputId.package, 'web/$relativePath');

      final content = _generateWebEntry(className, inputId.uri.toString());
      await buildStep.writeAsString(outputId, content);
    }
  }

  /// Generates a simple web entry point that uses the page's components getter.
  String _generateWebEntry(String pageClassName, String pageImportPath) {
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln("import 'package:spark_framework/spark.dart';");
    buffer.writeln("import '$pageImportPath';");
    buffer.writeln();
    buffer.writeln('void main() {');
    buffer.writeln('  hydrateComponents(');
    buffer.writeln('    Map.fromEntries(');
    buffer.writeln(
      '      $pageClassName().components.map((c) => MapEntry(c.tag, c.factory)),',
    );
    buffer.writeln('    ),');
    buffer.writeln('  );');
    buffer.writeln('}');

    return DartFormatter(
      languageVersion: DartFormatter.latestLanguageVersion,
    ).format(buffer.toString());
  }
}
