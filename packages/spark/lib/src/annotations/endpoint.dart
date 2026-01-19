import 'openapi.dart';

/// Annotation for defining API endpoints.
///
/// Apply this annotation to a class that extends [SparkEndpoint].
///
/// ## Usage
///
/// ```dart
/// @Endpoint(path: '/api/users/{id}', method: 'GET')
/// class GetUserEndpoint extends SparkEndpoint<void> {
///   @override
///   Future<UserDto> handler(SparkRequest request, void body) async {
///     final userId = request.pathParamInt('id');
///     return await userService.getUser(userId);
///   }
/// }
/// ```
///
/// ## With Middleware
///
/// ```dart
/// @Endpoint(path: '/api/admin/users', method: 'GET')
/// class AdminUsersEndpoint extends SparkEndpoint<void> {
///   @override
///   List<Middleware> get middleware => [
///     authMiddleware(authService),
///   ];
///
///   @override
///   Future<List<UserDto>> handler(SparkRequest request, void body) async {
///     return await userService.getAllUsers();
///   }
/// }
/// ```
class Endpoint {
  /// The URL path for this endpoint (e.g., '/api/users/{id}').
  final String path;

  /// The HTTP method for this endpoint (e.g., 'GET', 'POST').
  final String method;

  /// A short summary of what the operation does.
  final String? summary;

  /// A verbose explanation of the operation behavior.
  final String? description;

  /// A list of tags for API documentation control.
  final List<String>? tags;

  /// Declares this operation to be deprecated.
  final bool? deprecated;

  /// A declaration of which security mechanisms can be used for this operation.
  final List<Map<String, List<String>>>? security;

  /// Unique string used to identify the operation.
  final String? operationId;

  /// Additional external documentation for this operation.
  final ExternalDocumentation? externalDocs;

  /// A list of parameters that are applicable for this operation.
  final List<Parameter>? parameters;

  /// A list of supported content types for this endpoint.
  ///
  /// If provided, the request Content-Type header will be validated against this list.
  final List<String>? contentTypes;

  /// The default status code for the successful response (e.g., 200, 201).
  ///
  /// If provided, this overrides the automatically deduced status code.
  final int? statusCode;

  /// Creates an endpoint annotation.
  const Endpoint({
    required this.path,
    required this.method,
    this.summary,
    this.description,
    this.tags,
    this.deprecated,
    this.security,
    this.operationId,
    this.externalDocs,
    this.parameters,
    this.contentTypes,
    this.statusCode,
  });
}
