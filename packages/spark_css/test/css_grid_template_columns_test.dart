import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssTrackSize', () {
    test('fr outputs correct CSS', () {
      expect(CssTrackSize.fr(1).toCss(), equals('1fr'));
      expect(CssTrackSize.fr(2.5).toCss(), equals('2.5fr'));
    });

    test('length outputs correct CSS', () {
      expect(CssTrackSize.length(CssLength.px(200)).toCss(), equals('200px'));
      expect(CssTrackSize.length(CssLength.percent(50)).toCss(), equals('50%'));
    });

    test('minmax outputs correct CSS', () {
      expect(
        CssTrackSize.minmax(
          CssTrackSize.length(CssLength.px(200)),
          CssTrackSize.fr(1),
        ).toCss(),
        equals('minmax(200px, 1fr)'),
      );
    });

    test('fitContent outputs correct CSS', () {
      expect(
        CssTrackSize.fitContent(CssLength.px(300)).toCss(),
        equals('fit-content(300px)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(CssTrackSize.raw('auto').toCss(), equals('auto'));
    });
  });

  group('CssGridTemplateColumns', () {
    test('none outputs correct CSS', () {
      expect(CssGridTemplateColumns.none.toCss(), equals('none'));
    });

    test('subgrid outputs correct CSS', () {
      expect(CssGridTemplateColumns.subgrid.toCss(), equals('subgrid'));
    });

    test('tracks outputs space-separated values', () {
      expect(
        CssGridTemplateColumns.tracks([
          CssTrackSize.fr(1),
          CssTrackSize.fr(2),
          CssTrackSize.length(CssLength.px(100)),
        ]).toCss(),
        equals('1fr 2fr 100px'),
      );
    });

    test('repeat outputs correct CSS', () {
      expect(
        CssGridTemplateColumns.repeat(3, [CssTrackSize.fr(1)]).toCss(),
        equals('repeat(3, 1fr)'),
      );
    });

    test('repeat with multiple tracks', () {
      expect(
        CssGridTemplateColumns.repeat(2, [
          CssTrackSize.fr(1),
          CssTrackSize.length(CssLength.px(100)),
        ]).toCss(),
        equals('repeat(2, 1fr 100px)'),
      );
    });

    test('autoFill outputs correct CSS', () {
      expect(
        CssGridTemplateColumns.autoFill([
          CssTrackSize.minmax(
            CssTrackSize.length(CssLength.px(200)),
            CssTrackSize.fr(1),
          ),
        ]).toCss(),
        equals('repeat(auto-fill, minmax(200px, 1fr))'),
      );
    });

    test('autoFit outputs correct CSS', () {
      expect(
        CssGridTemplateColumns.autoFit([
          CssTrackSize.minmax(
            CssTrackSize.length(CssLength.px(150)),
            CssTrackSize.fr(1),
          ),
        ]).toCss(),
        equals('repeat(auto-fit, minmax(150px, 1fr))'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(
        CssGridTemplateColumns.variable('grid-cols').toCss(),
        equals('var(--grid-cols)'),
      );
    });

    test('raw outputs value as-is', () {
      expect(
        CssGridTemplateColumns.raw('1fr 2fr 1fr').toCss(),
        equals('1fr 2fr 1fr'),
      );
    });

    test('global outputs correct CSS', () {
      expect(
        CssGridTemplateColumns.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
  });
}
