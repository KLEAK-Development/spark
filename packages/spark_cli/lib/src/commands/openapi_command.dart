import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:args/command_runner.dart';
import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../console/console_output.dart';

/// Generates an OpenAPI specification from Spark endpoints.
class OpenApiCommand extends Command<void> {
  @override
  String get name => 'openapi';

  @override
  String get description => 'Generate OpenAPI specification from endpoints.';

  final ConsoleOutput _console = ConsoleOutput();
  final Directory _workingDirectory;

  OpenApiCommand({Directory? workingDirectory})
    : _workingDirectory = workingDirectory ?? Directory.current {
    argParser.addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'openapi.json',
      help: 'Output file path (JSON).',
    );
  }

  @override
  Future<void> run() async {
    final outputPath = p.join(
      _workingDirectory.path,
      argResults!['output'] as String,
    );
    final rootDir = _workingDirectory.path;
    final libDir = p.join(rootDir, 'lib');
    final binDir = p.join(rootDir, 'bin');

    if (!await Directory(libDir).exists()) {
      _console.printError('No lib/ directory found.');
      exit(1);
    }

    final includedPaths = [libDir];
    if (await Directory(binDir).exists()) {
      includedPaths.add(binDir);
    }

    _console.printInfo('Scanning for endpoints in $libDir...');

    final collection = AnalysisContextCollection(
      includedPaths: includedPaths,
      resourceProvider: PhysicalResourceProvider.INSTANCE,
    );

    final paths = <String, Map<String, dynamic>>{};

    // Default openapi structure
    final openApi = <String, dynamic>{
      'openapi': '3.0.0',
      'info': {'title': 'Spark Application API', 'version': '1.0.0'},
      'paths': paths,
      'components': {'schemas': <String, dynamic>{}},
    };

    final schemas = openApi['components']['schemas'] as Map<String, dynamic>;

    for (final context in collection.contexts) {
      for (final filePath in context.contextRoot.analyzedFiles()) {
        if (!filePath.endsWith('.dart')) continue;

        // Skip generated files
        if (filePath.endsWith('.g.dart')) continue;

        final result = await context.currentSession.getResolvedUnit(filePath);
        if (result is ResolvedUnitResult) {
          if (!result.exists) continue;

          final library = result.libraryElement;

          for (final declaration in result.unit.declarations) {
            if (declaration is ClassDeclaration) {
              final className = declaration.namePart.typeName.lexeme;
              final element = library.classes.firstWhereOrNull(
                (c) => c.name == className,
              );
              if (element != null) {
                _processClass(element, declaration, paths, schemas);
              }
            }
          }

          // Check for main function in library children
          for (final child in library.children) {
            if (child.name == 'main') {
              _processGlobalConfig(child, openApi);
            }
          }
        }
      }
    }

    // Write output
    final jsonOutput = JsonEncoder.withIndent('  ').convert(openApi);
    final file = File(outputPath);
    await file.writeAsString(jsonOutput);

    _console.printSuccess('OpenAPI spec generated at $outputPath');
  }

  void _processGlobalConfig(Element element, Map<String, dynamic> openApi) {
    final annotation = _getAnnotation(element, 'OpenApi');
    if (annotation == null) return;

    final info = openApi['info'] as Map<String, dynamic>;

    final title = annotation.getField('title')?.toStringValue();
    final version = annotation.getField('version')?.toStringValue();
    final description = annotation.getField('description')?.toStringValue();

    if (title != null) info['title'] = title;
    if (version != null) info['version'] = version;
    if (description != null) info['description'] = description;

    final servers = annotation
        .getField('servers')
        ?.toListValue()
        ?.map((e) => e.toStringValue())
        .whereType<String>()
        .toList();

    if (servers != null && servers.isNotEmpty) {
      openApi['servers'] = servers.map((url) => {'url': url}).toList();
    }

    final security = annotation.getField('security')?.toListValue();
    if (security != null) {
      final securityList = _parseSecurityList(security);
      if (securityList.isNotEmpty) {
        openApi['security'] = securityList;
      }
    }

    final securitySchemes = annotation
        .getField('securitySchemes')
        ?.toMapValue();
    if (securitySchemes != null) {
      final components = openApi['components'] as Map<String, dynamic>;
      final schemesMap = <String, dynamic>{};

      securitySchemes.forEach((keyObj, valueObj) {
        final key = keyObj?.toStringValue();
        if (key != null && valueObj != null) {
          schemesMap[key] = _parseSecurityScheme(valueObj);
        }
      });

      if (schemesMap.isNotEmpty) {
        components['securitySchemes'] = schemesMap;
      }
    }
  }

  Map<String, dynamic> _parseSecurityScheme(DartObject valueObj) {
    final type = valueObj.getField('type')?.toStringValue();
    final description = valueObj.getField('description')?.toStringValue();
    final name = valueObj.getField('name')?.toStringValue();
    final inLocation = valueObj.getField('inLocation')?.toStringValue();
    final scheme = valueObj.getField('scheme')?.toStringValue();
    final bearerFormat = valueObj.getField('bearerFormat')?.toStringValue();
    final openIdConnectUrl = valueObj
        .getField('openIdConnectUrl')
        ?.toStringValue();

    final schemeData = <String, dynamic>{
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (name != null) 'name': name,
      if (inLocation != null) 'in': inLocation,
      if (scheme != null) 'scheme': scheme,
      if (bearerFormat != null) 'bearerFormat': bearerFormat,
      if (openIdConnectUrl != null) 'openIdConnectUrl': openIdConnectUrl,
    };

    final flows = valueObj.getField('flows')?.toMapValue();
    if (flows != null) {
      final flowsMap = <String, dynamic>{};
      flows.forEach((flowKey, flowValue) {
        final flowName = flowKey?.toStringValue();
        if (flowName != null && flowValue != null) {
          flowsMap[flowName] = _parseOAuthFlow(flowValue);
        }
      });
      if (flowsMap.isNotEmpty) {
        schemeData['flows'] = flowsMap;
      }
    }

    return schemeData;
  }

  Map<String, dynamic> _parseOAuthFlow(DartObject flowValue) {
    final authorizationUrl = flowValue
        .getField('authorizationUrl')
        ?.toStringValue();
    final tokenUrl = flowValue.getField('tokenUrl')?.toStringValue();
    final refreshUrl = flowValue.getField('refreshUrl')?.toStringValue();
    final scopes = flowValue.getField('scopes')?.toMapValue();

    final flowData = <String, dynamic>{
      if (authorizationUrl != null) 'authorizationUrl': authorizationUrl,
      if (tokenUrl != null) 'tokenUrl': tokenUrl,
      if (refreshUrl != null) 'refreshUrl': refreshUrl,
    };

    if (scopes != null) {
      final scopesMap = <String, String>{};
      scopes.forEach((k, v) {
        final scopeKey = k?.toStringValue();
        final scopeDesc = v?.toStringValue();
        if (scopeKey != null && scopeDesc != null) {
          scopesMap[scopeKey] = scopeDesc;
        }
      });
      flowData['scopes'] = scopesMap;
    }
    return flowData;
  }

  List<Map<String, List<String>>> _parseSecurityList(
    List<DartObject> security,
  ) {
    final securityList = <Map<String, List<String>>>[];
    for (final secItem in security) {
      final secMap = secItem.toMapValue();
      if (secMap != null) {
        final newMap = <String, List<String>>{};
        secMap.forEach((key, value) {
          final keyStr = key?.toStringValue();
          final valueList = value
              ?.toListValue()
              ?.map((e) => e.toStringValue())
              .whereType<String>()
              .toList();
          if (keyStr != null && valueList != null) {
            newMap[keyStr] = valueList;
          }
        });
        if (newMap.isNotEmpty) {
          securityList.add(newMap);
        }
      }
    }
    return securityList;
  }

  void _processClass(
    ClassElement element,
    ClassDeclaration classNode,
    Map<String, dynamic> paths,
    Map<String, dynamic> schemas,
  ) {
    final endpointAnnotation = _getAnnotation(element, 'Endpoint');
    if (endpointAnnotation == null) return;

    final path = endpointAnnotation.getField('path')?.toStringValue();
    final method = endpointAnnotation
        .getField('method')
        ?.toStringValue()
        ?.toLowerCase();

    if (path == null || method == null) return;

    // Convert Spark path params :id to OpenAPI {id}
    final openApiPath = path.replaceAllMapped(
      RegExp(r'[:\{](\w+)[\}]?'),
      (match) => '{${match.group(1)!}}',
    );

    // Initialize path item
    paths[openApiPath] ??= <String, dynamic>{};
    final pathItem = paths[openApiPath] as Map<String, dynamic>;

    // Build operation object
    final operation = _createBaseOperation(endpointAnnotation, element);

    // Process Parameters
    final parameters = <Map<String, dynamic>>[];
    _processPathParameters(path, parameters, schemas);
    _processCustomParameters(endpointAnnotation, parameters, schemas);
    if (parameters.isNotEmpty) {
      operation['parameters'] = parameters;
    }

    // Process Request Body
    _deduceRequestBody(operation, endpointAnnotation, element, schemas);

    // Process Responses & Errors
    final statusCode = endpointAnnotation.getField('statusCode')?.toIntValue();
    _deduceSuccessResponse(classNode, operation, method, statusCode, schemas);
    _deduceErrorResponses(classNode, operation, element.library);

    if (operation.containsKey('requestBody')) {
      final requestBody = operation['requestBody'] as Map<String, dynamic>;
      _deduceValidationErrors(requestBody, operation, schemas);
    }
    _deduceMiddlewareErrors(classNode, operation);

    // External Docs & Security
    _processExternalDocs(operation, endpointAnnotation);
    _processSecurity(operation, endpointAnnotation);

    pathItem[method] = operation;
  }

  Map<String, dynamic> _createBaseOperation(
    DartObject annotation,
    ClassElement element,
  ) {
    final summary = annotation.getField('summary')?.toStringValue();
    final description = annotation.getField('description')?.toStringValue();
    final operationId = annotation.getField('operationId')?.toStringValue();
    final deprecated = annotation.getField('deprecated')?.toBoolValue();
    final tags = annotation
        .getField('tags')
        ?.toListValue()
        ?.map((e) => e.toStringValue())
        .whereType<String>()
        .toList();

    final operation = <String, dynamic>{
      'summary': summary ?? element.name,
      if (description != null && description.isNotEmpty)
        'description': description,
      'responses': <String, dynamic>{},
    };

    if (tags != null && tags.isNotEmpty) operation['tags'] = tags;
    if (operationId != null) operation['operationId'] = operationId;
    if (deprecated == true) operation['deprecated'] = true;

    return operation;
  }

  void _processPathParameters(
    String path,
    List<Map<String, dynamic>> parameters,
    Map<String, dynamic> schemas,
  ) {
    final pathParams = RegExp(r'[:\{](\w+)[\}]?').allMatches(path);
    if (pathParams.isNotEmpty) {
      parameters.addAll(
        pathParams.map((match) {
          return {
            'name': match.group(1) ?? 'param',
            'in': 'path',
            'required': true,
            'schema': {'type': 'string'}, // Default to string for now
          };
        }),
      );
    }
  }

  void _processCustomParameters(
    DartObject annotation,
    List<Map<String, dynamic>> parameters,
    Map<String, dynamic> schemas,
  ) {
    final extraParams = annotation.getField('parameters')?.toListValue();
    if (extraParams != null) {
      for (final pObj in extraParams) {
        final name = pObj.getField('name')?.toStringValue();
        final inLoc = pObj.getField('inLocation')?.toStringValue();
        if (name != null && inLoc != null) {
          final paramConfig = <String, dynamic>{'name': name, 'in': inLoc};

          final pDesc = pObj.getField('description')?.toStringValue();
          final pReq = pObj.getField('required')?.toBoolValue();
          final pDep = pObj.getField('deprecated')?.toBoolValue();

          if (pDesc != null) paramConfig['description'] = pDesc;
          if (pReq != null) paramConfig['required'] = pReq;
          if (pDep != null) paramConfig['deprecated'] = pDep;

          final pType = pObj.getField('type')?.toTypeValue();
          if (pType != null) {
            paramConfig['schema'] = _ensureSchema(pType, schemas);
          } else {
            final pSchema = pObj.getField('schema')?.toMapValue();
            if (pSchema != null) {
              paramConfig['schema'] = _parseManualSchema(pSchema);
            }
          }

          // Merge or add
          final existingIndex = parameters.indexWhere(
            (p) => p['name'] == name && p['in'] == inLoc,
          );
          if (existingIndex >= 0) {
            parameters[existingIndex].addAll(paramConfig);
          } else {
            parameters.add(paramConfig);
          }
        }
      }
    }
  }

  Map<String, dynamic> _parseManualSchema(
    Map<DartObject?, DartObject?> pSchema,
  ) {
    final schemaMap = <String, dynamic>{};
    pSchema.forEach((k, v) {
      final keyStr = k?.toStringValue();
      if (keyStr == null) return;
      if (v != null) {
        if (v.toBoolValue() != null) {
          schemaMap[keyStr] = v.toBoolValue();
        } else if (v.toIntValue() != null) {
          schemaMap[keyStr] = v.toIntValue();
        } else if (v.toDoubleValue() != null) {
          schemaMap[keyStr] = v.toDoubleValue();
        } else if (v.toStringValue() != null) {
          schemaMap[keyStr] = v.toStringValue();
        } else if (v.toListValue() != null) {
          schemaMap[keyStr] = v
              .toListValue()!
              .map((e) => e.toStringValue())
              .toList();
        }
      }
    });
    return schemaMap;
  }

  void _processExternalDocs(
    Map<String, dynamic> operation,
    DartObject annotation,
  ) {
    final externalDocs = annotation.getField('externalDocs');
    if (externalDocs != null && !externalDocs.isNull) {
      final docUrl = externalDocs.getField('url')?.toStringValue();
      final docDesc = externalDocs.getField('description')?.toStringValue();
      if (docUrl != null) {
        operation['externalDocs'] = {
          'url': docUrl,
          if (docDesc != null) 'description': docDesc,
        };
      }
    }
  }

  void _processSecurity(Map<String, dynamic> operation, DartObject annotation) {
    final security = annotation.getField('security')?.toListValue();
    if (security != null) {
      final securityList = _parseSecurityList(security);
      if (securityList.isNotEmpty) {
        operation['security'] = securityList;
      }
    }
  }

  void _deduceRequestBody(
    Map<String, dynamic> operation,
    DartObject annotation,
    ClassElement element,
    Map<String, dynamic> schemas,
  ) {
    final contentTypes = annotation
        .getField('contentTypes')
        ?.toListValue()
        ?.map((e) => e.toStringValue())
        .whereType<String>()
        .toList();

    // Inference from Code
    DartType? bodyType;
    bool isRequired = false;

    // Check if it extends SparkEndpointWithBody<T>
    for (final supertype in element.allSupertypes) {
      if (supertype.element.name == 'SparkEndpointWithBody') {
        if (supertype.typeArguments.isNotEmpty) {
          bodyType = supertype.typeArguments.first;
        }
        break;
      }
    }

    if (bodyType != null) {
      // SparkEndpointWithBody<T>
      final handler = element.methods.firstWhereOrNull(
        (m) => m.name == 'handler',
      );
      if (handler != null) {
        final normalParams = handler.type.normalParameterTypes;
        final optionalParams = handler.type.optionalParameterTypes;

        if (normalParams.length >= 2) {
          final bodyType = normalParams[1];
          isRequired = bodyType.nullabilitySuffix != NullabilitySuffix.question;
        } else if (normalParams.length == 1 && optionalParams.isNotEmpty) {
          isRequired = false;
        } else {
          isRequired = true;
        }
      } else {
        isRequired = true;
      }

      final contentMap = <String, dynamic>{};
      final types = (contentTypes != null && contentTypes.isNotEmpty)
          ? contentTypes
          : ['application/json'];

      final schema = _ensureSchema(bodyType, schemas);

      for (final type in types) {
        contentMap[type] = {'schema': schema};
      }

      operation['requestBody'] = {
        'required': isRequired,
        'content': contentMap,
      };
    } else {
      // SparkEndpoint (no specific body type)
      if (contentTypes != null && contentTypes.isNotEmpty) {
        final contentMap = <String, dynamic>{};
        for (final type in contentTypes) {
          contentMap[type] = {'schema': <String, dynamic>{}};
        }
        operation['requestBody'] = {'required': false, 'content': contentMap};
      }
    }
  }

  void _deduceSuccessResponse(
    ClassDeclaration classNode,
    Map<String, dynamic> operation,
    String method,
    int? overrideStatusCode,
    Map<String, dynamic> schemas,
  ) {
    int statusCode;
    if (overrideStatusCode != null) {
      statusCode = overrideStatusCode;
    } else {
      switch (method.toUpperCase()) {
        case 'POST':
          statusCode = 201;
          break;
        case 'DELETE':
          statusCode = 200;
          break;
        default:
          statusCode = 200;
      }
    }

    final responses = operation['responses'] as Map<String, dynamic>;
    if (responses.containsKey(statusCode.toString())) {
      return;
    }

    final members = classNode.body is BlockClassBody
        ? (classNode.body as BlockClassBody).members
        : <ClassMember>[];

    final handlerMethod = members
        .whereType<MethodDeclaration>()
        .firstWhereOrNull((m) => m.name.lexeme == 'handler');

    Map<String, dynamic> responseContent = {};

    if (handlerMethod != null) {
      final returnType = handlerMethod.returnType?.type;
      if (returnType != null) {
        DartType type = returnType;
        if (type.isDartAsyncFuture || type.isDartAsyncFutureOr) {
          if (type is InterfaceType && type.typeArguments.isNotEmpty) {
            type = type.typeArguments.first;
          }
        }

        if (type is! VoidType && type is! DynamicType) {
          final schema = _ensureSchema(type, schemas);
          final isPrimitive =
              type.isDartCoreString ||
              type.isDartCoreInt ||
              type.isDartCoreDouble ||
              type.isDartCoreNum ||
              type.isDartCoreBool ||
              (type.element?.name == 'DateTime' &&
                  type.element?.library?.name == 'dart.core');

          final contentType = isPrimitive ? 'text/plain' : 'application/json';
          responseContent = {
            contentType: {'schema': schema},
          };
        }
      }
    }

    responses[statusCode.toString()] = {
      'description': 'Successful operation',
      if (responseContent.isNotEmpty) 'content': responseContent,
    };
  }

  void _deduceErrorResponses(
    ClassDeclaration classNode,
    Map<String, dynamic> operation,
    LibraryElement library,
  ) {
    final members = classNode.body is BlockClassBody
        ? (classNode.body as BlockClassBody).members
        : <ClassMember>[];

    var handlerMethod = members.whereType<MethodDeclaration>().firstWhereOrNull(
      (m) => m.name.lexeme == 'handler',
    );

    handlerMethod ??= members.whereType<MethodDeclaration>().firstOrNull;

    if (handlerMethod == null) return;

    final responses = operation['responses'] as Map<String, dynamic>;

    _addErrorResponse(
      responses,
      500,
      'Internal Server Error',
      'INTERNAL_ERROR',
    );

    handlerMethod.visitChildren(
      _ThrowVisitor(library, (code, message, errorCode) {
        _addErrorResponse(responses, code, message, errorCode);
      }),
    );
  }

  void _deduceValidationErrors(
    Map<String, dynamic> requestBody,
    Map<String, dynamic> operation,
    Map<String, dynamic> schemas,
  ) {
    if (requestBody.containsKey('content')) {
      final content = requestBody['content'] as Map<String, dynamic>;
      if (content.containsKey('application/json')) {
        final schema =
            content['application/json']['schema'] as Map<String, dynamic>;
        if (schema.containsKey('\$ref')) {
          final schemaRef = schema['\$ref'] as String;
          final schemaName = schemaRef.split('/').last;

          if (schemas.containsKey(schemaName)) {
            final schemaDef = schemas[schemaName] as Map<String, dynamic>;
            if (schemaDef.containsKey('properties')) {
              final responses = operation['responses'] as Map<String, dynamic>;
              if (!responses.containsKey('400')) {
                responses['400'] = {
                  'description': 'Validation Error',
                  'content': {
                    'application/json': {
                      'schema': {
                        'type': 'object',
                        'properties': {
                          'message': {'type': 'string'},
                          'code': {
                            'type': 'string',
                            'example': 'VALIDATION_ERROR',
                          },
                          'details': {'type': 'object'},
                        },
                      },
                    },
                  },
                };
              }
            }
          }
        }
      }
    }
  }

  void _deduceMiddlewareErrors(
    ClassDeclaration classNode,
    Map<String, dynamic> operation,
  ) {
    MethodDeclaration? middlewareGetter;
    final members = classNode.body is BlockClassBody
        ? (classNode.body as BlockClassBody).members
        : const <ClassMember>[];

    for (final member in members) {
      if (member is MethodDeclaration &&
          member.name.lexeme == 'middleware' &&
          member.isGetter) {
        middlewareGetter = member;
        break;
      }
    }

    if (middlewareGetter == null) {
      return;
    }

    final body = middlewareGetter.body;
    if (body is ExpressionFunctionBody) {
      _analyzeMiddlewareExpression(body.expression, operation);
    } else if (body is BlockFunctionBody) {
      for (final stmt in body.block.statements) {
        if (stmt is ReturnStatement && stmt.expression != null) {
          _analyzeMiddlewareExpression(stmt.expression!, operation);
        }
      }
    }
  }

  void _analyzeMiddlewareExpression(
    Expression expression,
    Map<String, dynamic> operation,
  ) {
    if (expression is ListLiteral) {
      for (final element in expression.elements) {
        if (element is MethodInvocation) {
          final methodElement = element.methodName.element;
          if (methodElement != null) {
            _analyzeElementSource(methodElement, operation);
          }
        } else if (element is InstanceCreationExpression) {
          final typeElement = element.constructorName.type.element;
          if (typeElement is ClassElement) {
            _analyzeElementSource(typeElement, operation);
          }
        }
      }
    }
  }

  void _addErrorResponse(
    Map<String, dynamic> responses,
    int statusCode,
    String message,
    String errorCode,
  ) {
    final codeStr = statusCode.toString();

    final newSchema = {
      'type': 'object',
      'properties': {
        'message': {'type': 'string', 'example': message},
        'code': {'type': 'string', 'example': errorCode},
      },
    };

    if (responses.containsKey(codeStr)) {
      final content = responses[codeStr]['content'] as Map<String, dynamic>?;
      final jsonContent = content?['application/json'] as Map<String, dynamic>?;
      var existingSchema = jsonContent?['schema'] as Map<String, dynamic>?;

      if (existingSchema != null) {
        if (existingSchema.containsKey('oneOf')) {
          final list = existingSchema['oneOf'] as List;
          // Avoid duplicates
          final isDuplicate = list.any((s) {
            final props = s['properties'] as Map<String, dynamic>?;
            final code = props?['code']?['example'];
            return code == errorCode;
          });

          if (!isDuplicate) {
            list.add(newSchema);
          }
        } else {
          // Convert to oneOf if different
          final props = existingSchema['properties'] as Map<String, dynamic>?;
          final code = props?['code']?['example'];

          if (code != errorCode) {
            final newList = [existingSchema, newSchema];
            responses[codeStr]['content']['application/json']['schema'] = {
              'oneOf': newList,
            };
            responses[codeStr]['description'] = 'Multiple possible errors';
          }
        }
      }
    } else {
      responses[codeStr] = {
        'description': message,
        'content': {
          'application/json': {'schema': newSchema},
        },
      };
    }
  }

  // Schema generation helpers
  Map<String, dynamic> _ensureSchema(
    DartType type,
    Map<String, dynamic> schemas,
  ) {
    // Basic types
    if (type.isDartCoreInt) return {'type': 'integer'};
    if (type.isDartCoreDouble || type.isDartCoreNum) return {'type': 'number'};
    if (type.isDartCoreString) return {'type': 'string'};
    if (type.isDartCoreBool) return {'type': 'boolean'};
    if (type.element?.name == 'DateTime' &&
        type.element?.library?.name == 'dart.core') {
      return {'type': 'string', 'format': 'date-time'};
    }
    if (type.isDartCoreList) {
      if (type is InterfaceType && type.typeArguments.isNotEmpty) {
        return {
          'type': 'array',
          'items': _ensureSchema(type.typeArguments.first, schemas),
        };
      }
      return {'type': 'array'};
    }
    if (type.isDartCoreMap) return {'type': 'object'};

    // DTOs / Classes
    if (type is InterfaceType) {
      final name = type.element.name ?? '';
      if (!schemas.containsKey(name)) {
        // Placeholder to avoid infinite recursion
        schemas[name] = <String, dynamic>{};

        final properties = <String, dynamic>{};
        final required = <String>[];

        for (final field in type.element.fields) {
          if (field.isStatic) continue;
          // Skip internal/generated fields
          final fieldName = field.name ?? '';
          if (fieldName.startsWith('_')) continue;

          final fieldSchema = _ensureSchema(field.type, schemas);
          _extractValidation(field, fieldSchema);
          properties[fieldName] = fieldSchema;
          if (field.type.nullabilitySuffix != NullabilitySuffix.question) {
            required.add(fieldName);
          }
        }

        schemas[name] = {
          'type': 'object',
          'properties': properties,
          if (required.isNotEmpty) 'required': required,
        };
      }
      return {'\$ref': '#/components/schemas/$name'};
    }

    return {'type': 'string'}; // Fallback
  }

  void _extractValidation(FieldElement field, Map<String, dynamic> schema) {
    for (final meta in field.metadata.annotations) {
      final value = meta.computeConstantValue();
      if (value == null) continue;
      final typeName = value.type?.element?.name;

      if (typeName == 'NotEmpty') {
        if (schema['type'] == 'string') {
          schema['minLength'] = 1;
        }
        if (schema['type'] == 'array') {
          schema['minItems'] = 1;
        }
      } else if (typeName == 'Length') {
        final min = value.getField('min')?.toIntValue();
        final max = value.getField('max')?.toIntValue();
        if (min != null) schema['minLength'] = min;
        if (max != null) schema['maxLength'] = max;
      } else if (typeName == 'Min') {
        final v =
            value.getField('value')?.toDoubleValue() ??
            value.getField('value')?.toIntValue()?.toDouble();
        if (v != null) schema['minimum'] = v;
      } else if (typeName == 'Max') {
        final v =
            value.getField('value')?.toDoubleValue() ??
            value.getField('value')?.toIntValue()?.toDouble();
        if (v != null) schema['maximum'] = v;
      } else if (typeName == 'Email') {
        schema['format'] = 'email';
      } else if (typeName == 'Pattern') {
        final p = value.getField('pattern')?.toStringValue();
        if (p != null) schema['pattern'] = p;
      } else if (typeName == 'IsBooleanString') {
        schema['enum'] = ['true', 'false', '1', '0'];
      }
    }
  }

  DartObject? _getAnnotation(Element element, String name) {
    final metaObj = element.metadata.annotations;
    for (final meta in metaObj) {
      final value = meta.computeConstantValue();
      if (value != null) {
        final type = value.type;
        if (type != null && type.element?.name == name) {
          return value;
        }
      }
    }
    return null;
  }

  void _analyzeElementSource(Element element, Map<String, dynamic> operation) {
    try {
      final session = element.session;
      if (session == null) return;

      final library = element.library;
      if (library == null) return;
      final parsedLib = session.getParsedLibraryByElement(library);
      if (parsedLib is ParsedLibraryResult) {
        final declaration = parsedLib.units
            .expand((u) => u.unit.declarations)
            .firstWhereOrNull((d) {
              if (d is ClassDeclaration) {
                return d.namePart.toString() == element.name;
              } else if (d is FunctionDeclaration) {
                return d.name.lexeme == element.name;
              } else if (d is EnumDeclaration) {
                return d.namePart.toString() == element.name;
              } else if (d is MixinDeclaration) {
                return d.name.lexeme == element.name;
              } else if (d is ExtensionTypeDeclaration) {
                return d.primaryConstructor.typeName.lexeme == element.name;
              } else if (d is ExtensionDeclaration) {
                return d.name?.lexeme == element.name;
              }
              return false;
            });

        final node = declaration;
        if (node != null) {
          final responses = operation['responses'] as Map<String, dynamic>;
          node.visitChildren(
            _ThrowVisitor(library, (code, message, errorCode) {
              _addErrorResponse(responses, code, message, errorCode);
            }),
          );
        }
      }
    } catch (e) {
      // Ignore errors
    }
  }
}

class _ThrowVisitor extends RecursiveAstVisitor<void> {
  final LibraryElement library;
  final Function(int, String, String) onErrorFound;

  _ThrowVisitor(this.library, this.onErrorFound);

  @override
  void visitThrowExpression(ThrowExpression node) {
    final expression = node.expression;
    String? type;
    ArgumentList? argList;

    if (expression is InstanceCreationExpression) {
      type = expression.constructorName.type.name.lexeme;
      argList = expression.argumentList;
    } else if (expression is MethodInvocation) {
      type = expression.methodName.name;
      argList = expression.argumentList;
    }

    if (type != null && argList != null) {
      if (type == 'ApiError') {
        final args = argList.arguments;
        int code = 500;
        String message = 'Error';
        String errorCode = 'ERROR';

        for (final arg in args) {
          if (arg is NamedExpression) {
            final name = arg.name.label.name;
            if (name == 'statusCode') {
              final val = _extractIntValue(arg.expression);
              if (val != null) code = val;
            } else if (name == 'code') {
              errorCode = _extractStringValue(arg.expression) ?? errorCode;
            } else if (name == 'message') {
              message = _extractStringValue(arg.expression) ?? message;
            }
          }
        }
        onErrorFound(code, message, errorCode);
      } else if (_isApiErrorSubclass(type)) {
        // For ApiError subclasses, extract details from super() call
        if (expression is InstanceCreationExpression) {
          final details = _extractApiErrorSubclassDetails(type, expression);
          if (details != null) {
            onErrorFound(details.$1, details.$3, details.$2);
          }
        }
      } else if (type == 'SparkHttpException') {
        final args = argList.arguments;
        if (args.isNotEmpty) {
          final codeArg = args[0];
          final val = _extractIntValue(codeArg);
          if (val != null) {
            String message = 'Error';
            if (args.length > 1) {
              message = _extractStringValue(args[1]) ?? message;
            }
            onErrorFound(val, message, 'ERROR');
          }
        }
      }
    }
    super.visitThrowExpression(node);
  }

  /// Check if a class by name extends ApiError by looking it up in the library
  bool _isApiErrorSubclass(String className) {
    // Look up the class in all classes defined in the library
    for (final classElement in library.classes) {
      if (classElement.name == className) {
        for (final supertype in classElement.allSupertypes) {
          if (supertype.element.name == 'ApiError') {
            return true;
          }
        }
        return false;
      }
    }
    return false;
  }

  /// Extracts statusCode, code, message from an ApiError subclass constructor.
  /// Returns null if extraction fails.
  (int, String, String)? _extractApiErrorSubclassDetails(
    String className,
    InstanceCreationExpression? creationExpression,
  ) {
    // Look up the class element from library.classes (already verified in _isApiErrorSubclass)
    InterfaceElement? classElement;
    for (final c in library.classes) {
      if (c.name == className) {
        classElement = c;
        break;
      }
    }
    if (classElement == null) return null;

    // Find the unnamed constructor
    ConstructorElement? constructor;
    for (final c in classElement.constructors) {
      final cName = c.name ?? '';
      if (cName.isEmpty) {
        constructor = c;
        break;
      }
    }
    if (constructor == null && classElement.constructors.isNotEmpty) {
      constructor = classElement.constructors.first;
    }
    if (constructor == null) return null;

    // Get constructor node to find super() call
    final session = classElement.session;
    if (session == null) return null;

    final classLibrary = classElement.library;
    final parsedLib = session.getParsedLibraryByElement(classLibrary);
    if (parsedLib is! ParsedLibraryResult) return null;

    // Find the constructor declaration
    ConstructorDeclaration? constructorNode;
    for (final unit in parsedLib.units) {
      for (final decl in unit.unit.declarations) {
        if (decl is ClassDeclaration &&
            decl.namePart.typeName.lexeme == classElement.name) {
          for (final member in (decl.body as BlockClassBody).members) {
            if (member is ConstructorDeclaration) {
              final memberName = member.name?.lexeme ?? '';
              final cName = constructor.name ?? '';
              // Treat "new" as empty string (unnamed constructor)
              final normalizedCName = (cName == 'new' || cName.isEmpty)
                  ? ''
                  : cName;
              if (memberName.isEmpty && normalizedCName.isEmpty) {
                constructorNode = member;
                break;
              } else if (memberName == normalizedCName) {
                constructorNode = member;
                break;
              }
            }
          }
        }
      }
      if (constructorNode != null) break;
    }

    if (constructorNode == null) return null;

    // Map parameters to arguments if creationExpression is provided
    final paramMap = <String, Expression>{};
    if (creationExpression != null) {
      final args = creationExpression.argumentList.arguments;
      final params = constructorNode.parameters.parameters;
      int positionalIndex = 0;

      for (final param in params) {
        final paramName = param.name?.lexeme;
        if (paramName == null) continue;

        if (param.isNamed) {
          final arg = args.firstWhereOrNull(
            (a) => a is NamedExpression && a.name.label.name == paramName,
          );
          if (arg is NamedExpression) {
            paramMap[paramName] = arg.expression;
          }
        } else {
          // Positional
          if (positionalIndex < args.length) {
            final arg = args[positionalIndex];
            if (arg is! NamedExpression) {
              paramMap[paramName] = arg;
              positionalIndex++;
            }
          }
        }
      }
    }

    // Find super() initializer
    for (final initializer in constructorNode.initializers) {
      if (initializer is SuperConstructorInvocation) {
        int statusCode = 500;
        String code = 'ERROR';
        String message = 'Error';

        for (final arg in initializer.argumentList.arguments) {
          if (arg is NamedExpression) {
            final name = arg.name.label.name;
            if (name == 'statusCode') {
              final val = _extractIntValue(arg.expression);
              if (val != null) statusCode = val;
            } else if (name == 'code') {
              code = _resolveStringExpression(arg.expression, paramMap) ?? code;
            } else if (name == 'message') {
              message =
                  _resolveStringExpression(arg.expression, paramMap) ?? message;
            }
          }
        }
        return (statusCode, code, message);
      }
    }
    return null;
  }

  int? _extractIntValue(Expression expr) {
    if (expr is IntegerLiteral) return expr.value;
    return null;
  }

  String? _extractStringValue(Expression expr) {
    if (expr is StringLiteral) return expr.stringValue;
    return null;
  }

  String? _resolveStringExpression(
    Expression expr,
    Map<String, Expression> paramMap,
  ) {
    if (expr is StringLiteral && expr.stringValue != null) {
      return expr.stringValue;
    }

    if (expr is StringInterpolation) {
      final buffer = StringBuffer();
      for (final element in expr.elements) {
        if (element is InterpolationString) {
          buffer.write(element.value);
        } else if (element is InterpolationExpression) {
          final metaExpr = element.expression;
          if (metaExpr is SimpleIdentifier) {
            final paramName = metaExpr.name;
            if (paramMap.containsKey(paramName)) {
              final argExpr = paramMap[paramName];
              if (argExpr != null) {
                final val = _resolveStringExpression(argExpr, {});
                if (val != null) {
                  buffer.write(val);
                } else {
                  // Fallback: simpler representation or placeholder?
                  // For now, if we can't resolve, we might return null for whole string
                  // or just continue. Let's return null to indicate failure to fully resolve.
                  return null;
                }
              } else {
                return null;
              }
            } else {
              return null;
            }
          } else {
            return null;
          }
        }
      }
      return buffer.toString();
    }
    return null;
  }
}
