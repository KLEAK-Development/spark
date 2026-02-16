import 'package:test/test.dart';
import 'package:spark_css/src/css_types/css_transform.dart';
import 'package:spark_css/src/css_types/css_length.dart';
import 'package:spark_css/src/css_types/css_value.dart';

void main() {
  group('CssAngle', () {
    test('deg', () {
      expect(CssAngle.deg(45).toCss(), '45deg');
      expect(CssAngle.deg(90.5).toCss(), '90.5deg');
    });

    test('rad', () {
      expect(CssAngle.rad(1).toCss(), '1rad');
      expect(CssAngle.rad(3.14).toCss(), '3.14rad');
    });

    test('grad', () {
      expect(CssAngle.grad(100).toCss(), '100grad');
    });

    test('turn', () {
      expect(CssAngle.turn(0.5).toCss(), '0.5turn');
    });
  });

  group('CssTransform', () {
    test('none', () {
      expect(CssTransform.none.toCss(), 'none');
    });

    test('translateX', () {
      expect(
        CssTransform.translateX(CssLength.px(10)).toCss(),
        'translateX(10px)',
      );
      expect(
        CssTransform.translateX(CssLength.percent(50)).toCss(),
        'translateX(50%)',
      );
    });

    test('translateY', () {
      expect(
        CssTransform.translateY(CssLength.px(20)).toCss(),
        'translateY(20px)',
      );
    });

    test('translate', () {
      expect(
        CssTransform.translate(CssLength.px(10)).toCss(),
        'translate(10px)',
      );
      expect(
        CssTransform.translate(CssLength.px(10), CssLength.px(20)).toCss(),
        'translate(10px, 20px)',
      );
    });

    test('scaleX', () {
      expect(CssTransform.scaleX(2).toCss(), 'scaleX(2)');
    });

    test('scaleY', () {
      expect(CssTransform.scaleY(0.5).toCss(), 'scaleY(0.5)');
    });

    test('scale', () {
      expect(CssTransform.scale(2).toCss(), 'scale(2)');
      expect(CssTransform.scale(2, 0.5).toCss(), 'scale(2, 0.5)');
    });

    test('rotate', () {
      expect(CssTransform.rotate(CssAngle.deg(45)).toCss(), 'rotate(45deg)');
      expect(CssTransform.rotate(CssAngle.rad(1)).toCss(), 'rotate(1rad)');
    });

    test('skewX', () {
      expect(CssTransform.skewX(CssAngle.deg(30)).toCss(), 'skewX(30deg)');
    });

    test('skewY', () {
      expect(CssTransform.skewY(CssAngle.deg(10)).toCss(), 'skewY(10deg)');
    });

    test('skew', () {
      expect(CssTransform.skew(CssAngle.deg(30)).toCss(), 'skew(30deg)');
      expect(
        CssTransform.skew(CssAngle.deg(30), CssAngle.deg(10)).toCss(),
        'skew(30deg, 10deg)',
      );
    });

    test('matrix', () {
      expect(
        CssTransform.matrix(1, 0, 0, 1, 10, 20).toCss(),
        'matrix(1, 0, 0, 1, 10, 20)',
      );
    });

    test('list', () {
      expect(
        CssTransform.list([
          CssTransform.translateX(CssLength.px(10)),
          CssTransform.rotate(CssAngle.deg(45)),
        ]).toCss(),
        'translateX(10px) rotate(45deg)',
      );
    });

    test('variable', () {
      expect(
        CssTransform.variable('transform-var').toCss(),
        'var(--transform-var)',
      );
    });

    test('raw', () {
      expect(CssTransform.raw('translateZ(10px)').toCss(), 'translateZ(10px)');
    });

    test('global', () {
      expect(CssTransform.global(CssGlobal.inherit).toCss(), 'inherit');
    });
  });
}
