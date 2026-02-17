import 'package:shelf/shelf.dart';
import 'package:spark_framework/spark.dart';
import 'package:test/test.dart';

class TestEndpoint extends SparkEndpoint {
  @override
  Future<dynamic> handler(SparkRequest request) async => 'ok';
}

class TestEndpointWithBody extends SparkEndpointWithBody<String> {
  @override
  Future<dynamic> handler(SparkRequest request, String body) async => body;
}

void main() {
  final request = SparkRequest(
    shelfRequest: Request('GET', Uri.parse('http://localhost/')),
    pathParams: {},
  );

  group('SparkEndpoint', () {
    test('default middleware is empty', () {
      final endpoint = TestEndpoint();
      expect(endpoint.middleware, isEmpty);
    });

    test('handler works', () async {
      final endpoint = TestEndpoint();
      expect(await endpoint.handler(request), 'ok');
    });
  });

  group('SparkEndpointWithBody', () {
    test('default middleware is empty', () {
      final endpoint = TestEndpointWithBody();
      expect(endpoint.middleware, isEmpty);
    });

    test('handler works', () async {
      final endpoint = TestEndpointWithBody();
      expect(await endpoint.handler(request, 'hello'), 'hello');
    });
  });
}
