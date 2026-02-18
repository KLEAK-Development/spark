@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Geolocation (Server)', () {
    test('constants', () {
      expect(web.GeolocationPositionError.PERMISSION_DENIED, 1);
      expect(web.GeolocationPositionError.POSITION_UNAVAILABLE, 2);
      expect(web.GeolocationPositionError.TIMEOUT, 3);
    });

    test('PositionOptions constructor', () {
      const options = web.PositionOptions(
        enableHighAccuracy: true,
        timeout: 5000,
        maximumAge: 1000,
      );
      expect(options.enableHighAccuracy, isTrue);
      expect(options.timeout, 5000);
      expect(options.maximumAge, 1000);
    });

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

    test('getPosition reports error on server', () async {
      try {
        await web.window.navigator.geolocation.getPosition();
        fail('Should not succeed on server');
      } catch (error) {
        expect(error, isA<web.GeolocationPositionError>());
        final posErr = error as web.GeolocationPositionError;
        expect(posErr.code, equals(2)); // POSITION_UNAVAILABLE
        expect(posErr.message, contains('not supported on the server'));
      }
    });

    test('onPositionChanged reports error on server', () async {
      try {
        await web.window.navigator.geolocation.onPositionChanged().first;
        fail('Should not succeed on server');
      } catch (error) {
        expect(error, isA<web.GeolocationPositionError>());
        final posErr = error as web.GeolocationPositionError;
        expect(posErr.code, equals(2)); // POSITION_UNAVAILABLE
        expect(posErr.message, contains('not supported on the server'));
      }
    });
  });
}
