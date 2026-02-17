import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssFilter', () {
    test('none', () {
      expect(CssFilter.none.toCss(), equals('none'));
    });

    test('blur', () {
      expect(CssFilter.blur(CssLength.px(5)).toCss(), equals('blur(5px)'));
      expect(CssFilter.blur(CssLength.rem(1)).toCss(), equals('blur(1rem)'));
    });

    test('brightness', () {
      expect(CssFilter.brightness(0.5).toCss(), equals('brightness(0.5)'));
      expect(CssFilter.brightness(1).toCss(), equals('brightness(1)'));
      expect(
        CssFilter.brightnessPercent(50).toCss(),
        equals('brightness(50%)'),
      );
    });

    test('contrast', () {
      expect(CssFilter.contrast(0.5).toCss(), equals('contrast(0.5)'));
      expect(CssFilter.contrastPercent(200).toCss(), equals('contrast(200%)'));
    });

    test('dropShadow', () {
      expect(
        CssFilter.dropShadow(
          offsetX: CssLength.px(5),
          offsetY: CssLength.px(5),
        ).toCss(),
        equals('drop-shadow(5px 5px)'),
      );
      expect(
        CssFilter.dropShadow(
          offsetX: CssLength.px(5),
          offsetY: CssLength.px(5),
          blurRadius: CssLength.px(10),
        ).toCss(),
        equals('drop-shadow(5px 5px 10px)'),
      );
      expect(
        CssFilter.dropShadow(
          offsetX: CssLength.px(5),
          offsetY: CssLength.px(5),
          color: CssColor.black,
        ).toCss(),
        equals('drop-shadow(5px 5px black)'),
      );
      expect(
        CssFilter.dropShadow(
          offsetX: CssLength.px(5),
          offsetY: CssLength.px(5),
          blurRadius: CssLength.px(10),
          color: CssColor.rgba(0, 0, 0, 0.5),
        ).toCss(),
        equals('drop-shadow(5px 5px 10px rgba(0, 0, 0, 0.5))'),
      );
    });

    test('grayscale', () {
      expect(CssFilter.grayscale(0.5).toCss(), equals('grayscale(0.5)'));
      expect(
        CssFilter.grayscalePercent(100).toCss(),
        equals('grayscale(100%)'),
      );
    });

    test('hueRotate', () {
      expect(CssFilter.hueRotate(90).toCss(), equals('hue-rotate(90deg)'));
      expect(
        CssFilter.hueRotateRaw('0.5turn').toCss(),
        equals('hue-rotate(0.5turn)'),
      );
    });

    test('invert', () {
      expect(CssFilter.invert(0.5).toCss(), equals('invert(0.5)'));
      expect(CssFilter.invertPercent(100).toCss(), equals('invert(100%)'));
    });

    test('opacity', () {
      expect(CssFilter.opacity(0.5).toCss(), equals('opacity(0.5)'));
      expect(CssFilter.opacityPercent(50).toCss(), equals('opacity(50%)'));
    });

    test('saturate', () {
      expect(CssFilter.saturate(0.5).toCss(), equals('saturate(0.5)'));
      expect(CssFilter.saturatePercent(200).toCss(), equals('saturate(200%)'));
    });

    test('sepia', () {
      expect(CssFilter.sepia(0.5).toCss(), equals('sepia(0.5)'));
      expect(CssFilter.sepiaPercent(100).toCss(), equals('sepia(100%)'));
    });

    test('compose', () {
      final filter = CssFilter.compose([
        CssFilter.blur(CssLength.px(5)),
        CssFilter.grayscalePercent(50),
      ]);
      expect(filter.toCss(), equals('blur(5px) grayscale(50%)'));
    });

    test('global keywords', () {
      expect(CssFilter.global(CssGlobal.inherit).toCss(), equals('inherit'));
      expect(CssFilter.global(CssGlobal.initial).toCss(), equals('initial'));
      expect(CssFilter.global(CssGlobal.unset).toCss(), equals('unset'));
    });

    test('variable', () {
      expect(
        CssFilter.variable('my-filter').toCss(),
        equals('var(--my-filter)'),
      );
    });

    test('raw', () {
      expect(CssFilter.raw('blur(10px)').toCss(), equals('blur(10px)'));
    });
  });
}
