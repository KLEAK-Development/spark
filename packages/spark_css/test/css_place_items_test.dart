import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssPlaceItems', () {
    test('align only outputs single value', () {
      final pi = CssPlaceItems(CssAlignItems.center);
      expect(pi.toCss(), equals('center'));
    });
    test('align and justify outputs both values', () {
      final pi = CssPlaceItems(CssAlignItems.center, CssJustifyItems.start);
      expect(pi.toCss(), equals('center start'));
    });
    test('variable outputs correct CSS', () {
      expect(CssPlaceItems.variable('pi').toCss(), equals('var(--pi)'));
    });
    test('raw outputs value as-is', () {
      expect(CssPlaceItems.raw('center start').toCss(), equals('center start'));
    });
    test('global outputs correct CSS', () {
      expect(
        CssPlaceItems.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
    test('Style.typed integration', () {
      final style = Style.typed(
        placeItems: CssPlaceItems(CssAlignItems.center, CssJustifyItems.start),
      );
      expect(style.toCss(), contains('place-items: center start;'));
    });
  });
}
