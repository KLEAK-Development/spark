import 'package:spark_framework/spark.dart';
import 'package:test/test.dart';

void main() {
  group('Errors', () {
    test('ApiError.toJson includes details when present', () {
      final error = ApiError(
        message: 'msg',
        code: 'ERR',
        details: {'field': 'error'},
      );
      final json = error.toJson();
      expect(json['details'], {'field': 'error'});
      expect(json['code'], 'ERR');
    });

    test('ApiError.toJson covers code field without details', () {
      final error = ApiError(message: 'm', code: 'C');
      final json = error.toJson();
      expect(json['code'], 'C');
      expect(json.containsKey('details'), isFalse);
    });

    test('ApiError.toResponse with details and custom status', () async {
      final error = ApiError(
        message: 'msg',
        code: 'ERR',
        statusCode: 400,
        details: {'foo': 'bar'},
      );
      final response = error.toResponse();
      expect(response.statusCode, 400);
      final body = await response.readAsString();
      expect(body, contains('"code":"ERR"'));
      expect(body, contains('"details":{"foo":"bar"}'));
    });

    test('ApiError.toResponse overrides constructor status', () async {
      final error = ApiError(message: 'm', code: 'C', statusCode: 500);
      final response = error.toResponse(404);
      expect(response.statusCode, 404);
    });

    test('SparkValidationException stores message and errors', () {
      final errors = {'foo': 'bar'};
      final ex = SparkValidationException(errors, message: 'Custom failed');
      expect(ex.errors, errors);
      expect(ex.message, 'Custom failed');
    });

    test('SparkValidationException has default message', () {
      final ex = SparkValidationException({});
      expect(ex.message, 'Validation Failed');
    });

    test('SparkHttpException stores properties', () {
      final ex = SparkHttpException(
        400,
        'Bad',
        code: 'BAD_REQ',
        details: {'a': 1},
      );
      expect(ex.statusCode, 400);
      expect(ex.message, 'Bad');
      expect(ex.code, 'BAD_REQ');
      expect(ex.details, {'a': 1});
    });

    test('SparkHttpException has default code', () {
      final ex = SparkHttpException(500, 'Error');
      expect(ex.code, 'HTTP_ERROR');
    });
  });
}
