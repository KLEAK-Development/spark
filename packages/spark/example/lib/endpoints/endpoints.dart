import 'package:shelf/shelf.dart';
import 'package:spark_framework/spark.dart';

// 1. Simple Custom Object (DTO)
class UserDto {
  @Length(min: 10)
  final String name;
  UserDto({required this.name});
}

// 2. Middleware example
Handler logMw(Handler inner) {
  return (req) {
    print('Log: ${req.url}');
    return inner(req);
  };
}

// 3. Endpoints using the new class-based approach

/// Simple GET endpoint returning a string (no body)
@Endpoint(
  path: '/api/hello',
  method: 'GET',
  summary: 'HelloEndpoint',
  description: 'return Hello world',
  statusCode: 200,
)
class HelloEndpoint extends SparkEndpoint {
  @override
  Future<String> handler(SparkRequest request) async {
    return 'Hello World';
  }
}

/// POST endpoint with typed request body
@Endpoint(
  path: '/api/echo',
  method: 'POST',
  summary: 'EchoUserEndpoint',
  description: 'return Hello world',
  operationId: 'echoUser',
  statusCode: 200,
  contentTypes: ['application/json'],
)
class EchoUserEndpoint extends SparkEndpointWithBody<UserDto> {
  @override
  Future<UserDto> handler(SparkRequest request, UserDto body) async {
    print('Received user: ${body.name}');
    return body;
  }
}

/// POST endpoint with Map body
@Endpoint(path: '/api/details', method: 'POST')
class EchoDetailsEndpoint extends SparkEndpointWithBody<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> handler(
    SparkRequest request,
    Map<String, dynamic> body,
  ) async {
    return body;
  }
}

/// GET endpoint with middleware (no body)
@Endpoint(path: '/api/check', method: 'GET')
class CheckMwEndpoint extends SparkEndpoint {
  @override
  List<Middleware> get middleware => [logMw];

  @override
  Future<String> handler(SparkRequest request) async {
    return 'Checked ${request.path}';
  }
}

/// GET endpoint with path parameters (no body)
@Endpoint(path: '/api/users/{id}', method: 'GET')
class GetUserEndpoint extends SparkEndpoint {
  @override
  Future<UserDto> handler(SparkRequest request) async {
    final userId = request.pathParams['id'];
    return UserDto(name: 'User $userId');
  }
}
