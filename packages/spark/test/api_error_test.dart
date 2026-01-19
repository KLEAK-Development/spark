import 'dart:convert';
import 'package:spark_framework/src/errors/errors.dart';
import 'package:test/test.dart';

void main() {
  group('ApiError', () {
    test('toJson includes default status code 500 equivalent behavior', () {
      final error = ApiError(message: 'Something went wrong', code: 'ERROR');
      expect(error.toJson(), {
        'message': 'Something went wrong',
        'code': 'ERROR',
      });
      expect(error.statusCode, 500);
    });

    test('toResponse uses default status code 500', () async {
      final error = ApiError(message: 'Something went wrong', code: 'ERROR');
      final response = error.toResponse();
      expect(response.statusCode, 500);
      expect(jsonDecode(await response.readAsString()), {
        'message': 'Something went wrong',
        'code': 'ERROR',
      });
    });

    test('toResponse uses custom status code in constructor', () {
      final error = ApiError(
        message: 'Not Found',
        code: 'NOT_FOUND',
        statusCode: 404,
      );
      final response = error.toResponse();
      expect(response.statusCode, 404);
    });

    test('toResponse uses override status code', () {
      final error = ApiError(
        message: 'Forbidden',
        code: 'FORBIDDEN',
        statusCode: 403,
      );
      final response = error.toResponse(401);
      expect(response.statusCode, 401);
    });

    test('is an Exception', () {
      final error = ApiError(message: 'Error', code: 'ERR');
      expect(error, isA<Exception>());
      try {
        throw error;
      } catch (e) {
        expect(e, isA<ApiError>());
      }
    });
  });
}
