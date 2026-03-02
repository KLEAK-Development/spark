import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssScrollPadding', () {
    test('all outputs correct CSS', () {
      expect(CssScrollPadding.all(CssLength.px(10)).toCss(), equals('10px'));
    });

    test('symmetric outputs correct CSS', () {
      expect(
        CssScrollPadding.symmetric(CssLength.px(10), CssLength.px(20)).toCss(),
        equals('10px 20px'),
      );
    });

    test('only with all sides outputs correct CSS', () {
      expect(
        CssScrollPadding.only(
          top: CssLength.px(10),
          right: CssLength.px(20),
          bottom: CssLength.px(30),
          left: CssLength.px(40),
        ).toCss(),
        equals('10px 20px 30px 40px'),
      );
    });

    test('only with partial values defaults to zero', () {
      expect(
        CssScrollPadding.only(top: CssLength.px(10)).toCss(),
        equals('10px 0 0 0'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssScrollPadding.variable('sp').toCss(), equals('var(--sp)'));
    });

    test('raw outputs value as-is', () {
      expect(CssScrollPadding.raw('10px 20px').toCss(), equals('10px 20px'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssScrollPadding.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssScrollPadding.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssScrollPadding.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(
        CssScrollPadding.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
      expect(
        CssScrollPadding.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(
        scrollPadding: CssScrollPadding.all(CssLength.px(10)),
      );
      expect(style.toCss(), contains('scroll-padding: 10px;'));
    });
  });
}
