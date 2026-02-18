import 'package:spark_css/src/css_types/css_number.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssNumber', () {
    test('value outputs correct CSS', () {
      expect(CssNumber(1).toCss(), equals('1'));
      expect(CssNumber(0.5).toCss(), equals('0.5'));
    });
    test('variable outputs correct CSS', () {
      expect(CssNumber.variable('num').toCss(), equals('var(--num)'));
    });
    test('raw outputs value as-is', () {
      expect(CssNumber.raw('1').toCss(), equals('1'));
    });
    test('global outputs correct CSS', () {
      expect(CssNumber.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssZIndex', () {
    test('auto outputs correct CSS', () {
      expect(CssZIndex.auto.toCss(), equals('auto'));
    });
    test('value outputs correct CSS', () {
      expect(CssZIndex(10).toCss(), equals('10'));
    });
    test('variable outputs correct CSS', () {
      expect(CssZIndex.variable('z').toCss(), equals('var(--z)'));
    });
    test('raw outputs value as-is', () {
      expect(CssZIndex.raw('10').toCss(), equals('10'));
    });
    test('global outputs correct CSS', () {
      expect(CssZIndex.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
