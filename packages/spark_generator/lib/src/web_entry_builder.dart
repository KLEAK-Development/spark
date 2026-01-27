import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

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
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) return;

    final lib = await buildStep.inputLibrary;
    final reader = LibraryReader(lib);

    final pages = reader.annotatedWith(_pageChecker);
    if (pages.isEmpty) return;

    for (final page in pages) {
      final element = page.element;
      if (element is! ClassElement) continue;

      // Use getGetter to check if the class declares the getter
      final componentsGetter = element.getGetter('components');

      // Ensure it's not inherited from SparkPage (actually getGetter returns declared one primarily,
      // but checking enclosingName is safe)
      final hasComponents =
          componentsGetter != null &&
          componentsGetter.enclosingElement.name != 'SparkPage';

      if (!hasComponents) continue;

      final session = element.session;
      if (session == null) continue;

      final parsedLib = await session.getResolvedLibraryByElement(
        element.library,
      );
      if (parsedLib is! ResolvedLibraryResult) continue;

      MethodDeclaration? getterNode;
      // Search all units for the getter declaration (avoiding Element.source usage)
      for (final unitResult in parsedLib.units) {
        for (final decl in unitResult.unit.declarations) {
          if (decl is ClassDeclaration &&
              decl.namePart.typeName.lexeme ==
                  componentsGetter.enclosingElement.name) {
            for (final member in (decl.body as BlockClassBody).members) {
              if (member is MethodDeclaration &&
                  member.isGetter &&
                  member.name.lexeme == 'components') {
                getterNode = member;
                break;
              }
            }
          }
          if (getterNode != null) break;
        }
        if (getterNode != null) break;
      }

      if (getterNode == null) continue;

      final body = getterNode.body;
      if (body is! ExpressionFunctionBody) continue;

      final list = body.expression;
      if (list is! ListLiteral) continue;

      if (list.elements.isEmpty) continue;

      final componentImports = <String>{};
      final components = <MapEntry<String, String>>[];

      for (final item in list.elements) {
        final referencedClasses = _findReferencedClasses(item);

        for (final componentElement in referencedClasses) {
          final tagField = componentElement.getField('tag');
          if (tagField == null || !tagField.isStatic) continue;

          final constant = tagField.computeConstantValue();
          if (constant == null) continue;
          final tagValue = constant.toStringValue();
          if (tagValue == null) continue;

          // Use library identifier as import URI (definingCompilationUnit is missing)
          final importUri = componentElement.library.identifier;

          componentImports.add(importUri);
          final name = componentElement.name;
          if (name == null) continue;
          components.add(MapEntry(tagValue, name));
        }
      }

      if (components.isEmpty) continue;

      final outputId = AssetId(
        buildStep.inputId.package,
        'web/${buildStep.inputId.pathSegments.last}',
      );

      final content = _generateWebEntry(componentImports, components);
      await buildStep.writeAsString(
        outputId,
        DartFormatter(
          languageVersion: DartFormatter.latestLanguageVersion,
        ).format(content),
      );
    }
  }

  Set<ClassElement> _findReferencedClasses(AstNode node) {
    final classes = <ClassElement>{};

    // Simple recursive visitor closure
    void visit(AstNode n) {
      if (n is SimpleIdentifier) {
        final element = n.element;
        if (element is ClassElement && !element.isAbstract) {
          classes.add(element);
        }
      }
      n.childEntities.whereType<AstNode>().forEach(visit);
    }

    visit(node);
    return classes;
  }

  String _generateWebEntry(
    Set<String> componentImports,
    List<MapEntry<String, String>> components,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln("import 'package:spark_framework/spark.dart';");

    // imports
    for (final importPath in componentImports) {
      buffer.writeln("import '$importPath';");
    }

    buffer.writeln();
    buffer.writeln('void main() {');
    buffer.writeln('  hydrateComponents({');
    for (final component in components) {
      buffer.writeln("    '${component.key}': ${component.value}.new,");
    }
    buffer.writeln('  });');
    buffer.writeln('}');

    return buffer.toString();
  }
}
