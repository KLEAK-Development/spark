import 'package:spark_css/src/css_types/css_length.dart';
import 'package:spark_css/src/css_types/css_radial_size.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssRadialSize', () {
    test('keywords output correct CSS', () {
      expect(CssRadialSize.closestSide.toCss(), equals('closest-side'));
      expect(CssRadialSize.closestCorner.toCss(), equals('closest-corner'));
      expect(CssRadialSize.farthestSide.toCss(), equals('farthest-side'));
      expect(CssRadialSize.farthestCorner.toCss(), equals('farthest-corner'));
    });

    test('size outputs correct CSS', () {
      expect(CssRadialSize.size(CssLength.px(50)).toCss(), equals('50px'));
    });

    test('size2 outputs correct CSS', () {
      expect(
        CssRadialSize.size2(CssLength.px(50), CssLength.px(100)).toCss(),
        equals('50px 100px'),
      );
    });

    test('raw outputs value as-is', () {
      expect(CssRadialSize.raw('50px').toCss(), equals('50px'));
    });

    test('global outputs correct CSS', () {
      expect(CssRadialSize.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
