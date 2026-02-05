import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spark_generator/src/endpoint_generator.dart';
import 'package:test/test.dart';

class SimpleBuildStep implements BuildStep {
  @override
  final AssetId inputId;
  SimpleBuildStep(this.inputId);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('EndpointGenerator', () {
    test('generates endpoint handler for SparkEndpoint (no body)', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
          class Endpoint {
            final String path;
            final String method;
            // OpenApiPath fields
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;

            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody});
          }
        ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
          abstract class SparkEndpoint {
            Future<dynamic> handler(dynamic request);
            List<dynamic> get middleware => [];
          }

          abstract class SparkEndpointWithBody<T> {
            Future<dynamic> handler(dynamic request, T body);
            List<dynamic> get middleware => [];
          }
        ''',
          'spark|lib/spark.dart': '''
          library spark;
          export 'src/annotations/endpoint.dart';
          export 'src/endpoint/spark_endpoint.dart';
          export 'src/errors/errors.dart';
        ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkValidationException implements Exception {
              final Map<String, dynamic> errors;
              final String message;
              SparkValidationException(this.errors, {this.message = 'Validation Failed'});
            }
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
          ''',
          'a|lib/test_lib.dart': '''
          library a;
          import 'package:spark/spark.dart';

          class Response {
             static Response ok(String body, {Map<String, dynamic>? headers}) => Response();
          }

          class Request {
             Future<String> readAsString() async => '';
          }

          class SparkRequest {
            final Request shelfRequest;
            final Map<String, String> pathParams;
            SparkRequest({required this.shelfRequest, required this.pathParams});
          }

          @Endpoint(path: '/api/users', method: 'GET')
          class GetUsersEndpoint extends SparkEndpoint {
            @override
            Future<String> handler(SparkRequest request) async {
              return 'users';
            }
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          // Find the class
          final getUsersClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'GetUsersEndpoint');

          final annotations = getUsersClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            getUsersClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          expect(
            output,
            contains('Future<Response> _\$handleGetUsersEndpoint'),
          );
          expect(output, contains("path: '/api/users'"));
          expect(output, contains("methods: <String>['GET']"));
          expect(output, contains('final endpoint = GetUsersEndpoint()'));
          expect(output, contains('endpoint.handler(sparkRequest)'));
          // Should NOT contain body parsing for SparkEndpoint
          expect(output, isNot(contains('bodyString')));
        },
      );
    });

    test('generates endpoint handler for SparkEndpointWithBody', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
          class Endpoint {
            final String path;
            final String method;
            // OpenApiPath fields
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;

            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody});
          }
        ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
          abstract class SparkEndpoint {
            Future<dynamic> handler(dynamic request);
            List<dynamic> get middleware => [];
          }

          abstract class SparkEndpointWithBody<T> {
            Future<dynamic> handler(dynamic request, T body);
            List<dynamic> get middleware => [];
          }
        ''',
          'spark|lib/spark.dart': '''
          library spark;
          export 'src/annotations/endpoint.dart';
          export 'src/endpoint/spark_endpoint.dart';
          export 'src/errors/errors.dart';
        ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkValidationException implements Exception {
              final Map<String, dynamic> errors;
              final String message;
              SparkValidationException(this.errors, {this.message = 'Validation Failed'});
            }
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
          ''',
          'a|lib/test_lib.dart': '''
          library a;
          import 'package:spark/spark.dart';

          class Response {
             static Response ok(String body, {Map<String, dynamic>? headers}) => Response();
          }

          class Request {
             Future<String> readAsString() async => '';
          }

          class SparkRequest {
            final Request shelfRequest;
            final Map<String, String> pathParams;
            SparkRequest({required this.shelfRequest, required this.pathParams});
          }

          class UserDto {
            final String name;
            UserDto({required this.name});
            factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(name: json['name']);
            Map<String, dynamic> toJson() => {'name': name};
          }

          @Endpoint(path: '/api/users', method: 'POST')
          class CreateUserEndpoint extends SparkEndpointWithBody<UserDto> {
            @override
            Future<UserDto> handler(SparkRequest request, UserDto body) async {
              return body;
            }
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          // Find the class
          final createUserClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'CreateUserEndpoint');

          final annotations = createUserClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            createUserClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          expect(
            output,
            contains('Future<Response> _\$handleCreateUserEndpoint'),
          );
          expect(output, contains("path: '/api/users'"));
          expect(output, contains("methods: <String>['POST']"));
          expect(output, contains('final endpoint = CreateUserEndpoint()'));
          // Should contain body parsing for SparkEndpointWithBody
          expect(output, contains('bodyString'));
          // Should use constructor binding instead of fromJson
          expect(
            output,
            contains(
              'UserDto(name: (rawBody as Map<String, dynamic>)["name"].toString())',
            ),
          );
          expect(output, contains('endpoint.handler(sparkRequest, body)'));
          // Should NOT generate validation map or check for DTO without validation annotations
          expect(
            output,
            isNot(contains('final validationErrors = <String, dynamic>{};')),
          );
        },
      );
    });

    test('generates endpoint with path parameters', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
          class Endpoint {
            final String path;
            final String method;
             // OpenApiPath fields
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;

            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody});
          }
        ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
          abstract class SparkEndpoint {
            Future<dynamic> handler(dynamic request);
            List<dynamic> get middleware => [];
          }

          abstract class SparkEndpointWithBody<T> {
            Future<dynamic> handler(dynamic request, T body);
            List<dynamic> get middleware => [];
          }
        ''',
          'spark|lib/spark.dart': '''
          library spark;
          export 'src/annotations/endpoint.dart';
          export 'src/endpoint/spark_endpoint.dart';
          export 'src/errors/errors.dart';
        ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkValidationException implements Exception {
              final Map<String, dynamic> errors;
              final String message;
              SparkValidationException(this.errors, {this.message = 'Validation Failed'});
            }
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
          ''',
          'a|lib/test_lib.dart': '''
          library a;
          import 'package:spark/spark.dart';

          class Response {
             static Response ok(String body, {Map<String, dynamic>? headers}) => Response();
          }

          class Request {
             Future<String> readAsString() async => '';
          }

          class SparkRequest {
            final Request shelfRequest;
            final Map<String, String> pathParams;
            SparkRequest({required this.shelfRequest, required this.pathParams});
            String pathParam(String name) => pathParams[name] ?? '';
          }

          @Endpoint(path: '/api/users/{id}', method: 'GET')
          class GetUserEndpoint extends SparkEndpoint {
            @override
            Future<String> handler(SparkRequest request) async {
              return 'user';
            }
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          // Find the class
          final getUserClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'GetUserEndpoint');

          final annotations = getUserClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            getUserClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          expect(output, contains('Future<Response> _\$handleGetUserEndpoint'));
          // Path should be converted to shelf_router format
          expect(output, contains("path: '/api/users/<id>'"));
          expect(output, contains("pathParams: <String>['id']"));
          // Handler should receive path param
          expect(output, contains('String id,'));
          expect(output, contains("'id': id,"));
        },
      );
    });

    test('generates middleware pipeline', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
          class Endpoint {
            final String path;
            final String method;
            // OpenApiPath fields
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;

            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody});
          }
        ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
          abstract class SparkEndpoint {
            Future<dynamic> handler(dynamic request);
            List<dynamic> get middleware => [];
          }

          abstract class SparkEndpointWithBody<T> {
            Future<dynamic> handler(dynamic request, T body);
            List<dynamic> get middleware => [];
          }
        ''',
          'spark|lib/spark.dart': '''
          library spark;
          export 'src/annotations/endpoint.dart';
          export 'src/endpoint/spark_endpoint.dart';
          export 'src/errors/errors.dart';
        ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkValidationException implements Exception {
              final Map<String, dynamic> errors;
              final String message;
              SparkValidationException(this.errors, {this.message = 'Validation Failed'});
            }
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
          ''',
          'a|lib/test_lib.dart': '''
          library a;
          import 'package:spark/spark.dart';

          class Response {
             static Response ok(String body, {Map<String, dynamic>? headers}) => Response();
          }

          class Request {
             Future<String> readAsString() async => '';
          }

          class SparkRequest {
            final Request shelfRequest;
            final Map<String, String> pathParams;
            SparkRequest({required this.shelfRequest, required this.pathParams});
          }

          @Endpoint(path: '/api/admin', method: 'GET')
          class AdminEndpoint extends SparkEndpoint {
            @override
            List<dynamic> get middleware => [];

            @override
            Future<String> handler(SparkRequest request) async {
              return 'admin';
            }
          }
        ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          // Find the class
          final adminClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'AdminEndpoint');

          final annotations = adminClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            adminClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          // Should generate middleware pipeline from getter
          expect(output, contains('var pipeline = const Pipeline()'));
          expect(
            output,
            contains('for (final middleware in endpoint.middleware)'),
          );
          expect(
            output,
            contains('pipeline = pipeline.addMiddleware(middleware)'),
          );
        },
      );
    });

    test('generates validation logic', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
            class Endpoint {
              final String path;
              final String method;
              // OpenApiPath fields
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;

            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody});
            }
          ''',
          'spark|lib/src/annotations/validator.dart': '''
            abstract class Validator { const Validator(); }
            class NotEmpty extends Validator { final String? message; const NotEmpty({this.message}); }
            class Email extends Validator { final String? message; const Email({this.message}); }
            class IsNumeric extends Validator { final String? message; const IsNumeric({this.message}); }
            class IsDate extends Validator { final String? message; const IsDate({this.message}); }
            class IsBooleanString extends Validator { final String? message; const IsBooleanString({this.message}); }
            class IsString extends Validator { final String? message; const IsString({this.message}); }
            class Min extends Validator { final num value; final String? message; const Min(this.value, {this.message}); }
            class Max extends Validator { final num value; final String? message; const Max(this.value, {this.message}); }
            class Length extends Validator { final int? min; final int? max; final String? message; const Length({this.min, this.max, this.message}); }
            class Pattern extends Validator { final String pattern; final String? message; const Pattern(this.pattern, {this.message}); }
          ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
            abstract class SparkEndpoint {
              Future<dynamic> handler(dynamic request);
              List<dynamic> get middleware => [];
            }
            abstract class SparkEndpointWithBody<T> {
              Future<dynamic> handler(dynamic request, T body);
              List<dynamic> get middleware => [];
            }
          ''',
          'spark|lib/spark.dart': '''
            library spark;
            export 'src/annotations/endpoint.dart';
            export 'src/annotations/validator.dart';
            export 'src/endpoint/spark_endpoint.dart';
            export 'src/errors/errors.dart';
          ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkValidationException implements Exception {
              final Map<String, dynamic> errors;
              final String message;
              SparkValidationException(this.errors, {this.message = 'Validation Failed'});
            }
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
          ''',
          'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/spark.dart';

            class Response {
               static Response ok(String body, {Map<String, dynamic>? headers}) => Response();
               Response(int statusCode, {String? body, Map<String, dynamic>? headers});
            }

            class Request {
               Future<String> readAsString() async => '';
            }

            class SparkRequest {
              final Request shelfRequest;
              final Map<String, String> pathParams;
              SparkRequest({required this.shelfRequest, required this.pathParams});
            }

            class UserDto {
              @NotEmpty(message: 'Name required')
              final String name;

              @Email()
              final String email;

              @Min(18)
              final int age;

              @IsBooleanString()
              final String isActive;

              @IsString()
              final dynamic bio;

              UserDto({required this.name, required this.email, required this.age, required this.isActive, this.bio});
              factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(name: '', email: '', age: 0, isActive: '');
              Map<String, dynamic> toJson() => {};
            }

            @Endpoint(path: '/api/users', method: 'POST')
            class CreateUserEndpoint extends SparkEndpointWithBody<UserDto> {
              @override
              Future<UserDto> handler(SparkRequest request, UserDto body) async {
                return body;
              }
            }
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          // Find the class
          final createUserClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'CreateUserEndpoint');

          final annotations = createUserClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            createUserClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          expect(output, contains("validationErrors['name'] = {"));
          expect(output, contains("'code': 'VALIDATION_NOT_EMPTY',"));
          expect(output, contains("'message': \"Name required\""));

          expect(output, contains("validationErrors['email'] = {"));
          expect(output, contains("'code': 'VALIDATION_EMAIL',"));
          expect(
            output,
            contains("'message': \"Field 'email' must be a valid email\""),
          );

          expect(output, contains("if (body.age < 18)"));
          expect(
            output,
            contains("if (body.isActive.toString().toLowerCase() != 'true'"),
          );
          expect(output, contains("if (body.bio is! String)"));
          expect(
            output,
            contains("final validationErrors = <String, dynamic>{};"),
          );
          expect(output, contains("if (validationErrors.isNotEmpty)"));
          expect(
            output,
            contains("throw SparkValidationException(validationErrors);"),
          );
        },
      );
    });

    test('validates Content-Type header', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
            class Endpoint {
              final String path;
              final String method;
              final List<String>? contentTypes;
              // ... other fields ...
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
            const Endpoint({required this.path, required this.method, this.contentTypes, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters});
            }
          ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
            abstract class SparkEndpoint {
              Future<dynamic> handler(dynamic request);
              List<dynamic> get middleware => [];
            }
          ''',
          'spark|lib/spark.dart': '''
             library spark;
             export 'src/annotations/endpoint.dart';
             export 'src/endpoint/spark_endpoint.dart';
             export 'src/errors/errors.dart';
          ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
            class Response {
               static Response ok(String body, {Map<String, dynamic>? headers}) => Response(200);
               Response(int statusCode, {String? body, Map<String, dynamic>? headers});
            }
          ''',
          'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/spark.dart';

            class Request {
               final Map<String, String> headers;
               Request(this.headers);
               Future<String> readAsString() async => '';
            }

            class SparkRequest {
              final Request shelfRequest;
              final Map<String, String> pathParams;
              SparkRequest({required this.shelfRequest, required this.pathParams});
            }

            @Endpoint(
              path: '/api/xml', 
              method: 'POST',
              contentTypes: ['application/xml']
            )
            class XmlEndpoint extends SparkEndpoint {
              @override
              Future<String> handler(SparkRequest request) async {
                return 'ok';
              }
            }
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final xmlClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'XmlEndpoint');

          final annotations = xmlClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            xmlClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          expect(
            output,
            contains(
              "final validatingContentType = req.headers['content-type']",
            ),
          );
          expect(output, contains("const allowedTypes = ['application/xml']"));
          expect(output, contains("if (!allowedTypes.contains(mimeType))"));
          expect(output, contains("throw SparkHttpException("));
          expect(output, contains("400,"));
          expect(output, contains("'Invalid Content-Type',"));
        },
      );
    });

    test('does NOT generate empty OpenApiPath validation block', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
            class Endpoint {
              final String path;
              final String method;
              // OpenApiPath fields
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;

            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody});
            }
          ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
            abstract class SparkEndpoint {
              Future<dynamic> handler(dynamic request);
              List<dynamic> get middleware => [];
            }
          ''',
          'spark|lib/spark.dart': '''
            library spark;
            export 'src/annotations/endpoint.dart';
            export 'src/endpoint/spark_endpoint.dart';
            export 'src/errors/errors.dart';
          ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkValidationException implements Exception {
              final Map<String, dynamic> errors;
              final String message;
              SparkValidationException(this.errors, {this.message = 'Validation Failed'});
            }
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
            class Response {
               static Response ok(String body, {Map<String, dynamic>? headers}) => Response(200);
               Response(int statusCode, {String? body, Map<String, dynamic>? headers});
            }
          ''',
          'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/spark.dart';

            class Request {
               Future<String> readAsString() async => '';
            }

            class SparkRequest {
              final Request shelfRequest;
              final Map<String, String> pathParams;
              SparkRequest({required this.shelfRequest, required this.pathParams});
            }

            @Endpoint(path: '/api/no-validation', method: 'GET')
            class NoValidationEndpoint extends SparkEndpoint {
              @override
              Future<String> handler(SparkRequest request) async {
                return 'ok';
              }
            }
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final noValidationClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'NoValidationEndpoint');

          final annotations = noValidationClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            noValidationClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          // Should NOT generate validation map or check
          expect(
            output,
            isNot(
              contains("final openApiValidationErrors = <String, dynamic>{};"),
            ),
          );
          expect(
            output,
            isNot(contains("if (openApiValidationErrors.isNotEmpty)")),
          );
        },
      );
    });
    test('generates OpenApiPath validation logic - parameters', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
            class Endpoint {
              final String path;
              final String method;
               // OpenApiPath fields
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;

            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody});
            }
          ''',
          'spark|lib/src/annotations/openapi.dart': '''
            class OpenApiPath {
              final String? summary;
              final List<Parameter>? parameters;
              final OpenApiRequestBody? requestBody;
              const OpenApiPath({this.summary, this.parameters, this.requestBody});
            }
            class Parameter {
              final String name;
              final String inLocation;
              final bool? required;
              final Map<String, dynamic>? schema;
              const Parameter({required this.name, required this.inLocation, this.required, this.schema});
            }
            class OpenApiRequestBody {
              final Map<String, OpenApiMediaType>? content;
              final bool? required;
              const OpenApiRequestBody({this.content, this.required});
            }
            class OpenApiMediaType {
              const OpenApiMediaType();
            }
          ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
            abstract class SparkEndpoint {
              Future<dynamic> handler(dynamic request);
              List<dynamic> get middleware => [];
            }
          ''',
          'spark|lib/spark.dart': '''
            library spark;
            export 'src/annotations/endpoint.dart';
            export 'src/annotations/openapi.dart';
            export 'src/endpoint/spark_endpoint.dart';
            export 'src/errors/errors.dart';
          ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkValidationException implements Exception {
              final Map<String, dynamic> errors;
              final String message;
              SparkValidationException(this.errors, {this.message = 'Validation Failed'});
            }
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
          ''',
          'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/spark.dart';

            class Response {
               static Response ok(String body, {Map<String, dynamic>? headers}) => Response();
               Response(int statusCode, {String? body, Map<String, dynamic>? headers});
            }

            class Request {
               final Uri url;
               final Map<String, String> headers;
               Request(this.url, this.headers);
            }

            class SparkRequest {
              final Request shelfRequest;
              final Map<String, String> pathParams;
              SparkRequest({required this.shelfRequest, required this.pathParams});
            }

            @Endpoint(
              path: '/api/search', 
              method: 'GET',
              parameters: const [
                Parameter(
                  name: 'q',
                  inLocation: 'query',
                  required: true,
                ),
                Parameter(
                  name: 'sort', 
                  inLocation: 'query',
                  schema: {'type': 'string', 'enum': ['asc', 'desc']}
                ),
                Parameter(
                  name: 'limit',
                  inLocation: 'query',
                  schema: {'type': 'integer', 'minimum': 1, 'maximum': 100}
                ),
                Parameter(
                  name: 'code',
                  inLocation: 'query',
                  schema: {'type': 'string', 'pattern': r'^[A-Z]{3}\$'}
                ),
              ],
            )
            class SearchEndpoint extends SparkEndpoint {
              @override
              Future<String> handler(SparkRequest request) async {
                return 'search';
              }
            }
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final searchClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'SearchEndpoint');

          final annotations = searchClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            searchClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          // Check required param 'q'
          expect(
            output,
            contains("if (!req.url.queryParameters.containsKey('q'))"),
          );

          expect(output, contains("openApiValidationErrors['q'] = {"));
          expect(output, contains("'code': 'VALIDATION_REQUIRED'"));

          // Check enum 'sort'
          expect(output, contains("const allowedValues = ['asc', 'desc'];"));
          expect(output, contains("if (!allowedValues.contains(sortValue))"));
          expect(output, contains("openApiValidationErrors['sort'] = {"));
          expect(output, contains("'code': 'VALIDATION_ENUM'"));

          // Check integer constraints 'limit'
          expect(
            output,
            contains("final numValue = num.tryParse(limitValue);"),
          );
          expect(output, contains("if (numValue != null && numValue < 1)"));
          expect(output, contains("if (numValue != null && numValue > 100)"));
          expect(output, contains("openApiValidationErrors['limit'] = {"));
          expect(output, contains("'min': 1"));

          // Check pattern 'code'
          expect(
            output,
            contains("if (!RegExp(r'^[A-Z]{3}\$').hasMatch(codeValue))"),
          );
          expect(output, contains("openApiValidationErrors['code'] = {"));
          expect(output, contains("'pattern': r'^[A-Z]{3}\$'"));

          expect(
            output,
            contains(
              "throw SparkValidationException(openApiValidationErrors);",
            ),
          );
        },
      );
    });
    test('generates DateTime serialization', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
            class Endpoint {
              final String path;
              final String method;
              // ... other fields ...
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;
            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody});
            }
          ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
            abstract class SparkEndpoint {
              Future<dynamic> handler(dynamic request);
              List<dynamic> get middleware => [];
            }
          ''',
          'spark|lib/spark.dart': '''
             library spark;
             export 'src/annotations/endpoint.dart';
             export 'src/endpoint/spark_endpoint.dart';
             export 'src/errors/errors.dart';
          ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
            class Response {
               static Response ok(String body, {Map<String, dynamic>? headers}) => Response(200);
               Response(int statusCode, {String? body, Map<String, dynamic>? headers});
            }
          ''',
          'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/spark.dart';

            class Request {
               Future<String> readAsString() async => '';
            }

            class SparkRequest {
              final Request shelfRequest;
              final Map<String, String> pathParams;
              SparkRequest({required this.shelfRequest, required this.pathParams});
            }

            @Endpoint(path: '/api/time', method: 'GET')
            class TimeEndpoint extends SparkEndpoint {
              @override
              Future<DateTime> handler(SparkRequest request) async {
                return DateTime.now();
              }
            }
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final timeClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'TimeEndpoint');

          final annotations = timeClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            timeClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          expect(output, contains('result.toIso8601String()'));
          expect(output, contains('"content-type": "text/plain"'));
        },
      );
    });

    test('generates correct serialization for nullable Map in DTO', () async {
      await resolveSources(
        {
          'spark|lib/src/annotations/endpoint.dart': '''
            class Endpoint {
              final String path;
              final String method;
              final String? summary;
              final String? description;
              final List<String>? tags;
              final Map<int, dynamic>? responses;
              final bool? deprecated;
              final List<Map<String, List<String>>>? security;
              final String? operationId;
              final dynamic externalDocs;
              final List<dynamic>? parameters;
              final dynamic requestBody;
              final List<String>? contentTypes;

            const Endpoint({required this.path, required this.method, this.summary, this.description, this.tags, this.responses, this.deprecated, this.security, this.operationId, this.externalDocs, this.parameters, this.requestBody, this.contentTypes});
          }
          ''',
          'spark|lib/src/endpoint/spark_endpoint.dart': '''
            abstract class SparkEndpoint {
              Future<dynamic> handler(dynamic request);
              List<dynamic> get middleware => [];
            }
          ''',
          'spark|lib/spark.dart': '''
             library spark;
             export 'src/annotations/endpoint.dart';
             export 'src/endpoint/spark_endpoint.dart';
             export 'src/errors/errors.dart';
          ''',
          'spark|lib/src/errors/errors.dart': '''
            class SparkHttpException implements Exception {
              final int statusCode;
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              SparkHttpException(this.statusCode, this.message, {this.code = 'HTTP_ERROR', this.details});
            }
            class ApiError {
              final String message;
              final String code;
              final Map<String, dynamic>? details;
              ApiError({required this.message, required this.code, this.details});
              Response toResponse(int statusCode) => Response(statusCode);
            }
            class Response {
               static Response ok(String body, {Map<String, dynamic>? headers}) => Response(200);
               Response(int statusCode, {String? body, Map<String, dynamic>? headers});
            }
          ''',
          'a|lib/test_lib.dart': '''
            library a;
            import 'package:spark/spark.dart';

            class Request {
               Future<String> readAsString() async => '';
            }

            class SparkRequest {
              final Request shelfRequest;
              final Map<String, String> pathParams;
              SparkRequest({required this.shelfRequest, required this.pathParams});
            }

            class TestDto {
               final Map<String, dynamic>? nextTier;
               TestDto({this.nextTier});
            }

            @Endpoint(path: '/api/test', method: 'GET')
            class TestEndpoint extends SparkEndpoint {
              @override
              Future<TestDto> handler(SparkRequest request) async {
                return TestDto(nextTier: {'a': 1});
              }
            }
          ''',
        },
        (resolver) async {
          final libraryElement = await resolver.libraryFor(
            AssetId('a', 'lib/test_lib.dart'),
          );

          final testClass = libraryElement.children
              .whereType<ClassElement>()
              .firstWhere((e) => e.name == 'TestEndpoint');

          final annotations = testClass.metadata.annotations;
          final annotation = annotations.firstWhere((a) {
            final element = a.element;
            final enclosing = element?.enclosingElement;
            return enclosing?.name == 'Endpoint';
          });
          final constantReader = ConstantReader(
            annotation.computeConstantValue(),
          );

          final generator = EndpointGenerator();
          final output = generator.generateForAnnotatedElement(
            testClass,
            constantReader,
            SimpleBuildStep(AssetId('a', 'lib/test_lib.dart')),
          );

          // Verify the fix: null check before map
          expect(
            output,
            contains(
              "if (result.nextTier != null) 'next_tier': result.nextTier!.map((k, v) => MapEntry(k, v))",
            ),
          );
        },
      );
    });
  });
}
