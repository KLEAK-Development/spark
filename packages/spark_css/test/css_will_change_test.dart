import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssWillChange', () {
    test('keywords output correct CSS', () {
      expect(CssWillChange.auto.toCss(), equals('auto'));
      expect(CssWillChange.scrollPosition.toCss(), equals('scroll-position'));
      expect(CssWillChange.contents.toCss(), equals('contents'));
    });

    test('properties outputs comma-separated list', () {
      expect(
        CssWillChange.properties(['transform']).toCss(),
        equals('transform'),
      );
      expect(
        CssWillChange.properties(['transform', 'opacity']).toCss(),
        equals('transform, opacity'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssWillChange.variable('wc').toCss(), equals('var(--wc)'));
    });

    test('raw outputs value as-is', () {
      expect(CssWillChange.raw('transform').toCss(), equals('transform'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssWillChange.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssWillChange.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssWillChange.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssWillChange.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssWillChange.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(willChange: CssWillChange.auto);
      expect(style.toCss(), contains('will-change: auto;'));
    });
  });
}
