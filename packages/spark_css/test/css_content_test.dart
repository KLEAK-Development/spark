import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssContent', () {
    test('keywords output correct CSS', () {
      expect(CssContent.normal.toCss(), equals('normal'));
      expect(CssContent.none.toCss(), equals('none'));
    });
    test('value outputs correct CSS', () {
      expect(CssContent.value('"Hello"').toCss(), equals('"Hello"'));
    });
    test('variable outputs correct CSS', () {
      expect(CssContent.variable('c').toCss(), equals('var(--c)'));
    });
    test('raw outputs value as-is', () {
      expect(CssContent.raw('counter(item)').toCss(), equals('counter(item)'));
    });
    test('global outputs correct CSS', () {
      expect(CssContent.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
    test('Style.typed integration', () {
      final style = Style.typed(content: CssContent.normal);
      expect(style.toCss(), contains('content: normal;'));
    });
  });
}
