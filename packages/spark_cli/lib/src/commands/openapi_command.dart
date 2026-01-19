import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart'; // Needed for AST iteration
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';

import '../console/console_output.dart';

/// Generates an OpenAPI specification from Spark endpoints.
class OpenApiCommand extends Command<void> {
  @override
  String get name => 'openapi';

  @override
  String get description => 'Generate OpenAPI specification from endpoints.';

  final ConsoleOutput _console = ConsoleOutput();

  OpenApiCommand() {
    argParser.addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'openapi.json',
      help: 'Output file path (JSON).',
    );
  }

  @override
  Future<void> run() async {
    final outputPath = argResults!['output'] as String;
    final rootDir = Directory.current.path;
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
          final type = valueObj.getField('type')?.toStringValue();
          final description = valueObj.getField('description')?.toStringValue();
          final name = valueObj.getField('name')?.toStringValue();
          final inLocation = valueObj.getField('inLocation')?.toStringValue();
          final scheme = valueObj.getField('scheme')?.toStringValue();
          final bearerFormat = valueObj
              .getField('bearerFormat')
              ?.toStringValue();
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
                final authorizationUrl = flowValue
                    .getField('authorizationUrl')
                    ?.toStringValue();
                final tokenUrl = flowValue
                    .getField('tokenUrl')
                    ?.toStringValue();
                final refreshUrl = flowValue
                    .getField('refreshUrl')
                    ?.toStringValue();
                final scopes = flowValue.getField('scopes')?.toMapValue();

                final flowData = <String, dynamic>{
                  if (authorizationUrl != null)
                    'authorizationUrl': authorizationUrl,
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
                flowsMap[flowName] = flowData;
              }
            });
            if (flowsMap.isNotEmpty) {
              schemeData['flows'] = flowsMap;
            }
          }

          schemesMap[key] = schemeData;
        }
      });

      if (schemesMap.isNotEmpty) {
        components['securitySchemes'] = schemesMap;
      }
    }
  }

  void _processClass(
    ClassElement element,
    ClassDeclaration classNode,
    Map<String, dynamic> paths,
    Map<String, dynamic> schemas,
  ) {
    // Check for @Endpoint annotation
    final endpointAnnotation = _getAnnotation(element, 'Endpoint');
    if (endpointAnnotation == null) return;

    final path = endpointAnnotation.getField('path')?.toStringValue();
    final method = endpointAnnotation
        .getField('method')
        ?.toStringValue()
        ?.toLowerCase();

    if (path == null || method == null) return;

    // Extract OpenApiPath fields from Endpoint
    final summary = endpointAnnotation.getField('summary')?.toStringValue();
    final description = endpointAnnotation
        .getField('description')
        ?.toStringValue();
    final operationId = endpointAnnotation
        .getField('operationId')
        ?.toStringValue();
    final deprecated = endpointAnnotation.getField('deprecated')?.toBoolValue();
    final tags = endpointAnnotation
        .getField('tags')
        ?.toListValue()
        ?.map((e) => e.toStringValue())
        .whereType<String>()
        .toList();

    final statusCode = endpointAnnotation.getField('statusCode')?.toIntValue();

    // Convert Spark path params :id to OpenAPI {id}
    final openApiPath = path.replaceAllMapped(
      RegExp(r'[:\{](\w+)[\}]?'),
      (match) => '{${match.group(1)!}}',
    );

    // Initialize path item
    paths[openApiPath] ??= <String, dynamic>{};
    final pathItem = paths[openApiPath] as Map<String, dynamic>;

    // Build operation object
    final operation = <String, dynamic>{
      'summary': summary ?? element.name,
      if (description != null && description.isNotEmpty)
        'description': description,
      'responses': <String, dynamic>{},
    };

    // Deduce success response
    _deduceSuccessResponse(classNode, operation, method, statusCode, schemas);

    if (tags != null && tags.isNotEmpty) operation['tags'] = tags;
    if (operationId != null) operation['operationId'] = operationId;
    if (deprecated == true) operation['deprecated'] = true;

    // External Docs
    final externalDocs = endpointAnnotation.getField('externalDocs');
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

    // Security overrides
    final security = endpointAnnotation.getField('security')?.toListValue();
    if (security != null) {
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
      operation['security'] = securityList;
    }

    // Add path parameters
    final parameters = <Map<String, dynamic>>[];
    // Match both :id and {id}
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

    // Custom Parameters
    final extraParams = endpointAnnotation
        .getField('parameters')
        ?.toListValue();
    if (extraParams != null) {
      for (final pObj in extraParams) {
        // pObj is the Parameter instance
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

          // Schema priorities: type > schema field
          final pType = pObj.getField('type')?.toTypeValue();
          if (pType != null) {
            paramConfig['schema'] = _ensureSchema(pType, schemas);
          } else {
            final pSchema = pObj.getField('schema')?.toMapValue();
            if (pSchema != null) {
              // Manual schema map building would go here
              final schemaMap = <String, dynamic>{};
              pSchema.forEach((k, v) {
                final keyStr = k?.toStringValue();
                if (keyStr == null) return;
                // Simplified handling for basic values
                // In a real scenario, this needs recursive DartObject -> json logic
                // For now, handling basic types and lists of strings (enums)
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
              paramConfig['schema'] = schemaMap;
            }
          }

          // Check if we already added this path param
          final existingIndex = parameters.indexWhere(
            (p) => p['name'] == name && p['in'] == inLoc,
          );
          if (existingIndex >= 0) {
            // update existing
            parameters[existingIndex].addAll(paramConfig);
          } else {
            parameters.add(paramConfig);
          }
        }
      }
    }

    if (parameters.isNotEmpty) {
      operation['parameters'] = parameters;
    }

    // Deduce Request Body
    final contentTypes = endpointAnnotation
        .getField('contentTypes')
        ?.toListValue()
        ?.map((e) => e.toStringValue())
        .whereType<String>()
        .toList();

    _deduceRequestBody(operation, element, schemas, contentTypes);

    // Deduce errors from AST
    _deduceErrorResponses(classNode, operation);

    // Deduce validation errors from Request Body
    if (operation.containsKey('requestBody')) {
      final requestBody = operation['requestBody'] as Map<String, dynamic>;
      _deduceValidationErrors(requestBody, operation, schemas);
    }

    // Deduce middleware errors
    _deduceMiddlewareErrors(classNode, operation);

    pathItem[method] = operation;
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
      // Default based on method
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
      return; // Already handled (unlikely here but safety check)
    }

    // Analyze handler return type
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
        // Unwrap Future<T>
        if (type.isDartAsyncFuture || type.isDartAsyncFutureOr) {
          if (type is InterfaceType && type.typeArguments.isNotEmpty) {
            type = type.typeArguments.first;
          }
        }

        if (type is! VoidType && type is! DynamicType) {
          final schema = _ensureSchema(type, schemas);
          responseContent = {
            'application/json': {'schema': schema},
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
  ) {
    // Get members from body to avoid deprecation
    final members = classNode.body is BlockClassBody
        ? (classNode.body as BlockClassBody).members
        : <ClassMember>[];

    final handlerMethod = members.whereType<MethodDeclaration>().firstWhere(
      (m) => m.name.lexeme == 'handler',
      orElse: () => members.whereType<MethodDeclaration>().first,
    );

    final responses = operation['responses'] as Map<String, dynamic>;

    // Add default Internal Server Error (always present due to global error handler)
    _addErrorResponse(
      responses,
      500,
      'Internal Server Error',
      'INTERNAL_ERROR',
    );

    handlerMethod.visitChildren(
      _ThrowVisitor((code, message, errorCode) {
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

          // Let's check if schema has properties, if so, add 400.
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
    // 1. Find 'middleware' getter
    MethodDeclaration? middlewareGetter;
    // Get members from body to avoid deprecation
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

    if (middlewareGetter == null) return;

    // 2. Analyze the body to find the list expression
    final body = middlewareGetter.body;
    if (body is ExpressionFunctionBody) {
      _analyzeMiddlewareExpression(body.expression, operation);
    } else if (body is BlockFunctionBody) {
      // Look for return statement
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
          // Resolve element
          // usage: element.methodName.staticElement
          final methodElement = element.methodName.element;
          if (methodElement != null) {
            _analyzeElementSource(methodElement, operation);
          }
        } else if (element is InstanceCreationExpression) {
          // Fallback to analyzing the class if specific constructor resolution fails/is complex
          final typeElement = element.constructorName.type.element;
          if (typeElement is ClassElement) {
            _analyzeElementSource(typeElement, operation);
          }
        }
      }
    }
  }

  void _analyzeElementSource(Element element, Map<String, dynamic> operation) {
    try {
      final session = element.session;
      if (session == null) {
        return;
      }

      final library = element.library;
      if (library == null) {
        return;
      }
      final parsedLib = session.getParsedLibraryByElement(library);
      if (parsedLib is ParsedLibraryResult) {
        // Find declaration manually
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
              }
              // ExtensionDeclaration name is optional/nullable
              else if (d is ExtensionDeclaration) {
                return d.name?.lexeme == element.name;
              }
              return false;
            });

        final node = declaration;
        if (node != null) {
          final responses = operation['responses'] as Map<String, dynamic>;
          node.visitChildren(
            _ThrowVisitor((code, message, errorCode) {
              _addErrorResponse(responses, code, message, errorCode);
            }),
          );
        }
      }
    } catch (e) {
      // Ignore errors during analysis
    }
  }

  void _deduceRequestBody(
    Map<String, dynamic> operation,
    ClassElement element,
    Map<String, dynamic> schemas,
    List<String>? contentTypes,
  ) {
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
      // Check handler signature for nullability of 2nd argument
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
          // Optional positional is implicitly nullable or forced optional usage
          isRequired = false;
        } else {
          // Fallback
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
      // "if user use SparkEndpoint the content consider the content optional"
      // Only generate if contentTypes is specified
      if (contentTypes != null && contentTypes.isNotEmpty) {
        final contentMap = <String, dynamic>{};
        for (final type in contentTypes) {
          // Schema is generic/open since we don't know the type
          contentMap[type] = {'schema': <String, dynamic>{}};
        }
        operation['requestBody'] = {'required': false, 'content': contentMap};
      }
    }
  }

  DartObject? _getAnnotation(Element element, String name) {
    final metaObj = element.metadata;

    try {
      final List<dynamic> annotations = metaObj.annotations;
      for (final meta in annotations) {
        if (meta is ElementAnnotation) {
          final value = meta.computeConstantValue();
          if (value?.type?.element?.name == name) {
            return value;
          }
        }
      }
    } catch (e) {
      // Ignore metadata access errors
    }
    return null;
  }

  Map<String, dynamic> _ensureSchema(
    DartType type,
    Map<String, dynamic> schemas,
  ) {
    if (type.isDartCoreInt) return {'type': 'integer'};
    if (type.isDartCoreDouble || type.isDartCoreNum) return {'type': 'number'};
    if (type.isDartCoreString) return {'type': 'string'};
    if (type.isDartCoreBool) return {'type': 'boolean'};

    if (type.element?.name == 'DateTime' &&
        type.element?.library?.name == 'dart.core') {
      return {'type': 'string', 'format': 'date-time'};
    }

    if (type.isDartCoreList) {
      final args = (type as InterfaceType).typeArguments;
      final inner = args.isNotEmpty ? args.first : type; // fallback
      return {'type': 'array', 'items': _ensureSchema(inner, schemas)};
    }

    if (type.isDartCoreMap) {
      return {'type': 'object'};
    }

    if (type is VoidType || type is DynamicType) {
      return {'type': 'object'};
    }

    // Handle Object/DTO
    final element = type.element;
    if (element is! ClassElement) return {'type': 'object'};

    final name = element.name ?? 'Unnamed';

    // Already exists?
    if (schemas.containsKey(name)) {
      return {'\$ref': '#/components/schemas/$name'};
    }

    // Create placeholder to prevent infinite recursion
    schemas[name] = <String, dynamic>{};

    final properties = <String, dynamic>{};

    // Inspect fields
    for (final field in element.fields) {
      if (field.isPublic && !field.isStatic) {
        final fieldName = field.name;
        if (['hashCode', 'runtimeType'].contains(fieldName)) continue;

        final fieldSchema = _ensureSchema(field.type, schemas);
        final validations = _extractValidations(field);
        properties[fieldName ?? 'unknown'] = {...fieldSchema, ...validations};
      }
    }

    schemas[name] = <String, dynamic>{
      'type': 'object',
      'properties': properties,
    };

    return {'\$ref': '#/components/schemas/$name'};
  }

  void _addErrorResponse(
    Map<String, dynamic> responses,
    int code,
    String message,
    String? errorCode,
  ) {
    // Basic implementation for now, will enhance for oneOf
    final statusKey = code.toString();
    final newSchema = {
      'type': 'object',
      'properties': {
        'message': {'type': 'string', 'example': message},
        'code': {'type': 'string', 'example': errorCode},
      },
    };

    if (!responses.containsKey(statusKey)) {
      // New status code
      responses[statusKey] = {
        'description': message, // Use the first message
        'content': {
          'application/json': {'schema': newSchema},
        },
      };
    } else {
      // Existing status code, merge into oneOf
      final existingResponse = responses[statusKey] as Map<String, dynamic>;
      final content =
          existingResponse['content'] as Map<String, dynamic>? ?? {};
      final jsonContent =
          content['application/json'] as Map<String, dynamic>? ?? {};
      final existingSchema = jsonContent['schema'] as Map<String, dynamic>?;

      if (existingSchema != null) {
        List<Map<String, dynamic>> oneOfList;

        if (existingSchema.containsKey('oneOf')) {
          oneOfList = (existingSchema['oneOf'] as List)
              .cast<Map<String, dynamic>>();
        } else {
          // different schema, convert to oneOf
          oneOfList = [existingSchema];
          // Reset schema to be oneOf wrapper
          jsonContent['schema'] = {'oneOf': oneOfList};
        }

        // Prevent duplicates (simple check by errorCode example)
        bool exists = false;
        if (errorCode != null) {
          exists = oneOfList.any((s) {
            final props = s['properties'] as Map<String, dynamic>?;
            final codeProp = props?['code'] as Map<String, dynamic>?;
            return codeProp?['example'] == errorCode;
          });
        } else {
          // If new error has no code, check if we have a generic one
          exists = oneOfList.any((s) {
            final props = s['properties'] as Map<String, dynamic>?;
            final codeProp = props?['code'] as Map<String, dynamic>?;
            return codeProp == null ||
                (codeProp['type'] == 'string' &&
                    !codeProp.containsKey('example'));
          });
        }

        if (!exists) {
          oneOfList.add(newSchema);
        }
      }
    }
  }

  Map<String, dynamic> _extractValidations(FieldElement field) {
    final validationMap = <String, dynamic>{};

    // Fix for: The type 'Metadata' used in the 'for' loop must implement 'Iterable'.
    // Copied compatibility logic from _getAnnotation
    List<ElementAnnotation> annotations = [];
    try {
      final dynamic rawMetadata = field.metadata;
      if (rawMetadata is List) {
        annotations = rawMetadata.cast<ElementAnnotation>();
      } else {
        // Access via dynamic if it's the wrapper type 'Metadata'
        // ignore: avoid_dynamic_calls
        annotations = (rawMetadata as dynamic).annotations
            .cast<ElementAnnotation>();
      }
    } catch (_) {
      // Fallback or ignore
    }

    for (final metadata in annotations) {
      final value = metadata.computeConstantValue();
      if (value == null) continue;

      final typeName = value.type?.element?.name;
      if (typeName == null) continue;

      // Logic mapping
      if (typeName == 'NotEmpty') {
        if (field.type.isDartCoreString) {
          validationMap['minLength'] = 1;
        } else if (field.type.isDartCoreList) {
          validationMap['minItems'] = 1;
        }
      } else if (typeName == 'Email') {
        if (field.type.isDartCoreString) {
          validationMap['format'] = 'email';
        }
      } else if (typeName == 'Min') {
        final valField = value.getField('value');
        final minVal = valField?.toDoubleValue() ?? valField?.toIntValue();
        if (minVal != null) validationMap['minimum'] = minVal;
      } else if (typeName == 'Max') {
        final valField = value.getField('value');
        final maxVal = valField?.toDoubleValue() ?? valField?.toIntValue();
        if (maxVal != null) validationMap['maximum'] = maxVal;
      } else if (typeName == 'Length') {
        final min = value.getField('min')?.toIntValue();
        final max = value.getField('max')?.toIntValue();
        if (field.type.isDartCoreString) {
          if (min != null) validationMap['minLength'] = min;
          if (max != null) validationMap['maxLength'] = max;
        }
      } else if (typeName == 'Pattern') {
        final pattern = value.getField('pattern')?.toStringValue();
        if (pattern != null && field.type.isDartCoreString) {
          validationMap['pattern'] = pattern;
        }
      } else if (typeName == 'IsBooleanString') {
        if (field.type.isDartCoreString) {
          validationMap['enum'] = ['true', 'false', '1', '0'];
        }
      } else if (typeName == 'IsString') {
        // Just enforcing type, which is likely already handled by type system
      } else if (typeName == 'IsNumeric') {
        if (field.type.isDartCoreString) {
          validationMap['pattern'] = r'^[0-9]+$';
        }
      } else if (typeName == 'IsDate') {
        if (field.type.isDartCoreString) {
          validationMap['format'] = 'date-time';
        }
      }
    }
    return validationMap;
  }
}

class _ThrowVisitor extends GeneralizingAstVisitor<void> {
  final void Function(int code, String message, String? errorCode) onThrow;

  _ThrowVisitor(this.onThrow);

  // @override
  // void visitNode(AstNode node) {
  //   print('DEBUG: Visiting ${node.runtimeType}');
  //   super.visitNode(node);
  // }

  @override
  void visitThrowExpression(ThrowExpression node) {
    final expression = node.expression;
    // print('DEBUG: visitThrowExpression for $expression (${expression.runtimeType})');

    String? name;
    ArgumentList? args;

    if (expression is MethodInvocation) {
      name = expression.methodName.name;
      args = expression.argumentList;
    } else if (expression is InstanceCreationExpression) {
      name = expression.constructorName.type.toSource();
      args = expression.argumentList;
    }

    if (name != null) {
      if (name.endsWith('ApiError')) {
        // Default 500
        int statusCode = 500;
        String message = 'Internal Server Error';
        String? errorCode;

        // Check named arguments
        if (args != null) {
          for (final arg in args.arguments) {
            if (arg is NamedExpression) {
              final label = arg.name.label.name;
              if (label == 'statusCode') {
                final val = arg.expression;
                if (val is IntegerLiteral) {
                  statusCode = val.value ?? 500;
                }
              } else if (label == 'message') {
                final val = arg.expression;
                if (val is StringLiteral) {
                  message = val.stringValue ?? message;
                }
              } else if (label == 'code') {
                final val = arg.expression;
                if (val is StringLiteral) {
                  errorCode = val.stringValue;
                }
              }
            }
          }
        }
        onThrow(statusCode, message, errorCode);
      } else if (name.endsWith('SparkHttpException')) {
        // Positional: code, message
        int statusCode = 500;
        String message = 'HTTP Error';

        if (args != null) {
          final arguments = args.arguments;
          if (arguments.isNotEmpty) {
            final first = arguments[0];
            if (first is IntegerLiteral) {
              statusCode = first.value ?? 500;
            }
          }
          if (arguments.length > 1) {
            final second = arguments[1];
            if (second is StringLiteral) {
              message = second.stringValue ?? message;
            }
          }
        }
        onThrow(statusCode, message, null);
      }
    }
    super.visitThrowExpression(node);
  }
}
