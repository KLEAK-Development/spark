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
      expect(
        CssTimingFunction.cubicBezier(0.1, 0.2, 0.3, 0.4).toCss(),
        equals('cubic-bezier(0.1, 0.2, 0.3, 0.4)'),
      );
    });
    test('steps outputs correct CSS', () {
      expect(
        CssTimingFunction.steps(4, jumpTerm: 'end').toCss(),
        equals('steps(4, end)'),
      );
      expect(CssTimingFunction.steps(4).toCss(), equals('steps(4)'));
    });
    test('variable outputs correct CSS', () {
      expect(
        CssTimingFunction.variable('timing').toCss(),
        equals('var(--timing)'),
      );
    });
    test('raw outputs value as-is', () {
      expect(CssTimingFunction.raw('ease').toCss(), equals('ease'));
    });
  });

  group('CssTransitionProperty', () {
    test('keywords output correct CSS', () {
      expect(CssTransitionProperty.all.toCss(), equals('all'));
      expect(CssTransitionProperty.opacity.toCss(), equals('opacity'));
      expect(CssTransitionProperty.transform.toCss(), equals('transform'));
      expect(
        CssTransitionProperty.backgroundColor.toCss(),
        equals('background-color'),
      );
      expect(CssTransitionProperty.color.toCss(), equals('color'));
      expect(CssTransitionProperty.width.toCss(), equals('width'));
      expect(CssTransitionProperty.height.toCss(), equals('height'));
      expect(CssTransitionProperty.margin.toCss(), equals('margin'));
      expect(CssTransitionProperty.padding.toCss(), equals('padding'));
      expect(CssTransitionProperty.border.toCss(), equals('border'));
      expect(
        CssTransitionProperty.borderRadius.toCss(),
        equals('border-radius'),
      );
      expect(CssTransitionProperty.boxShadow.toCss(), equals('box-shadow'));
      expect(CssTransitionProperty.top.toCss(), equals('top'));
      expect(CssTransitionProperty.right.toCss(), equals('right'));
      expect(CssTransitionProperty.bottom.toCss(), equals('bottom'));
      expect(CssTransitionProperty.left.toCss(), equals('left'));
      expect(CssTransitionProperty.visibility.toCss(), equals('visibility'));
      expect(CssTransitionProperty.fontSize.toCss(), equals('font-size'));
      expect(CssTransitionProperty.lineHeight.toCss(), equals('line-height'));
      expect(
        CssTransitionProperty.letterSpacing.toCss(),
        equals('letter-spacing'),
      );
      expect(CssTransitionProperty.gap.toCss(), equals('gap'));
    });
    test('variable outputs correct CSS', () {
      expect(
        CssTransitionProperty.variable('prop').toCss(),
        equals('var(--prop)'),
      );
    });
    test('raw outputs value as-is', () {
      expect(
        CssTransitionProperty.raw('max-width').toCss(),
        equals('max-width'),
      );
    });
  });

  group('CssDuration', () {
    test('ms outputs correct CSS', () {
      expect(CssDuration.ms(200).toCss(), equals('200ms'));
      expect(CssDuration.ms(1.5).toCss(), equals('1.5ms'));
    });
    test('s outputs correct CSS', () {
      expect(CssDuration.s(1).toCss(), equals('1s'));
      expect(CssDuration.s(0.3).toCss(), equals('0.3s'));
    });
    test('variable outputs correct CSS', () {
      expect(CssDuration.variable('dur').toCss(), equals('var(--dur)'));
    });
    test('raw outputs value as-is', () {
      expect(CssDuration.raw('200ms').toCss(), equals('200ms'));
    });
  });

  group('CssTransition', () {
    test('none outputs correct CSS', () {
      expect(CssTransition.none.toCss(), equals('none'));
    });
    test('single outputs correct CSS', () {
      expect(
        CssTransition(
          property: CssTransitionProperty.opacity,
          duration: CssDuration.s(1),
          delay: CssDuration.s(0.5),
        ).toCss(),
        equals('opacity 1s 0.5s'),
      );
    });
    test('multiple outputs correct CSS', () {
      expect(
        CssTransition.multiple([
          CssTransition.simple(CssTransitionProperty.opacity, CssDuration.s(1)),
          CssTransition.simple(CssTransitionProperty.width, CssDuration.s(2)),
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
      expect(
        CssTransition.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
  });
}
