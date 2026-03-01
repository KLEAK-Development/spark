import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssBackgroundBlendMode', () {
    test('keywords output correct CSS', () {
      expect(CssBackgroundBlendMode.normal.toCss(), equals('normal'));
      expect(CssBackgroundBlendMode.multiply.toCss(), equals('multiply'));
      expect(CssBackgroundBlendMode.screen.toCss(), equals('screen'));
      expect(CssBackgroundBlendMode.overlay.toCss(), equals('overlay'));
      expect(CssBackgroundBlendMode.darken.toCss(), equals('darken'));
      expect(CssBackgroundBlendMode.lighten.toCss(), equals('lighten'));
      expect(CssBackgroundBlendMode.colorDodge.toCss(), equals('color-dodge'));
      expect(CssBackgroundBlendMode.colorBurn.toCss(), equals('color-burn'));
      expect(CssBackgroundBlendMode.hardLight.toCss(), equals('hard-light'));
      expect(CssBackgroundBlendMode.softLight.toCss(), equals('soft-light'));
      expect(CssBackgroundBlendMode.difference.toCss(), equals('difference'));
      expect(CssBackgroundBlendMode.exclusion.toCss(), equals('exclusion'));
      expect(CssBackgroundBlendMode.hue.toCss(), equals('hue'));
      expect(CssBackgroundBlendMode.saturation.toCss(), equals('saturation'));
      expect(CssBackgroundBlendMode.color.toCss(), equals('color'));
      expect(CssBackgroundBlendMode.luminosity.toCss(), equals('luminosity'));
    });

    test('variable outputs correct CSS', () {
      expect(
        CssBackgroundBlendMode.variable('bbm').toCss(),
        equals('var(--bbm)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(CssBackgroundBlendMode.raw('screen').toCss(), equals('screen'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssBackgroundBlendMode.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssBackgroundBlendMode.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(
        CssBackgroundBlendMode.global(CssGlobal.unset).toCss(),
        equals('unset'),
      );
      expect(
        CssBackgroundBlendMode.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
      expect(
        CssBackgroundBlendMode.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(
        backgroundBlendMode: CssBackgroundBlendMode.screen,
      );
      expect(style.toCss(), contains('background-blend-mode: screen;'));
    });
  });
}
