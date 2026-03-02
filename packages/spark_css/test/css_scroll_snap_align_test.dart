import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssScrollSnapAlign', () {
    test('keywords output correct CSS', () {
      expect(CssScrollSnapAlign.none.toCss(), equals('none'));
      expect(CssScrollSnapAlign.start.toCss(), equals('start'));
      expect(CssScrollSnapAlign.end.toCss(), equals('end'));
      expect(CssScrollSnapAlign.center.toCss(), equals('center'));
    });

    test('pair outputs correct CSS', () {
      expect(
        CssScrollSnapAlign.pair('start', 'end').toCss(),
        equals('start end'),
      );
      expect(
        CssScrollSnapAlign.pair('center', 'none').toCss(),
        equals('center none'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssScrollSnapAlign.variable('ssa').toCss(), equals('var(--ssa)'));
    });

    test('raw outputs value as-is', () {
      expect(CssScrollSnapAlign.raw('start end').toCss(), equals('start end'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssScrollSnapAlign.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssScrollSnapAlign.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(
        CssScrollSnapAlign.global(CssGlobal.unset).toCss(),
        equals('unset'),
      );
      expect(
        CssScrollSnapAlign.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
      expect(
        CssScrollSnapAlign.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(scrollSnapAlign: CssScrollSnapAlign.start);
      expect(style.toCss(), contains('scroll-snap-align: start;'));
    });
  });
}
