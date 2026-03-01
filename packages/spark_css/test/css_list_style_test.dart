import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssListStyleType', () {
    test('keywords output correct CSS', () {
      expect(CssListStyleType.disc.toCss(), equals('disc'));
      expect(CssListStyleType.circle.toCss(), equals('circle'));
      expect(CssListStyleType.square.toCss(), equals('square'));
      expect(CssListStyleType.decimal.toCss(), equals('decimal'));
      expect(CssListStyleType.none.toCss(), equals('none'));
    });
  });

  group('CssListStylePosition', () {
    test('keywords output correct CSS', () {
      expect(CssListStylePosition.inside.toCss(), equals('inside'));
      expect(CssListStylePosition.outside.toCss(), equals('outside'));
    });
  });

  group('CssListStyle', () {
    test('none keyword outputs correct CSS', () {
      expect(CssListStyle.none.toCss(), equals('none'));
    });
    test('shorthand with type only', () {
      final style = CssListStyle(type: CssListStyleType.disc);
      expect(style.toCss(), equals('disc'));
    });
    test('shorthand with position only', () {
      final style = CssListStyle(position: CssListStylePosition.inside);
      expect(style.toCss(), equals('inside'));
    });
    test('shorthand with image only', () {
      final style = CssListStyle(image: 'url("marker.png")');
      expect(style.toCss(), equals('url("marker.png")'));
    });
    test('shorthand with all parts', () {
      final style = CssListStyle(
        type: CssListStyleType.square,
        position: CssListStylePosition.outside,
        image: 'url("marker.png")',
      );
      expect(style.toCss(), equals('square outside url("marker.png")'));
    });
    test('variable outputs correct CSS', () {
      expect(CssListStyle.variable('ls').toCss(), equals('var(--ls)'));
    });
    test('raw outputs value as-is', () {
      expect(CssListStyle.raw('disc inside').toCss(), equals('disc inside'));
    });
    test('global outputs correct CSS', () {
      expect(CssListStyle.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
    test('Style.typed integration', () {
      final style = Style.typed(listStyle: CssListStyle.none);
      expect(style.toCss(), contains('list-style: none;'));
    });
  });
}
