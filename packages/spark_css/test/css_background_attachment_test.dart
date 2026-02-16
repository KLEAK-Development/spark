import 'package:spark_css/src/css_types/css_background_attachment.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssBackgroundAttachment', () {
    test('scroll keyword outputs correct CSS', () {
      expect(CssBackgroundAttachment.scroll.toCss(), equals('scroll'));
    });

    test('fixed keyword outputs correct CSS', () {
      expect(CssBackgroundAttachment.fixed.toCss(), equals('fixed'));
    });

    test('local keyword outputs correct CSS', () {
      expect(CssBackgroundAttachment.local.toCss(), equals('local'));
    });

    test('multiple values output comma-separated string', () {
      expect(
        CssBackgroundAttachment.multiple([
          CssBackgroundAttachment.scroll,
          CssBackgroundAttachment.fixed,
        ]).toCss(),
        equals('scroll, fixed'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(
        CssBackgroundAttachment.variable('bg-attachment').toCss(),
        equals('var(--bg-attachment)'),
      );
    });

    test('raw value outputs as-is', () {
      expect(
        CssBackgroundAttachment.raw('scroll, fixed').toCss(),
        equals('scroll, fixed'),
      );
    });

    test('global inherit outputs correct CSS', () {
      expect(
        CssBackgroundAttachment.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });

    test('global initial outputs correct CSS', () {
      expect(
        CssBackgroundAttachment.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
    });

    test('global unset outputs correct CSS', () {
      expect(
        CssBackgroundAttachment.global(CssGlobal.unset).toCss(),
        equals('unset'),
      );
    });

    test('global revert outputs correct CSS', () {
      expect(
        CssBackgroundAttachment.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
    });
  });
}
