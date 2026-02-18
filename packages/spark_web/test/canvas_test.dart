import 'package:spark_web/spark_web.dart';
import 'package:test/test.dart';

void main() {
  group('CanvasContextType', () {
    test('canvasContextTypeToString', () {
      expect(canvasContextTypeToString(CanvasContextType.canvas2d), '2d');
    });
  });
}
