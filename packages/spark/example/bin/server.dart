import 'package:shelf/shelf.dart';
import 'package:spark_framework/spark.dart';

// ignore: uri_has_not_been_generated
import 'package:spark_example/spark_router.g.dart';

@OpenApi(
  title: 'Spark Example API',
  version: '1.0.0',
  description: 'An example API built with Spark.',
  servers: ['http://localhost:8080'],
  securitySchemes: {
    'ApiKeyAuth': SecurityScheme.apiKey(
      name: 'X-API-KEY',
      inLocation: 'header',
    ),
    'BearerAuth': SecurityScheme.http(scheme: 'bearer', bearerFormat: 'JWT'),
  },
  security: [
    {'ApiKeyAuth': []},
  ],
)
void main() async {
  final server = await createSparkServer(
    SparkServerConfig(
      port: 9004,
      middleware: [logRequests()],
      notFoundHandler: (request) {
        return Response.notFound('NOT FOUND');
      },
    ),
  );
  print('Server running at http://localhost:${server.port}');
}
