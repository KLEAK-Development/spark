import 'package:spark_framework/src/server/render_page.dart';
import 'package:test/test.dart';

void main() {
  group('renderPage', () {
    test('injects nonce into script tag', () {
      final html = renderPage(
        title: 'Test Page',
        content: '<div>Hello</div>',
        scriptName: 'main.dart.js',
        nonce: 'test-nonce-123',
      );

      expect(
        html,
        contains(
          '<script defer src="/main.dart.js" nonce="test-nonce-123"></script>',
        ),
      );
    });

    test('injects nonce into inline styles', () {
      final html = renderPage(
        title: 'Test Page',
        content: '<div>Hello</div>',
        inlineStyles: 'body { color: red; }',
        nonce: 'test-nonce-123',
      );

      expect(html, contains('<style nonce="test-nonce-123">'));
      expect(html, contains('body { color: red; }'));
    });

    test('injects nonce into additional scripts', () {
      final html = renderPage(
        title: 'Test Page',
        content: '<div>Hello</div>',
        additionalScripts: ['other.js'],
        nonce: 'test-nonce-123',
      );

      expect(
        html,
        contains(
          '<script defer src="other.js" nonce="test-nonce-123"></script>',
        ),
      );
    });

    test('ignores empty nonce string', () {
      final html = renderPage(
        title: 'Test Page',
        content: '<div>Hello</div>',
        scriptName: 'main.dart.js',
        nonce: '',
      );

      expect(html, contains('<script defer src="/main.dart.js"></script>'));
      expect(html, isNot(contains('nonce=""')));
    });
  });
}
