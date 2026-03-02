import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssScrollSnapType', () {
    test('none keyword outputs correct CSS', () {
      expect(CssScrollSnapType.none.toCss(), equals('none'));
    });

    test('axis only outputs correct CSS', () {
      expect(CssScrollSnapType.axis('x').toCss(), equals('x'));
      expect(CssScrollSnapType.axis('y').toCss(), equals('y'));
      expect(CssScrollSnapType.axis('block').toCss(), equals('block'));
      expect(CssScrollSnapType.axis('inline').toCss(), equals('inline'));
      expect(CssScrollSnapType.axis('both').toCss(), equals('both'));
    });

    test('axis with strictness outputs correct CSS', () {
      expect(
        CssScrollSnapType.axis('x', 'mandatory').toCss(),
        equals('x mandatory'),
      );
      expect(
        CssScrollSnapType.axis('y', 'proximity').toCss(),
        equals('y proximity'),
      );
      expect(
        CssScrollSnapType.axis('both', 'mandatory').toCss(),
        equals('both mandatory'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssScrollSnapType.variable('sst').toCss(), equals('var(--sst)'));
    });

    test('raw outputs value as-is', () {
      expect(
        CssScrollSnapType.raw('x mandatory').toCss(),
        equals('x mandatory'),
      );
    });

    test('global outputs correct CSS', () {
      expect(
        CssScrollSnapType.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssScrollSnapType.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(
        CssScrollSnapType.global(CssGlobal.unset).toCss(),
        equals('unset'),
      );
      expect(
        CssScrollSnapType.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
      expect(
        CssScrollSnapType.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(
        scrollSnapType: CssScrollSnapType.axis('x', 'mandatory'),
      );
      expect(style.toCss(), contains('scroll-snap-type: x mandatory;'));
    });
  });
}
