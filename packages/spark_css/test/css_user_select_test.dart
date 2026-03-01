import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssUserSelect', () {
    test('keywords output correct CSS', () {
      expect(CssUserSelect.none.toCss(), equals('none'));
      expect(CssUserSelect.auto.toCss(), equals('auto'));
      expect(CssUserSelect.text.toCss(), equals('text'));
      expect(CssUserSelect.all.toCss(), equals('all'));
      expect(CssUserSelect.contain.toCss(), equals('contain'));
    });

    test('variable outputs correct CSS', () {
      expect(CssUserSelect.variable('us').toCss(), equals('var(--us)'));
    });

    test('raw outputs value as-is', () {
      expect(CssUserSelect.raw('text').toCss(), equals('text'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssUserSelect.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssUserSelect.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssUserSelect.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssUserSelect.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssUserSelect.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(userSelect: CssUserSelect.none);
      expect(style.toCss(), contains('user-select: none;'));
    });
  });
}
