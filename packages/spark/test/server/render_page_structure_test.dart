@TestOn('vm')
library;

import 'package:spark_html_dsl/spark_html_dsl.dart';
import 'package:spark_framework/src/server/render_page.dart';
import 'package:spark_css/spark_css.dart';
import 'package:test/test.dart';

void main() {
  group('renderPage', () {
    test('renders basic HTML structure', () {
      final html = renderPage(
        title: 'Basic Page',
        content: '<div>Content</div>',
      );

      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('<html lang="en">'));
      expect(html, contains('<head>'));
      expect(html, contains('<meta charset="UTF-8">'));
      expect(
        html,
        contains(
          '<meta name="viewport" content="width=device-width, initial-scale=1">',
        ),
      );
      expect(html, contains('<title>Basic Page</title>'));
      expect(html, contains('<body>'));
      expect(html, contains('<div>Content</div>'));
      expect(html, contains('</body>'));
      expect(html, contains('</html>'));
    });

    test('renders with custom lang, charset, and viewport', () {
      final html = renderPage(
        title: 'Custom Page',
        content: '<div>Content</div>',
        lang: 'fr',
        charset: 'ISO-8859-1',
        viewport: 'width=500',
      );

      expect(html, contains('<html lang="fr">'));
      expect(html, contains('<meta charset="ISO-8859-1">'));
      expect(html, contains('<meta name="viewport" content="width=500">'));
    });

    test('renders scriptName with defer', () {
      final html = renderPage(
        title: 'Script Page',
        content: '<div>Content</div>',
        scriptName: 'app.js',
      );

      expect(html, contains('<script defer src="/app.js"></script>'));
    });

    test('renders additional scripts', () {
      final html = renderPage(
        title: 'Scripts Page',
        content: '<div>Content</div>',
        additionalScripts: ['script1.js', 'script2.js'],
      );

      expect(html, contains('<script defer src="script1.js"></script>'));
      expect(html, contains('<script defer src="script2.js"></script>'));
    });

    test('renders stylesheets', () {
      final html = renderPage(
        title: 'Style Page',
        content: '<div>Content</div>',
        stylesheets: ['style1.css', 'style2.css'],
      );

      expect(html, contains('<link rel="stylesheet" href="style1.css">'));
      expect(html, contains('<link rel="stylesheet" href="style2.css">'));
    });

    test('renders inline styles as String', () {
      final html = renderPage(
        title: 'Inline Style Page',
        content: '<div>Content</div>',
        inlineStyles: 'body { background: #000; }',
      );

      expect(html, contains('<style>'));
      expect(html, contains('body { background: #000; }'));
      expect(html, contains('</style>'));
    });

    test('renders inline styles as Stylesheet', () {
      final stylesheet = Stylesheet({
        'body': Style(backgroundColor: 'red'),
        '.container': Style(padding: '10px'),
      });

      final html = renderPage(
        title: 'Stylesheet Page',
        content: '<div>Content</div>',
        inlineStyles: stylesheet,
      );

      expect(html, contains('<style>'));
      expect(html, contains('body {'));
      expect(html, contains('background-color: red;'));
      expect(html, contains('.container {'));
      expect(html, contains('padding: 10px;'));
      expect(html, contains('</style>'));
    });

    test('renders default styles when inlineStyles is missing', () {
      final html = renderPage(
        title: 'Default Style Page',
        content: '<div>Content</div>',
      );

      expect(html, contains('<style>'));
      expect(html, contains('font-family: system-ui'));
      expect(html, contains('margin: 0;'));
      expect(html, contains('padding: 20px;'));
      expect(html, contains('</style>'));
    });

    test('renders headContent as String', () {
      final html = renderPage(
        title: 'Head Content Page',
        content: '<div>Content</div>',
        headContent: '<meta name="description" content="test">',
      );

      expect(html, contains('<meta name="description" content="test">'));
    });

    test('renders headContent as Node', () {
      final vNode = Element(
        'meta',
        attributes: {'name': 'author', 'content': 'Me'},
        selfClosing: true,
      );

      final html = renderPage(
        title: 'Node Head Page',
        content: '<div>Content</div>',
        headContent: vNode,
      );

      expect(html, contains('<meta name="author" content="Me" />'));
    });

    test('renders headContent as List', () {
      final html = renderPage(
        title: 'List Head Page',
        content: '<div>Content</div>',
        headContent: [
          '<meta name="test1" content="1">',
          Element(
            'meta',
            attributes: {'name': 'test2', 'content': '2'},
            selfClosing: true,
          ),
        ],
      );

      expect(html, contains('<meta name="test1" content="1">'));
      expect(html, contains('<meta name="test2" content="2" />'));
    });

    test('renders headContent with CSP nonce injection in Node', () {
      // Create a style element without nonce
      // It should pick up the nonce from the zone set by renderPage
      final styleNode = Element(
        'style',
        children: [Text('body { color: blue; }')],
      );

      final html = renderPage(
        title: 'Nonce Page',
        content: '<div>Content</div>',
        headContent: styleNode,
        nonce: 'my-nonce-123',
      );

      // Check if the nonce was injected into the style tag
      expect(html, contains('<style nonce="my-nonce-123">'));
      expect(html, contains('body { color: blue; }'));
    });

    test('renders metaTags', () {
      final html = renderPage(
        title: 'Meta Page',
        content: '<div>Content</div>',
        metaTags: [
          '<meta property="og:title" content="My Page">',
          '<meta property="og:type" content="website">',
        ],
      );

      expect(html, contains('<meta property="og:title" content="My Page">'));
      expect(html, contains('<meta property="og:type" content="website">'));
    });
  });

  group('renderPageWithOptions', () {
    test('renders correctly using PageOptions', () {
      final options = PageOptions(
        title: 'Options Page',
        content: '<div>Content</div>',
        scriptName: 'main.js',
        additionalScripts: ['extra.js'],
        stylesheets: ['style.css'],
        lang: 'es',
        charset: 'UTF-16',
        viewport: 'width=100',
        metaTags: ['<meta name="test" content="value">'],
        nonce: 'nonce-abc',
      );

      final html = renderPageWithOptions(options);

      expect(html, contains('<title>Options Page</title>'));
      expect(html, contains('<html lang="es">'));
      expect(html, contains('<meta charset="UTF-16">'));
      expect(html, contains('<meta name="viewport" content="width=100">'));
      expect(
        html,
        contains('<script defer src="/main.js" nonce="nonce-abc"></script>'),
      );
      expect(
        html,
        contains('<script defer src="extra.js" nonce="nonce-abc"></script>'),
      );
      expect(html, contains('<link rel="stylesheet" href="style.css">'));
      expect(html, contains('<meta name="test" content="value">'));
      expect(html, contains('<div>Content</div>'));
    });
  });
}
