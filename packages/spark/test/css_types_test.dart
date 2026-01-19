import 'package:spark_framework/spark.dart';
import 'package:test/test.dart';

void main() {
  group('CssGlobal', () {
    test('inherit outputs correct CSS', () {
      expect(CssGlobal.inherit.toCss(), equals('inherit'));
    });

    test('initial outputs correct CSS', () {
      expect(CssGlobal.initial.toCss(), equals('initial'));
    });

    test('unset outputs correct CSS', () {
      expect(CssGlobal.unset.toCss(), equals('unset'));
    });

    test('revert outputs correct CSS', () {
      expect(CssGlobal.revert.toCss(), equals('revert'));
    });
  });

  group('CssColor', () {
    test('hex color outputs correct CSS', () {
      expect(CssColor.hex('ff0000').toCss(), equals('#ff0000'));
      expect(CssColor.hex('#00ff00').toCss(), equals('#00ff00'));
    });

    test('rgb color outputs correct CSS', () {
      expect(CssColor.rgb(255, 0, 0).toCss(), equals('rgb(255, 0, 0)'));
    });

    test('rgba color outputs correct CSS', () {
      expect(
        CssColor.rgba(255, 0, 0, 0.5).toCss(),
        equals('rgba(255, 0, 0, 0.5)'),
      );
    });

    test('hsl color outputs correct CSS', () {
      expect(CssColor.hsl(0, 100, 50).toCss(), equals('hsl(0, 100%, 50%)'));
    });

    test('hsla color outputs correct CSS', () {
      expect(
        CssColor.hsla(0, 100, 50, 0.5).toCss(),
        equals('hsla(0, 100%, 50%, 0.5)'),
      );
    });

    test('named colors output correct CSS', () {
      expect(CssColor.transparent.toCss(), equals('transparent'));
      expect(CssColor.currentColor.toCss(), equals('currentColor'));
      expect(CssColor.black.toCss(), equals('black'));
      expect(CssColor.white.toCss(), equals('white'));
    });

    test('variable outputs correct CSS', () {
      expect(CssColor.variable('primary').toCss(), equals('var(--primary)'));
    });

    test('raw outputs value as-is', () {
      expect(
        CssColor.raw('color-mix(in srgb, red 50%, blue)').toCss(),
        equals('color-mix(in srgb, red 50%, blue)'),
      );
    });

    test('global outputs correct CSS', () {
      expect(CssColor.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });

  group('CssLength', () {
    test('pixel value outputs correct CSS', () {
      expect(CssLength.px(16).toCss(), equals('16px'));
    });

    test('em value outputs correct CSS', () {
      expect(CssLength.em(1.5).toCss(), equals('1.5em'));
    });

    test('rem value outputs correct CSS', () {
      expect(CssLength.rem(2).toCss(), equals('2rem'));
    });

    test('percent value outputs correct CSS', () {
      expect(CssLength.percent(100).toCss(), equals('100%'));
    });

    test('viewport units output correct CSS', () {
      expect(CssLength.vw(50).toCss(), equals('50vw'));
      expect(CssLength.vh(100).toCss(), equals('100vh'));
      expect(CssLength.dvw(50).toCss(), equals('50dvw'));
      expect(CssLength.dvh(100).toCss(), equals('100dvh'));
    });

    test('zero outputs without unit', () {
      expect(CssLength.zero.toCss(), equals('0'));
    });

    test('keywords output correct CSS', () {
      expect(CssLength.auto.toCss(), equals('auto'));
      expect(CssLength.maxContent.toCss(), equals('max-content'));
      expect(CssLength.minContent.toCss(), equals('min-content'));
    });

    test('calc outputs correct CSS', () {
      expect(
        CssLength.calc('100% - 20px').toCss(),
        equals('calc(100% - 20px)'),
      );
    });

    test('min outputs correct CSS', () {
      expect(
        CssLength.min([CssLength.px(100), CssLength.percent(50)]).toCss(),
        equals('min(100px, 50%)'),
      );
    });

    test('max outputs correct CSS', () {
      expect(
        CssLength.max([CssLength.px(100), CssLength.percent(50)]).toCss(),
        equals('max(100px, 50%)'),
      );
    });

    test('clamp outputs correct CSS', () {
      expect(
        CssLength.clamp(
          CssLength.px(10),
          CssLength.percent(50),
          CssLength.px(100),
        ).toCss(),
        equals('clamp(10px, 50%, 100px)'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssLength.variable('spacing').toCss(), equals('var(--spacing)'));
    });
  });

  group('CssDisplay', () {
    test('keywords output correct CSS', () {
      expect(CssDisplay.flex.toCss(), equals('flex'));
      expect(CssDisplay.grid.toCss(), equals('grid'));
      expect(CssDisplay.block.toCss(), equals('block'));
      expect(CssDisplay.inline.toCss(), equals('inline'));
      expect(CssDisplay.inlineBlock.toCss(), equals('inline-block'));
      expect(CssDisplay.inlineFlex.toCss(), equals('inline-flex'));
      expect(CssDisplay.none.toCss(), equals('none'));
    });

    test('variable outputs correct CSS', () {
      expect(
        CssDisplay.variable('display-mode').toCss(),
        equals('var(--display-mode)'),
      );
    });
  });

  group('CssPosition', () {
    test('keywords output correct CSS', () {
      expect(CssPosition.static_.toCss(), equals('static'));
      expect(CssPosition.relative.toCss(), equals('relative'));
      expect(CssPosition.absolute.toCss(), equals('absolute'));
      expect(CssPosition.fixed.toCss(), equals('fixed'));
      expect(CssPosition.sticky.toCss(), equals('sticky'));
    });
  });

  group('CssFlexDirection', () {
    test('keywords output correct CSS', () {
      expect(CssFlexDirection.row.toCss(), equals('row'));
      expect(CssFlexDirection.rowReverse.toCss(), equals('row-reverse'));
      expect(CssFlexDirection.column.toCss(), equals('column'));
      expect(CssFlexDirection.columnReverse.toCss(), equals('column-reverse'));
    });
  });

  group('CssJustifyContent', () {
    test('keywords output correct CSS', () {
      expect(CssJustifyContent.flexStart.toCss(), equals('flex-start'));
      expect(CssJustifyContent.flexEnd.toCss(), equals('flex-end'));
      expect(CssJustifyContent.center.toCss(), equals('center'));
      expect(CssJustifyContent.spaceBetween.toCss(), equals('space-between'));
      expect(CssJustifyContent.spaceAround.toCss(), equals('space-around'));
      expect(CssJustifyContent.spaceEvenly.toCss(), equals('space-evenly'));
    });
  });

  group('CssAlignItems', () {
    test('keywords output correct CSS', () {
      expect(CssAlignItems.flexStart.toCss(), equals('flex-start'));
      expect(CssAlignItems.flexEnd.toCss(), equals('flex-end'));
      expect(CssAlignItems.center.toCss(), equals('center'));
      expect(CssAlignItems.stretch.toCss(), equals('stretch'));
      expect(CssAlignItems.baseline.toCss(), equals('baseline'));
    });
  });

  group('CssFontWeight', () {
    test('named weights output correct CSS', () {
      expect(CssFontWeight.normal.toCss(), equals('normal'));
      expect(CssFontWeight.bold.toCss(), equals('bold'));
      expect(CssFontWeight.bolder.toCss(), equals('bolder'));
      expect(CssFontWeight.lighter.toCss(), equals('lighter'));
    });

    test('numeric weights output correct CSS', () {
      expect(CssFontWeight.w100.toCss(), equals('100'));
      expect(CssFontWeight.w400.toCss(), equals('400'));
      expect(CssFontWeight.w700.toCss(), equals('700'));
      expect(CssFontWeight.w900.toCss(), equals('900'));
      expect(CssFontWeight.numeric(550).toCss(), equals('550'));
    });
  });

  group('CssFontFamily', () {
    test('generic families output correct CSS', () {
      expect(CssFontFamily.serif.toCss(), equals('serif'));
      expect(CssFontFamily.sansSerif.toCss(), equals('sans-serif'));
      expect(CssFontFamily.monospace.toCss(), equals('monospace'));
      expect(CssFontFamily.systemUi.toCss(), equals('system-ui'));
    });

    test('named family outputs quoted', () {
      expect(
        CssFontFamily.named('Helvetica Neue').toCss(),
        equals('"Helvetica Neue"'),
      );
    });

    test('font stack outputs correct CSS', () {
      expect(
        CssFontFamily.stack([
          CssFontFamily.named('Helvetica Neue'),
          CssFontFamily.named('Arial'),
          CssFontFamily.sansSerif,
        ]).toCss(),
        equals('"Helvetica Neue", "Arial", sans-serif'),
      );
    });
  });

  group('CssTextAlign', () {
    test('keywords output correct CSS', () {
      expect(CssTextAlign.left.toCss(), equals('left'));
      expect(CssTextAlign.right.toCss(), equals('right'));
      expect(CssTextAlign.center.toCss(), equals('center'));
      expect(CssTextAlign.justify.toCss(), equals('justify'));
    });
  });

  group('CssOverflow', () {
    test('keywords output correct CSS', () {
      expect(CssOverflow.visible.toCss(), equals('visible'));
      expect(CssOverflow.hidden.toCss(), equals('hidden'));
      expect(CssOverflow.scroll.toCss(), equals('scroll'));
      expect(CssOverflow.auto.toCss(), equals('auto'));
      expect(CssOverflow.clip.toCss(), equals('clip'));
    });
  });

  group('CssCursor', () {
    test('keywords output correct CSS', () {
      expect(CssCursor.pointer.toCss(), equals('pointer'));
      expect(CssCursor.text.toCss(), equals('text'));
      expect(CssCursor.move.toCss(), equals('move'));
      expect(CssCursor.notAllowed.toCss(), equals('not-allowed'));
      expect(CssCursor.grab.toCss(), equals('grab'));
    });

    test('url cursor outputs correct CSS', () {
      expect(
        CssCursor.url('cursor.png', fallback: CssCursor.pointer).toCss(),
        equals('url(cursor.png), pointer'),
      );
    });
  });

  group('CssNumber', () {
    test('numeric value outputs correct CSS', () {
      expect(CssNumber(1.5).toCss(), equals('1.5'));
      expect(CssNumber(0).toCss(), equals('0'));
    });

    test('variable outputs correct CSS', () {
      expect(CssNumber.variable('opacity').toCss(), equals('var(--opacity)'));
    });
  });

  group('CssZIndex', () {
    test('auto outputs correct CSS', () {
      expect(CssZIndex.auto.toCss(), equals('auto'));
    });

    test('numeric value outputs correct CSS', () {
      expect(CssZIndex(10).toCss(), equals('10'));
      expect(CssZIndex(-1).toCss(), equals('-1'));
    });
  });

  group('CssSpacing', () {
    test('all outputs single value', () {
      expect(CssSpacing.all(CssLength.px(10)).toCss(), equals('10px'));
    });

    test('zero outputs 0', () {
      expect(CssSpacing.zero.toCss(), equals('0'));
    });

    test('symmetric outputs two values', () {
      expect(
        CssSpacing.symmetric(CssLength.px(10), CssLength.px(20)).toCss(),
        equals('10px 20px'),
      );
    });

    test('only (three values) outputs correct CSS', () {
      expect(
        CssSpacing.only(
          top: CssLength.px(10),
          horizontal: CssLength.px(20),
          bottom: CssLength.px(30),
        ).toCss(),
        equals('10px 20px 30px'),
      );
    });

    test('trbl outputs four values', () {
      expect(
        CssSpacing.trbl(
          CssLength.px(10),
          CssLength.px(20),
          CssLength.px(30),
          CssLength.px(40),
        ).toCss(),
        equals('10px 20px 30px 40px'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssSpacing.variable('spacing').toCss(), equals('var(--spacing)'));
    });

    test('raw outputs value as-is', () {
      expect(CssSpacing.raw('10px 20px').toCss(), equals('10px 20px'));
    });

    test('length factory creates single value', () {
      expect(CssSpacing.length(CssLength.rem(1)).toCss(), equals('1rem'));
    });

    test('works with different units', () {
      expect(
        CssSpacing.symmetric(CssLength.rem(1), CssLength.percent(5)).toCss(),
        equals('1rem 5%'),
      );
    });
  });

  group('CssBorder', () {
    test('none outputs correct CSS', () {
      expect(CssBorder.none.toCss(), equals('none'));
    });

    test('shorthand outputs correct CSS', () {
      expect(
        CssBorder(
          width: CssLength.px(1),
          style: CssBorderStyle.solid,
          color: CssColor.black,
        ).toCss(),
        equals('1px solid black'),
      );
    });

    test('shorthand without color outputs correct CSS', () {
      expect(
        CssBorder.widthStyle(CssLength.px(2), CssBorderStyle.dashed).toCss(),
        equals('2px dashed'),
      );
    });
  });

  group('CssTransition', () {
    test('none outputs correct CSS', () {
      expect(CssTransition.none.toCss(), equals('none'));
    });

    test('single transition outputs correct CSS', () {
      expect(
        CssTransition(
          property: 'all',
          duration: '0.3s',
          timingFunction: CssTimingFunction.ease,
        ).toCss(),
        equals('all 0.3s ease'),
      );
    });

    test('simple transition outputs correct CSS', () {
      expect(
        CssTransition.simple('opacity', '200ms').toCss(),
        equals('opacity 200ms'),
      );
    });

    test('multiple transitions output correct CSS', () {
      expect(
        CssTransition.multiple([
          CssTransition.simple('opacity', '200ms'),
          CssTransition.simple(
            'transform',
            '300ms',
            CssTimingFunction.easeInOut,
          ),
        ]).toCss(),
        equals('opacity 200ms, transform 300ms ease-in-out'),
      );
    });
  });

  group('CssTimingFunction', () {
    test('keywords output correct CSS', () {
      expect(CssTimingFunction.linear.toCss(), equals('linear'));
      expect(CssTimingFunction.ease.toCss(), equals('ease'));
      expect(CssTimingFunction.easeIn.toCss(), equals('ease-in'));
      expect(CssTimingFunction.easeOut.toCss(), equals('ease-out'));
      expect(CssTimingFunction.easeInOut.toCss(), equals('ease-in-out'));
    });

    test('cubic-bezier outputs correct CSS', () {
      expect(
        CssTimingFunction.cubicBezier(0.4, 0, 0.2, 1).toCss(),
        equals('cubic-bezier(0.4, 0.0, 0.2, 1.0)'),
      );
    });

    test('steps outputs correct CSS', () {
      expect(CssTimingFunction.steps(4).toCss(), equals('steps(4)'));
      expect(
        CssTimingFunction.steps(4, jumpTerm: 'jump-start').toCss(),
        equals('steps(4, jump-start)'),
      );
    });
  });

  group('Style.v2', () {
    test('renders typed color properties', () {
      final style = Style.typed(
        color: CssColor.hex('ff0000'),
        backgroundColor: CssColor.rgb(0, 255, 0),
      );
      expect(style.toCss(), contains('color: #ff0000;'));
      expect(style.toCss(), contains('background-color: rgb(0, 255, 0);'));
    });

    test('renders flexbox properties', () {
      final style = Style.typed(
        display: CssDisplay.flex,
        flexDirection: CssFlexDirection.column,
        justifyContent: CssJustifyContent.spaceBetween,
        alignItems: CssAlignItems.center,
        gap: CssLength.rem(1),
      );
      expect(style.toCss(), contains('display: flex;'));
      expect(style.toCss(), contains('flex-direction: column;'));
      expect(style.toCss(), contains('justify-content: space-between;'));
      expect(style.toCss(), contains('align-items: center;'));
      expect(style.toCss(), contains('gap: 1rem;'));
    });

    test('renders sizing properties', () {
      final style = Style.typed(
        width: CssLength.percent(100),
        height: CssLength.vh(100),
        maxWidth: CssLength.px(1200),
        minHeight: CssLength.px(400),
      );
      expect(style.toCss(), contains('width: 100%;'));
      expect(style.toCss(), contains('height: 100vh;'));
      expect(style.toCss(), contains('max-width: 1200px;'));
      expect(style.toCss(), contains('min-height: 400px;'));
    });

    test('renders spacing with multi-value syntax', () {
      final style = Style.typed(
        // Single value
        padding: CssSpacing.all(CssLength.px(16)),
        // Two values (vertical | horizontal)
        margin: CssSpacing.symmetric(CssLength.px(10), CssLength.px(20)),
      );
      expect(style.toCss(), contains('padding: 16px;'));
      expect(style.toCss(), contains('margin: 10px 20px;'));
    });

    test('renders spacing with four values', () {
      final style = Style.typed(
        margin: CssSpacing.trbl(
          CssLength.px(10),
          CssLength.px(20),
          CssLength.px(30),
          CssLength.px(40),
        ),
      );
      expect(style.toCss(), contains('margin: 10px 20px 30px 40px;'));
    });

    test('renders with CSS variables', () {
      final style = Style.typed(
        color: CssColor.variable('text-color'),
        padding: CssSpacing.variable('spacing'),
      );
      expect(style.toCss(), contains('color: var(--text-color);'));
      expect(style.toCss(), contains('padding: var(--spacing);'));
    });

    test('renders typography properties', () {
      final style = Style.typed(
        fontSize: CssLength.rem(1.5),
        fontWeight: CssFontWeight.w600,
        fontFamily: CssFontFamily.sansSerif,
        textAlign: CssTextAlign.center,
        lineHeight: CssNumber(1.6),
      );
      expect(style.toCss(), contains('font-size: 1.5rem;'));
      expect(style.toCss(), contains('font-weight: 600;'));
      expect(style.toCss(), contains('font-family: sans-serif;'));
      expect(style.toCss(), contains('text-align: center;'));
      expect(style.toCss(), contains('line-height: 1.6;'));
    });

    test('renders border properties', () {
      final style = Style.typed(
        border: CssBorder(
          width: CssLength.px(1),
          style: CssBorderStyle.solid,
          color: CssColor.variable('border-color'),
        ),
        borderRadius: CssLength.px(8),
      );
      expect(style.toCss(), contains('border: 1px solid var(--border-color);'));
      expect(style.toCss(), contains('border-radius: 8px;'));
    });

    test('renders visual properties', () {
      final style = Style.typed(
        opacity: CssNumber(0.8),
        overflow: CssOverflow.hidden,
        zIndex: CssZIndex(100),
        cursor: CssCursor.pointer,
      );
      expect(style.toCss(), contains('opacity: 0.8;'));
      expect(style.toCss(), contains('overflow: hidden;'));
      expect(style.toCss(), contains('z-index: 100;'));
      expect(style.toCss(), contains('cursor: pointer;'));
    });

    test('renders string-based complex properties', () {
      final style = Style.typed(
        transform: 'translateY(-2px)',
        boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
        gridTemplateColumns: 'repeat(3, 1fr)',
      );
      expect(style.toCss(), contains('transform: translateY(-2px);'));
      expect(
        style.toCss(),
        contains('box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);'),
      );
      expect(style.toCss(), contains('grid-template-columns: repeat(3, 1fr);'));
    });

    test('add method still works with v2', () {
      final style = Style.typed(color: CssColor.black)
        ..add('--custom-property', 'custom-value');
      expect(style.toCss(), contains('color: black;'));
      expect(style.toCss(), contains('--custom-property: custom-value;'));
    });
  });

  group('backward compatibility', () {
    test('original Style constructor still works', () {
      final style = Style(color: 'red', fontSize: '12px');
      expect(style.toCss(), contains('color: red;'));
      expect(style.toCss(), contains('font-size: 12px;'));
    });

    test('both constructors produce same output for equivalent values', () {
      final styleOld = Style(
        display: 'flex',
        justifyContent: 'center',
        padding: '16px',
      );
      final styleNew = Style.typed(
        display: CssDisplay.flex,
        justifyContent: CssJustifyContent.center,
        padding: CssSpacing.all(CssLength.px(16)),
      );

      expect(styleOld.toCss(), contains('display: flex;'));
      expect(styleNew.toCss(), contains('display: flex;'));
      expect(styleOld.toCss(), contains('justify-content: center;'));
      expect(styleNew.toCss(), contains('justify-content: center;'));
      expect(styleOld.toCss(), contains('padding: 16px;'));
      expect(styleNew.toCss(), contains('padding: 16px;'));
    });
  });
}
