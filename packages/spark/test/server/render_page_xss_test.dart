import 'package:spark_framework/src/server/render_page.dart';
import 'package:test/test.dart';

void main() {
  group('renderPage XSS Protection', () {
    test('should escape HTML in title', () {
      final html = renderPage(
        title: 'Home</title><script>alert("XSS")</script>',
        content: '<div>Content</div>',
      );

      expect(
        html,
        contains(
          '<title>Home&lt;&#47;title&gt;&lt;script&gt;alert(&quot;XSS&quot;)&lt;&#47;script&gt;</title>',
        ),
      );
      expect(html, isNot(contains('<script>alert("XSS")</script>')));
    });

    test('should escape HTML in lang attribute', () {
      final html = renderPage(
        title: 'Home',
        content: '<div>Content</div>',
        lang: 'en"><script>alert("XSS")</script>',
      );

      expect(
        html,
        contains(
          'lang="en&quot;&gt;&lt;script&gt;alert(&quot;XSS&quot;)&lt;&#47;script&gt;"',
        ),
      );
    });

    test('should escape HTML in custom viewport', () {
      final html = renderPage(
        title: 'Home',
        content: '<div>Content</div>',
        viewport: 'width=device-width"><script>alert("XSS")</script>',
      );

      // Note: HtmlEscape() escapes / as &#47;
      expect(
        html,
        contains(
          'content="width=device-width&quot;&gt;&lt;script&gt;alert(&quot;XSS&quot;)&lt;&#47;script&gt;"',
        ),
      );
    });

    test('should escape HTML in scriptName', () {
      final html = renderPage(
        title: 'Home',
        content: '<div>Content</div>',
        scriptName: 'home.js"><script>alert(1)</script>',
      );

      expect(
        html,
        contains(
          'src="/home.js&quot;&gt;&lt;script&gt;alert(1)&lt;&#47;script&gt;"',
        ),
      );
    });

    test('should escape HTML in stylesheets', () {
      final html = renderPage(
        title: 'Home',
        content: '<div>Content</div>',
        stylesheets: ['style.css"><script>alert(1)</script>'],
      );

      expect(
        html,
        contains(
          'href="style.css&quot;&gt;&lt;script&gt;alert(1)&lt;&#47;script&gt;"',
        ),
      );
    });
  });
}
