import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('CssBackground', () {
    test('none outputs correct CSS', () {
      expect(CssBackground.none.toCss(), equals('none'));
    });

    test('color outputs correct CSS', () {
      expect(CssBackground.color(CssColor.red).toCss(), equals('red'));
      expect(
        CssBackground.color(CssColor.hex('ff0000')).toCss(),
        equals('#ff0000'),
      );
    });

    test('shorthand with image and color', () {
      expect(
        CssBackground.shorthand(
          image: CssBackgroundImage.url('bg.png'),
          color: CssColor.white,
        ).toCss(),
        equals('url(bg.png) white'),
      );
    });

    test('shorthand with position and size uses slash syntax', () {
      expect(
        CssBackground.shorthand(
          image: CssBackgroundImage.url('bg.png'),
          position: CssBackgroundPosition.center,
          size: CssBackgroundSize.cover,
        ).toCss(),
        equals('url(bg.png) center / cover'),
      );
    });

    test('shorthand with position only (no slash)', () {
      expect(
        CssBackground.shorthand(
          image: CssBackgroundImage.url('bg.png'),
          position: CssBackgroundPosition.topLeft,
        ).toCss(),
        equals('url(bg.png) top left'),
      );
    });

    test('shorthand with size only', () {
      expect(
        CssBackground.shorthand(size: CssBackgroundSize.cover).toCss(),
        equals('cover'),
      );
    });

    test('shorthand with all components', () {
      expect(
        CssBackground.shorthand(
          image: CssBackgroundImage.url('bg.png'),
          position: CssBackgroundPosition.center,
          size: CssBackgroundSize.cover,
          repeat: CssBackgroundRepeat.noRepeat,
          attachment: CssBackgroundAttachment.fixed,
          origin: CssBackgroundOrigin.paddingBox,
          clip: CssBackgroundClip.borderBox,
          color: CssColor.white,
        ).toCss(),
        equals(
          'url(bg.png) center / cover no-repeat fixed padding-box border-box white',
        ),
      );
    });

    test('layers outputs comma-separated values', () {
      expect(
        CssBackground.layers([
          CssBackground.shorthand(
            image: CssBackgroundImage.url('top.png'),
            repeat: CssBackgroundRepeat.noRepeat,
          ),
          CssBackground.color(CssColor.white),
        ]).toCss(),
        equals('url(top.png) no-repeat, white'),
      );
    });

    test('variable outputs correct CSS', () {
      expect(CssBackground.variable('bg').toCss(), equals('var(--bg)'));
    });

    test('raw outputs value as-is', () {
      expect(
        CssBackground.raw('linear-gradient(red, blue)').toCss(),
        equals('linear-gradient(red, blue)'),
      );
    });

    test('global outputs correct CSS', () {
      expect(
        CssBackground.global(CssGlobal.inherit).toCss(),
        equals('inherit'),
      );
    });
  });
}
