import 'package:shelf/shelf.dart' show Middleware;
import '../page/page_request.dart';

/// Abstract base class for Spark API endpoints without a request body.
///
/// Use this for GET, DELETE, or other endpoints that don't expect a body.
///
/// ## Basic Usage
///
/// ```dart
/// @Endpoint(path: '/api/hello', method: 'GET')
/// class HelloEndpoint extends SparkEndpoint {
///   @override
///   Future<String> handler(SparkRequest request) async {
///     return 'Hello World';
///   }
/// }
/// ```
///
/// ## With Middleware
///
/// ```dart
/// @Endpoint(path: '/api/admin/users', method: 'GET')
/// class AdminUsersEndpoint extends SparkEndpoint {
///   final AuthService _authService;
///
///   AdminUsersEndpoint(this._authService);
///
///   @override
///   List<Middleware> get middleware => [
///     authMiddleware(_authService),
///     adminOnlyMiddleware(),
///   ];
///
///   @override
///   Future<List<UserDto>> handler(SparkRequest request) async {
///     return await userService.getAllUsers();
///   }
/// }
/// ```
abstract class SparkEndpoint {
  /// Handles incoming requests.
  ///
  /// The return type can be:
  /// - `String`: Returned as plain text with content-type: text/plain
  /// - Custom object with `toJson()`: Serialized to JSON
  /// - `List`, `Map`, primitives: Serialized to JSON
  /// - `Response`: Returned directly
  Future<dynamic> handler(SparkRequest request);

  /// Middleware to apply to this endpoint's route.
  ///
  /// Override this to provide middleware specific to this endpoint.
  /// These middleware will be applied before the handler is called.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// List<Middleware> get middleware => [
  ///   logRequests(),
  ///   authMiddleware(authService),
  /// ];
  /// ```
  List<Middleware> get middleware => [];
}

/// Abstract base class for Spark API endpoints with a typed request body.
///
/// Use this for POST, PUT, PATCH, or other endpoints that expect a body.
/// The generic type [T] represents the request body type that will be
/// automatically parsed from JSON.
///
/// ## Basic Usage
///
/// ```dart
/// @Endpoint(path: '/api/users', method: 'POST')
/// class CreateUserEndpoint extends SparkEndpointWithBody<CreateUserDto> {
///   @override
///   Future<UserDto> handler(SparkRequest request, CreateUserDto body) async {
///     final user = await userService.create(body);
///     return user;
///   }
/// }
/// ```
///
/// ## With Middleware
///
/// ```dart
/// @Endpoint(path: '/api/admin/users', method: 'POST')
/// class AdminCreateUserEndpoint extends SparkEndpointWithBody<CreateUserDto> {
///   final AuthService _authService;
///
///   AdminCreateUserEndpoint(this._authService);
///
///   @override
///   List<Middleware> get middleware => [
///     authMiddleware(_authService),
///   ];
///
///   @override
///   Future<UserDto> handler(SparkRequest request, CreateUserDto body) async {
///     return await userService.create(body);
///   }
/// }
/// ```
abstract class SparkEndpointWithBody<T> {
  /// Handles incoming requests with a parsed body.
  ///
  /// The [body] parameter contains the parsed request body of type [T].
  ///
  /// The return type can be:
  /// - `String`: Returned as plain text with content-type: text/plain
  /// - Custom object with `toJson()`: Serialized to JSON
  /// - `List`, `Map`, primitives: Serialized to JSON
  /// - `Response`: Returned directly
  Future<dynamic> handler(SparkRequest request, T body);

  /// Middleware to apply to this endpoint's route.
  ///
  /// Override this to provide middleware specific to this endpoint.
  /// These middleware will be applied before the handler is called.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// List<Middleware> get middleware => [
  ///   logRequests(),
  ///   authMiddleware(authService),
  /// ];
  /// ```
  List<Middleware> get middleware => [];
}
