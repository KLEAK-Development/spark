import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssContain', () {
    test('keyword shorthands output correct CSS', () {
      expect(CssContain.none.toCss(), equals('none'));
      expect(CssContain.strict.toCss(), equals('strict'));
      expect(CssContain.content.toCss(), equals('content'));
    });

    test('individual keyword constants output correct CSS', () {
      expect(CssContain.size.toCss(), equals('size'));
      expect(CssContain.layout.toCss(), equals('layout'));
      expect(CssContain.style.toCss(), equals('style'));
      expect(CssContain.paint.toCss(), equals('paint'));
    });

    test('flags with no active flags returns none', () {
      expect(CssContain.flags().toCss(), equals('none'));
    });

    test('flags with single flag', () {
      expect(CssContain.flags(size: true).toCss(), equals('size'));
      expect(CssContain.flags(layout: true).toCss(), equals('layout'));
      expect(CssContain.flags(style: true).toCss(), equals('style'));
      expect(CssContain.flags(paint: true).toCss(), equals('paint'));
    });

    test('flags with multiple flags joins in order', () {
      expect(
        CssContain.flags(size: true, layout: true).toCss(),
        equals('size layout'),
      );
      expect(
        CssContain.flags(layout: true, style: true, paint: true).toCss(),
        equals('layout style paint'),
      );
      expect(
        CssContain.flags(
          size: true,
          layout: true,
          style: true,
          paint: true,
        ).toCss(),
        equals('size layout style paint'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssContain.variable('ctn').toCss(), equals('var(--ctn)'));
    });

    test('raw outputs value as-is', () {
      expect(CssContain.raw('strict').toCss(), equals('strict'));
    });

    test('global outputs correct CSS', () {
      expect(CssContain.global(CssGlobal.inherit).toCss(), equals('inherit'));
      expect(CssContain.global(CssGlobal.initial).toCss(), equals('initial'));
      expect(CssContain.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssContain.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssContain.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(contain: CssContain.strict);
      expect(style.toCss(), contains('contain: strict;'));
    });
  });
}
