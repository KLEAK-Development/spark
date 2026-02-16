import 'package:test/test.dart';
import 'package:spark_css/src/css_types/css_background_image.dart';
import 'package:spark_css/src/css_types/css_background_position.dart';
import 'package:spark_css/src/css_types/css_color.dart';
import 'package:spark_css/src/css_types/css_gradient_direction.dart';
import 'package:spark_css/src/css_types/css_length.dart';
import 'package:spark_css/src/css_types/css_radial_shape.dart';
import 'package:spark_css/src/css_types/css_radial_size.dart';
import 'package:spark_css/src/css_types/css_value.dart';

void main() {
  group('CssBackgroundImage', () {
    test('url', () {
      expect(
        CssBackgroundImage.url('images/test.png').toCss(),
        equals('url(images/test.png)'),
      );
    });

    test('none', () {
      expect(CssBackgroundImage.none.toCss(), equals('none'));
    });

    group('linearGradient', () {
      test('basic', () {
        final gradient = CssBackgroundImage.linearGradient(
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(gradient.toCss(), equals('linear-gradient(red, blue)'));
      });

      test('with direction keyword', () {
        final gradient = CssBackgroundImage.linearGradient(
          direction: CssGradientDirection.toRight,
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(
          gradient.toCss(),
          equals('linear-gradient(to right, red, blue)'),
        );
      });

      test('with direction angle', () {
        final gradient = CssBackgroundImage.linearGradient(
          direction: CssGradientDirection.angle('45deg'),
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(gradient.toCss(), equals('linear-gradient(45deg, red, blue)'));
      });

      test('with stops having offsets', () {
        final gradient = CssBackgroundImage.linearGradient(
          stops: [
            CssGradientStop(CssColor.red, CssLength.percent(10)),
            CssGradientStop(CssColor.blue, CssLength.percent(90)),
          ],
        );
        expect(gradient.toCss(), equals('linear-gradient(red 10%, blue 90%)'));
      });

      test('repeating', () {
        final gradient = CssBackgroundImage.linearGradient(
          repeating: true,
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(
          gradient.toCss(),
          equals('repeating-linear-gradient(red, blue)'),
        );
      });
    });

    group('radialGradient', () {
      test('basic', () {
        final gradient = CssBackgroundImage.radialGradient(
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(gradient.toCss(), equals('radial-gradient(red, blue)'));
      });

      test('with shape', () {
        final gradient = CssBackgroundImage.radialGradient(
          shape: CssRadialShape.circle,
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(gradient.toCss(), equals('radial-gradient(circle, red, blue)'));
      });

      test('with shape and size keyword', () {
        final gradient = CssBackgroundImage.radialGradient(
          shape: CssRadialShape.circle,
          size: CssRadialSize.closestSide,
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(
          gradient.toCss(),
          equals('radial-gradient(circle closest-side, red, blue)'),
        );
      });

      test('with only size length', () {
        final gradient = CssBackgroundImage.radialGradient(
          size: CssRadialSize.size(CssLength.px(50)),
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(gradient.toCss(), equals('radial-gradient(50px, red, blue)'));
      });

      test('with position keyword', () {
        final gradient = CssBackgroundImage.radialGradient(
          position: CssBackgroundPosition.center,
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(
          gradient.toCss(),
          equals('radial-gradient(at center, red, blue)'),
        );
      });

      test('with shape, size, and position', () {
        final gradient = CssBackgroundImage.radialGradient(
          shape: CssRadialShape.circle,
          size: CssRadialSize.size(CssLength.px(50)),
          position: CssBackgroundPosition.topLeft,
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(
          gradient.toCss(),
          equals('radial-gradient(circle 50px at top left, red, blue)'),
        );
      });

      test('with position coordinates', () {
        final gradient = CssBackgroundImage.radialGradient(
          position: CssBackgroundPosition.xy(
            CssLength.percent(50),
            CssLength.percent(50),
          ),
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(
          gradient.toCss(),
          equals('radial-gradient(at 50% 50%, red, blue)'),
        );
      });

      test('repeating', () {
        final gradient = CssBackgroundImage.radialGradient(
          repeating: true,
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        );
        expect(
          gradient.toCss(),
          equals('repeating-radial-gradient(red, blue)'),
        );
      });
    });

    test('list', () {
      final list = CssBackgroundImage.list([
        CssBackgroundImage.url('img1.png'),
        CssBackgroundImage.linearGradient(
          stops: [
            CssGradientStop(CssColor.red),
            CssGradientStop(CssColor.blue),
          ],
        ),
      ]);
      expect(list.toCss(), equals('url(img1.png), linear-gradient(red, blue)'));
    });

    test('raw', () {
      expect(
        CssBackgroundImage.raw('conic-gradient(red, blue)').toCss(),
        equals('conic-gradient(red, blue)'),
      );
    });

    test('global', () {
      expect(
        CssBackgroundImage.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
  });
}
