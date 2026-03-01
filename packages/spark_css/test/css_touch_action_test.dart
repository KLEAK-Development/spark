import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssTouchAction', () {
    test('standalone keywords output correct CSS', () {
      expect(CssTouchAction.auto.toCss(), equals('auto'));
      expect(CssTouchAction.none.toCss(), equals('none'));
      expect(CssTouchAction.manipulation.toCss(), equals('manipulation'));
    });

    test('combinable keywords output correct CSS', () {
      expect(CssTouchAction.panX.toCss(), equals('pan-x'));
      expect(CssTouchAction.panLeft.toCss(), equals('pan-left'));
      expect(CssTouchAction.panRight.toCss(), equals('pan-right'));
      expect(CssTouchAction.panY.toCss(), equals('pan-y'));
      expect(CssTouchAction.panUp.toCss(), equals('pan-up'));
      expect(CssTouchAction.panDown.toCss(), equals('pan-down'));
      expect(CssTouchAction.pinchZoom.toCss(), equals('pinch-zoom'));
    });

    test('combine outputs space-separated values', () {
      final combined = CssTouchAction.combine([
        CssTouchAction.panX,
        CssTouchAction.pinchZoom,
      ]);
      expect(combined.toCss(), equals('pan-x pinch-zoom'));
    });

    test('combine with pan-y and pinch-zoom', () {
      final combined = CssTouchAction.combine([
        CssTouchAction.panY,
        CssTouchAction.pinchZoom,
      ]);
      expect(combined.toCss(), equals('pan-y pinch-zoom'));
    });

    test('variable outputs correct CSS', () {
      expect(CssTouchAction.variable('ta').toCss(), equals('var(--ta)'));
    });

    test('raw outputs value as-is', () {
      expect(
        CssTouchAction.raw('pan-x pinch-zoom').toCss(),
        equals('pan-x pinch-zoom'),
      );
    });

    test('global outputs correct CSS', () {
      expect(
        CssTouchAction.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssTouchAction.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssTouchAction.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssTouchAction.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssTouchAction.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(touchAction: CssTouchAction.manipulation);
      expect(style.toCss(), contains('touch-action: manipulation;'));
    });
  });
}
