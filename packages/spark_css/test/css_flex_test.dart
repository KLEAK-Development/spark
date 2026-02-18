import 'package:spark_css/src/css_types/css_flex.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssFlexDirection', () {
    test('keywords output correct CSS', () {
      expect(CssFlexDirection.row.toCss(), equals('row'));
      expect(CssFlexDirection.column.toCss(), equals('column'));
    });
    test('variable outputs correct CSS', () {
      expect(CssFlexDirection.variable('dir').toCss(), equals('var(--dir)'));
    });
    test('raw outputs value as-is', () {
      expect(CssFlexDirection.raw('row').toCss(), equals('row'));
    });
    test('global outputs correct CSS', () {
      expect(CssFlexDirection.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssFlexWrap', () {
    test('keywords output correct CSS', () {
      expect(CssFlexWrap.nowrap.toCss(), equals('nowrap'));
      expect(CssFlexWrap.wrap.toCss(), equals('wrap'));
    });
    test('variable outputs correct CSS', () {
      expect(CssFlexWrap.variable('wrap').toCss(), equals('var(--wrap)'));
    });
    test('raw outputs value as-is', () {
      expect(CssFlexWrap.raw('wrap').toCss(), equals('wrap'));
    });
    test('global outputs correct CSS', () {
      expect(CssFlexWrap.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssJustifyContent', () {
    test('keywords output correct CSS', () {
      expect(CssJustifyContent.center.toCss(), equals('center'));
      expect(CssJustifyContent.spaceBetween.toCss(), equals('space-between'));
    });
    test('variable outputs correct CSS', () {
      expect(CssJustifyContent.variable('justify').toCss(), equals('var(--justify)'));
    });
    test('raw outputs value as-is', () {
      expect(CssJustifyContent.raw('center').toCss(), equals('center'));
    });
    test('global outputs correct CSS', () {
      expect(CssJustifyContent.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssAlignItems', () {
    test('keywords output correct CSS', () {
      expect(CssAlignItems.center.toCss(), equals('center'));
      expect(CssAlignItems.stretch.toCss(), equals('stretch'));
    });
    test('variable outputs correct CSS', () {
      expect(CssAlignItems.variable('align').toCss(), equals('var(--align)'));
    });
    test('raw outputs value as-is', () {
      expect(CssAlignItems.raw('center').toCss(), equals('center'));
    });
    test('global outputs correct CSS', () {
      expect(CssAlignItems.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssAlignSelf', () {
    test('keywords output correct CSS', () {
      expect(CssAlignSelf.auto.toCss(), equals('auto'));
      expect(CssAlignSelf.center.toCss(), equals('center'));
    });
    test('variable outputs correct CSS', () {
      expect(CssAlignSelf.variable('align-self').toCss(), equals('var(--align-self)'));
    });
    test('raw outputs value as-is', () {
      expect(CssAlignSelf.raw('center').toCss(), equals('center'));
    });
    test('global outputs correct CSS', () {
      expect(CssAlignSelf.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssAlignContent', () {
    test('keywords output correct CSS', () {
      expect(CssAlignContent.center.toCss(), equals('center'));
      expect(CssAlignContent.stretch.toCss(), equals('stretch'));
    });
    test('variable outputs correct CSS', () {
      expect(CssAlignContent.variable('align-content').toCss(), equals('var(--align-content)'));
    });
    test('raw outputs value as-is', () {
      expect(CssAlignContent.raw('center').toCss(), equals('center'));
    });
    test('global outputs correct CSS', () {
      expect(CssAlignContent.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
