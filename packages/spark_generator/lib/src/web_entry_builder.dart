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
    '^lib/pages/{{}}.dart': ['web/{{}}.dart'],
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

      // Use lookUpGetter to check if the class declares or inherits the getter
      final componentsGetter = element.lookUpGetter(
        name: 'components',
        library: element.library,
      );

      if (componentsGetter == null) continue;

      // Ensure it's not inherited from SparkPage
      final hasComponents =
          componentsGetter.enclosingElement.name != 'SparkPage';

      if (!hasComponents) continue;

      final getterDefiningClass = componentsGetter.enclosingElement;
      // Allow ClassElement or MixinElement
      if (getterDefiningClass is! ClassElement &&
          getterDefiningClass is! MixinElement) {
        continue;
      }

      final session = element.session;
      if (session == null) continue;

      final targetLibrary = getterDefiningClass.library;
      if (targetLibrary == null) continue;

      final parsedLib = await session.getResolvedLibraryByElement(
        targetLibrary,
      );
      if (parsedLib is! ResolvedLibraryResult) continue;

      AstNode? targetNode;
      // Search all units for the getter declaration (avoiding Element.source usage)
      for (final unitResult in parsedLib.units) {
        for (final decl in unitResult.unit.declarations) {
          final String? declName;
          final List<ClassMember> members;

          if (decl is ClassDeclaration) {
            declName = decl.namePart.typeName.lexeme;
            members = (decl.body as BlockClassBody).members;
          } else if (decl is MixinDeclaration) {
            declName = decl.name.lexeme;
            members = decl.body.members;
          } else {
            declName = null;
            members = const [];
          }

          if (declName != null && declName == getterDefiningClass.name) {
            for (final member in members) {
              if (member is MethodDeclaration &&
                  member.isGetter &&
                  member.name.lexeme == 'components') {
                targetNode = member;
                break;
              } else if (member is FieldDeclaration) {
                for (final field in member.fields.variables) {
                  if (field.name.lexeme == 'components') {
                    targetNode = field;
                    break;
                  }
                }
              }
            }
          }
          if (targetNode != null) break;
        }
        if (targetNode != null) break;
      }

      if (targetNode != null) {
        log.info('Found components definition in ${getterDefiningClass.name}');
      } else {
        log.warning(
          'Could not find source for components definition in ${getterDefiningClass.name} (Library: ${targetLibrary.identifier})',
        );
      }

      if (targetNode == null) continue;

      ListLiteral? list;

      if (targetNode is MethodDeclaration) {
        final body = targetNode.body;
        if (body is ExpressionFunctionBody) {
          if (body.expression is ListLiteral) {
            list = body.expression as ListLiteral;
          }
        } else if (body is BlockFunctionBody) {
          for (final statement in body.block.statements) {
            if (statement is ReturnStatement &&
                statement.expression is ListLiteral) {
              list = statement.expression as ListLiteral;
              break;
            }
          }
        }
      } else if (targetNode is VariableDeclaration) {
        if (targetNode.initializer is ListLiteral) {
          list = targetNode.initializer as ListLiteral;
        }
      }

      if (list == null) continue;

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

      final outputId = buildStep.allowedOutputs.single;

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
      // If the import is a base file, import the generated implementation instead
      final effectiveImport = importPath.endsWith('_base.dart')
          ? importPath.replaceAll(RegExp(r'\.dart$'), '.impl.dart')
          : importPath;
      buffer.writeln("import '$effectiveImport';");
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
