import 'package:spark_css/src/css_types/css_angle.dart';
import 'package:spark_css/src/css_types/css_gradient_direction.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssGradientDirection', () {
    test('keywords output correct CSS', () {
      expect(CssGradientDirection.toTop.toCss(), equals('to top'));
      expect(CssGradientDirection.toBottom.toCss(), equals('to bottom'));
      expect(CssGradientDirection.toLeft.toCss(), equals('to left'));
      expect(CssGradientDirection.toRight.toCss(), equals('to right'));
      expect(CssGradientDirection.toTopLeft.toCss(), equals('to top left'));
      expect(CssGradientDirection.toTopRight.toCss(), equals('to top right'));
      expect(CssGradientDirection.toBottomLeft.toCss(), equals('to bottom left'));
      expect(CssGradientDirection.toBottomRight.toCss(), equals('to bottom right'));
    });

    test('angle outputs correct CSS', () {
      expect(CssGradientDirection.angle(CssAngle.deg(45)).toCss(), equals('45deg'));
    });

    test('raw outputs value as-is', () {
      expect(CssGradientDirection.raw('to top left').toCss(), equals('to top left'));
    });

    test('global outputs correct CSS', () {
      expect(CssGradientDirection.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
