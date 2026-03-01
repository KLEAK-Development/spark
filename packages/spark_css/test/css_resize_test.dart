import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssResize', () {
    test('keywords output correct CSS', () {
      expect(CssResize.none.toCss(), equals('none'));
      expect(CssResize.both.toCss(), equals('both'));
      expect(CssResize.horizontal.toCss(), equals('horizontal'));
      expect(CssResize.vertical.toCss(), equals('vertical'));
      expect(CssResize.block.toCss(), equals('block'));
      expect(CssResize.inline.toCss(), equals('inline'));
    });
    test('variable outputs correct CSS', () {
      expect(CssResize.variable('r').toCss(), equals('var(--r)'));
    });
    test('raw outputs value as-is', () {
      expect(CssResize.raw('both').toCss(), equals('both'));
    });
    test('global outputs correct CSS', () {
      expect(CssResize.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
    test('Style.typed integration', () {
      final style = Style.typed(resize: CssResize.both);
      expect(style.toCss(), contains('resize: both;'));
    });
  });
}
