// ignore_for_file: deprecated_member_use

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
// Use absolute URI to avoid package:spark barrel file which imports web
// But we are in spark_generator package. use package:spark/src/annotations...
import 'package:spark_framework/server.dart';

/// Generator that processes @Component annotations for SparkComponents.
class ComponentGenerator extends GeneratorForAnnotation<Component> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    print('ComponentGenerator: Processing element ${element.name}');
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Component can only be applied to classes',
        element: element,
      );
    }

    final className = element.name;
    final buffer = StringBuffer();

    // Find all fields with @Attribute
    final attributes = <String, String>{}; // fieldName -> attrName

    for (final field in element.fields) {
      // Access annotations list via dynamic to bypass type issues with unknown Analyzer version
      final dynamic metadata = field.metadata; // dynamic access
      final annotations = (metadata as dynamic).annotations as List;

      for (final meta in annotations) {
        final value = (meta as dynamic).computeConstantValue();
        if (value == null) continue;

        final typeName = value.type?.element?.name;

        if (typeName == 'Attribute') {
          final nameField = value.getField('name');
          final nameOverride = nameField?.toStringValue();
          // Paranoid null checks
          // ignore: unnecessary_cast
          final safeFieldName = (field.name as String?);
          if (safeFieldName != null) {
            final attrName = nameOverride ?? safeFieldName;
            attributes[safeFieldName] = attrName.toString();
          }
          break;
        }
      }
    }

    // Generate Mixin
    buffer.writeln('mixin _\$${className}Sync on SparkComponent {');

    // 1. Generate observedAttributes
    if (attributes.isNotEmpty) {
      final attrList = attributes.values.map((a) => "'$a'").join(', ');
      buffer.writeln('  @override');
      buffer.writeln(
        '  List<String> get observedAttributes => const [$attrList];',
      );
    }

    // 2. Generate syncAttributes
    buffer.writeln('  @override');
    buffer.writeln('  void syncAttributes() {');

    attributes.forEach((field, attr) {
      final fieldElement = element.fields.firstWhere((f) => f.name == field);
      final type = fieldElement.type;
      final isPrimitive =
          type.isDartCoreInt ||
          type.isDartCoreDouble ||
          type.isDartCoreBool ||
          type.isDartCoreString;

      if (isPrimitive) {
        buffer.writeln(
          "    setAttr('$attr', (this as $className).$field.toString());",
        );
      } else {
        // Assume custom object with toJson
        buffer.writeln(
          "    setAttr('$attr', jsonEncode((this as $className).$field.toJson()));",
        );
      }
    });

    buffer.writeln('  }');

    // 3. Generate dumpedAttributes
    buffer.writeln('  @override');
    buffer.writeln('  Map<String, String> get dumpedAttributes => {');
    attributes.forEach((field, attr) {
      final fieldElement = element.fields.firstWhere((f) => f.name == field);
      final type = fieldElement.type;
      final isPrimitive =
          type.isDartCoreInt ||
          type.isDartCoreDouble ||
          type.isDartCoreBool ||
          type.isDartCoreString;

      if (isPrimitive) {
        buffer.writeln("    '$attr': (this as $className).$field.toString(),");
      } else {
        buffer.writeln(
          "    '$attr': jsonEncode((this as $className).$field.toJson()),",
        );
      }
    });
    buffer.writeln('  };');

    // 4. Generate attributeChangedCallback (Attr -> Field)
    buffer.writeln('  @override');
    buffer.writeln(
      '  void attributeChangedCallback(String name, String? oldValue, String? newValue) {',
    );
    buffer.writeln('    switch (name) {');

    attributes.forEach((field, attr) {
      buffer.writeln("      case '$attr':");
      // Find the field element to get its type
      final fieldElement = element.fields.firstWhere((f) => f.name == field);
      final type = fieldElement.type;

      if (type.isDartCoreInt) {
        buffer.writeln(
          "        (this as $className).$field = int.tryParse(newValue ?? '') ?? 0;",
        );
      } else if (type.isDartCoreDouble) {
        buffer.writeln(
          "        (this as $className).$field = double.tryParse(newValue ?? '') ?? 0.0;",
        );
      } else if (type.isDartCoreBool) {
        buffer.writeln(
          "        (this as $className).$field = newValue != null && newValue != 'false';",
        );
      } else if (type.isDartCoreString) {
        buffer.writeln("        (this as $className).$field = newValue ?? '';");
      } else {
        // Check for fromJson factory
        final element = type.element;
        bool hasFromJson = false;
        if (element is ClassElement) {
          hasFromJson = element.constructors.any((c) => c.name == 'fromJson');
        }

        if (hasFromJson) {
          buffer.writeln("        if (newValue != null) {");
          buffer.writeln("          try {");
          buffer.writeln(
            "            (this as $className).$field = ${type.getDisplayString(withNullability: false)}.fromJson(jsonDecode(newValue));",
          );
          buffer.writeln("          } catch (_) {}");
          buffer.writeln("        }");
        } else {
          // Fallback check if it has a constructor that takes a Map or dynamic?
          // For now, if no fromJson, we can't do much.
          buffer.writeln(
            "        // Custom type '${type.getDisplayString(withNullability: false)}' must have a fromJson factory constructor.",
          );
        }
      }
      buffer.writeln('        break;');
    });

    buffer.writeln('    }');
    // Call super to trigger update()
    buffer.writeln(
      '    super.attributeChangedCallback(name, oldValue, newValue);',
    );
    buffer.writeln('  }');

    buffer.writeln('}');

    return buffer.toString();
  }
}
