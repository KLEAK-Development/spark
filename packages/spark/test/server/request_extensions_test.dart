@TestOn('vm')
library;

import 'package:shelf/shelf.dart';
import 'package:spark_framework/src/server/request_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('RequestSet and RequestGet', () {
    test('can set and get a value of type T', () {
      final request = Request('GET', Uri.parse('http://localhost/'));
      final newRequest = request.set<String>(() => 'test_value');

      expect(newRequest.get<String>(), 'test_value');
    });

    test('value is initialized lazily', () {
      var callCount = 0;
      final request = Request('GET', Uri.parse('http://localhost/'));
      final newRequest = request.set<String>(() {
        callCount++;
        return 'test_value';
      });

      expect(callCount, 0); // Not called yet
      expect(newRequest.get<String>(), 'test_value');
      expect(callCount, 1); // Called once
    });

    test('can set and get multiple values of different types', () {
      final request = Request('GET', Uri.parse('http://localhost/'));
      final newRequest = request
          .set<String>(() => 'string_value')
          .set<int>(() => 42);

      expect(newRequest.get<String>(), 'string_value');
      expect(newRequest.get<int>(), 42);
    });

    test('throws StateError when get<T> is called without a provider', () {
      final request = Request('GET', Uri.parse('http://localhost/'));
      expect(
        () => request.get<String>(),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('request.get<String>() called with a request context that does not contain a String'),
          ),
        ),
      );
    });
  });

  group('RequestGetPathParameter', () {
    test('can get an existing path parameter', () {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        context: {
          'shelf_router/params': {'id': '123'},
        },
      );
      expect(request.getPathParameter('id'), '123');
    });

    test('throws StateError when path parameter is missing', () {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        context: {
          'shelf_router/params': <String, String>{},
        },
      );
      expect(
        () => request.getPathParameter('missing_id'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('request.getPathParameter(missing_id) called with a request context that does not contain a value'),
          ),
        ),
      );
    });

     test('throws StateError when shelf_router/params context is missing', () {
      final request = Request('GET', Uri.parse('http://localhost/'));
      expect(
        () => request.getPathParameter('missing_id'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('request.getPathParameter(missing_id) called with a request context that does not contain a value'),
          ),
        ),
      );
    });
  });
}
