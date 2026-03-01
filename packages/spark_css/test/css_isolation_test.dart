import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssIsolation', () {
    test('keywords output correct CSS', () {
      expect(CssIsolation.auto.toCss(), equals('auto'));
      expect(CssIsolation.isolate.toCss(), equals('isolate'));
    });

    test('variable outputs correct CSS', () {
      expect(CssIsolation.variable('iso').toCss(), equals('var(--iso)'));
    });

    test('raw outputs value as-is', () {
      expect(CssIsolation.raw('isolate').toCss(), equals('isolate'));
    });

    test('global outputs correct CSS', () {
      expect(CssIsolation.global(CssGlobal.inherit).toCss(), equals('inherit'));
      expect(CssIsolation.global(CssGlobal.initial).toCss(), equals('initial'));
      expect(CssIsolation.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssIsolation.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssIsolation.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(isolation: CssIsolation.isolate);
      expect(style.toCss(), contains('isolation: isolate;'));
    });
  });
}
