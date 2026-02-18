import 'package:spark_css/src/css_types/css_border.dart';
import 'package:spark_css/src/css_types/css_color.dart';
import 'package:spark_css/src/css_types/css_length.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssBorderStyle', () {
    test('keywords output correct CSS', () {
      expect(CssBorderStyle.none.toCss(), equals('none'));
      expect(CssBorderStyle.hidden.toCss(), equals('hidden'));
      expect(CssBorderStyle.solid.toCss(), equals('solid'));
      expect(CssBorderStyle.dashed.toCss(), equals('dashed'));
      expect(CssBorderStyle.dotted.toCss(), equals('dotted'));
      expect(CssBorderStyle.double_.toCss(), equals('double'));
      expect(CssBorderStyle.groove.toCss(), equals('groove'));
      expect(CssBorderStyle.ridge.toCss(), equals('ridge'));
      expect(CssBorderStyle.inset.toCss(), equals('inset'));
      expect(CssBorderStyle.outset.toCss(), equals('outset'));
    });

    test('variable outputs correct CSS', () {
      expect(
        CssBorderStyle.variable('border-style').toCss(),
        equals('var(--border-style)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(CssBorderStyle.raw('solid').toCss(), equals('solid'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssBorderStyle.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
  });

  group('CssBorder', () {
    test('none keyword outputs correct CSS', () {
      expect(CssBorder.none.toCss(), equals('none'));
    });

    test('shorthand with color outputs correct CSS', () {
      expect(
        CssBorder(
          width: CssLength.px(1),
          style: CssBorderStyle.solid,
          color: CssColor.black,
        ).toCss(),
        equals('1px solid black'),
      );
    });

    test('shorthand without color outputs correct CSS', () {
      expect(
        CssBorder.widthStyle(CssLength.px(2), CssBorderStyle.dashed).toCss(),
        equals('2px dashed'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssBorder.variable('border').toCss(), equals('var(--border)'));
    });

    test('raw outputs value as-is', () {
      expect(
        CssBorder.raw('1px solid black').toCss(),
        equals('1px solid black'),
      );
    });

    test('global outputs correct CSS', () {
      expect(CssBorder.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
