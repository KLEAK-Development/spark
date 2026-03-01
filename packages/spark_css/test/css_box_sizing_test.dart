import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssBoxSizing', () {
    test('keywords output correct CSS', () {
      expect(CssBoxSizing.contentBox.toCss(), equals('content-box'));
      expect(CssBoxSizing.borderBox.toCss(), equals('border-box'));
    });
    test('variable outputs correct CSS', () {
      expect(CssBoxSizing.variable('bs').toCss(), equals('var(--bs)'));
    });
    test('raw outputs value as-is', () {
      expect(CssBoxSizing.raw('border-box').toCss(), equals('border-box'));
    });
    test('global outputs correct CSS', () {
      expect(CssBoxSizing.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
    test('Style.typed integration', () {
      final style = Style.typed(boxSizing: CssBoxSizing.borderBox);
      expect(style.toCss(), contains('box-sizing: border-box;'));
    });
  });
}
