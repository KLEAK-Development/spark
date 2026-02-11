/// DOM Element types matching the MDN Web API.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Element
library;

import 'core.dart';
import 'collections.dart';
import 'css.dart';

// ---------------------------------------------------------------------------
// Element
// ---------------------------------------------------------------------------

/// Represents a DOM Element.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Element
abstract class Element implements Node {
  String get tagName;
  String get id;
  set id(String value);
  String get className;
  set className(String value);

  String get innerHTML;
  set innerHTML(String value);
  String get outerHTML;

  String? get namespaceURI;

  NamedNodeMap get attributes;
  DOMTokenList get classList;

  String? getAttribute(String name);
  void setAttribute(String name, String value);
  void removeAttribute(String name);
  bool hasAttribute(String name);

  Element? querySelector(String selectors);
  NodeList querySelectorAll(String selectors);

  void remove();
  void append(Node node);
}

// ---------------------------------------------------------------------------
// HTMLElement
// ---------------------------------------------------------------------------

/// Represents an HTML Element.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement
abstract class HTMLElement implements Element {
  String get innerText;
  set innerText(String value);
  bool get hidden;
  set hidden(bool value);
  String get title;
  set title(String value);

  CSSStyleDeclaration get style;
  ShadowRoot? get shadowRoot;

  ShadowRoot attachShadow(ShadowRootInit init);
}

/// Options for [HTMLElement.attachShadow].
class ShadowRootInit {
  final String mode;
  const ShadowRootInit({required this.mode});
}

// ---------------------------------------------------------------------------
// Specific HTMLElement subclasses
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLDivElement
abstract class HTMLDivElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLSpanElement
abstract class HTMLSpanElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLParagraphElement
abstract class HTMLParagraphElement implements HTMLElement {}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement
abstract class HTMLInputElement implements HTMLElement {
  String get value;
  set value(String val);
  String get type;
  set type(String val);
  String get placeholder;
  set placeholder(String val);
  bool get disabled;
  set disabled(bool val);
  bool get checked;
  set checked(bool val);
  String get name;
  set name(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLTextAreaElement
abstract class HTMLTextAreaElement implements HTMLElement {
  String get value;
  set value(String val);
  String get placeholder;
  set placeholder(String val);
  bool get disabled;
  set disabled(bool val);
  int get rows;
  set rows(int val);
  int get cols;
  set cols(int val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLButtonElement
abstract class HTMLButtonElement implements HTMLElement {
  bool get disabled;
  set disabled(bool val);
  String get type;
  set type(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLSelectElement
abstract class HTMLSelectElement implements HTMLElement {
  String get value;
  set value(String val);
  int get selectedIndex;
  set selectedIndex(int val);
  bool get disabled;
  set disabled(bool val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLOptionElement
abstract class HTMLOptionElement implements HTMLElement {
  String get value;
  set value(String val);
  String get text;
  set text(String val);
  bool get selected;
  set selected(bool val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLAnchorElement
abstract class HTMLAnchorElement implements HTMLElement {
  String get href;
  set href(String val);
  String get target;
  set target(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLImageElement
abstract class HTMLImageElement implements HTMLElement {
  String get src;
  set src(String val);
  String get alt;
  set alt(String val);
  int get width;
  set width(int val);
  int get height;
  set height(int val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement
abstract class HTMLFormElement implements HTMLElement {
  String get action;
  set action(String val);
  String get method;
  set method(String val);
  void submit();
  void reset();
  bool reportValidity();
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement
abstract class HTMLLabelElement implements HTMLElement {
  String get htmlFor;
  set htmlFor(String val);
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLTemplateElement
abstract class HTMLTemplateElement implements HTMLElement {
  DocumentFragment get content;
}

// ---------------------------------------------------------------------------
// DocumentFragment
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/DocumentFragment
abstract class DocumentFragment implements Node {
  Element? querySelector(String selectors);
  NodeList querySelectorAll(String selectors);
}

// ---------------------------------------------------------------------------
// ShadowRoot
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/ShadowRoot
abstract class ShadowRoot implements DocumentFragment {
  Element get host;
  String get mode;
  Element? get firstElementChild;

  @override
  Element? querySelector(String selectors);
  @override
  NodeList querySelectorAll(String selectors);

  List<CSSStyleSheet> get adoptedStyleSheets;
  set adoptedStyleSheets(List<CSSStyleSheet> sheets);
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/Document
abstract class Document implements Node {
  Element? get documentElement;
  HTMLElement? get body;
  HTMLElement? get head;

  Element createElement(String tagName);
  Element createElementNS(String? namespace, String qualifiedName);
  Text createTextNode(String data);
  Comment createComment(String data);
  DocumentFragment createDocumentFragment();

  Element? getElementById(String id);
  Element? querySelector(String selectors);
  NodeList querySelectorAll(String selectors);
}

// ---------------------------------------------------------------------------
// Text & Comment nodes
// ---------------------------------------------------------------------------

/// See: https://developer.mozilla.org/en-US/docs/Web/API/Text
abstract class Text implements Node {
  String get data;
  set data(String value);
  String get wholeText;
}

/// See: https://developer.mozilla.org/en-US/docs/Web/API/Comment
abstract class Comment implements Node {
  String get data;
  set data(String value);
}
