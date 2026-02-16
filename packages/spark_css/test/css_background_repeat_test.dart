import 'package:spark_css/src/css_types/css_background_repeat.dart';
import 'package:spark_css/src/css_types/css_value.dart';
import 'package:test/test.dart';

void main() {
  group('CssBackgroundRepeat', () {
    test('keywords output correct CSS', () {
      expect(CssBackgroundRepeat.repeat.toCss(), equals('repeat'));
      expect(CssBackgroundRepeat.repeatX.toCss(), equals('repeat-x'));
      expect(CssBackgroundRepeat.repeatY.toCss(), equals('repeat-y'));
      expect(CssBackgroundRepeat.space.toCss(), equals('space'));
      expect(CssBackgroundRepeat.round.toCss(), equals('round'));
      expect(CssBackgroundRepeat.noRepeat.toCss(), equals('no-repeat'));
    });

    test('two-value syntax outputs correct CSS', () {
      expect(
        CssBackgroundRepeat.xy(
          CssBackgroundRepeat.repeat,
          CssBackgroundRepeat.space,
        ).toCss(),
        equals('repeat space'),
      );
      expect(
        CssBackgroundRepeat.xy(
          CssBackgroundRepeat.noRepeat,
          CssBackgroundRepeat.round,
        ).toCss(),
        equals('no-repeat round'),
      );
    });

    test('multiple values output correct CSS', () {
      expect(
        CssBackgroundRepeat.multiple([
          CssBackgroundRepeat.repeatX,
          CssBackgroundRepeat.repeatY,
        ]).toCss(),
        equals('repeat-x, repeat-y'),
      );

      expect(
        CssBackgroundRepeat.multiple([
          CssBackgroundRepeat.xy(
            CssBackgroundRepeat.space,
            CssBackgroundRepeat.round,
          ),
          CssBackgroundRepeat.noRepeat,
        ]).toCss(),
        equals('space round, no-repeat'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(
        CssBackgroundRepeat.variable('bg-repeat').toCss(),
        equals('var(--bg-repeat)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(
        CssBackgroundRepeat.raw('repeat round').toCss(),
        equals('repeat round'),
      );
    });

    test('global outputs correct CSS', () {
      expect(
        CssBackgroundRepeat.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
  });
}
