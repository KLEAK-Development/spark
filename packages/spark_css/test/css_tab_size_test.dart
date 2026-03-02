import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssTabSize', () {
    test('number outputs correct CSS', () {
      expect(CssTabSize.number(4).toCss(), equals('4'));
      expect(CssTabSize.number(8).toCss(), equals('8'));
    });

    test('length outputs correct CSS', () {
      expect(CssTabSize.length(CssLength.px(20)).toCss(), equals('20px'));
      expect(CssTabSize.length(CssLength.em(2)).toCss(), equals('2em'));
    });

    test('variable outputs correct CSS', () {
      expect(CssTabSize.variable('ts').toCss(), equals('var(--ts)'));
    });

    test('raw outputs value as-is', () {
      expect(CssTabSize.raw('4').toCss(), equals('4'));
    });

    test('global outputs correct CSS', () {
      expect(CssTabSize.global(CssGlobal.inherit).toCss(), equals('inherit'));
      expect(CssTabSize.global(CssGlobal.initial).toCss(), equals('initial'));
      expect(CssTabSize.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssTabSize.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssTabSize.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(tabSize: CssTabSize.number(4));
      expect(style.toCss(), contains('tab-size: 4;'));
    });
  });
}
