import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssCaretColor', () {
    test('auto keyword outputs correct CSS', () {
      expect(CssCaretColor.auto.toCss(), equals('auto'));
    });

    test('color outputs correct CSS', () {
      expect(CssCaretColor.color(CssColor.red).toCss(), equals('red'));
      expect(
        CssCaretColor.color(CssColor.hex('#ff0000')).toCss(),
        equals('#ff0000'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssCaretColor.variable('cc').toCss(), equals('var(--cc)'));
    });

    test('raw outputs value as-is', () {
      expect(CssCaretColor.raw('red').toCss(), equals('red'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssCaretColor.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssCaretColor.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssCaretColor.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssCaretColor.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssCaretColor.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(caretColor: CssCaretColor.auto);
      expect(style.toCss(), contains('caret-color: auto;'));
    });
  });
}
