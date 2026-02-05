import 'dart:async';
import 'dart:convert';

/// Base class for all HTML nodes.
abstract class VNode {
  /// Renders the node to an HTML string.
  String toHtml();

  @override
  String toString() => toHtml();
}

/// A text node containing a string value.
/// The content is automatically escaped when rendered.
class Text extends VNode {
  final String text;

  Text(this.text);

  @override
  String toHtml() => const HtmlEscape().convert(text);
}

/// A raw HTML node.
/// The content is rendered exactly as provided, without escaping.
/// Use with caution.
class RawHtml extends VNode {
  final String html;

  RawHtml(this.html);

  @override
  String toHtml() => html;
}

/// An HTML element with a tag, attributes, and children.
class Element extends VNode {
  final String tag;
  final Map<String, dynamic> attributes;
  final Map<String, Function> events;
  final List<VNode> children;
  final bool selfClosing;

  Element(
    this.tag, {
    this.attributes = const {},
    this.events = const {},
    this.children = const [],
    this.selfClosing = false,
  });

  @override
  String toHtml() {
    final buffer = StringBuffer();
    buffer.write('<$tag');

    attributes.forEach((key, value) {
      if (value == null || value == false) return;
      if (value == true) {
        buffer.write(' $key');
      } else {
        buffer.write(
          ' $key="${const HtmlEscape(HtmlEscapeMode.attribute).convert(value.toString())}"',
        );
      }
    });

    // Auto-inject nonce for style and script tags if available in Zone
    if ((tag == 'style' || tag == 'script') &&
        !attributes.containsKey('nonce')) {
      final nonce = Zone.current['spark.cspNonce'];
      if (nonce != null && nonce is String && nonce.isNotEmpty) {
        buffer.write(' nonce="$nonce"');
      }
    }

    if (selfClosing && children.isEmpty) {
      buffer.write(' />');
      return buffer.toString();
    }

    buffer.write('>');

    for (final child in children) {
      buffer.write(child.toHtml());
    }

    buffer.write('</$tag>');
    return buffer.toString();
  }
}
