@TestOn('browser')
import 'package:spark_web/spark_web.dart' as spark;
import 'package:test/test.dart';

void main() {
  group('Browser Geolocation', () {
    test('is available on navigator', () {
      expect(spark.window.navigator.geolocation, isNotNull);
    });

    test('methods exist', () {
      final geo = spark.window.navigator.geolocation;
      expect(geo.getPosition, isNotNull);
      expect(geo.onPositionChanged, isNotNull);
      expect(geo.getCurrentPosition, isNotNull);
      expect(geo.watchPosition, isNotNull);
      expect(geo.clearWatch, isNotNull);
      
      // Call with options to cover _createNativeOptions
      geo.getCurrentPosition((_) {}, (_) {}, const spark.PositionOptions(timeout: 1000));
    });
  });
}
