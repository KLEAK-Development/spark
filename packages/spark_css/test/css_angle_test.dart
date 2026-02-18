import 'package:spark_css/src/css_types/css_angle.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssAngle', () {
    test('units output correct CSS', () {
      expect(CssAngle.deg(45).toCss(), equals('45deg'));
      expect(CssAngle.rad(3.14).toCss(), equals('3.14rad'));
      expect(CssAngle.grad(100).toCss(), equals('100grad'));
      expect(CssAngle.turn(0.5).toCss(), equals('0.5turn'));
    });

    test('variable outputs correct CSS', () {
      expect(CssAngle.variable('angle').toCss(), equals('var(--angle)'));
    });

    test('raw outputs value as-is', () {
      expect(CssAngle.raw('45deg').toCss(), equals('45deg'));
    });

    test('global outputs correct CSS', () {
      expect(CssAngle.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
