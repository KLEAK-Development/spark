import 'package:spark_css/src/css_types/css_animation.dart';
import 'package:spark_css/src/css_types/css_transition.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssAnimationDirection', () {
    test('keywords output correct CSS', () {
      expect(CssAnimationDirection.normal.toCss(), equals('normal'));
      expect(CssAnimationDirection.reverse.toCss(), equals('reverse'));
      expect(CssAnimationDirection.alternate.toCss(), equals('alternate'));
      expect(
        CssAnimationDirection.alternateReverse.toCss(),
        equals('alternate-reverse'),
      );
    });
    test('variable outputs correct CSS', () {
      expect(
        CssAnimationDirection.variable('dir').toCss(),
        equals('var(--dir)'),
      );
    });
    test('raw outputs value as-is', () {
      expect(CssAnimationDirection.raw('normal').toCss(), equals('normal'));
    });
    test('global outputs correct CSS', () {
      expect(
        CssAnimationDirection.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
  });

  group('CssAnimationFillMode', () {
    test('keywords output correct CSS', () {
      expect(CssAnimationFillMode.none.toCss(), equals('none'));
      expect(CssAnimationFillMode.forwards.toCss(), equals('forwards'));
      expect(CssAnimationFillMode.backwards.toCss(), equals('backwards'));
      expect(CssAnimationFillMode.both.toCss(), equals('both'));
    });
    test('variable outputs correct CSS', () {
      expect(
        CssAnimationFillMode.variable('fill').toCss(),
        equals('var(--fill)'),
      );
    });
    test('raw outputs value as-is', () {
      expect(CssAnimationFillMode.raw('both').toCss(), equals('both'));
    });
    test('global outputs correct CSS', () {
      expect(
        CssAnimationFillMode.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
    });
  });

  group('CssAnimationPlayState', () {
    test('keywords output correct CSS', () {
      expect(CssAnimationPlayState.running.toCss(), equals('running'));
      expect(CssAnimationPlayState.paused.toCss(), equals('paused'));
    });
    test('variable outputs correct CSS', () {
      expect(
        CssAnimationPlayState.variable('state').toCss(),
        equals('var(--state)'),
      );
    });
    test('raw outputs value as-is', () {
      expect(CssAnimationPlayState.raw('paused').toCss(), equals('paused'));
    });
    test('global outputs correct CSS', () {
      expect(
        CssAnimationPlayState.global(CssGlobal.unset).toCss(),
        equals('unset'),
      );
    });
  });

  group('CssAnimationIterationCount', () {
    test('infinite outputs correct CSS', () {
      expect(CssAnimationIterationCount.infinite.toCss(), equals('infinite'));
    });
    test('count outputs correct CSS', () {
      expect(CssAnimationIterationCount.count(3).toCss(), equals('3'));
      expect(CssAnimationIterationCount.count(1.5).toCss(), equals('1.5'));
    });
    test('variable outputs correct CSS', () {
      expect(
        CssAnimationIterationCount.variable('count').toCss(),
        equals('var(--count)'),
      );
    });
    test('raw outputs value as-is', () {
      expect(
        CssAnimationIterationCount.raw('infinite').toCss(),
        equals('infinite'),
      );
    });
    test('global outputs correct CSS', () {
      expect(
        CssAnimationIterationCount.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
    });
  });

  group('CssAnimation', () {
    test('none outputs correct CSS', () {
      expect(CssAnimation.none.toCss(), equals('none'));
    });
    test('name-only outputs correct CSS', () {
      expect(CssAnimation(name: 'fadeIn').toCss(), equals('fadeIn'));
    });
    test('single with all properties outputs correct CSS', () {
      expect(
        CssAnimation(
          name: 'slideIn',
          duration: CssDuration.s(1),
          timingFunction: CssTimingFunction.easeInOut,
          delay: CssDuration.ms(500),
          iterationCount: CssAnimationIterationCount.infinite,
          direction: CssAnimationDirection.alternate,
          fillMode: CssAnimationFillMode.forwards,
          playState: CssAnimationPlayState.running,
        ).toCss(),
        equals(
          'slideIn 1s ease-in-out 500ms infinite alternate forwards running',
        ),
      );
    });
    test('single with partial properties outputs correct CSS', () {
      expect(
        CssAnimation(
          name: 'fadeIn',
          duration: CssDuration.s(0.3),
          fillMode: CssAnimationFillMode.forwards,
        ).toCss(),
        equals('fadeIn 0.3s forwards'),
      );
    });
    test('multiple outputs correct CSS', () {
      expect(
        CssAnimation.multiple([
          CssAnimation(name: 'fadeIn', duration: CssDuration.s(1)),
          CssAnimation(
            name: 'slideUp',
            duration: CssDuration.ms(500),
            fillMode: CssAnimationFillMode.both,
          ),
        ]).toCss(),
        equals('fadeIn 1s, slideUp 500ms both'),
      );
    });
    test('variable outputs correct CSS', () {
      expect(CssAnimation.variable('anim').toCss(), equals('var(--anim)'));
    });
    test('raw outputs value as-is', () {
      expect(
        CssAnimation.raw('fadeIn 1s ease-in-out').toCss(),
        equals('fadeIn 1s ease-in-out'),
      );
    });
    test('global outputs correct CSS', () {
      expect(CssAnimation.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
