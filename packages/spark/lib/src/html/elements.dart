/// Spark HTML DSL
///
/// This library provides a set of helper functions to create virtual DOM elements
/// using a declarative syntax. It mirrors standard HTML tags (e.g., [div], [span], [h1])
/// and attributes.
///
/// ## Example
///
/// ```dart
/// html.div(
///   ['Hello, world!'],
///   className: 'container',
///   onClick: (_) => print('Clicked!'),
/// )
/// ```
library;

import 'dart:async';

import 'node.dart';

/// Helper to convert a dynamic list of children into [Node]s.
List<Node> _normalizeChildren(List<dynamic>? children) {
  if (children == null) return [];
  final nodes = <Node>[];
  for (final child in children) {
    if (child == null) continue;
    if (child is Node) {
      nodes.add(child);
    } else if (child is String) {
      nodes.add(Text(child));
    } else if (child is List) {
      nodes.addAll(_normalizeChildren(child));
    } else {
      nodes.add(Text(child.toString()));
    }
  }
  return nodes;
}

/// Creates a generic virtual DOM element.
///
/// [tag] is the HTML tag name (e.g., 'div', 'custom-element').
///
/// - [id]: The element's ID.
/// - [className]: The CSS class(es).
/// - [attributes]: Additional HTML attributes.
/// - [events]: Event listeners (e.g., `{'click': (e) {}}`).
/// - [children]: The child nodes (can be [Node], [String], or list of them).
/// - [selfClosing]: Whether this tag is self-closing (void element).
///
/// Usually, you should use the specific tag helpers (like [div], [span]) instead
/// of calling this directly.
Element h(
  String tag, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
  Map<String, Function>? events,
  List<dynamic>?
  children, // Kept for internal flexibility, but helpers will enforce structure
  bool selfClosing = false,
}) {
  final attrs = <String, dynamic>{
    if (id != null) 'id': id,
    if (className != null) 'class': className,
    ...?attributes,
  };

  return Element(
    tag,
    attributes: attrs,
    events: events ?? const {},
    children: _normalizeChildren(children),
    selfClosing: selfClosing,
  );
}

/// Helper for container elements: (children, {attributes}).
/// Wraps single child in list if needed.
Element _el(
  String tag,
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
  Map<String, Function>? events,
}) {
  final List<dynamic> childList = children is List ? children : [children];
  return h(
    tag,
    id: id,
    className: className,
    attributes: attributes,
    events: events,
    children: childList,
  );
}

// --- Sectioning Root ---
Element html(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) =>
    _el('html', children, id: id, className: className, attributes: attributes);

Element body(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) =>
    _el('body', children, id: id, className: className, attributes: attributes);

// --- Metadata ---
Element head(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) =>
    _el('head', children, id: id, className: className, attributes: attributes);

Element title(dynamic children) => _el('title', children);

Element meta({
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => h(
  'meta',
  id: id,
  className: className,
  attributes: attributes,
  selfClosing: true,
);

Element link({
  String? id,
  String? className,
  String? rel,
  String? href,
  Map<String, dynamic>? attributes,
}) => h(
  'link',
  id: id,
  className: className,
  attributes: {'rel': rel, 'href': href, ...?attributes},
  selfClosing: true,
);

// --- Content Sectioning ---
Element article(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'article',
  children,
  id: id,
  className: className,
  attributes: attributes,
);

Element aside(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'aside',
  children,
  id: id,
  className: className,
  attributes: attributes,
);

Element footer(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'footer',
  children,
  id: id,
  className: className,
  attributes: attributes,
);

Element header(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'header',
  children,
  id: id,
  className: className,
  attributes: attributes,
);

Element h1(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('h1', children, id: id, className: className, attributes: attributes);

Element h2(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('h2', children, id: id, className: className, attributes: attributes);

Element h3(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('h3', children, id: id, className: className, attributes: attributes);

Element h4(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('h4', children, id: id, className: className, attributes: attributes);

Element h5(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('h5', children, id: id, className: className, attributes: attributes);

Element h6(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('h6', children, id: id, className: className, attributes: attributes);

Element main(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) =>
    _el('main', children, id: id, className: className, attributes: attributes);

Element nav(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) =>
    _el('nav', children, id: id, className: className, attributes: attributes);

Element section(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'section',
  children,
  id: id,
  className: className,
  attributes: attributes,
);

// --- Text Content ---
Element div(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
  Function? onClick,
  Function? onDoubleClick,
  Function? onMouseEnter,
  Function? onMouseLeave,
}) => _el(
  'div',
  children,
  id: id,
  className: className,
  attributes: attributes,
  events: {
    if (onClick != null) 'click': onClick,
    if (onDoubleClick != null) 'dblclick': onDoubleClick,
    if (onMouseEnter != null) 'mouseenter': onMouseEnter,
    if (onMouseLeave != null) 'mouseleave': onMouseLeave,
  },
);

Element p(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('p', children, id: id, className: className, attributes: attributes);

Element hr({String? id, String? className, Map<String, dynamic>? attributes}) =>
    h(
      'hr',
      id: id,
      className: className,
      attributes: attributes,
      selfClosing: true,
    );

Element pre(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) =>
    _el('pre', children, id: id, className: className, attributes: attributes);

Element blockquote(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'blockquote',
  children,
  id: id,
  className: className,
  attributes: attributes,
);

Element ol(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('ol', children, id: id, className: className, attributes: attributes);

Element ul(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('ul', children, id: id, className: className, attributes: attributes);

Element li(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('li', children, id: id, className: className, attributes: attributes);

// --- Inline Text Semantics ---
Element a(
  dynamic children, {
  String? href,
  String? target,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
  Function? onClick,
}) => _el(
  'a',
  children,
  id: id,
  className: className,
  attributes: {'href': href, 'target': target, ...?attributes},
  events: {if (onClick != null) 'click': onClick},
);

Element code(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) =>
    _el('code', children, id: id, className: className, attributes: attributes);

Element em(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('em', children, id: id, className: className, attributes: attributes);

Element i(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('i', children, id: id, className: className, attributes: attributes);

Element s(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('s', children, id: id, className: className, attributes: attributes);

Element span(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
  Function? onClick,
}) => _el(
  'span',
  children,
  id: id,
  className: className,
  attributes: attributes,
  events: {if (onClick != null) 'click': onClick},
);

Element small(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'small',
  children,
  id: id,
  className: className,
  attributes: attributes,
);

Element strong(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'strong',
  children,
  id: id,
  className: className,
  attributes: attributes,
);

Element b(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('b', children, id: id, className: className, attributes: attributes);

Element u(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el('u', children, id: id, className: className, attributes: attributes);

Element br() => h('br', selfClosing: true);

// --- Image and Multimedia ---
Element img({
  String? src,
  String? alt,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => h(
  'img',
  id: id,
  className: className,
  attributes: {'src': src, 'alt': alt, ...?attributes},
  selfClosing: true,
);

// --- Forms ---
Element button(
  dynamic children, {
  String? type,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
  Function? onClick,
}) => _el(
  'button',
  children,
  id: id,
  className: className,
  attributes: {'type': type, ...?attributes},
  events: {if (onClick != null) 'click': onClick},
);

Element form(
  dynamic children, {
  String? action,
  String? method,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'form',
  children,
  id: id,
  className: className,
  attributes: {'action': action, 'method': method, ...?attributes},
);

Element input<T>({
  String? type,
  String? name,
  T? value,
  String? placeholder,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
  FutureOr<void> Function(T)? onInput,
  Function? onChange,
  Function? onKeyDown,
  Function? onKeyUp,
}) => h(
  'input',
  id: id,
  className: className,
  attributes: {
    'type': type,
    'name': name,
    'value': value,
    'placeholder': placeholder,
    ...?attributes,
  },
  events: {
    if (onInput != null) 'input': onInput,
    if (onChange != null) 'change': onChange,
    if (onKeyDown != null) 'keydown': onKeyDown,
    if (onKeyUp != null) 'keyup': onKeyUp,
  },
  selfClosing: true,
);

Element label(
  dynamic children, {
  String? htmlFor,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'label',
  children,
  id: id,
  className: className,
  attributes: {'for': htmlFor, ...?attributes},
);

Element select(
  dynamic children, {
  String? name,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'select',
  children,
  id: id,
  className: className,
  attributes: {'name': name, ...?attributes},
);

Element option(
  dynamic children, {
  String? value,
  bool? selected,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'option',
  children,
  id: id,
  className: className,
  attributes: {'value': value, 'selected': selected, ...?attributes},
);

Element textarea(
  dynamic children, {
  String? name,
  String? rows,
  String? cols,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'textarea',
  children,
  id: id,
  className: className,
  attributes: {'name': name, 'rows': rows, 'cols': cols, ...?attributes},
);

// --- Scripting ---
Element script(
  dynamic children, {
  String? src,
  String? type,
  bool? async,
  bool? defer,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'script',
  children,
  id: id,
  className: className,
  attributes: {
    'src': src,
    'type': type,
    'async': async,
    'defer': defer,
    ...?attributes,
  },
);

// --- Web Components ---

/// Generic helper for custom elements.
Element element(
  String tag,
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => h(
  tag,
  id: id,
  className: className,
  attributes: attributes,
  children: children is List ? children : [children],
);

Element template(
  dynamic children, {
  String? shadowrootmode,
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'template',
  children,
  id: id,
  className: className,
  attributes: {'shadowrootmode': shadowrootmode, ...?attributes},
);

Element style(
  dynamic children, {
  String? id,
  String? className,
  Map<String, dynamic>? attributes,
}) => _el(
  'style',
  children,
  id: id,
  className: className,
  attributes: attributes,
);
