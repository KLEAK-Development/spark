import 'dart:async';
import 'package:test/test.dart';
import 'package:spark_css/spark_css.dart';

void main() {
  group('Style', () {
    test('respects minification settings (minified via Zone)', () {
      runZoned(() {
        final style = Style(color: 'red', fontSize: '12px');
        final rendered = style.toCss();
        // Check for lack of spaces/newlines
        expect(rendered, equals('color:red;font-size:12px;'));

        final sheet = css({'.foo': Style(color: 'blue')});
        expect(sheet.toCss(), equals('.foo{color:blue;}'));

        final nested = Style(color: 'red', css: css({'.bar': Style(color: 'blue')}));
        expect(nested.toCss(), equals('color:red;.bar{color:blue;}'));
      }, zoneValues: {#spark_css_minify: true});
    });

    test('renders simple properties', () {
      final style = Style(color: 'red', fontSize: '12px');
      expect(style.toCss(), contains('color: red;'));
      expect(style.toCss(), contains('font-size: 12px;'));
    });

    test('renders added custom properties', () {
      final style = Style();
      style.add('--custom-var', '10px');
      expect(style.toCss(), contains('--custom-var: 10px;'));
    });

    test('renders all typed properties in Style.typed', () {
      final style = Style.typed(
        color: CssColor.red,
        backgroundColor: CssColor.blue,
        borderColor: CssColor.black,
        fill: CssColor.white,
        display: CssDisplay.flex,
        position: CssPosition.absolute,
        width: CssLength.px(100),
        height: CssLength.px(200),
        minWidth: CssLength.px(50),
        minHeight: CssLength.px(50),
        maxWidth: CssLength.px(500),
        maxHeight: CssLength.px(500),
        margin: CssSpacing.all(CssLength.px(10)),
        marginTop: CssLength.px(5),
        marginRight: CssLength.px(5),
        marginBottom: CssLength.px(5),
        marginLeft: CssLength.px(5),
        padding: CssSpacing.all(CssLength.px(20)),
        paddingTop: CssLength.px(10),
        paddingRight: CssLength.px(10),
        paddingBottom: CssLength.px(10),
        paddingLeft: CssLength.px(10),
        top: CssLength.px(0),
        right: CssLength.px(0),
        bottom: CssLength.px(0),
        left: CssLength.px(0),
        flexDirection: CssFlexDirection.row,
        flexWrap: CssFlexWrap.wrap,
        justifyContent: CssJustifyContent.center,
        alignItems: CssAlignItems.center,
        alignSelf: CssAlignSelf.stretch,
        alignContent: CssAlignContent.start,
        flexGrow: CssNumber(1),
        flexShrink: CssNumber(0),
        gap: CssLength.px(10),
        flex: CssFlexShorthand(grow: 1),
        fontSize: CssLength.px(16),
        fontWeight: CssFontWeight.bold,
        fontFamily: CssFontFamily.sansSerif,
        fontStyle: CssFontStyle.italic,
        textAlign: CssTextAlign.center,
        textDecoration: CssTextDecoration.underline,
        textTransform: CssTextTransform.uppercase,
        whiteSpace: CssWhiteSpace.nowrap,
        wordBreak: CssWordBreak.breakAll,
        lineHeight: CssNumber(1.5),
        letterSpacing: CssLength.px(1),
        textShadow: CssTextShadow(x: CssLength.px(1), y: CssLength.px(1)),
        border: CssBorder.widthStyle(CssLength.px(1), CssBorderStyle.solid),
        borderTop: CssBorder.widthStyle(CssLength.px(1), CssBorderStyle.solid),
        borderRight: CssBorder.widthStyle(CssLength.px(1), CssBorderStyle.solid),
        borderBottom: CssBorder.widthStyle(CssLength.px(1), CssBorderStyle.solid),
        borderLeft: CssBorder.widthStyle(CssLength.px(1), CssBorderStyle.solid),
        borderRadius: CssBorderRadius.all(CssLength.px(5)),
        outline: CssOutline(width: CssLength.px(1), style: CssBorderStyle.solid),
        outlineOffset: CssLength.px(2),
        opacity: CssNumber(0.5),
        overflow: CssOverflow.hidden,
        overflowX: CssOverflow.auto,
        overflowY: CssOverflow.scroll,
        zIndex: CssZIndex(10),
        cursor: CssCursor.pointer,
        boxShadow: CssBoxShadow(x: CssLength.px(2), y: CssLength.px(2)),
        filter: CssFilter.blur(CssLength.px(5)),
        backdropFilter: CssFilter.brightness(0.8),
        backgroundImage: CssBackgroundImage.url('test.png'),
        backgroundSize: CssBackgroundSize.cover,
        backgroundPosition: CssBackgroundPosition.center,
        backgroundRepeat: CssBackgroundRepeat.noRepeat,
        backgroundClip: CssBackgroundClip.borderBox,
        backgroundOrigin: CssBackgroundOrigin.paddingBox,
        backgroundAttachment: CssBackgroundAttachment.fixed,
        transition: CssTransition.simple('opacity', '1s'),
        transform: CssTransform.scale(1.1),
        background: 'red',
        gridTemplateColumns: '1fr 1fr',
      );

      final css = style.toCss();
      expect(css, contains('color: red;'));
      expect(css, contains('background-color: blue;'));
      expect(css, contains('display: flex;'));
      expect(css, contains('flex-direction: row;'));
      expect(css, contains('padding: 20px;'));
      expect(css, contains('margin: 10px;'));
      expect(css, contains('background: red;'));
      expect(css, contains('grid-template-columns: 1fr 1fr;'));
    });

    test('renders all properties in default Style constructor', () {
      final style = Style(
        color: 'red',
        backgroundColor: 'blue',
        background: 'green',
        fontSize: '16px',
        fontWeight: 'bold',
        fontFamily: 'sans-serif',
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
        margin: '10px',
        padding: '20px',
        width: '100px',
        height: '100px',
        maxWidth: '200px',
        maxHeight: '200px',
        border: '1px solid black',
        borderBottom: '2px solid red',
        borderRadius: '5px',
        position: 'absolute',
        top: '0',
        bottom: '0',
        left: '0',
        right: '0',
        zIndex: '1',
        opacity: '0.5',
        transition: 'all 1s',
        cursor: 'pointer',
        textAlign: 'center',
        lineHeight: '1.5',
        letterSpacing: '1px',
        textDecoration: 'none',
        textTransform: 'uppercase',
        gap: '10px',
        gridTemplateColumns: '1fr',
        fill: 'red',
        backdropFilter: 'blur(5px)',
        marginTop: '1px',
        marginBottom: '2px',
        marginLeft: '3px',
        marginRight: '4px',
        paddingTop: '5px',
        paddingBottom: '6px',
        paddingLeft: '7px',
        paddingRight: '8px',
        borderTop: '1px solid a',
        borderLeft: '1px solid b',
        borderRight: '1px solid c',
        flex: '1',
        flexGrow: '1',
        flexShrink: '0',
        flexWrap: 'wrap',
        alignSelf: 'auto',
        overflow: 'hidden',
        overflowX: 'auto',
        overflowY: 'scroll',
        minHeight: '10px',
        minWidth: '10px',
        boxShadow: 'none',
        transform: 'none',
        borderColor: 'black',
      );
      final css = style.toCss();
      expect(css, contains('color: red;'));
      expect(style.toString(), equals(css));
    });

    test('Stylesheet.toString() works', () {
      final sheet = css({'.a': Style(color: 'red')});
      expect(sheet.toString(), equals(sheet.toCss()));
    });

    test('renders nested stylesheet', () {
      final style = Style(
        color: 'red',
        css: css({'@media (max-width: 600px)': Style(color: 'blue')}),
      );
      final output = style.toCss();
      expect(output, contains('color: red;'));
      expect(output, contains('@media (max-width: 600px) {'));
      // The inner style properties are indented by Style.toCss but Stylesheet wraps them
      expect(output, contains('color: blue;'));
    });
  });

  group('Stylesheet', () {
    test('renders multiple rules', () {
      final sheet = css({
        'body': Style(margin: '0'),
        '.foo': Style(color: 'red'),
      });
      final output = sheet.toCss();
      expect(output, contains('body {'));
      expect(output, contains('margin: 0;'));
      expect(output, contains('.foo {'));
      expect(output, contains('color: red;'));
    });
  });

  test('respects minification settings (unminified in dev)', () {
    // In test environment (VM), dart.vm.product is false.
    // So we expect unminified CSS with indentation/newlines.
    final style = Style(color: 'red');
    final css = style.toCss();
    // Check for newline after property
    expect(css, contains(';\n'));
    // Check for indentation
    expect(css, contains('  color: red;'));
  });
}
