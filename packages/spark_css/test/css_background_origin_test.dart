import 'package:spark_css/src/css_types/css_background_origin.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssBackgroundOrigin', () {
    test('keywords output correct CSS', () {
      expect(CssBackgroundOrigin.borderBox.toCss(), equals('border-box'));
      expect(CssBackgroundOrigin.paddingBox.toCss(), equals('padding-box'));
      expect(CssBackgroundOrigin.contentBox.toCss(), equals('content-box'));
    });

    test('multiple outputs correct CSS', () {
      expect(
        CssBackgroundOrigin.multiple([
          CssBackgroundOrigin.borderBox,
          CssBackgroundOrigin.paddingBox,
        ]).toCss(),
        equals('border-box, padding-box'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(
        CssBackgroundOrigin.variable('bg-origin').toCss(),
        equals('var(--bg-origin)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(CssBackgroundOrigin.raw('border-box').toCss(), equals('border-box'));
    });

    test('global outputs correct CSS', () {
      expect(CssBackgroundOrigin.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
