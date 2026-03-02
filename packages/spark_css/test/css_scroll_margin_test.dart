import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssScrollMargin', () {
    test('all outputs correct CSS', () {
      expect(CssScrollMargin.all(CssLength.px(10)).toCss(), equals('10px'));
    });

    test('symmetric outputs correct CSS', () {
      expect(
        CssScrollMargin.symmetric(CssLength.px(10), CssLength.px(20)).toCss(),
        equals('10px 20px'),
      );
    });

    test('only outputs correct CSS', () {
      expect(
        CssScrollMargin.only(
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
        CssScrollMargin.only(top: CssLength.px(10)).toCss(),
        equals('10px 0 0 0'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssScrollMargin.variable('sm').toCss(), equals('var(--sm)'));
    });

    test('raw outputs value as-is', () {
      expect(CssScrollMargin.raw('10px 20px').toCss(), equals('10px 20px'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssScrollMargin.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssScrollMargin.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssScrollMargin.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(
        CssScrollMargin.global(CssGlobal.revert).toCss(),
        equals('revert'),
      );
      expect(
        CssScrollMargin.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(
        scrollMargin: CssScrollMargin.all(CssLength.px(10)),
      );
      expect(style.toCss(), contains('scroll-margin: 10px;'));
    });
  });
}
