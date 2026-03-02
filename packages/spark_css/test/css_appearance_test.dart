import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssAppearance', () {
    test('keywords output correct CSS', () {
      expect(CssAppearance.none.toCss(), equals('none'));
      expect(CssAppearance.auto.toCss(), equals('auto'));
      expect(CssAppearance.menulistButton.toCss(), equals('menulist-button'));
      expect(CssAppearance.textfield.toCss(), equals('textfield'));
    });

    test('variable outputs correct CSS', () {
      expect(CssAppearance.variable('ap').toCss(), equals('var(--ap)'));
    });

    test('raw outputs value as-is', () {
      expect(CssAppearance.raw('none').toCss(), equals('none'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssAppearance.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssAppearance.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssAppearance.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssAppearance.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssAppearance.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(appearance: CssAppearance.none);
      expect(style.toCss(), contains('appearance: none;'));
    });
  });
}
