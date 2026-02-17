import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssFlexShorthand', () {
    test('keywords output correct CSS', () {
      expect(CssFlexShorthand.auto.toCss(), equals('auto'));
      expect(CssFlexShorthand.initial.toCss(), equals('initial'));
      expect(CssFlexShorthand.none.toCss(), equals('none'));
    });

    test('single value (grow) outputs correct CSS', () {
      expect(CssFlexShorthand(grow: 1).toCss(), equals('1'));
      expect(CssFlexShorthand(grow: 0.5).toCss(), equals('0.5'));
    });

    test('single value (basis) outputs correct CSS', () {
      expect(
        CssFlexShorthand(basis: CssLength.px(100)).toCss(),
        equals('100px'),
      );
      expect(CssFlexShorthand(basis: CssLength.auto).toCss(), equals('auto'));
    });

    test('two values (grow + shrink) outputs correct CSS', () {
      expect(CssFlexShorthand(grow: 1, shrink: 2).toCss(), equals('1 2'));
    });

    test('two values (grow + basis) outputs correct CSS', () {
      expect(
        CssFlexShorthand(grow: 1, basis: CssLength.percent(50)).toCss(),
        equals('1 50%'),
      );
    });

    test('three values (grow + shrink + basis) outputs correct CSS', () {
      expect(
        CssFlexShorthand(grow: 1, shrink: 0, basis: CssLength.auto).toCss(),
        equals('1 0 auto'),
      );
    });

    test('throws ArgumentError when shrink provided without grow', () {
      expect(() => CssFlexShorthand(shrink: 1), throwsArgumentError);
      expect(
        () => CssFlexShorthand(shrink: 1, basis: CssLength.auto),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError when neither grow nor basis provided', () {
      expect(() => CssFlexShorthand(), throwsArgumentError);
    });

    test('variable outputs correct CSS', () {
      expect(
        CssFlexShorthand.variable('flex-val').toCss(),
        equals('var(--flex-val)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(CssFlexShorthand.raw('1 1 auto').toCss(), equals('1 1 auto'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssFlexShorthand.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
  });
}
