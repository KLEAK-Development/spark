@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Geolocation (Server)', () {
    test('is available on navigator', () {
      expect(web.window.navigator.geolocation, isNotNull);
    });

    test('getCurrentPosition reports error on server', () {
      bool errorCalled = false;
      web.window.navigator.geolocation.getCurrentPosition(
        (position) {
          fail('Should not succeed on server');
        },
        (error) {
          errorCalled = true;
          expect(error.code, equals(2)); // POSITION_UNAVAILABLE
          expect(error.message, contains('not supported on the server'));
        },
      );
      expect(errorCalled, isTrue);
    });

    test('watchPosition reports error on server', () {
      bool errorCalled = false;
      web.window.navigator.geolocation.watchPosition(
        (position) {
          fail('Should not succeed on server');
        },
        (error) {
          errorCalled = true;
          expect(error.code, equals(2)); // POSITION_UNAVAILABLE
          expect(error.message, contains('not supported on the server'));
        },
      );
      expect(errorCalled, isTrue);
    });
  });
}
