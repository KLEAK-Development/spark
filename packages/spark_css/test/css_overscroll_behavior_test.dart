import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssOverscrollBehavior', () {
    test('keywords output correct CSS', () {
      expect(CssOverscrollBehavior.auto.toCss(), equals('auto'));
      expect(CssOverscrollBehavior.contain.toCss(), equals('contain'));
      expect(CssOverscrollBehavior.none.toCss(), equals('none'));
    });

    test('xy outputs correct CSS', () {
      expect(
        CssOverscrollBehavior.xy(
          CssOverscrollBehavior.contain,
          CssOverscrollBehavior.none,
        ).toCss(),
        equals('contain none'),
      );
      expect(
        CssOverscrollBehavior.xy(
          CssOverscrollBehavior.auto,
          CssOverscrollBehavior.contain,
        ).toCss(),
        equals('auto contain'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssOverscrollBehavior.variable('ob').toCss(), equals('var(--ob)'));
    });

    test('raw outputs value as-is', () {
      expect(
        CssOverscrollBehavior.raw('contain none').toCss(),
        equals('contain none'),
      );
    });

    test('global outputs correct CSS', () {
      expect(
        CssOverscrollBehavior.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssOverscrollBehavior.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(
        CssOverscrollBehavior.global(CssGlobal.unset).toCss(),
        equals('unset'),
      );
      expect(
        CssOverscrollBehavior.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
      expect(
        CssOverscrollBehavior.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(
        overscrollBehavior: CssOverscrollBehavior.contain,
      );
      expect(style.toCss(), contains('overscroll-behavior: contain;'));
    });
  });
}
