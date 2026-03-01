import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssMixBlendMode', () {
    test('keywords output correct CSS', () {
      expect(CssMixBlendMode.normal.toCss(), equals('normal'));
      expect(CssMixBlendMode.multiply.toCss(), equals('multiply'));
      expect(CssMixBlendMode.screen.toCss(), equals('screen'));
      expect(CssMixBlendMode.overlay.toCss(), equals('overlay'));
      expect(CssMixBlendMode.darken.toCss(), equals('darken'));
      expect(CssMixBlendMode.lighten.toCss(), equals('lighten'));
      expect(CssMixBlendMode.colorDodge.toCss(), equals('color-dodge'));
      expect(CssMixBlendMode.colorBurn.toCss(), equals('color-burn'));
      expect(CssMixBlendMode.hardLight.toCss(), equals('hard-light'));
      expect(CssMixBlendMode.softLight.toCss(), equals('soft-light'));
      expect(CssMixBlendMode.difference.toCss(), equals('difference'));
      expect(CssMixBlendMode.exclusion.toCss(), equals('exclusion'));
      expect(CssMixBlendMode.hue.toCss(), equals('hue'));
      expect(CssMixBlendMode.saturation.toCss(), equals('saturation'));
      expect(CssMixBlendMode.color.toCss(), equals('color'));
      expect(CssMixBlendMode.luminosity.toCss(), equals('luminosity'));
    });

    test('variable outputs correct CSS', () {
      expect(CssMixBlendMode.variable('bm').toCss(), equals('var(--bm)'));
    });

    test('raw outputs value as-is', () {
      expect(CssMixBlendMode.raw('multiply').toCss(), equals('multiply'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssMixBlendMode.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssMixBlendMode.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssMixBlendMode.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(
        CssMixBlendMode.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
      expect(
        CssMixBlendMode.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(mixBlendMode: CssMixBlendMode.multiply);
      expect(style.toCss(), contains('mix-blend-mode: multiply;'));
    });
  });
}
