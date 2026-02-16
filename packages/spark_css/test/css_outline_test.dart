import 'package:spark_css/src/css_types/css_border.dart';
import 'package:spark_css/src/css_types/css_color.dart';
import 'package:spark_css/src/css_types/css_length.dart';
import 'package:spark_css/src/css_types/css_outline.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssOutline', () {
    test('none', () {
      expect(CssOutline.none.toCss(), equals('none'));
    });

    test('shorthand with all values', () {
      final outline = CssOutline(
        width: CssLength.px(2),
        style: CssBorderStyle.solid,
        color: CssColor.red,
      );
      expect(outline.toCss(), equals('2px solid red'));
    });

    test('shorthand with some values', () {
      final outline = CssOutline(
        width: CssLength.px(1),
        style: CssBorderStyle.dashed,
      );
      expect(outline.toCss(), equals('1px dashed'));
    });

    test('shorthand with just color', () {
      final outline = CssOutline(color: CssColor.blue);
      expect(outline.toCss(), equals('blue'));
    });

    test('shorthand empty defaults to none', () {
      final outline = CssOutline();
      expect(outline.toCss(), equals('none'));
    });

    test('variable', () {
      final outline = CssOutline.variable('my-outline');
      expect(outline.toCss(), equals('var(--my-outline)'));
    });

    test('raw', () {
      final outline = CssOutline.raw('thick double #000');
      expect(outline.toCss(), equals('thick double #000'));
    });

    test('global', () {
      final outline = CssOutline.global(CssGlobal.inherit);
      expect(outline.toCss(), equals('inherit'));
    });
  });

  group('CssOutlineOffset', () {
    test('length', () {
      final offset = CssOutlineOffset(CssLength.px(5));
      expect(offset.toCss(), equals('5px'));
    });

    test('variable', () {
      final offset = CssOutlineOffset.variable('offset');
      expect(offset.toCss(), equals('var(--offset)'));
    });

    test('raw', () {
      final offset = CssOutlineOffset.raw('10%');
      expect(offset.toCss(), equals('10%'));
    });

    test('global', () {
      final offset = CssOutlineOffset.global(CssGlobal.initial);
      expect(offset.toCss(), equals('initial'));
    });
  });
}
