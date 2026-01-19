import 'dart:convert';

/// Base class for all HTML nodes.
abstract class Node {
  /// Renders the node to an HTML string.
  String toHtml();

  @override
  String toString() => toHtml();
}

/// A text node containing a string value.
/// The content is automatically escaped when rendered.
class Text extends Node {
  final String text;

  Text(this.text);

  @override
  String toHtml() => const HtmlEscape().convert(text);
}

/// A raw HTML node.
/// The content is rendered exactly as provided, without escaping.
/// Use with caution.
class RawHtml extends Node {
  final String html;

  RawHtml(this.html);

  @override
  String toHtml() => html;
}

/// An HTML element with a tag, attributes, and children.
class Element extends Node {
  final String tag;
  final Map<String, dynamic> attributes;
  final Map<String, Function> events;
  final List<Node> children;
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
