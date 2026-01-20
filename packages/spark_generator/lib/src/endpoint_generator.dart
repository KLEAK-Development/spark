import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spark_framework/spark.dart' show Endpoint;
import 'package:spark_generator/src/generator_helpers.dart' as helpers;

/// Generator that processes @Endpoint annotations on classes.
///
/// Supports two base classes:
/// - `SparkEndpoint` - for endpoints without a request body
/// - `SparkEndpointWithBody<T>` - for endpoints with a typed request body
class EndpointGenerator extends GeneratorForAnnotation<Endpoint> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    log.info('EndpointGenerator processing ${element.name}');
    try {
      helpers.validateClassElement(element, 'Endpoint');

      final classElement = element as ClassElement;

      // Check which base class is extended
      final hasBody = helpers.checkInheritance(
        classElement,
        'SparkEndpointWithBody',
      );
      final hasNoBody = helpers.checkInheritance(classElement, 'SparkEndpoint');

      if (!hasBody && !hasNoBody) {
        throw InvalidGenerationSourceError(
          '@Endpoint classes must extend SparkEndpoint or SparkEndpointWithBody<T>',
          element: element,
        );
      }

      final className = element.name;
      final path = annotation.read('path').stringValue;
      final method = annotation.read('method').stringValue;

      // Parse path parameters from the route pattern
      final pathParams = helpers.parsePathParams(path);

      // Convert path pattern to shelf_router format
      final shelfPath = helpers.convertToShelfPath(path);

      // Get the body type if using SparkEndpointWithBody
      final bodyType = hasBody ? _getBodyType(element) : null;

      // Get the return type from the handler method
      final handlerMethod = element.getMethod('handler');
      final returnType = handlerMethod?.returnType;

      final buffer = StringBuffer();

      // Generate static route info constant
      buffer.writeln('// Route: $path ($method)');
      buffer.writeln('const _\$${className}Route = (');
      buffer.writeln("  path: '$shelfPath',");
      buffer.writeln("  methods: <String>['$method'],");
      buffer.writeln(
        '  pathParams: <String>[${pathParams.map((p) => "'$p'").join(', ')}],',
      );
      buffer.writeln("  className: '$className',");
      buffer.writeln(');');
      buffer.writeln();

      // Generate Handler Function
      buffer.writeln('Future<Response> _\$handle$className(');
      buffer.writeln('  Request request,');
      for (final param in pathParams) {
        buffer.writeln('  String $param,');
      }
      buffer.writeln(') async {');

      // Instantiate the endpoint class
      buffer.writeln('  final endpoint = $className();');
      buffer.writeln();

      // Build middleware pipeline from the endpoint's middleware getter
      buffer.writeln('  var pipeline = const Pipeline();');
      buffer.writeln('  for (final middleware in endpoint.middleware) {');
      buffer.writeln('    pipeline = pipeline.addMiddleware(middleware);');
      buffer.writeln('  }');
      buffer.writeln();

      buffer.writeln('  final handler = (Request req) async {');
      buffer.writeln('    try {');

      // Create SparkRequest
      buffer.writeln('    final sparkRequest = SparkRequest(');
      buffer.writeln('      shelfRequest: req,');
      buffer.writeln('      pathParams: {');
      for (final p in pathParams) {
        buffer.writeln("        '$p': $p,");
      }
      buffer.writeln('      },');
      buffer.writeln('    );');
      buffer.writeln();

      if (hasBody && bodyType != null) {
        // Generate OpenAPI validation before body parsing
        _generateOpenApiValidation(buffer, annotation);

        // Parse body for SparkEndpointWithBody
        final contentTypes = annotation.objectValue
            .getField('contentTypes')
            ?.toListValue()
            ?.map((e) => e.toStringValue())
            .where((e) => e != null)
            .cast<String>()
            .toList();
        _generateBodyParsing(buffer, bodyType, contentTypes);
        buffer.writeln(
          '    final result = await endpoint.handler(sparkRequest, body);',
        );
      } else {
        // Generate OpenAPI validation before handler execution
        _generateOpenApiValidation(buffer, annotation);

        // No body for SparkEndpoint
        buffer.writeln(
          '    final result = await endpoint.handler(sparkRequest);',
        );
      }
      buffer.writeln();

      // Handle response serialization
      _generateResponseSerialization(buffer, returnType);

      buffer.writeln('    } on SparkValidationException catch (e) {');
      buffer.writeln('      return ApiError(');
      buffer.writeln("        message: e.message,");
      buffer.writeln("        code: 'VALIDATION_ERROR',");
      buffer.writeln("        details: e.errors,");
      buffer.writeln('      ).toResponse(400);');
      buffer.writeln('    } on ApiError catch (e) {');
      buffer.writeln('      return e.toResponse();');
      buffer.writeln('    } on SparkHttpException catch (e) {');
      buffer.writeln('      return ApiError(');
      buffer.writeln("        message: e.message,");
      buffer.writeln("        code: e.code,");
      buffer.writeln("        details: e.details,");
      buffer.writeln('      ).toResponse(e.statusCode);');
      buffer.writeln('    } catch (e, s) {');
      buffer.writeln("      print(e);");
      buffer.writeln('      return ApiError(');
      buffer.writeln("        message: 'Internal Server Error',");
      buffer.writeln("        code: 'INTERNAL_ERROR',");
      buffer.writeln('      ).toResponse(500);');
      buffer.writeln('    }');

      buffer.writeln('  };');
      buffer.writeln();

      // Execute pipeline
      buffer.writeln('  return pipeline.addHandler(handler)(request);');
      buffer.writeln('}');

      return buffer.toString();
    } catch (e, s) {
      log.severe('Error generating endpoint for ${element.name}', e, s);
      return '';
    }
  }

  void _generateBodyParsing(
    StringBuffer buffer,
    DartType bodyType,
    List<String>? allowedContentTypes,
  ) {
    final bodyTypeName = bodyType.getDisplayString();

    // Special case for Stream<MultipartPart>
    if (bodyTypeName == 'Stream<MultipartPart>') {
      buffer.writeln('    final body = sparkRequest.multipart;');
      return;
    }

    buffer.writeln('    dynamic rawBody;');
    buffer.writeln(
      '    final contentTypeHeader = req.headers["content-type"];',
    );
    buffer.writeln(
      '    final contentType = ContentType.from(contentTypeHeader);',
    );

    // If no specific content types are defined, allow all supported types
    final allowAll = allowedContentTypes == null || allowedContentTypes.isEmpty;
    final allowMultipart =
        allowAll || allowedContentTypes.contains('multipart/form-data');
    final allowFormUrlEncoded =
        allowAll ||
        allowedContentTypes.contains('application/x-www-form-urlencoded');
    final allowJson =
        allowAll || allowedContentTypes.contains('application/json');

    var isFirst = true;

    if (allowMultipart) {
      buffer.writeln('    if (contentType == ContentType.multipart) {');
      buffer.writeln('      final formData = <String, dynamic>{};');
      buffer.writeln(
        '      await for (final part in sparkRequest.multipart) {',
      );
      buffer.writeln('        if (part.filename == null) {');
      buffer.writeln('          final value = await part.readString();');
      buffer.writeln('          formData[part.name ?? ""] = value;');
      buffer.writeln('        }');
      buffer.writeln('      }');
      buffer.writeln('      rawBody = formData;');
      buffer.writeln('    }');
      isFirst = false;
    }

    if (allowFormUrlEncoded) {
      buffer.writeln(
        '    ${isFirst ? '' : 'else '}if (contentType == ContentType.formUrlEncoded) {',
      );
      buffer.writeln('      final bodyString = await req.readAsString();');
      buffer.writeln('      rawBody = Uri.splitQueryString(bodyString);');
      buffer.writeln('    }');
      isFirst = false;
    }

    if (allowJson) {
      buffer.writeln(
        '    ${isFirst ? '' : 'else '}if (contentType == ContentType.json) {',
      );
      buffer.writeln('      final bodyString = await req.readAsString();');
      buffer.writeln('      rawBody = jsonDecode(bodyString);');
      buffer.writeln('    }');
      isFirst = false;
    }

    // Fallback logic for when allowedContentTypes is not specified (allowAll),
    // or when specific types like 'text/plain' might be used which fallback to string reading.

    if (allowAll) {
      if (!isFirst) {
        buffer.writeln('    else {');
      } else {
        // If nothing else was generated (e.g. no support for multipart/json etc?) - unlikely
        // Just plain block
      }

      if (!isFirst) {
        buffer.writeln('      rawBody = await req.readAsString();');
        buffer.writeln('    }');
      } else {
        // No structured parsing supported or generated?
        buffer.writeln('    rawBody = await req.readAsString();');
      }
    } else {
      // We have specific allowed types.
      // If we allowed 'text/plain' or others that fall into "readAsString", we need to handle them.
      // We can check if there are other types not covered by the 3 structure parsers.
      final standardTypes = [
        'multipart/form-data',
        'application/x-www-form-urlencoded',
        'application/json',
      ];
      final hasOtherTypes = allowedContentTypes.any(
        (t) => !standardTypes.contains(t),
      );

      if (hasOtherTypes) {
        buffer.writeln('    ${isFirst ? '' : 'else '} {');
        buffer.writeln('      rawBody = await req.readAsString();');
        buffer.writeln('    }');
      }
    }

    if (bodyType.isDartCoreString) {
      buffer.writeln('    final body = rawBody.toString();');
    } else if (bodyType.isDartCoreInt) {
      buffer.writeln('    final body = int.parse(rawBody.toString());');
    } else if (bodyType.isDartCoreBool) {
      buffer.writeln('    final body = rawBody.toString() == "true";');
    } else if (bodyType.isDartCoreDouble || bodyType.isDartCoreNum) {
      buffer.writeln('    final body = num.parse(rawBody.toString());');
    } else if (bodyType.isDartCoreList) {
      buffer.writeln('    final body = rawBody as List<dynamic>;');
    } else if (bodyType.isDartCoreMap) {
      buffer.writeln('    final body = rawBody as Map<String, dynamic>;');
    } else if (bodyType is DynamicType) {
      buffer.writeln('    final body = rawBody;');
    } else {
      // Custom object - use constructor binding
      buffer.writeln(
        '    final body = ${_generateTypeParsing(bodyType, 'rawBody')};',
      );
    }

    if (bodyType.element is ClassElement) {
      _generateValidation(buffer, bodyType.element as ClassElement);
    }
  }

  String _generateTypeParsing(DartType type, String varName) {
    if (type.isDartCoreString) {
      return '$varName.toString()';
    } else if (type.isDartCoreInt) {
      return 'int.parse($varName.toString())';
    } else if (type.isDartCoreDouble || type.isDartCoreNum) {
      return 'num.parse($varName.toString())';
    } else if (type.isDartCoreBool) {
      return '$varName.toString() == "true"';
    } else if (type.isDartCoreList) {
      final typeArg = (type as InterfaceType).typeArguments.first;
      return '($varName as List).map((e) => ${_generateTypeParsing(typeArg, 'e')}).toList()';
    } else if (type is InterfaceType &&
        !type.isDartCoreMap &&
        !type.isDartCoreList &&
        !type.isDartCoreString &&
        !type.isDartCoreInt &&
        !type.isDartCoreDouble &&
        !type.isDartCoreBool &&
        !type.isDartCoreNum) {
      // It's a DTO, use constructor
      final element = type.element as ClassElement;
      final constructor = element.unnamedConstructor;
      if (constructor == null) {
        throw Exception(
          'Class ${element.name} must have an unnamed constructor',
        );
      }

      final params = constructor.formalParameters
          .map((param) {
            final paramName = param.name;
            final paramType = param.type;
            final jsonKey = paramName;
            final valueExpr = '($varName as Map<String, dynamic>)["$jsonKey"]';

            if (param.isNamed) {
              return '$paramName: ${_generateTypeParsing(paramType, valueExpr)}';
            } else {
              return _generateTypeParsing(paramType, valueExpr);
            }
          })
          .join(', ');

      return '${element.name}($params)';
    }
    return '$varName as ${type.getDisplayString()}';
  }

  void _generateResponseSerialization(
    StringBuffer buffer,
    DartType? returnType,
  ) {
    if (returnType == null) {
      buffer.writeln('    return Response.ok(result.toString());');
      return;
    }

    // Unwrap Future if needed
    DartType innerType = returnType;
    if (returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr) {
      if (returnType is InterfaceType && returnType.typeArguments.isNotEmpty) {
        innerType = returnType.typeArguments.first;
      }
    }

    // Check if returning Response directly
    if (_isResponse(innerType)) {
      buffer.writeln('    return result;');
      return;
    }

    if (innerType.isDartCoreString) {
      buffer.writeln(
        '    return Response.ok(result, headers: {"content-type": "text/plain"});',
      );
    } else if (innerType.isDartCoreInt ||
        innerType.isDartCoreDouble ||
        innerType.isDartCoreBool ||
        innerType.isDartCoreNum) {
      buffer.writeln(
        '    return Response.ok(result.toString(), headers: {"content-type": "text/plain"});',
      );
    } else if (innerType.element?.name == 'DateTime' &&
        innerType.element?.library?.name == 'dart.core') {
      buffer.writeln(
        '    return Response.ok(result.toIso8601String(), headers: {"content-type": "text/plain"});',
      );
    } else if (innerType is VoidType ||
        innerType.getDisplayString() == 'void') {
      buffer.writeln(
        '    return Response.ok("", headers: {"content-type": "text/plain"});',
      );
    } else {
      // Use field-based serialization
      final serialized = _generateTypeSerialization(innerType, 'result');
      buffer.writeln(
        '    return Response.ok(jsonEncode($serialized), headers: {"content-type": "application/json"});',
      );
    }
  }

  String _generateTypeSerialization(DartType type, String varName) {
    if (type.isDartCoreString ||
        type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreNum ||
        type.isDartCoreBool) {
      return varName;
    } else if (type.isDartCoreList) {
      final typeArg = (type as InterfaceType).typeArguments.first;
      return '$varName.map((e) => ${_generateTypeSerialization(typeArg, 'e')}).toList()';
    } else if (type.isDartCoreMap) {
      // Assuming String keys for JSON
      final valueType = (type as InterfaceType).typeArguments[1];
      return '$varName.map((k, v) => MapEntry(k, ${_generateTypeSerialization(valueType, 'v')}))';
    } else if (type is InterfaceType) {
      // DTO object, serialize fields
      final element = type.element as ClassElement;
      final fields = element.fields
          .where((f) => !f.isStatic && f.isPublic)
          .map((f) {
            return "'${f.name}': ${_generateTypeSerialization(f.type, '$varName.${f.name}')}";
          })
          .join(', ');
      return '{$fields}';
    }
    return varName; // Fallback
  }

  DartType? _getBodyType(ClassElement element) {
    var current = element.supertype;
    while (current != null) {
      if (current.element.name == 'SparkEndpointWithBody') {
        final typeArgs = current.typeArguments;
        if (typeArgs.isNotEmpty) {
          return typeArgs.first;
        }
        return null;
      }
      current = current.element.supertype;
    }
    return null;
  }

  bool _isResponse(DartType type) {
    return type.element?.name == 'Response';
  }

  void _generateValidation(StringBuffer buffer, ClassElement element) {
    final validationBuffer = StringBuffer();

    for (final field in element.fields) {
      if (field.isStatic) continue;

      for (final annotation in field.metadata.annotations) {
        final constantValue = annotation.computeConstantValue();
        if (constantValue == null) continue;

        final annotationType = constantValue.type;
        if (annotationType == null) continue;

        final name = annotationType.element?.name;
        final fieldName = field.name;

        // Extract message if present
        final messageField = constantValue.getField('message');
        final message = messageField?.toStringValue();

        if (name == 'NotEmpty') {
          final msg = message ?? "Field '$fieldName' cannot be empty";
          validationBuffer.writeln('''
            if (body.$fieldName.trim().isEmpty) {
              validationErrors['$fieldName'] = {
                'code': 'VALIDATION_NOT_EMPTY',
                'message': "$msg"
              };
            }
          ''');
        } else if (name == 'Email') {
          final msg = message ?? "Field '$fieldName' must be a valid email";
          validationBuffer.writeln('''
            final emailRegex = RegExp(r'^[^@]+@[^@]+\\.[^@]+\$');
            if (!emailRegex.hasMatch(body.$fieldName)) {
              validationErrors['$fieldName'] = {
                'code': 'VALIDATION_EMAIL',
                'message': "$msg"
              };
            }
          ''');
        } else if (name == 'Min') {
          final valueObj = constantValue.getField('value');
          final value = valueObj?.toDoubleValue() ?? valueObj?.toIntValue();
          if (value != null) {
            final msg = message ?? "Field '$fieldName' must be at least $value";
            validationBuffer.writeln('''
              if (body.$fieldName < $value) {
                validationErrors['$fieldName'] = {
                  'code': 'VALIDATION_MIN',
                  'message': "$msg",
                  'min': $value
                };
              }
            ''');
          }
        } else if (name == 'Max') {
          final valueObj = constantValue.getField('value');
          final value = valueObj?.toDoubleValue() ?? valueObj?.toIntValue();
          if (value != null) {
            final msg = message ?? "Field '$fieldName' must be at most $value";
            validationBuffer.writeln('''
              if (body.$fieldName > $value) {
                validationErrors['$fieldName'] = {
                  'code': 'VALIDATION_MAX',
                  'message': "$msg",
                  'max': $value
                };
              }
            ''');
          }
        } else if (name == 'Length') {
          final min = constantValue.getField('min')?.toIntValue();
          final max = constantValue.getField('max')?.toIntValue();

          if (min != null) {
            final msg =
                message ??
                "Field '$fieldName' must be at least $min characters long";
            validationBuffer.writeln('''
              if (body.$fieldName.length < $min) {
                 validationErrors['$fieldName'] = {
                  'code': 'VALIDATION_MIN_LENGTH',
                  'message': "$msg",
                  'min': $min
                };
              }
            ''');
          }
          if (max != null) {
            final msg =
                message ??
                "Field '$fieldName' must be at most $max characters long";
            validationBuffer.writeln('''
              if (body.$fieldName.length > $max) {
                 validationErrors['$fieldName'] = {
                  'code': 'VALIDATION_MAX_LENGTH',
                  'message': "$msg",
                  'max': $max
                };
              }
            ''');
          }
        } else if (name == 'Pattern') {
          final pattern = constantValue.getField('pattern')?.toStringValue();
          if (pattern != null) {
            final msg = message ?? "Field '$fieldName' does not match pattern";
            // Escape pattern for dart string
            final escapedPattern = pattern
                .replaceAll(r'\', r'\\')
                .replaceAll(r'$', r'\$');
            validationBuffer.writeln('''
                if (!RegExp(r'$escapedPattern').hasMatch(body.$fieldName)) {
                  validationErrors['$fieldName'] = {
                    'code': 'VALIDATION_PATTERN',
                    'message': "$msg",
                    'pattern': r'$escapedPattern'
                  };
                }
              ''');
          }
        } else if (name == 'IsNumeric') {
          final msg = message ?? "Field '$fieldName' must be numeric";
          validationBuffer.writeln('''
            if (double.tryParse(body.$fieldName.toString()) == null) {
              validationErrors['$fieldName'] = {
                'code': 'VALIDATION_IS_NUMERIC',
                'message': "$msg"
              };
            }
          ''');
        } else if (name == 'IsDate') {
          final msg = message ?? "Field '$fieldName' must be a valid date";
          validationBuffer.writeln('''
            if (DateTime.tryParse(body.$fieldName.toString()) == null) {
               validationErrors['$fieldName'] = {
                'code': 'VALIDATION_IS_DATE',
                'message': "$msg"
              };
            }
          ''');
        } else if (name == 'IsBooleanString') {
          final msg = message ?? "Field '$fieldName' must be a boolean string";
          validationBuffer.writeln('''
            if (body.$fieldName.toString().toLowerCase() != 'true' && body.$fieldName.toString().toLowerCase() != 'false') {
               validationErrors['$fieldName'] = {
                'code': 'VALIDATION_IS_BOOLEAN_STRING',
                'message': "$msg"
              };
            }
          ''');
        } else if (name == 'IsString') {
          final msg = message ?? "Field '$fieldName' must be a string";
          validationBuffer.writeln('''
            if (body.$fieldName is! String) {
               validationErrors['$fieldName'] = {
                'code': 'VALIDATION_IS_STRING',
                'message': "$msg"
              };
            }
          ''');
        }
      }
    }

    if (validationBuffer.isNotEmpty) {
      buffer.writeln('    final validationErrors = <String, dynamic>{};');
      buffer.write(validationBuffer);
      buffer.writeln('    if (validationErrors.isNotEmpty) {');
      buffer.writeln('      throw SparkValidationException(validationErrors);');
      buffer.writeln('    }');
    }
  }

  void _generateOpenApiValidation(
    StringBuffer buffer,
    ConstantReader annotation,
  ) {
    try {
      final constantValue = annotation.objectValue;
      final validationBuffer = StringBuffer();

      // Validate Parameters
      final parameters = constantValue.getField('parameters')?.toListValue();
      if (parameters != null) {
        for (final param in parameters) {
          final name = param.getField('name')?.toStringValue();
          final inLocation = param.getField('inLocation')?.toStringValue();
          final required = param.getField('required')?.toBoolValue() ?? false;
          final schema = param.getField('schema')?.toMapValue();
          final schemaMap = <String, dynamic>{};
          schema?.forEach((k, v) {
            final key = k?.toStringValue();
            if (key != null && v != null) {
              if (!v.isNull) {
                // Handle different types
                var value =
                    v.toStringValue() ??
                    v.toIntValue() ??
                    v.toBoolValue() ??
                    v.toDoubleValue();

                // Handle List (e.g. enum)
                if (value == null) {
                  final list = v.toListValue();
                  if (list != null) {
                    value = list
                        .map(
                          (e) =>
                              e.toStringValue() ??
                              e.toIntValue() ??
                              e.toBoolValue() ??
                              e.toDoubleValue(),
                        )
                        .toList();
                  }
                }

                if (value != null) {
                  schemaMap[key] = value;
                }
              }
            }
          });

          if (name == null || inLocation == null) continue;

          if (inLocation == 'query') {
            validationBuffer.writeln("    // Validate query parameter: $name");
            if (required) {
              validationBuffer.writeln('''
                if (!req.url.queryParameters.containsKey('$name')) {
                  openApiValidationErrors['$name'] = {
                    'code': 'VALIDATION_REQUIRED',
                    'message': 'Missing required query parameter: $name'
                  };
                }
              ''');
            }

            if (schemaMap.isNotEmpty) {
              validationBuffer.writeln(
                "    final ${name}Value = req.url.queryParameters['$name'];",
              );
              validationBuffer.writeln("    if (${name}Value != null) {");

              // Enum validation
              if (schemaMap.containsKey('enum')) {
                final enumValues = schemaMap['enum'] as List<dynamic>?;
                if (enumValues != null) {
                  final dartEnumList = enumValues.map((e) => "'$e'").join(', ');
                  validationBuffer.writeln('''
                    const allowedValues = [$dartEnumList];
                    if (!allowedValues.contains(${name}Value)) {
                      openApiValidationErrors['$name'] = {
                        'code': 'VALIDATION_ENUM',
                        'message': 'Invalid value. Allowed: \${allowedValues.join(", ")}',
                        'allowed': allowedValues
                      };
                    }
                  ''');
                }
              }

              // Numeric validation
              if (schemaMap['type'] == 'integer' ||
                  schemaMap['type'] == 'number') {
                validationBuffer.writeln(
                  "      final numValue = num.tryParse(${name}Value);",
                );
                validationBuffer.writeln("      if (numValue == null) {");
                validationBuffer.writeln('''
                  openApiValidationErrors['$name'] = {
                    'code': 'VALIDATION_IS_NUMERIC',
                    'message': 'Parameter $name must be a number'
                  };
                ''');
                validationBuffer.writeln("      }");

                if (schemaMap.containsKey('minimum')) {
                  final min = schemaMap['minimum'];
                  validationBuffer.writeln(
                    "      if (numValue != null && numValue < $min) {",
                  );
                  validationBuffer.writeln('''
                    openApiValidationErrors['$name'] = {
                      'code': 'VALIDATION_MIN',
                      'message': 'Parameter $name must be greater than or equal to $min',
                      'min': $min
                    };
                  ''');
                  validationBuffer.writeln("      }");
                }
                if (schemaMap.containsKey('maximum')) {
                  final max = schemaMap['maximum'];
                  validationBuffer.writeln(
                    "      if (numValue != null && numValue > $max) {",
                  );
                  validationBuffer.writeln('''
                    openApiValidationErrors['$name'] = {
                      'code': 'VALIDATION_MAX',
                      'message': 'Parameter $name must be less than or equal to $max',
                      'max': $max
                    };
                  ''');
                  validationBuffer.writeln("      }");
                }
              } else if (schemaMap['type'] == 'string') {
                if (schemaMap.containsKey('minLength')) {
                  final minLen = schemaMap['minLength'];
                  validationBuffer.writeln(
                    "      if (${name}Value.length < $minLen) {",
                  );
                  validationBuffer.writeln('''
                    openApiValidationErrors['$name'] = {
                      'code': 'VALIDATION_MIN_LENGTH',
                      'message': 'Parameter $name length must be at least $minLen',
                      'min': $minLen
                    };
                  ''');
                  validationBuffer.writeln("      }");
                }
                if (schemaMap.containsKey('maxLength')) {
                  final maxLen = schemaMap['maxLength'];
                  validationBuffer.writeln(
                    "      if (${name}Value.length > $maxLen) {",
                  );
                  validationBuffer.writeln('''
                    openApiValidationErrors['$name'] = {
                      'code': 'VALIDATION_MAX_LENGTH',
                      'message': 'Parameter $name length must be at most $maxLen',
                      'max': $maxLen
                    };
                  ''');
                  validationBuffer.writeln("      }");
                }
                if (schemaMap.containsKey('pattern')) {
                  final pattern = schemaMap['pattern'];
                  // Escape backslashes for the Dart string literal
                  final escapedPattern = pattern.toString().replaceAll(
                    r'\',
                    r'\\',
                  );
                  validationBuffer.writeln(
                    "      if (!RegExp(r'$escapedPattern').hasMatch(${name}Value)) {",
                  );
                  validationBuffer.writeln('''
                    openApiValidationErrors['$name'] = {
                      'code': 'VALIDATION_PATTERN',
                      'message': 'Parameter $name does not match pattern',
                      'pattern': r'$escapedPattern'
                    };
                  ''');
                  validationBuffer.writeln("      }");
                }
              }

              validationBuffer.writeln("    }");
            }
          }
        }
      }

      if (validationBuffer.isNotEmpty) {
        buffer.writeln(
          "    final openApiValidationErrors = <String, dynamic>{};",
        );
        buffer.write(validationBuffer);
      }

      // Validate Content-Type from simple list
      final contentTypes = constantValue
          .getField('contentTypes')
          ?.toListValue();
      if (contentTypes != null && contentTypes.isNotEmpty) {
        final allowedList = contentTypes
            .map((e) => e.toStringValue())
            .where((e) => e != null)
            .map((e) => "'$e'")
            .join(', ');

        buffer.writeln('''
            final validatingContentType = req.headers['content-type'];
            if (validatingContentType != null) {
              const allowedTypes = [$allowedList];
              final mimeType = validatingContentType.split(';').first.trim();
              if (!allowedTypes.contains(mimeType)) {
                 throw SparkHttpException(
                    400, 
                    'Invalid Content-Type',
                    code: 'INVALID_CONTENT_TYPE',
                    details: {'allowed': allowedTypes}
                 );
              }
            }
          ''');
      }

      if (validationBuffer.isNotEmpty) {
        buffer.writeln('    if (openApiValidationErrors.isNotEmpty) {');
        buffer.writeln(
          '      throw SparkValidationException(openApiValidationErrors);',
        );
        buffer.writeln('    }');
      }
    } catch (e) {
      // Ignore errors if annotation not found or invalid
    }
  }
}
