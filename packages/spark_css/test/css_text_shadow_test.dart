import 'package:spark_css/spark_css.dart';
import 'package:spark_css/src/css_types/css_text_shadow.dart';
import 'package:test/test.dart';

void main() {
  group('CssTextShadow', () {
    test('none returns "none"', () {
      expect(CssTextShadow.none.toCss(), 'none');
    });

    test('single shadow with x and y', () {
      final shadow = CssTextShadow(x: CssLength.px(1), y: CssLength.px(2));
      expect(shadow.toCss(), '1px 2px');
    });

    test('single shadow with x, y, and blur', () {
      final shadow = CssTextShadow(
        x: CssLength.px(1),
        y: CssLength.px(2),
        blur: CssLength.px(3),
      );
      expect(shadow.toCss(), '1px 2px 3px');
    });

    test('single shadow with x, y, blur, and color', () {
      final shadow = CssTextShadow(
        x: CssLength.px(1),
        y: CssLength.px(2),
        blur: CssLength.px(3),
        color: CssColor.red,
      );
      expect(shadow.toCss(), '1px 2px 3px red');
    });

    test('single shadow with x, y, and color', () {
      final shadow = CssTextShadow(
        x: CssLength.px(1),
        y: CssLength.px(2),
        color: CssColor.hex('000'),
      );
      expect(shadow.toCss(), '1px 2px #000');
    });

    test('multiple shadows', () {
      final shadow = CssTextShadow.multiple([
        CssTextShadow(
          x: CssLength.px(1),
          y: CssLength.px(1),
          color: CssColor.red,
        ),
        CssTextShadow(
          x: CssLength.px(2),
          y: CssLength.px(2),
          color: CssColor.blue,
        ),
      ]);
      expect(shadow.toCss(), '1px 1px red, 2px 2px blue');
    });

    test('variable', () {
      expect(CssTextShadow.variable('shadow').toCss(), 'var(--shadow)');
    });

    test('raw', () {
      expect(CssTextShadow.raw('1px 1px red').toCss(), '1px 1px red');
    });

    test('global', () {
      expect(CssTextShadow.global(CssGlobal.inherit).toCss(), 'inherit');
    });
  });
}
