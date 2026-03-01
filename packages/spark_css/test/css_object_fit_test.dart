import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssObjectFit', () {
    test('keywords output correct CSS', () {
      expect(CssObjectFit.fill.toCss(), equals('fill'));
      expect(CssObjectFit.contain.toCss(), equals('contain'));
      expect(CssObjectFit.cover.toCss(), equals('cover'));
      expect(CssObjectFit.none.toCss(), equals('none'));
      expect(CssObjectFit.scaleDown.toCss(), equals('scale-down'));
    });
    test('variable outputs correct CSS', () {
      expect(CssObjectFit.variable('of').toCss(), equals('var(--of)'));
    });
    test('raw outputs value as-is', () {
      expect(CssObjectFit.raw('cover').toCss(), equals('cover'));
    });
    test('global outputs correct CSS', () {
      expect(CssObjectFit.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
    test('Style.typed integration', () {
      final style = Style.typed(objectFit: CssObjectFit.cover);
      expect(style.toCss(), contains('object-fit: cover;'));
    });
  });
}
