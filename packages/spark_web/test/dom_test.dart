import 'package:spark_web/spark_web.dart';
import 'package:test/test.dart';

void main() {
  group('ShadowRootInit', () {
    test('constructor sets mode', () {
      const init = ShadowRootInit(mode: 'open');
      expect(init.mode, 'open');
    });
  });
}
