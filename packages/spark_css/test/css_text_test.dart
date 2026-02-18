import 'package:spark_css/src/css_types/css_text.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssTextAlign', () {
    test('keywords output correct CSS', () {
      expect(CssTextAlign.left.toCss(), equals('left'));
      expect(CssTextAlign.center.toCss(), equals('center'));
    });
    test('variable outputs correct CSS', () {
      expect(CssTextAlign.variable('align').toCss(), equals('var(--align)'));
    });
    test('raw outputs value as-is', () {
      expect(CssTextAlign.raw('center').toCss(), equals('center'));
    });
    test('global outputs correct CSS', () {
      expect(CssTextAlign.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssTextDecoration', () {
    test('keywords output correct CSS', () {
      expect(CssTextDecoration.none.toCss(), equals('none'));
      expect(CssTextDecoration.underline.toCss(), equals('underline'));
    });
    test('variable outputs correct CSS', () {
      expect(CssTextDecoration.variable('decor').toCss(), equals('var(--decor)'));
    });
    test('raw outputs value as-is', () {
      expect(CssTextDecoration.raw('underline').toCss(), equals('underline'));
    });
    test('global outputs correct CSS', () {
      expect(CssTextDecoration.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssTextTransform', () {
    test('keywords output correct CSS', () {
      expect(CssTextTransform.none.toCss(), equals('none'));
      expect(CssTextTransform.uppercase.toCss(), equals('uppercase'));
    });
    test('variable outputs correct CSS', () {
      expect(CssTextTransform.variable('trans').toCss(), equals('var(--trans)'));
    });
    test('raw outputs value as-is', () {
      expect(CssTextTransform.raw('uppercase').toCss(), equals('uppercase'));
    });
    test('global outputs correct CSS', () {
      expect(CssTextTransform.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssWhiteSpace', () {
    test('keywords output correct CSS', () {
      expect(CssWhiteSpace.normal.toCss(), equals('normal'));
      expect(CssWhiteSpace.nowrap.toCss(), equals('nowrap'));
    });
    test('variable outputs correct CSS', () {
      expect(CssWhiteSpace.variable('ws').toCss(), equals('var(--ws)'));
    });
    test('raw outputs value as-is', () {
      expect(CssWhiteSpace.raw('nowrap').toCss(), equals('nowrap'));
    });
    test('global outputs correct CSS', () {
      expect(CssWhiteSpace.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssWordBreak', () {
    test('keywords output correct CSS', () {
      expect(CssWordBreak.normal.toCss(), equals('normal'));
      expect(CssWordBreak.breakAll.toCss(), equals('break-all'));
    });
    test('variable outputs correct CSS', () {
      expect(CssWordBreak.variable('wb').toCss(), equals('var(--wb)'));
    });
    test('raw outputs value as-is', () {
      expect(CssWordBreak.raw('break-all').toCss(), equals('break-all'));
    });
    test('global outputs correct CSS', () {
      expect(CssWordBreak.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
