import 'package:spark_css/src/css_types/css_box_shadow.dart';
import 'package:spark_css/src/css_types/css_color.dart';
import 'package:spark_css/src/css_types/css_length.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssBoxShadow', () {
    test('none outputs correct CSS', () {
      expect(CssBoxShadow.none.toCss(), equals('none'));
    });

    test('single shadow with required params outputs correct CSS', () {
      expect(
        CssBoxShadow(x: CssLength.px(1), y: CssLength.px(2)).toCss(),
        equals('1px 2px'),
      );
    });

    test('single shadow with color outputs correct CSS', () {
      expect(
        CssBoxShadow(
          x: CssLength.px(1),
          y: CssLength.px(2),
          color: CssColor.black,
        ).toCss(),
        equals('1px 2px black'),
      );
    });

    test('single shadow with blur outputs correct CSS', () {
      expect(
        CssBoxShadow(
          x: CssLength.px(1),
          y: CssLength.px(2),
          blur: CssLength.px(3),
        ).toCss(),
        equals('1px 2px 3px'),
      );
    });

    test('single shadow with spread outputs correct CSS (implies blur)', () {
      expect(
        CssBoxShadow(
          x: CssLength.px(1),
          y: CssLength.px(2),
          spread: CssLength.px(4),
        ).toCss(),
        equals('1px 2px 0 4px'),
      );
    });

    test('single shadow with blur and spread outputs correct CSS', () {
      expect(
        CssBoxShadow(
          x: CssLength.px(1),
          y: CssLength.px(2),
          blur: CssLength.px(3),
          spread: CssLength.px(4),
        ).toCss(),
        equals('1px 2px 3px 4px'),
      );
    });

    test('single shadow with inset outputs correct CSS', () {
      expect(
        CssBoxShadow(
          x: CssLength.px(1),
          y: CssLength.px(2),
          inset: true,
        ).toCss(),
        equals('inset 1px 2px'),
      );
    });

    test('full single shadow outputs correct CSS', () {
      expect(
        CssBoxShadow(
          x: CssLength.px(1),
          y: CssLength.px(2),
          blur: CssLength.px(3),
          spread: CssLength.px(4),
          color: CssColor.rgba(0, 0, 0, 0.5),
          inset: true,
        ).toCss(),
        equals('inset 1px 2px 3px 4px rgba(0, 0, 0, 0.5)'),
      );
    });

    test('multiple shadows output correct CSS', () {
      expect(
        CssBoxShadow.multiple([
          CssBoxShadow(x: CssLength.px(1), y: CssLength.px(1)),
          CssBoxShadow(
            x: CssLength.px(2),
            y: CssLength.px(2),
            color: CssColor.red,
          ),
        ]).toCss(),
        equals('1px 1px, 2px 2px red'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(
        CssBoxShadow.variable('shadow-md').toCss(),
        equals('var(--shadow-md)'),
      );
    });

    test('raw outputs correct CSS', () {
      expect(
        CssBoxShadow.raw('5px 5px 10px #888888').toCss(),
        equals('5px 5px 10px #888888'),
      );
    });

    test('global outputs correct CSS', () {
      expect(CssBoxShadow.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
