import 'package:spark_css/src/css_types/css_overflow.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssOverflow', () {
    test('keywords output correct CSS', () {
      expect(CssOverflow.visible.toCss(), equals('visible'));
      expect(CssOverflow.hidden.toCss(), equals('hidden'));
      expect(CssOverflow.scroll.toCss(), equals('scroll'));
      expect(CssOverflow.auto.toCss(), equals('auto'));
      expect(CssOverflow.clip.toCss(), equals('clip'));
    });
    test('variable outputs correct CSS', () {
      expect(CssOverflow.variable('ov').toCss(), equals('var(--ov)'));
    });
    test('raw outputs value as-is', () {
      expect(CssOverflow.raw('auto').toCss(), equals('auto'));
    });
    test('global outputs correct CSS', () {
      expect(CssOverflow.global(CssGlobal.inherit).toCss(), equals('inherit'));
    });
  });
}
