import 'package:spark_css/src/css_types/css_length.dart';
import 'package:spark_css/src/css_types/css_spacing.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssSpacing', () {
    test('all outputs correct CSS', () {
      expect(CssSpacing.all(CssLength.px(10)).toCss(), equals('10px'));
    });
    test('symmetric outputs correct CSS', () {
      expect(CssSpacing.symmetric(CssLength.px(10), CssLength.px(20)).toCss(), equals('10px 20px'));
    });
    test('only outputs correct CSS', () {
      expect(
        CssSpacing.only(top: CssLength.px(10), horizontal: CssLength.px(20), bottom: CssLength.px(30)).toCss(),
        equals('10px 20px 30px'),
      );
    });
    test('trbl outputs correct CSS', () {
      expect(
        CssSpacing.trbl(CssLength.px(10), CssLength.px(20), CssLength.px(30), CssLength.px(40)).toCss(),
        equals('10px 20px 30px 40px'),
      );
    });
    test('sides convenience factory', () {
      // No arguments
      final empty = CssSpacing.sides();
      expect(empty.toCss(), equals('0'));

      // All four
      expect(
        CssSpacing.sides(top: CssLength.px(10), right: CssLength.px(20), bottom: CssLength.px(30), left: CssLength.px(40)).toCss(),
        equals('10px 20px 30px 40px'),
      );
      // Just one (top)
      expect(CssSpacing.sides(top: CssLength.px(10)).toCss(), equals('10px'));
      // Two sides
      expect(CssSpacing.sides(top: CssLength.px(10), right: CssLength.px(20)).toCss(), equals('10px 20px'));
      // Three sides
      expect(CssSpacing.sides(top: CssLength.px(10), right: CssLength.px(20), bottom: CssLength.px(30)).toCss(), equals('10px 20px 30px'));
      // Four sides (different values)
      expect(CssSpacing.sides(top: CssLength.px(10), right: CssLength.px(20), bottom: CssLength.px(30), left: CssLength.px(40)).toCss(), equals('10px 20px 30px 40px'));
      // Four sides (same values - should use _CssSpacingAll)
      expect(CssSpacing.sides(top: CssLength.px(10), right: null, bottom: null, left: null).toCss(), equals('10px'));
      // Empty
      expect(CssSpacing.sides().toCss(), equals('0'));
    });
    test('variable outputs correct CSS', () {
      expect(CssSpacing.variable('space').toCss(), equals('var(--space)'));
    });
    test('raw outputs value as-is', () {
      expect(CssSpacing.raw('10px 20px').toCss(), equals('10px 20px'));
    });
    test('global outputs correct CSS', () {
      expect(CssSpacing.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
    test('length factory', () {
      expect(CssSpacing.length(CssLength.px(10)).toCss(), equals('10px'));
    });
  });
}
