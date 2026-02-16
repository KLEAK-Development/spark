import 'package:spark_css/src/css_types/css_background_size.dart';
import 'package:spark_css/src/css_types/css_length.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssBackgroundSize', () {
    test('keywords output correct CSS', () {
      expect(CssBackgroundSize.cover.toCss(), equals('cover'));
      expect(CssBackgroundSize.contain.toCss(), equals('contain'));
      expect(CssBackgroundSize.auto.toCss(), equals('auto'));
    });

    test('size factory outputs correct CSS with one value', () {
      expect(
        CssBackgroundSize.size(CssLength.percent(50)).toCss(),
        equals('50%'),
      );
      expect(CssBackgroundSize.size(CssLength.auto).toCss(), equals('auto'));
    });

    test('size factory outputs correct CSS with two values', () {
      expect(
        CssBackgroundSize.size(CssLength.percent(50), CssLength.auto).toCss(),
        equals('50% auto'),
      );
      expect(
        CssBackgroundSize.size(
          CssLength.px(100),
          CssLength.percent(30),
        ).toCss(),
        equals('100px 30%'),
      );
    });

    test('multiple factory outputs correct CSS', () {
      expect(
        CssBackgroundSize.multiple([
          CssBackgroundSize.cover,
          CssBackgroundSize.size(CssLength.percent(50)),
        ]).toCss(),
        equals('cover, 50%'),
      );

      expect(
        CssBackgroundSize.multiple([
          CssBackgroundSize.size(CssLength.px(100), CssLength.auto),
          CssBackgroundSize.contain,
        ]).toCss(),
        equals('100px auto, contain'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(
        CssBackgroundSize.variable('bg-size').toCss(),
        equals('var(--bg-size)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(CssBackgroundSize.raw('100% 100%').toCss(), equals('100% 100%'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssBackgroundSize.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
  });
}
