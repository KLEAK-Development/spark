import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssPointerEvents', () {
    test('keywords output correct CSS', () {
      expect(CssPointerEvents.auto.toCss(), equals('auto'));
      expect(CssPointerEvents.none.toCss(), equals('none'));
      expect(CssPointerEvents.visiblePainted.toCss(), equals('visiblePainted'));
      expect(CssPointerEvents.visibleFill.toCss(), equals('visibleFill'));
      expect(CssPointerEvents.visibleStroke.toCss(), equals('visibleStroke'));
      expect(CssPointerEvents.visible.toCss(), equals('visible'));
      expect(CssPointerEvents.painted.toCss(), equals('painted'));
      expect(CssPointerEvents.fill.toCss(), equals('fill'));
      expect(CssPointerEvents.stroke.toCss(), equals('stroke'));
      expect(CssPointerEvents.all.toCss(), equals('all'));
    });
    test('variable outputs correct CSS', () {
      expect(CssPointerEvents.variable('pe').toCss(), equals('var(--pe)'));
    });
    test('raw outputs value as-is', () {
      expect(CssPointerEvents.raw('none').toCss(), equals('none'));
    });
    test('global outputs correct CSS', () {
      expect(
        CssPointerEvents.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
    test('Style.typed integration', () {
      final style = Style.typed(pointerEvents: CssPointerEvents.none);
      expect(style.toCss(), contains('pointer-events: none;'));
    });
  });
}
