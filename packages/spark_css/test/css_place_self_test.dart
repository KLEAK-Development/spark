import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssPlaceSelf', () {
    test('shorthand with align only outputs single value', () {
      final ps = CssPlaceSelf(CssAlignSelf.center);
      expect(ps.toCss(), equals('center'));
    });

    test('shorthand with align and justify outputs both values', () {
      final ps = CssPlaceSelf(CssAlignSelf.center, CssJustifySelf.start);
      expect(ps.toCss(), equals('center start'));
    });

    test('variable outputs correct CSS', () {
      expect(CssPlaceSelf.variable('ps').toCss(), equals('var(--ps)'));
    });

    test('raw outputs value as-is', () {
      expect(CssPlaceSelf.raw('center start').toCss(), equals('center start'));
    });

    test('global outputs correct CSS', () {
      expect(CssPlaceSelf.global(CssGlobal.inherit).toCss(), equals('inherit'));
      expect(CssPlaceSelf.global(CssGlobal.initial).toCss(), equals('initial'));
      expect(CssPlaceSelf.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssPlaceSelf.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssPlaceSelf.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(
        placeSelf: CssPlaceSelf(CssAlignSelf.center, CssJustifySelf.end),
      );
      expect(style.toCss(), contains('place-self: center end;'));
    });
  });
}
