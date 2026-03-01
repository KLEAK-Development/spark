import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssScrollBehavior', () {
    test('keywords output correct CSS', () {
      expect(CssScrollBehavior.auto.toCss(), equals('auto'));
      expect(CssScrollBehavior.smooth.toCss(), equals('smooth'));
    });
    test('variable outputs correct CSS', () {
      expect(CssScrollBehavior.variable('sb').toCss(), equals('var(--sb)'));
    });
    test('raw outputs value as-is', () {
      expect(CssScrollBehavior.raw('smooth').toCss(), equals('smooth'));
    });
    test('global outputs correct CSS', () {
      expect(
        CssScrollBehavior.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
    test('Style.typed integration', () {
      final style = Style.typed(scrollBehavior: CssScrollBehavior.smooth);
      expect(style.toCss(), contains('scroll-behavior: smooth;'));
    });
  });
}
