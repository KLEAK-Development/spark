import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spark_generator/src/generator_helpers.dart' as helpers;
import 'package:spark_framework/server.dart';

/// Generator that processes @Component annotations for SparkComponents.
///
/// Expects user's class in a file ending with _base.dart
/// Generates an independent implementation file ending with _impl.dart
class ComponentGenerator extends GeneratorForAnnotation<Component> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    print('ComponentGenerator: Processing element ${element.name}');
    helpers.validateClassElement(element, 'Component');
    final classElement = element as ClassElement;

    final className = element.name;
    if (className == null) {
      throw InvalidGenerationSourceError(
        '@Component class must have a name',
        element: element,
      );
    }

    // Get the source file path from the build step
    final sourceFilePath = buildStep.inputId.path;

    // Verify the source file ends with _base.dart
    if (!sourceFilePath.endsWith('_base.dart')) {
      throw InvalidGenerationSourceError(
        '@Component class must be in a file ending with _base.dart',
        element: element,
      );
    }

    // Generate complete reactive class with same name
    return _generateCompleteReactiveClass(
      classElement,
      className,
      annotation,
      sourceFilePath,
    );
  }

  /// Generates a complete reactive class for plain @Component classes.
  String _generateCompleteReactiveClass(
    ClassElement classElement,
    String className,
    ConstantReader annotation,
    String sourceFilePath,
  ) {
    final buffer = StringBuffer();
    final attributes = _extractAttributes(classElement);

    // Check for render() method
    final renderMethod = classElement.getMethod('render');
    if (renderMethod == null) {
      throw InvalidGenerationSourceError(
        '@Component class must have a render() method',
        element: classElement,
      );
    }

    // Check for adoptedStyleSheets getter
    final hasAdoptedStyleSheets =
        classElement.getGetter('adoptedStyleSheets') != null;

    // Check for static 'tag' field
    final tagField = classElement.getField('tag');
    if (tagField == null || !tagField.isStatic) {
      throw InvalidGenerationSourceError(
        '@Component class must have a static "tag" constant',
        element: classElement,
      );
    }

    // Generate imports
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln();
    buffer.writeln('// ignore_for_file: unused_import');
    buffer.writeln();

    // Copy imports from the base file
    final baseFileImports = _extractImports(sourceFilePath);
    for (final import in baseFileImports) {
      buffer.writeln(import);
    }

    // Add dart:convert if needed for JSON serialization
    final needsJson = attributes.values.any(
      (info) =>
          !info.fieldType.isDartCoreString &&
          !info.fieldType.isDartCoreInt &&
          !info.fieldType.isDartCoreDouble &&
          !info.fieldType.isDartCoreNum &&
          !info.fieldType.isDartCoreBool,
    );
    // Almost always need it for List/Map support now
    if ((needsJson ||
            attributes.values.any(
              (i) => i.fieldType.isDartCoreList || i.fieldType.isDartCoreMap,
            )) &&
        !baseFileImports.any((import) => import.contains('dart:convert'))) {
      buffer.writeln("import 'dart:convert';");
    }

    buffer.writeln();
    buffer.writeln('/// Generated reactive implementation of [$className].');
    buffer.writeln('class $className extends SparkComponent {');

    // Generate static tag
    final tagValue = _getStaticFieldValue(tagField);
    buffer.writeln('  static const tag = $tagValue;');
    buffer.writeln();

    // Generate private fields for attributes
    for (final entry in attributes.entries) {
      final fieldName = entry.key;
      final info = entry.value;
      final typeStr = info.fieldType.getDisplayString();
      final fieldElement = classElement.fields.firstWhere(
        (f) => f.name == fieldName,
      );

      // Try to get default value
      final defaultValue = _getFieldInitializer(fieldElement);
      if (defaultValue != null && defaultValue.isNotEmpty) {
        buffer.writeln('  $typeStr _$fieldName = $defaultValue;');
      } else {
        // No default value - will be initialized in constructor
        buffer.writeln('  late $typeStr _$fieldName;');
      }
    }

    buffer.writeln();

    // Generate constructor matching user's constructor
    _generateConstructor(
      buffer,
      classElement,
      className,
      attributes,
      sourceFilePath,
    );

    // Generate reactive getters/setters
    for (final entry in attributes.entries) {
      final fieldName = entry.key;
      final info = entry.value;
      final typeStr = info.fieldType.getDisplayString();

      buffer.writeln('  $typeStr get $fieldName => _$fieldName;');
      buffer.writeln('  set $fieldName($typeStr v) {');
      buffer.writeln('    if (_$fieldName != v) {');
      buffer.writeln('      _$fieldName = v;');
      buffer.writeln('      scheduleUpdate();');
      buffer.writeln('    }');
      buffer.writeln('  }');
      buffer.writeln();
    }

    // Copy user's methods (render, etc.)
    _copyUserMethods(buffer, classElement, attributes, sourceFilePath);

    // tagName getter
    buffer.writeln('  @override');
    buffer.writeln('  String get tagName => tag;');
    buffer.writeln();

    // Generate observedAttributes, syncAttributes, dumpedAttributes, attributeChangedCallback
    _generateAttributeMethods(
      buffer,
      classElement,
      className,
      attributes,
      true, // uses private fields with reactive setters
    );

    // adoptedStyleSheets if available
    if (hasAdoptedStyleSheets) {
      final getter = classElement.getGetter('adoptedStyleSheets');
      if (getter != null) {
        final getterSource = _getGetterSource(getter, sourceFilePath);
        if (getterSource != null) {
          buffer.writeln('  @override');
          buffer.writeln(getterSource);
          buffer.writeln();
        }
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  /// Extracts @Attribute annotated fields from a class.
  Map<String, _AttributeInfo> _extractAttributes(ClassElement classElement) {
    final attributes = <String, _AttributeInfo>{};

    for (final field in classElement.fields) {
      // Access annotations list via dynamic to bypass type issues
      final dynamic metadata = field.metadata;
      final annotations = (metadata as dynamic).annotations as List;

      for (final meta in annotations) {
        final value = (meta as dynamic).computeConstantValue();
        if (value == null) continue;

        final typeName = value.type?.element?.name;

        if (typeName == 'Attribute') {
          final nameField = value.getField('name');
          final nameOverride = nameField?.toStringValue();
          final safeFieldName = field.name;
          if (safeFieldName != null) {
            final isPrivate = safeFieldName.startsWith('_');
            final publicName = isPrivate
                ? safeFieldName.substring(1)
                : safeFieldName;
            final attrName = (nameOverride ?? publicName).toLowerCase();
            attributes[safeFieldName] = _AttributeInfo(
              attrName: attrName,
              isPrivate: isPrivate,
              publicName: publicName,
              fieldType: field.type,
            );
          }
          break;
        }
      }
    }

    return attributes;
  }

  /// Generates observedAttributes, syncAttributes, dumpedAttributes, attributeChangedCallback.
  void _generateAttributeMethods(
    StringBuffer buffer,
    ClassElement classElement,
    String className,
    Map<String, _AttributeInfo> attributes,
    bool isWrapper,
  ) {
    // observedAttributes
    if (attributes.isNotEmpty) {
      final attrList = attributes.values
          .map((a) => "'${a.attrName}'")
          .join(', ');
      buffer.writeln('  @override');
      buffer.writeln(
        '  List<String> get observedAttributes => const [$attrList];',
      );
      buffer.writeln();
    }

    // syncAttributes
    buffer.writeln('  @override');
    buffer.writeln('  void syncAttributes() {');
    for (final entry in attributes.entries) {
      final info = entry.value;
      final accessName = info.isPrivate ? info.publicName : entry.key;
      final serializeExpr = _getSerializeExpr(accessName, info.fieldType);
      buffer.writeln("    setAttr('${info.attrName}', $serializeExpr);");
    }
    buffer.writeln('  }');
    buffer.writeln();

    // dumpedAttributes
    buffer.writeln('  @override');
    buffer.writeln('  Map<String, String> get dumpedAttributes => {');
    for (final entry in attributes.entries) {
      final info = entry.value;
      final accessName = info.isPrivate ? info.publicName : entry.key;
      final serializeExpr = _getSerializeExpr(accessName, info.fieldType);
      buffer.writeln("    '${info.attrName}': $serializeExpr,");
    }
    buffer.writeln('  };');
    buffer.writeln();

    // attributeChangedCallback
    buffer.writeln('  @override');
    buffer.writeln(
      '  void attributeChangedCallback(String name, String? oldValue, String? newValue) {',
    );
    buffer.writeln('    switch (name) {');
    for (final entry in attributes.entries) {
      final fieldName = entry.key;
      final info = entry.value;
      final type = info.fieldType;

      buffer.writeln("      case '${info.attrName}':");

      // Determine the correct target access based on pattern:
      // - New complete class pattern (isWrapper=true): use private field _$fieldName
      // - Old mixin pattern (isWrapper=false): cast to original class and use fieldName as-is
      final targetAccess = isWrapper
          ? '_$fieldName'
          : '(this as $className).$fieldName';

      _generateAttributeDeserialization(buffer, type, targetAccess);

      buffer.writeln('        break;');
    }
    buffer.writeln('    }');
    buffer.writeln(
      '    super.attributeChangedCallback(name, oldValue, newValue);',
    );
    buffer.writeln('  }');
  }

  /// Helper method to generate attribute deserialization logic.
  void _generateAttributeDeserialization(
    StringBuffer buffer,
    DartType type,
    String targetAccess,
  ) {
    if (type.isDartCoreInt) {
      buffer.writeln(
        "        $targetAccess = int.tryParse(newValue ?? '') ?? 0;",
      );
    } else if (type.isDartCoreDouble) {
      buffer.writeln(
        "        $targetAccess = double.tryParse(newValue ?? '') ?? 0.0;",
      );
    } else if (type.isDartCoreNum) {
      buffer.writeln(
        "        $targetAccess = num.tryParse(newValue ?? '') ?? 0;",
      );
    } else if (type.isDartCoreBool) {
      buffer.writeln(
        "        $targetAccess = newValue != null && newValue != 'false';",
      );
    } else if (type.isDartCoreString) {
      buffer.writeln("        $targetAccess = newValue ?? '';");
    } else if (type.isDartCoreList) {
      if (type is ParameterizedType && type.typeArguments.isNotEmpty) {
        final genericType = type.typeArguments.first;
        if (genericType.isDartCoreString ||
            genericType.isDartCoreInt ||
            genericType.isDartCoreDouble ||
            genericType.isDartCoreNum ||
            genericType.isDartCoreBool ||
            genericType is DynamicType) {
          buffer.writeln(
            "        $targetAccess = (jsonDecode(newValue ?? '[]') as List).cast<${genericType.getDisplayString()}>().toList();",
          );
        } else {
          buffer.writeln(
            "        $targetAccess = (jsonDecode(newValue ?? '[]') as List).map((e) => ${genericType.getDisplayString()}.fromJson(e)).toList();",
          );
        }
      } else {
        buffer.writeln(
          "        $targetAccess = (jsonDecode(newValue ?? '[]') as List);",
        );
      }
    } else if (type.isDartCoreMap) {
      if (type is ParameterizedType && type.typeArguments.length == 2) {
        final keyType = type.typeArguments[0];
        final valueType = type.typeArguments[1];

        if (valueType.isDartCoreString ||
            valueType.isDartCoreInt ||
            valueType.isDartCoreDouble ||
            valueType.isDartCoreNum ||
            valueType.isDartCoreBool ||
            valueType is DynamicType) {
          buffer.writeln(
            "        $targetAccess = (jsonDecode(newValue ?? '{}') as Map).cast<${keyType.getDisplayString()}, ${valueType.getDisplayString()}>();",
          );
        } else {
          buffer.writeln(
            "        $targetAccess = (jsonDecode(newValue ?? '{}') as Map).map((k, v) => MapEntry(k as ${keyType.getDisplayString()}, ${valueType.getDisplayString()}.fromJson(v)));",
          );
        }
      } else {
        buffer.writeln(
          "        $targetAccess = (jsonDecode(newValue ?? '{}') as Map);",
        );
      }
    } else {
      // Check for fromJson factory
      final typeElement = type.element;
      bool hasFromJson = false;
      if (typeElement is ClassElement) {
        hasFromJson = typeElement.constructors.any((c) => c.name == 'fromJson');
      }

      if (hasFromJson) {
        buffer.writeln("        if (newValue != null) {");
        buffer.writeln("          try {");
        buffer.writeln(
          "            $targetAccess = ${type.getDisplayString()}.fromJson(jsonDecode(newValue));",
        );
        buffer.writeln("          } catch (_) {}");
        buffer.writeln("        }");
      } else {
        buffer.writeln(
          "        // Custom type '${type.getDisplayString()}' must have a fromJson factory.",
        );
      }
    }
  }

  /// Returns an expression to serialize a field to string.
  String _getSerializeExpr(String fieldName, DartType type) {
    if (type.isDartCoreString) {
      return fieldName;
    } else if (type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreNum ||
        type.isDartCoreBool) {
      return '$fieldName.toString()';
    } else if (type.isDartCoreList || type.isDartCoreMap) {
      return 'jsonEncode($fieldName)';
    } else {
      return 'jsonEncode($fieldName.toJson())';
    }
  }

  /// Extracts import statements from the source file.
  List<String> _extractImports(String sourceFilePath) {
    try {
      final file = File(sourceFilePath);
      if (!file.existsSync()) return [];

      final contents = file.readAsStringSync();
      final imports = <String>[];

      // Find all import statements
      final lines = contents.split('\n');
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('import ') && trimmed.endsWith(';')) {
          imports.add(trimmed);
        }
      }

      return imports;
    } catch (e) {
      print('Failed to extract imports: $e');
      return [];
    }
  }

  // /// Returns an expression to parse an attribute value to a field type.
  // String _getParseExpr(String fieldName, String attrName, DartType type) {
  //   if (type.isDartCoreInt) {
  //     return "getPropsInt('$attrName', 0)";
  //   } else if (type.isDartCoreDouble) {
  //     return "getPropsDouble('$attrName', 0)";
  //   } else if (type.isDartCoreBool) {
  //     final expr = "getPropsBool('$attrName')";
  //     return "$expr != null && $expr != 'false'";
  //   } else if (type.isDartCoreString) {
  //     return "getPropsString('$attrName')";
  //   } else {
  //     final typeName = type.getDisplayString();
  //     return "$typeName.fromJson(jsonDecode(getAttribute('$attrName') ?? '{}'))";
  //   }
  // }

  /// Formats a parameter's default value for code generation.
  String _formatDefaultValue(FormalParameterElement param) {
    final constantValue = param.computeConstantValue();
    if (constantValue == null) return '';

    final type = param.type;

    if (type.isDartCoreInt) {
      final intVal = constantValue.toIntValue();
      return intVal?.toString() ?? '';
    } else if (type.isDartCoreDouble) {
      final doubleVal = constantValue.toDoubleValue();
      return doubleVal?.toString() ?? '';
    } else if (type.isDartCoreNum) {
      // num can be either int or double at runtime
      final intVal = constantValue.toIntValue();
      if (intVal != null) return intVal.toString();
      final doubleVal = constantValue.toDoubleValue();
      if (doubleVal != null) return doubleVal.toString();
      return '';
    } else if (type.isDartCoreBool) {
      final boolVal = constantValue.toBoolValue();
      return boolVal?.toString() ?? '';
    } else if (type.isDartCoreString) {
      final stringVal = constantValue.toStringValue();
      return stringVal != null ? "'$stringVal'" : '';
    } else {
      // For complex const objects, use the source code representation
      // This handles cases like "const CounterConfig()"
      final source = param.defaultValueCode;
      if (source != null && source.isNotEmpty) {
        return source;
      }

      // Fallback: try to construct a const expression
      final typeName = type.getDisplayString();
      return 'const $typeName()';
    }
  }

  /// Gets the value of a static field as a string.
  String _getStaticFieldValue(FieldElement field) {
    final constantValue = field.computeConstantValue();
    if (constantValue != null) {
      final stringValue = constantValue.toStringValue();
      if (stringValue != null) {
        return "'$stringValue'";
      }
    }
    // Fallback: use the field name
    return field.name ?? 'tag';
  }

  /// Gets a field's initializer expression from source.
  String? _getFieldInitializer(FieldElement field) {
    // Try to get constant value first
    final constantValue = field.computeConstantValue();
    if (constantValue != null) {
      final type = field.type;
      if (type.isDartCoreInt) {
        return constantValue.toIntValue()?.toString();
      } else if (type.isDartCoreDouble) {
        return constantValue.toDoubleValue()?.toString();
      } else if (type.isDartCoreNum) {
        // num can be either int or double at runtime
        final intVal = constantValue.toIntValue();
        if (intVal != null) return intVal.toString();
        final doubleVal = constantValue.toDoubleValue();
        if (doubleVal != null) return doubleVal.toString();
        return null;
      } else if (type.isDartCoreBool) {
        return constantValue.toBoolValue()?.toString();
      } else if (type.isDartCoreString) {
        final stringVal = constantValue.toStringValue();
        return stringVal != null ? "'$stringVal'" : null;
      } else {
        return '${type.getDisplayString()}()';
      }
    }

    return null;
  }

  /// Generates a constructor matching the user's constructor signature.
  void _generateConstructor(
    StringBuffer buffer,
    ClassElement classElement,
    String className,
    Map<String, _AttributeInfo> attributes,
    String sourceFilePath,
  ) {
    final constructor = classElement.unnamedConstructor;
    if (constructor != null && constructor.formalParameters.isNotEmpty) {
      buffer.writeln('  $className({');
      for (final param in constructor.formalParameters) {
        if (param.isNamed) {
          final typeStr = param.type.getDisplayString();
          final paramName = param.name;
          final required = param.isRequired ? 'required ' : '';

          // Handle default values
          String defaultPart = '';
          if (!param.isRequired && param.hasDefaultValue) {
            final defaultValue = _formatDefaultValue(param);
            if (defaultValue.isNotEmpty) {
              defaultPart = ' = $defaultValue';
            }
          }

          buffer.writeln('    $required$typeStr $paramName$defaultPart,');
        }
      }
      buffer.writeln('  }) {');

      // Initialize private fields from constructor parameters
      for (final param in constructor.formalParameters) {
        if (param.isNamed) {
          final paramName = param.name;
          if (attributes.containsKey(paramName)) {
            buffer.writeln('    _$paramName = $paramName;');
          }
        }
      }

      // Initialize remaining fields with defaults if not already initialized
      for (final entry in attributes.entries) {
        final fieldName = entry.key;
        final fieldElement = classElement.fields.firstWhere(
          (f) => f.name == fieldName,
        );

        // Check if this field was initialized from a constructor parameter
        final wasInitialized = constructor.formalParameters.any(
          (p) => p.isNamed && p.name == fieldName,
        );

        if (!wasInitialized) {
          // Check if the field has a default value
          final defaultValue = _getFieldInitializer(fieldElement);
          if (defaultValue != null && defaultValue.isNotEmpty) {
            // Already has default in field declaration
            continue;
          } else {
            // Need to initialize with a default
            final type = entry.value.fieldType;
            if (type.isDartCoreString) {
              buffer.writeln("    _$fieldName = '';");
            } else if (type.isDartCoreBool) {
              buffer.writeln('    _$fieldName = false;');
            } else if (type.isDartCoreInt) {
              buffer.writeln('    _$fieldName = 0;');
            } else if (type.isDartCoreDouble) {
              buffer.writeln('    _$fieldName = 0.0;');
            } else if (type.isDartCoreNum) {
              buffer.writeln('    _$fieldName = 0;');
            } else {
              // Complex type - use default constructor if available
              final typeStr = type.getDisplayString();
              buffer.writeln('    _$fieldName = $typeStr();');
            }
          }
        }
      }
      buffer.writeln('  }');
      buffer.writeln();
    } else {
      // No-arg constructor
      buffer.writeln('  $className();');
      buffer.writeln();
    }
  }

  /// Copies user's methods into the generated class.
  void _copyUserMethods(
    StringBuffer buffer,
    ClassElement classElement,
    Map<String, _AttributeInfo> attributes,
    String sourceFilePath,
  ) {
    // Copy render method
    final renderMethod = classElement.getMethod('render');
    if (renderMethod != null) {
      final methodSource = _getMethodSource(renderMethod, sourceFilePath);
      if (methodSource != null && methodSource.isNotEmpty) {
        buffer.writeln('@override');
        buffer.writeln(methodSource.replaceFirst('render', 'build'));
        buffer.writeln();
      } else {
        // Fallback: generate placeholder
        buffer.writeln('  Element build() {');
        buffer.writeln('    // TODO: Copy render method from user class');
        buffer.writeln('    return div([]);');
        buffer.writeln('  }');
        buffer.writeln();
      }
    }

    final onMountMethod = classElement.getMethod('onMount');
    if (onMountMethod != null) {
      final methodSource = _getMethodSource(onMountMethod, sourceFilePath);
      if (methodSource != null && methodSource.isNotEmpty) {
        buffer.writeln('@override');
        buffer.writeln(
          methodSource.replaceFirst(
            'void onMount() {',
            'void onMount() {\n    super.onMount();\n',
          ),
        );
        buffer.writeln();
      }
    }

    // Copy other non-static public methods (excluding getters/setters)
    for (final method in classElement.methods) {
      if (method.isStatic ||
          method.name == 'render' ||
          method.name == 'onMount') {
        continue;
      }

      final methodSource = _getMethodSource(method, sourceFilePath);
      if (methodSource != null && methodSource.isNotEmpty) {
        buffer.writeln(methodSource);
        buffer.writeln();
      }
    }
  }

  /// Extracts method source code from a method element.
  /// Finds the method by name and extracts from the previous declaration boundary.
  String? _getMethodSource(MethodElement method, String sourceFilePath) {
    final methodName = method.name;
    if (methodName == null) return null;

    try {
      final file = File(sourceFilePath);
      if (!file.existsSync()) return null;
      final contents = file.readAsStringSync();

      // Match method declarations with return type or modifiers before method name
      // This pattern ensures we match actual method declarations, not method calls
      // The lookahead ensures at least one of: annotation, modifier, or return type is present
      final pattern = RegExp(
        r'(?:^|\n)\s*'
        // Positive lookahead: require at least annotation, modifier, or return type
        r'(?=(?:@\w+\s+|(?:static|const|final|late|override)\s+|\w+(?:<[^>]+>)?(?:\?)?\s+))'
        // Now match the actual components
        r'(?:@\w+\s+)*(?:(?:static|const|final|late|override)\s+)*(?:\w+(?:<[^>]+>)?(?:\?)?\s+)?'
        '${RegExp.escape(methodName)}'
        r'\s*\(',
        multiLine: true,
      );

      final matches = pattern.allMatches(contents);
      if (matches.isEmpty) return null;

      for (final match in matches) {
        // Extract the full match and find where the actual declaration starts
        // Skip any leading newlines
        int start = match.start;
        while (start < contents.length &&
            (contents[start] == '\n' || contents[start] == '\r')) {
          start++;
        }

        // Find opening brace or arrow after method signature
        int pos = match.end;
        bool isArrowFunction = false;
        while (pos < contents.length &&
            contents[pos] != '{' &&
            contents[pos] != '=') {
          pos++;
        }
        if (pos >= contents.length) continue;

        // Check if it's an arrow function
        if (pos + 1 < contents.length &&
            contents[pos] == '=' &&
            contents[pos + 1] == '>') {
          isArrowFunction = true;
        }

        int end;
        if (isArrowFunction) {
          // Arrow function - find semicolon or end of expression
          end = pos + 2;
          int braceCount = 0;
          int parenCount = 0;
          int bracketCount = 0;

          while (end < contents.length) {
            final char = contents[end];
            if (char == '{') {
              braceCount++;
            } else if (char == '}') {
              braceCount--;
            } else if (char == '(') {
              parenCount++;
            } else if (char == ')') {
              parenCount--;
            } else if (char == '[') {
              bracketCount++;
            } else if (char == ']') {
              bracketCount--;
            } else if (char == ';' &&
                braceCount == 0 &&
                parenCount == 0 &&
                bracketCount == 0) {
              end++;
              break;
            }
            end++;
          }
        } else {
          // Block function - find matching closing brace
          int braceCount = 0;
          end = pos;
          while (end < contents.length) {
            if (contents[end] == '{') {
              braceCount++;
            } else if (contents[end] == '}') {
              braceCount--;
              if (braceCount == 0) {
                end++;
                break;
              }
            }
            end++;
          }
        }

        if (end > start) {
          final extracted = contents.substring(start, end).trim();
          // Verify this looks like a valid method (basic sanity check)
          if (extracted.contains(methodName) &&
              (extracted.contains('{') || extracted.contains('=>'))) {
            return '  $extracted';
          }
        }
      }
    } catch (e) {
      print('Failed to extract method source for $methodName: $e');
    }

    return null;
  }

  /// Extracts getter source code from a getter element.
  /// Finds the getter by name and extracts from the previous declaration boundary.
  String? _getGetterSource(
    PropertyAccessorElement getter,
    String sourceFilePath,
  ) {
    final getterName = getter.name;
    if (getterName == null) return null;

    try {
      final file = File(sourceFilePath);
      if (!file.existsSync()) return null;
      final contents = file.readAsStringSync();

      // Find "get getterName" pattern
      final pattern = RegExp(
        r'\bget\s+' + RegExp.escape(getterName) + r'\b',
        multiLine: true,
      );

      final matches = pattern.allMatches(contents);
      if (matches.isEmpty) return null;

      for (final match in matches) {
        // Go backwards to find previous closing brace or semicolon
        int start = match.start - 1;
        while (start > 0 && contents[start] != '}' && contents[start] != ';') {
          start--;
        }
        // Move past the closing brace/semicolon
        if (start > 0) start++;

        // Skip any whitespace/newlines
        while (start < match.start &&
            (contents[start] == ' ' ||
                contents[start] == '\t' ||
                contents[start] == '\n' ||
                contents[start] == '\r')) {
          start++;
        }

        // Find getter body - either => or {
        int pos = match.end;
        while (pos < contents.length &&
            contents[pos] != '=' &&
            contents[pos] != '{') {
          pos++;
        }
        if (pos >= contents.length) continue;

        int end;
        if (pos + 1 < contents.length &&
            contents[pos] == '=' &&
            contents[pos + 1] == '>') {
          // Arrow syntax - find semicolon
          end = pos + 2;
          while (end < contents.length && contents[end] != ';') {
            end++;
          }
          if (end < contents.length) end++;
        } else if (contents[pos] == '{') {
          // Block syntax - find matching brace
          int braceCount = 0;
          end = pos;
          while (end < contents.length) {
            if (contents[end] == '{') {
              braceCount++;
            } else if (contents[end] == '}') {
              braceCount--;
              if (braceCount == 0) {
                end++;
                break;
              }
            }
            end++;
          }
        } else {
          continue;
        }

        if (end > start) {
          return '  ${contents.substring(start, end).trim()}';
        }
      }
    } catch (e) {
      print('Failed to extract getter source for $getterName: $e');
    }

    return null;
  }
}

/// Helper class to store attribute information.
class _AttributeInfo {
  final String attrName;
  final bool isPrivate;
  final String publicName;
  final DartType fieldType;

  _AttributeInfo({
    required this.attrName,
    required this.isPrivate,
    required this.publicName,
    required this.fieldType,
  });
}
