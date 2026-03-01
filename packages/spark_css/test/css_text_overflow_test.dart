import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssTextOverflow', () {
    test('keywords output correct CSS', () {
      expect(CssTextOverflow.clip.toCss(), equals('clip'));
      expect(CssTextOverflow.ellipsis.toCss(), equals('ellipsis'));
    });
    test('value outputs quoted string', () {
      expect(CssTextOverflow.value('…').toCss(), equals('"…"'));
      expect(CssTextOverflow.value('>>').toCss(), equals('">>"'));
    });
    test('variable outputs correct CSS', () {
      expect(CssTextOverflow.variable('to').toCss(), equals('var(--to)'));
    });
    test('raw outputs value as-is', () {
      expect(CssTextOverflow.raw('ellipsis').toCss(), equals('ellipsis'));
    });
    test('global outputs correct CSS', () {
      expect(
        CssTextOverflow.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
    test('Style.typed integration', () {
      final style = Style.typed(textOverflow: CssTextOverflow.ellipsis);
      expect(style.toCss(), contains('text-overflow: ellipsis;'));
    });
  });
}
