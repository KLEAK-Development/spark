import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssPlaceContent', () {
    test('shorthand with align only outputs single value', () {
      final pc = CssPlaceContent(CssAlignContent.center);
      expect(pc.toCss(), equals('center'));
    });

    test('shorthand with align and justify outputs both values', () {
      final pc = CssPlaceContent(
        CssAlignContent.center,
        CssJustifyContent.spaceBetween,
      );
      expect(pc.toCss(), equals('center space-between'));
    });

    test('variable outputs correct CSS', () {
      expect(CssPlaceContent.variable('pc').toCss(), equals('var(--pc)'));
    });

    test('raw outputs value as-is', () {
      expect(
        CssPlaceContent.raw('center start').toCss(),
        equals('center start'),
      );
    });

    test('global outputs correct CSS', () {
      expect(
        CssPlaceContent.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssPlaceContent.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssPlaceContent.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(
        CssPlaceContent.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
      expect(
        CssPlaceContent.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(
        placeContent: CssPlaceContent(
          CssAlignContent.center,
          CssJustifyContent.spaceEvenly,
        ),
      );
      expect(style.toCss(), contains('place-content: center space-evenly;'));
    });
  });
}
