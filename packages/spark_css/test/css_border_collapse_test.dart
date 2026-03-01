import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssBorderCollapse', () {
    test('keywords output correct CSS', () {
      expect(CssBorderCollapse.separate.toCss(), equals('separate'));
      expect(CssBorderCollapse.collapse.toCss(), equals('collapse'));
    });
    test('variable outputs correct CSS', () {
      expect(CssBorderCollapse.variable('bc').toCss(), equals('var(--bc)'));
    });
    test('raw outputs value as-is', () {
      expect(CssBorderCollapse.raw('collapse').toCss(), equals('collapse'));
    });
    test('global outputs correct CSS', () {
      expect(
        CssBorderCollapse.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
    test('Style.typed integration', () {
      final style = Style.typed(borderCollapse: CssBorderCollapse.collapse);
      expect(style.toCss(), contains('border-collapse: collapse;'));
    });
  });
}
