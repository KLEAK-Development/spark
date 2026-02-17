import 'package:spark_framework/spark.dart';
import 'package:test/test.dart';

void main() {
  group('PageResponse Cookies', () {
    final cookie1 = Cookie('session', '12345', httpOnly: true);
    final cookie2 = Cookie('theme', 'dark');

    test('PageData stores cookies', () {
      final response = PageData<String>('data', cookies: [cookie1, cookie2]);

      expect(response.cookies, hasLength(2));
      expect(response.cookies, contains(cookie1));
      expect(response.cookies, contains(cookie2));
    });

    test('PageRedirect stores cookies', () {
      final response = PageRedirect('/login', cookies: [cookie1]);

      expect(response.cookies, hasLength(1));
      expect(response.cookies.first, equals(cookie1));
    });

    test('PageRedirect.permanent stores cookies', () {
      final response = PageRedirect.permanent('/new-home', cookies: [cookie2]);

      expect(response.statusCode, equals(301));
      expect(response.cookies, contains(cookie2));
    });

    test('PageRedirect.temporary stores cookies', () {
      final response = PageRedirect.temporary('/temp', cookies: [cookie1]);

      expect(response.statusCode, equals(307));
      expect(response.cookies, contains(cookie1));
    });

    test('PageRedirect.seeOther stores cookies', () {
      final response = PageRedirect.seeOther('/other', cookies: [cookie1]);

      expect(response.statusCode, equals(303));
      expect(response.cookies, contains(cookie1));
    });

    test('PageError stores cookies', () {
      final response = PageError('Error', cookies: [cookie1]);

      expect(response.cookies, hasLength(1));
      expect(response.cookies.first, equals(cookie1));
    });

    test('PageError.notFound stores cookies', () {
      final response = PageError.notFound('Not Found', [cookie1, cookie2]);

      expect(response.statusCode, equals(404));
      expect(response.cookies, hasLength(2));
    });

    test('PageError.forbidden stores cookies', () {
      final response = PageError.forbidden('No Access', [cookie1]);

      expect(response.statusCode, equals(403));
      expect(response.cookies.first, equals(cookie1));
    });

    test('PageError.badRequest stores cookies', () {
      final response = PageError.badRequest('Bad', [cookie2]);

      expect(response.statusCode, equals(400));
      expect(response.cookies.first, equals(cookie2));
    });

    test('PageError.unauthorized stores cookies', () {
      final response = PageError.unauthorized('Auth Required', [cookie1]);

      expect(response.statusCode, equals(401));
      expect(response.cookies.first, equals(cookie1));
    });
  });
}
