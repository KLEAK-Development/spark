import 'package:test/test.dart';
import 'package:spark_framework/src/server/render_page.dart';
import 'package:spark_framework/src/server/static_handler.dart';
import 'package:spark_framework/src/html/dsl.dart';

void main() {
  group('renderPage', () {
    test('renders a complete HTML document', () {
      final html = renderPage(title: 'Test Page', content: '<h1>Hello</h1>');
      expect(html, startsWith('<!DOCTYPE html>'));
      expect(html, contains('<html lang="en">'));
      expect(html, contains('<title>Test Page</title>'));
      expect(html, contains('<h1>Hello</h1>'));
    });

    test('escapes title', () {
      final html = renderPage(title: '<script>alert(1)</script>', content: '');
      expect(html, contains('&lt;script&gt;alert(1)&lt;&#47;script&gt;'));
      expect(html, isNot(contains('<script>alert(1)</script>')));
    });

    test('includes script tags when scriptName is provided', () {
      final html = renderPage(
        title: 'Script Test',
        content: '',
        scriptName: 'main.dart.js',
      );
      expect(html, contains('<script defer src="/main.dart.js"></script>'));
    });

    test('includes additional scripts', () {
      final html = renderPage(
        title: 'Scripts',
        content: '',
        additionalScripts: ['foo.js', 'bar.js'],
      );
      expect(html, contains('<script defer src="foo.js"></script>'));
      expect(html, contains('<script defer src="bar.js"></script>'));
    });

    test('includes stylesheets', () {
      final html = renderPage(
        title: 'Styles',
        content: '',
        stylesheets: ['style.css'],
      );
      expect(html, contains('<link rel="stylesheet" href="style.css">'));
    });

    test('renders inline styles', () {
      final html = renderPage(
        title: 'Inline',
        content: '',
        inlineStyles: 'body { color: red; }',
      );
      expect(html, contains('<style>'));
      expect(html, contains('body { color: red; }'));
    });

    test('renders head content', () {
      final html = renderPage(
        title: 'Head',
        content: '',
        headContent: [
          meta(attributes: {'name': 'description', 'content': 'desc'}),
        ],
      );
      expect(html, contains('<meta name="description" content="desc" />'));
    });
  });

  group('StaticHandlerConfig', () {
    test('defaults are sane', () {
      const config = StaticHandlerConfig(path: 'web');
      expect(config.enableCaching, isTrue);
      expect(config.maxAge, equals(86400));
      expect(config.defaultFile, equals('index.html'));
    });
  });
}
