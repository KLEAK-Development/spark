import 'package:spark_css/src/css_types/css_cursor.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssCursor', () {
    test('keywords output correct CSS', () {
      expect(CssCursor.auto.toCss(), equals('auto'));
      expect(CssCursor.default_.toCss(), equals('default'));
      expect(CssCursor.none.toCss(), equals('none'));
      expect(CssCursor.pointer.toCss(), equals('pointer'));
      expect(CssCursor.wait.toCss(), equals('wait'));
      expect(CssCursor.text.toCss(), equals('text'));
      expect(CssCursor.move.toCss(), equals('move'));
      expect(CssCursor.help.toCss(), equals('help'));
      expect(CssCursor.notAllowed.toCss(), equals('not-allowed'));
      expect(CssCursor.zoomIn.toCss(), equals('zoom-in'));
    });

    test('url with fallback outputs correct CSS', () {
      expect(
        CssCursor.url('my-cursor.png', fallback: CssCursor.pointer).toCss(),
        equals('url(my-cursor.png), pointer'),
      );
    });

    test('url without fallback outputs correct CSS', () {
      expect(
        CssCursor.url('my-cursor.png').toCss(),
        equals('url(my-cursor.png)'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(
        CssCursor.variable('my-cursor').toCss(),
        equals('var(--my-cursor)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(CssCursor.raw('pointer').toCss(), equals('pointer'));
    });

    test('global outputs correct CSS', () {
      expect(CssCursor.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
