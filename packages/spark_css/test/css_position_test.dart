import 'package:spark_css/src/css_types/css_position.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssPosition', () {
    test('keywords output correct CSS', () {
      expect(CssPosition.static_.toCss(), equals('static'));
      expect(CssPosition.relative.toCss(), equals('relative'));
      expect(CssPosition.absolute.toCss(), equals('absolute'));
      expect(CssPosition.fixed.toCss(), equals('fixed'));
      expect(CssPosition.sticky.toCss(), equals('sticky'));
    });
    test('variable outputs correct CSS', () {
      expect(CssPosition.variable('pos').toCss(), equals('var(--pos)'));
    });
    test('raw outputs value as-is', () {
      expect(CssPosition.raw('absolute').toCss(), equals('absolute'));
    });
    test('global outputs correct CSS', () {
      expect(CssPosition.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
