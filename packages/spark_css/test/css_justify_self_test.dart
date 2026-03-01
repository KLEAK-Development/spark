import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssJustifySelf', () {
    test('keywords output correct CSS', () {
      expect(CssJustifySelf.auto.toCss(), equals('auto'));
      expect(CssJustifySelf.normal.toCss(), equals('normal'));
      expect(CssJustifySelf.stretch.toCss(), equals('stretch'));
      expect(CssJustifySelf.start.toCss(), equals('start'));
      expect(CssJustifySelf.end.toCss(), equals('end'));
      expect(CssJustifySelf.center.toCss(), equals('center'));
      expect(CssJustifySelf.left.toCss(), equals('left'));
      expect(CssJustifySelf.right.toCss(), equals('right'));
      expect(CssJustifySelf.baseline.toCss(), equals('baseline'));
      expect(CssJustifySelf.firstBaseline.toCss(), equals('first baseline'));
      expect(CssJustifySelf.lastBaseline.toCss(), equals('last baseline'));
      expect(CssJustifySelf.selfStart.toCss(), equals('self-start'));
      expect(CssJustifySelf.selfEnd.toCss(), equals('self-end'));
    });

    test('variable outputs correct CSS', () {
      expect(CssJustifySelf.variable('js').toCss(), equals('var(--js)'));
    });

    test('raw outputs value as-is', () {
      expect(CssJustifySelf.raw('center').toCss(), equals('center'));
    });

    test('global outputs correct CSS', () {
      expect(
        CssJustifySelf.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
      expect(
        CssJustifySelf.global(CssGlobal.initial).toCss(),
        equals('initial'),
      );
      expect(CssJustifySelf.global(CssGlobal.unset).toCss(), equals('unset'));
      expect(CssJustifySelf.global(CssGlobal.revert).toCss(), equals('revert'));
      expect(
        CssJustifySelf.global(CssGlobal.revertLayer).toCss(),
        equals('revert-layer'),
      );
    });

    test('Style.typed integration', () {
      final style = Style.typed(justifySelf: CssJustifySelf.center);
      expect(style.toCss(), contains('justify-self: center;'));
    });
  });
}
