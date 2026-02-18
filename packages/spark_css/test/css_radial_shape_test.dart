import 'package:spark_css/src/css_types/css_radial_shape.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssRadialShape', () {
    test('keywords output correct CSS', () {
      expect(CssRadialShape.circle.toCss(), equals('circle'));
      expect(CssRadialShape.ellipse.toCss(), equals('ellipse'));
    });

    test('raw outputs value as-is', () {
      expect(CssRadialShape.raw('circle').toCss(), equals('circle'));
    });

    test('global outputs correct CSS', () {
      expect(CssRadialShape.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
