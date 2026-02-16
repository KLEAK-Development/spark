import 'package:test/test.dart';
import 'package:spark_css/src/css_types/css_background_clip.dart';
import 'package:spark_css/src/css_types/css_value.dart';

void main() {
  group('CssBackgroundClip', () {
    test('keywords', () {
      expect(CssBackgroundClip.borderBox.toCss(), 'border-box');
      expect(CssBackgroundClip.paddingBox.toCss(), 'padding-box');
      expect(CssBackgroundClip.contentBox.toCss(), 'content-box');
      expect(CssBackgroundClip.text.toCss(), 'text');
    });

    test('multiple', () {
      final multiple = CssBackgroundClip.multiple([
        CssBackgroundClip.borderBox,
        CssBackgroundClip.paddingBox,
        CssBackgroundClip.text,
      ]);
      expect(multiple.toCss(), 'border-box, padding-box, text');
    });

    test('variable', () {
      expect(CssBackgroundClip.variable('foo').toCss(), 'var(--foo)');
    });

    test('raw', () {
      expect(CssBackgroundClip.raw('custom-value').toCss(), 'custom-value');
    });

    test('global', () {
      expect(CssBackgroundClip.global(CssGlobal.inherit).toCss(), 'inherit');
      expect(CssBackgroundClip.global(CssGlobal.initial).toCss(), 'initial');
      expect(CssBackgroundClip.global(CssGlobal.unset).toCss(), 'unset');
      expect(CssBackgroundClip.global(CssGlobal.revert).toCss(), 'revert');
      expect(
        CssBackgroundClip.global(CssGlobal.revertLayer).toCss(),
        'revert-layer',
      );
    });
  });
}
