@TestOn('vm')
library;

import 'package:spark_framework/spark.dart';
import 'package:test/test.dart';

void main() {
  group('Cookie', () {
    test('formats simple cookie', () {
      final cookie = Cookie('session_id', '12345');
      expect(cookie.toString(), equals('session_id=12345'));
    });

    test('formats cookie with all attributes', () {
      final date = DateTime.utc(2025, 1, 1, 12, 0, 0);
      final cookie = Cookie(
        'user',
        'alice',
        expires: date,
        maxAge: 3600,
        domain: 'example.com',
        path: '/app',
        secure: true,
        httpOnly: true,
        sameSite: SameSite.strict,
      );

      final str = cookie.toString();
      expect(str, contains('user=alice'));
      expect(str, contains('Expires=Wed, 01 Jan 2025 12:00:00 GMT'));
      expect(str, contains('Max-Age=3600'));
      expect(str, contains('Domain=example.com'));
      expect(str, contains('Path=/app'));
      expect(str, contains('Secure'));
      expect(str, contains('HttpOnly'));
      expect(str, contains('SameSite=Strict'));
    });

    test('formats same site attribute', () {
      expect(
        Cookie('a', 'b', sameSite: SameSite.lax).toString(),
        contains('SameSite=Lax'),
      );
      expect(
        Cookie('a', 'b', sameSite: SameSite.none).toString(),
        contains('SameSite=None'),
      );
    });

    test('formats expiry date correctly', () {
      final date = DateTime.utc(2025, 12, 25, 10, 30, 45);
      final cookie = Cookie('c', 'v', expires: date);
      expect(
        cookie.toString(),
        contains('Expires=Thu, 25 Dec 2025 10:30:45 GMT'),
      );
    });
  });
}
