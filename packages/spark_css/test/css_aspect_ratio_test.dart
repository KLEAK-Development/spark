import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssAspectRatio', () {
    test('auto keyword outputs correct CSS', () {
      expect(CssAspectRatio.auto.toCss(), equals('auto'));
    });
    test('ratio outputs correct CSS', () {
      expect(CssAspectRatio.ratio(16, 9).toCss(), equals('16 / 9'));
      expect(CssAspectRatio.ratio(4, 3).toCss(), equals('4 / 3'));
    });
    test('number outputs correct CSS', () {
      expect(CssAspectRatio.number(1).toCss(), equals('1'));
      expect(CssAspectRatio.number(0.5).toCss(), equals('0.5'));
    });
    test('variable outputs correct CSS', () {
      expect(CssAspectRatio.variable('ar').toCss(), equals('var(--ar)'));
    });
    test('raw outputs value as-is', () {
      expect(CssAspectRatio.raw('16 / 9').toCss(), equals('16 / 9'));
    });
    test('global outputs correct CSS', () {
      expect(
        CssAspectRatio.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
    test('Style.typed integration', () {
      final style = Style.typed(aspectRatio: CssAspectRatio.ratio(16, 9));
      expect(style.toCss(), contains('aspect-ratio: 16 / 9;'));
    });
  });
}
