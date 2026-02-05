/// HTML page rendering utilities for server-side rendering.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../style/style.dart';
import '../html/node.dart';

/// Configuration options for page rendering.
class PageOptions {
  /// The page title displayed in the browser tab.
  final String title;

  /// The main body content (rendered components).
  final String content;

  /// The JavaScript file to load for hydration (e.g., 'home.dart.js').
  final String? scriptName;

  /// Additional scripts to load.
  final List<String> additionalScripts;

  /// Additional stylesheets to load.
  final List<String> stylesheets;

  /// Inline CSS to include in the head.
  ///
  /// Can be a [String] or a [Stylesheet].
  final Object? inlineStyles;

  /// Additional content for the head section.
  ///
  /// Can be a [String], [VNode], or [List<dynamic>].
  final Object? headContent;

  /// The language attribute for the HTML element.
  final String lang;

  /// The charset meta tag value.
  final String charset;

  /// The viewport meta tag content.
  final String viewport;

  /// Additional meta tags as HTML strings.
  final List<String> metaTags;

  /// The nonce for Content-Security-Policy.
  final String? nonce;

  /// Creates page options.
  const PageOptions({
    required this.title,
    required this.content,
    this.scriptName,
    this.additionalScripts = const [],
    this.stylesheets = const [],
    this.inlineStyles,
    this.headContent,
    this.lang = 'en',
    this.charset = 'UTF-8',
    this.viewport = 'width=device-width, initial-scale=1',
    this.metaTags = const [],
    this.nonce,
  });
}

/// Renders a complete HTML page with the given options.
///
/// This function generates a full HTML document with proper structure
/// for server-side rendering with Declarative Shadow DOM support.
///
/// ## Example
///
/// ```dart
/// final html = renderPage(
///   title: 'Home',
///   content: Counter(start: 100).render(),
///   scriptName: 'home.dart.js',
/// );
/// ```
String renderPage({
  required String title,
  required String content,
  String? scriptName,
  List<String> additionalScripts = const [],
  List<String> stylesheets = const [],
  Object? inlineStyles,
  Object? headContent,
  String lang = 'en',
  String charset = 'UTF-8',
  String viewport = 'width=device-width, initial-scale=1',
  List<String> metaTags = const [],
  String? nonce,
}) {
  final buffer = StringBuffer();

  // Escape user inputs to prevent XSS
  final safeTitle = _escape(title);
  final safeLang = _escape(lang);
  final safeCharset = _escape(charset);
  final safeViewport = _escape(viewport);

  buffer.writeln('<!DOCTYPE html>');
  buffer.writeln('<html lang="$safeLang">');
  buffer.writeln('<head>');
  buffer.writeln('  <meta charset="$safeCharset">');
  buffer.writeln('  <meta name="viewport" content="$safeViewport">');

  // Additional meta tags
  for (final meta in metaTags) {
    buffer.writeln('  $meta');
  }

  buffer.writeln('  <title>$safeTitle</title>');

  // Stylesheets
  for (final stylesheet in stylesheets) {
    buffer.writeln('  <link rel="stylesheet" href="${_escape(stylesheet)}">');
  }

  // Inline styles
  String? stylesStr;
  if (inlineStyles is Stylesheet) {
    stylesStr = inlineStyles.toCss();
  } else if (inlineStyles is String) {
    stylesStr = inlineStyles;
  }

  if (stylesStr != null && stylesStr.isNotEmpty) {
    buffer.writeln(
      '  <style${nonce != null && nonce.isNotEmpty ? ' nonce="$nonce"' : ''}>',
    );
    buffer.writeln(stylesStr);
    buffer.writeln('  </style>');
  } else {
    // Default minimal styles
    buffer.writeln(
      '  <style${nonce != null && nonce.isNotEmpty ? ' nonce="$nonce"' : ''}>',
    );
    buffer.writeln('    body {');
    buffer.writeln(
      '      font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;',
    );
    buffer.writeln('      margin: 0;');
    buffer.writeln('      padding: 20px;');
    buffer.writeln('      line-height: 1.5;');
    buffer.writeln('    }');
    buffer.writeln('  </style>');
  }

  // Additional head content
  if (headContent != null) {
    runZoned(() {
      if (headContent is String && headContent.isNotEmpty) {
        buffer.writeln(headContent);
      } else if (headContent is VNode) {
        buffer.writeln(headContent.toHtml());
      } else if (headContent is List) {
        for (final item in headContent) {
          if (item is VNode) {
            buffer.writeln(item.toHtml());
          } else if (item != null) {
            buffer.writeln(item.toString());
          }
        }
      }
    }, zoneValues: {'spark.cspNonce': ?nonce});
  }

  // Main script (deferred to allow HTML to render first)
  if (scriptName != null && scriptName.isNotEmpty) {
    buffer.writeln(
      '  <script defer src="/${_escape(scriptName)}"${nonce != null && nonce.isNotEmpty ? ' nonce="$nonce"' : ''}></script>',
    );
  }

  // Additional scripts
  for (final script in additionalScripts) {
    buffer.writeln(
      '  <script defer src="${_escape(script)}"${nonce != null && nonce.isNotEmpty ? ' nonce="$nonce"' : ''}></script>',
    );
  }

  // Live Reload Script (Injected in Dev Mode)
  // We avoid importing dart:io directly to keep this file platform-agnostic if possible,
  // but checking Platform.environment requires dart:io.
  // Since this is 'server/render_page.dart', dart:io is expected.
  // However, to be safe and clean, we can look for a global override or just use Platform.
  // implementation:
  _injectLiveReload(buffer, nonce);

  buffer.writeln('</head>');
  buffer.writeln('<body>');
  buffer.writeln(content);
  buffer.writeln('</body>');
  buffer.writeln('</html>');

  return buffer.toString();
}

final _escaper = HtmlEscape();

String _escape(String text) {
  return _escaper.convert(text);
}

/// Renders a page using [PageOptions] configuration.
///
/// This is an alternative to [renderPage] that uses a configuration object
/// for more complex page setups.
String renderPageWithOptions(PageOptions options) {
  return renderPage(
    title: options.title,
    content: options.content,
    scriptName: options.scriptName,
    additionalScripts: options.additionalScripts,
    stylesheets: options.stylesheets,
    inlineStyles: options.inlineStyles,
    headContent: options.headContent,
    lang: options.lang,
    metaTags: options.metaTags,
    nonce: options.nonce,
  );
}

void _injectLiveReload(StringBuffer buffer, [String? nonce]) {
  try {
    final portStr = Platform.environment['SPARK_DEV_RELOAD_PORT'];
    if (portStr != null) {
      buffer.writeln('''
  <script${nonce != null && nonce.isNotEmpty ? ' nonce="$nonce"' : ''}>
    (function() {
      const socket = new WebSocket('ws://localhost:$portStr');
      socket.addEventListener('message', function (event) {
        if (event.data === 'reload') {
          window.location.reload();
        }
      });
      socket.addEventListener('close', function () {
         console.log('[Spark] Live Reload Disconnected');
      });
    })();
  </script>
''');
    }
  } catch (_) {
    // Ignore platform errors
  }
}
