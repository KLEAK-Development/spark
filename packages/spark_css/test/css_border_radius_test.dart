import 'package:spark_css/src/css_types/css_border_radius.dart';
import 'package:spark_css/src/css_types/css_length.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssBorderRadius', () {
    test('all outputs single value', () {
      final radius = CssBorderRadius.all(CssLength.px(10));
      expect(radius.toCss(), equals('10px'));
    });

    test('zero outputs 0', () {
      expect(CssBorderRadius.zero.toCss(), equals('0'));
    });

    test('symmetric outputs two values', () {
      final radius = CssBorderRadius.symmetric(
        CssLength.px(10),
        CssLength.px(20),
      );
      expect(radius.toCss(), equals('10px 20px'));
    });

    test('only (three values) outputs three values', () {
      final radius = CssBorderRadius.only(
        topLeft: CssLength.px(10),
        topRightBottomLeft: CssLength.px(20),
        bottomRight: CssLength.px(30),
      );
      expect(radius.toCss(), equals('10px 20px 30px'));
    });

    test('trbl outputs four values', () {
      final radius = CssBorderRadius.trbl(
        CssLength.px(10),
        CssLength.px(20),
        CssLength.px(30),
        CssLength.px(40),
      );
      expect(radius.toCss(), equals('10px 20px 30px 40px'));
    });

    test('variable outputs correct CSS', () {
      final radius = CssBorderRadius.variable('radius-md');
      expect(radius.toCss(), equals('var(--radius-md)'));
    });

    test('raw outputs value as-is', () {
      final radius = CssBorderRadius.raw('10px / 20px');
      expect(radius.toCss(), equals('10px / 20px'));
    });

    test('global outputs correct CSS', () {
      final radius = CssBorderRadius.global(CssGlobal.inherit);
      expect(radius.toCss(), equals('inherit'));
    });
  });
}
