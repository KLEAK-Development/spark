import 'package:spark_css/src/css_types/css_display.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssDisplay', () {
    test('keywords output correct CSS', () {
      expect(CssDisplay.none.toCss(), equals('none'));
      expect(CssDisplay.block.toCss(), equals('block'));
      expect(CssDisplay.inline.toCss(), equals('inline'));
      expect(CssDisplay.flex.toCss(), equals('flex'));
      expect(CssDisplay.grid.toCss(), equals('grid'));
      expect(CssDisplay.contents.toCss(), equals('contents'));
      expect(CssDisplay.table.toCss(), equals('table'));
      expect(CssDisplay.listItem.toCss(), equals('list-item'));
    });

    test('variable outputs correct CSS', () {
      expect(CssDisplay.variable('display-mode').toCss(), equals('var(--display-mode)'));
    });

    test('raw outputs value as-is', () {
      expect(CssDisplay.raw('flex').toCss(), equals('flex'));
    });

    test('global outputs correct CSS', () {
      expect(CssDisplay.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
