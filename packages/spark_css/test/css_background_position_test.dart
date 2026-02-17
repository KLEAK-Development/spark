import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssBackgroundPosition', () {
    test('keywords output correct CSS', () {
      expect(CssBackgroundPosition.left.toCss(), equals('left'));
      expect(CssBackgroundPosition.center.toCss(), equals('center'));
      expect(CssBackgroundPosition.right.toCss(), equals('right'));
      expect(CssBackgroundPosition.top.toCss(), equals('top'));
      expect(CssBackgroundPosition.bottom.toCss(), equals('bottom'));
    });

    test('parts outputs correct CSS with lengths and keywords', () {
      // 1 value
      expect(
        CssBackgroundPosition.parts([CssBackgroundPosition.left]).toCss(),
        equals('left'),
      );

      // 2 values (keyword + length)
      expect(
        CssBackgroundPosition.parts([
          CssBackgroundPosition.left,
          CssLength.px(20),
        ]).toCss(),
        equals('left 20px'),
      );

      // 2 values (length + length)
      expect(
        CssBackgroundPosition.parts([
          CssLength.percent(50),
          CssLength.percent(50),
        ]).toCss(),
        equals('50% 50%'),
      );

      // 3 values
      expect(
        CssBackgroundPosition.parts([
          CssBackgroundPosition.left,
          CssLength.px(20),
          CssBackgroundPosition.top,
        ]).toCss(),
        equals('left 20px top'),
      );

      // 4 values
      expect(
        CssBackgroundPosition.parts([
          CssBackgroundPosition.left,
          CssLength.px(20),
          CssBackgroundPosition.top,
          CssLength.px(10),
        ]).toCss(),
        equals('left 20px top 10px'),
      );
    });

    test('multiple outputs correct CSS', () {
      expect(
        CssBackgroundPosition.multiple([
          CssBackgroundPosition.parts([CssBackgroundPosition.left]),
          CssBackgroundPosition.parts([CssBackgroundPosition.right]),
        ]).toCss(),
        equals('left, right'),
      );

      expect(
        CssBackgroundPosition.multiple([
          CssBackgroundPosition.parts([
            CssBackgroundPosition.left,
            CssLength.px(20),
          ]),
          CssBackgroundPosition.center,
        ]).toCss(),
        equals('left 20px, center'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(
        CssBackgroundPosition.variable('bg-pos').toCss(),
        equals('var(--bg-pos)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(
        CssBackgroundPosition.raw('left 20px').toCss(),
        equals('left 20px'),
      );
    });

    test('global outputs correct CSS', () {
      expect(
        CssBackgroundPosition.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssBackgroundPosition.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
    });
  });
}
