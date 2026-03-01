import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssHyphens', () {
    test('keywords output correct CSS', () {
      expect(CssHyphens.none.toCss(), equals('none'));
      expect(CssHyphens.manual.toCss(), equals('manual'));
      expect(CssHyphens.auto.toCss(), equals('auto'));
    });

    test('variable outputs correct CSS', () {
      expect(CssHyphens.variable('hyph').toCss(), equals('var(--hyph)'));
    });

    test('raw outputs value as-is', () {
      expect(CssHyphens.raw('manual').toCss(), equals('manual'));
    });

    test('global outputs correct CSS', () {
      expect(CssHyphens.global(CssGlobal.inherit).toCss(), equals('inherit'));
      expect(CssHyphens.global(CssGlobal.initial).toCss(), equals('initial'));
      expect(CssHyphens.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssHyphens.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssHyphens.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(hyphens: CssHyphens.auto);
      expect(style.toCss(), contains('hyphens: auto;'));
    });
  });
}
