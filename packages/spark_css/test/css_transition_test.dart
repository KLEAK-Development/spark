import 'package:spark_css/src/css_types/css_transition.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssTimingFunction', () {
    test('keywords output correct CSS', () {
      expect(CssTimingFunction.linear.toCss(), equals('linear'));
      expect(CssTimingFunction.stepStart.toCss(), equals('step-start'));
    });
    test('cubicBezier outputs correct CSS', () {
      expect(CssTimingFunction.cubicBezier(0.1, 0.2, 0.3, 0.4).toCss(), equals('cubic-bezier(0.1, 0.2, 0.3, 0.4)'));
    });
    test('steps outputs correct CSS', () {
      expect(CssTimingFunction.steps(4, jumpTerm: 'end').toCss(), equals('steps(4, end)'));
      expect(CssTimingFunction.steps(4).toCss(), equals('steps(4)'));
    });
    test('variable outputs correct CSS', () {
      expect(CssTimingFunction.variable('timing').toCss(), equals('var(--timing)'));
    });
    test('raw outputs value as-is', () {
      expect(CssTimingFunction.raw('ease').toCss(), equals('ease'));
    });
  });

  group('CssTransition', () {
    test('none outputs correct CSS', () {
      expect(CssTransition.none.toCss(), equals('none'));
    });
    test('single outputs correct CSS', () {
      expect(
        CssTransition(property: 'opacity', duration: '1s', delay: '0.5s').toCss(),
        equals('opacity 1s 0.5s'),
      );
    });
    test('multiple outputs correct CSS', () {
      expect(
        CssTransition.multiple([
          CssTransition.simple('opacity', '1s'),
          CssTransition.simple('width', '2s'),
        ]).toCss(),
        equals('opacity 1s, width 2s'),
      );
    });
    test('variable outputs correct CSS', () {
      expect(CssTransition.variable('trans').toCss(), equals('var(--trans)'));
    });
    test('raw outputs value as-is', () {
      expect(CssTransition.raw('all 1s').toCss(), equals('all 1s'));
    });
    test('global outputs correct CSS', () {
      expect(CssTransition.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
