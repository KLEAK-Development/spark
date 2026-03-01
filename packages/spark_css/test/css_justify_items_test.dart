import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssJustifyItems', () {
    test('keywords output correct CSS', () {
      expect(CssJustifyItems.normal.toCss(), equals('normal'));
      expect(CssJustifyItems.stretch.toCss(), equals('stretch'));
      expect(CssJustifyItems.start.toCss(), equals('start'));
      expect(CssJustifyItems.end.toCss(), equals('end'));
      expect(CssJustifyItems.center.toCss(), equals('center'));
      expect(CssJustifyItems.left.toCss(), equals('left'));
      expect(CssJustifyItems.right.toCss(), equals('right'));
      expect(CssJustifyItems.baseline.toCss(), equals('baseline'));
      expect(CssJustifyItems.firstBaseline.toCss(), equals('first baseline'));
      expect(CssJustifyItems.lastBaseline.toCss(), equals('last baseline'));
    });
    test('variable outputs correct CSS', () {
      expect(CssJustifyItems.variable('ji').toCss(), equals('var(--ji)'));
    });
    test('raw outputs value as-is', () {
      expect(
        CssJustifyItems.raw('legacy center').toCss(),
        equals('legacy center'),
      );
    });
    test('global outputs correct CSS', () {
      expect(
        CssJustifyItems.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
    test('Style.typed integration', () {
      final style = Style.typed(justifyItems: CssJustifyItems.center);
      expect(style.toCss(), contains('justify-items: center;'));
    });
  });
}
