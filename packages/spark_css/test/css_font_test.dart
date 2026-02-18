import 'package:spark_css/src/css_types/css_font.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssFontWeight', () {
    test('keywords output correct CSS', () {
      expect(CssFontWeight.normal.toCss(), equals('normal'));
      expect(CssFontWeight.bold.toCss(), equals('bold'));
    });
    test('numeric outputs correct CSS', () {
      expect(CssFontWeight.numeric(500).toCss(), equals('500'));
    });
    test('variable outputs correct CSS', () {
      expect(CssFontWeight.variable('weight').toCss(), equals('var(--weight)'));
    });
    test('raw outputs value as-is', () {
      expect(CssFontWeight.raw('bold').toCss(), equals('bold'));
    });
    test('global outputs correct CSS', () {
      expect(CssFontWeight.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssFontFamily', () {
    test('generic output correct CSS', () {
      expect(CssFontFamily.sansSerif.toCss(), equals('sans-serif'));
    });
    test('named output quoted CSS', () {
      expect(CssFontFamily.named('Arial').toCss(), equals('"Arial"'));
    });
    test('stack outputs correct CSS', () {
      expect(
        CssFontFamily.stack([CssFontFamily.named('Arial'), CssFontFamily.sansSerif]).toCss(),
        equals('"Arial", sans-serif'),
      );
    });
    test('variable outputs correct CSS', () {
      expect(CssFontFamily.variable('font').toCss(), equals('var(--font)'));
    });
    test('raw outputs value as-is', () {
      expect(CssFontFamily.raw('sans-serif').toCss(), equals('sans-serif'));
    });
    test('global outputs correct CSS', () {
      expect(CssFontFamily.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssFontStyle', () {
    test('keywords output correct CSS', () {
      expect(CssFontStyle.normal.toCss(), equals('normal'));
      expect(CssFontStyle.italic.toCss(), equals('italic'));
    });
    test('obliqueAngle outputs correct CSS', () {
      expect(CssFontStyle.obliqueAngle('10deg').toCss(), equals('oblique 10deg'));
    });
    test('variable outputs correct CSS', () {
      expect(CssFontStyle.variable('style').toCss(), equals('var(--style)'));
    });
    test('raw outputs value as-is', () {
      expect(CssFontStyle.raw('italic').toCss(), equals('italic'));
    });
    test('global outputs correct CSS', () {
      expect(CssFontStyle.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
