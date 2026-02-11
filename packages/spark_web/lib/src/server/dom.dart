/// Server-side implementations of DOM types.
///
/// These are no-ops or return sensible defaults, allowing component code
/// to compile and run on the Dart VM without crashing.
library;

import '../core.dart';
import '../dom.dart' as iface;
import '../collections.dart';
import '../css.dart';
import 'collections.dart';
import 'css.dart';

// ---------------------------------------------------------------------------
// EventTarget
// ---------------------------------------------------------------------------

class ServerEventTarget implements EventTarget {
  @override
  void addEventListener(String type, EventListener? callback) {}
  @override
  void removeEventListener(String type, EventListener? callback) {}
  @override
  bool dispatchEvent(Event event) => false;
  @override
  dynamic get raw => null;
}

// ---------------------------------------------------------------------------
// Node
// ---------------------------------------------------------------------------

class ServerNode extends ServerEventTarget implements Node {
  @override
  int get nodeType => 0;
  @override
  String get nodeName => '';
  @override
  Node? get parentNode => null;
  @override
  Node? get parentElement => null;
  @override
  NodeList get childNodes => ServerNodeList();
  @override
  Node? get firstChild => null;
  @override
  Node? get lastChild => null;
  @override
  Node? get nextSibling => null;
  @override
  Node? get previousSibling => null;
  @override
  String? get textContent => '';
  @override
  set textContent(String? value) {}
  @override
  bool get isConnected => false;
  @override
  Node appendChild(Node child) => child;
  @override
  Node removeChild(Node child) => child;
  @override
  Node insertBefore(Node newNode, Node? referenceNode) => newNode;
  @override
  Node replaceChild(Node newChild, Node oldChild) => oldChild;
  @override
  Node cloneNode([bool deep = false]) => this;
  @override
  bool contains(Node? other) => false;
  @override
  bool hasChildNodes() => false;
}

// ---------------------------------------------------------------------------
// Element
// ---------------------------------------------------------------------------

class ServerElement extends ServerNode implements iface.Element {
  @override
  int get nodeType => Node.ELEMENT_NODE;
  @override
  String get tagName => '';
  @override
  String get id => '';
  @override
  set id(String value) {}
  @override
  String get className => '';
  @override
  set className(String value) {}
  @override
  String get innerHTML => '';
  @override
  set innerHTML(String value) {}
  @override
  String get outerHTML => '';
  @override
  String? get namespaceURI => null;
  @override
  NamedNodeMap get attributes => ServerNamedNodeMap();
  @override
  DOMTokenList get classList => ServerDOMTokenList();
  @override
  String? getAttribute(String name) => null;
  @override
  void setAttribute(String name, String value) {}
  @override
  void removeAttribute(String name) {}
  @override
  bool hasAttribute(String name) => false;
  @override
  iface.Element? querySelector(String selectors) => null;
  @override
  NodeList querySelectorAll(String selectors) => ServerNodeList();
  @override
  void remove() {}
  @override
  void append(Node node) {}
}

// ---------------------------------------------------------------------------
// HTMLElement
// ---------------------------------------------------------------------------

class ServerHTMLElement extends ServerElement implements iface.HTMLElement {
  @override
  String get innerText => '';
  @override
  set innerText(String value) {}
  @override
  bool get hidden => false;
  @override
  set hidden(bool value) {}
  @override
  String get title => '';
  @override
  set title(String value) {}
  @override
  CSSStyleDeclaration get style => ServerCSSStyleDeclaration();
  @override
  iface.ShadowRoot? get shadowRoot => null;
  @override
  iface.ShadowRoot attachShadow(iface.ShadowRootInit init) =>
      ServerShadowRoot();
}

// ---------------------------------------------------------------------------
// Specific HTMLElement subclasses
// ---------------------------------------------------------------------------

class ServerHTMLInputElement extends ServerHTMLElement
    implements iface.HTMLInputElement {
  @override
  String get value => '';
  @override
  set value(String val) {}
  @override
  String get type => '';
  @override
  set type(String val) {}
  @override
  String get placeholder => '';
  @override
  set placeholder(String val) {}
  @override
  bool get disabled => false;
  @override
  set disabled(bool val) {}
  @override
  bool get checked => false;
  @override
  set checked(bool val) {}
  @override
  String get name => '';
  @override
  set name(String val) {}
}

class ServerHTMLButtonElement extends ServerHTMLElement
    implements iface.HTMLButtonElement {
  @override
  bool get disabled => false;
  @override
  set disabled(bool val) {}
  @override
  String get type => '';
  @override
  set type(String val) {}
}

class ServerHTMLTextAreaElement extends ServerHTMLElement
    implements iface.HTMLTextAreaElement {
  @override
  String get value => '';
  @override
  set value(String val) {}
  @override
  String get placeholder => '';
  @override
  set placeholder(String val) {}
  @override
  bool get disabled => false;
  @override
  set disabled(bool val) {}
  @override
  int get rows => 0;
  @override
  set rows(int val) {}
  @override
  int get cols => 0;
  @override
  set cols(int val) {}
}

class ServerHTMLSelectElement extends ServerHTMLElement
    implements iface.HTMLSelectElement {
  @override
  String get value => '';
  @override
  set value(String val) {}
  @override
  int get selectedIndex => -1;
  @override
  set selectedIndex(int val) {}
  @override
  bool get disabled => false;
  @override
  set disabled(bool val) {}
}

class ServerHTMLOptionElement extends ServerHTMLElement
    implements iface.HTMLOptionElement {
  @override
  String get value => '';
  @override
  set value(String val) {}
  @override
  String get text => '';
  @override
  set text(String val) {}
  @override
  bool get selected => false;
  @override
  set selected(bool val) {}
}

class ServerHTMLAnchorElement extends ServerHTMLElement
    implements iface.HTMLAnchorElement {
  @override
  String get href => '';
  @override
  set href(String val) {}
  @override
  String get target => '';
  @override
  set target(String val) {}
}

class ServerHTMLImageElement extends ServerHTMLElement
    implements iface.HTMLImageElement {
  @override
  String get src => '';
  @override
  set src(String val) {}
  @override
  String get alt => '';
  @override
  set alt(String val) {}
  @override
  int get width => 0;
  @override
  set width(int val) {}
  @override
  int get height => 0;
  @override
  set height(int val) {}
}

class ServerHTMLFormElement extends ServerHTMLElement
    implements iface.HTMLFormElement {
  @override
  String get action => '';
  @override
  set action(String val) {}
  @override
  String get method => '';
  @override
  set method(String val) {}
  @override
  void submit() {}
  @override
  void reset() {}
  @override
  bool reportValidity() => true;
}

class ServerHTMLLabelElement extends ServerHTMLElement
    implements iface.HTMLLabelElement {
  @override
  String get htmlFor => '';
  @override
  set htmlFor(String val) {}
}

class ServerHTMLTemplateElement extends ServerHTMLElement
    implements iface.HTMLTemplateElement {
  @override
  iface.DocumentFragment get content => ServerDocumentFragment();
}

// ---------------------------------------------------------------------------
// DocumentFragment
// ---------------------------------------------------------------------------

class ServerDocumentFragment extends ServerNode
    implements iface.DocumentFragment {
  @override
  int get nodeType => Node.DOCUMENT_FRAGMENT_NODE;
  @override
  iface.Element? querySelector(String selectors) => null;
  @override
  NodeList querySelectorAll(String selectors) => ServerNodeList();
}

// ---------------------------------------------------------------------------
// ShadowRoot
// ---------------------------------------------------------------------------

class ServerShadowRoot extends ServerDocumentFragment
    implements iface.ShadowRoot {
  @override
  iface.Element get host => ServerElement();
  @override
  String get mode => 'open';
  @override
  iface.Element? get firstElementChild => null;
  @override
  iface.Element? querySelector(String selectors) => null;
  @override
  NodeList querySelectorAll(String selectors) => ServerNodeList();
  @override
  List<CSSStyleSheet> get adoptedStyleSheets => [];
  @override
  set adoptedStyleSheets(List<CSSStyleSheet> sheets) {}
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

class ServerDocument extends ServerNode implements iface.Document {
  @override
  int get nodeType => Node.DOCUMENT_NODE;
  @override
  iface.Element? get documentElement => null;
  @override
  iface.HTMLElement? get body => null;
  @override
  iface.HTMLElement? get head => null;
  @override
  iface.Element createElement(String tagName) => ServerElement();
  @override
  iface.Element createElementNS(String? namespace, String qualifiedName) =>
      ServerElement();
  @override
  iface.Text createTextNode(String data) => ServerText(data);
  @override
  iface.Comment createComment(String data) => ServerComment(data);
  @override
  iface.DocumentFragment createDocumentFragment() =>
      ServerDocumentFragment();
  @override
  iface.Element? getElementById(String id) => null;
  @override
  iface.Element? querySelector(String selectors) => null;
  @override
  NodeList querySelectorAll(String selectors) => ServerNodeList();
}

// ---------------------------------------------------------------------------
// Text & Comment
// ---------------------------------------------------------------------------

class ServerText extends ServerNode implements iface.Text {
  String _data;
  ServerText(this._data);
  @override
  int get nodeType => Node.TEXT_NODE;
  @override
  String get data => _data;
  @override
  set data(String value) => _data = value;
  @override
  String get wholeText => _data;
  @override
  String? get textContent => _data;
  @override
  set textContent(String? value) => _data = value ?? '';
}

class ServerComment extends ServerNode implements iface.Comment {
  String _data;
  ServerComment(this._data);
  @override
  int get nodeType => Node.COMMENT_NODE;
  @override
  String get data => _data;
  @override
  set data(String value) => _data = value;
  @override
  String? get textContent => _data;
  @override
  set textContent(String? value) => _data = value ?? '';
}

// ---------------------------------------------------------------------------
// MutationObserver
// ---------------------------------------------------------------------------

class ServerMutationObserver implements MutationObserver {
  ServerMutationObserver(MutationCallback callback);
  @override
  void observe(Node target, [MutationObserverInit? options]) {}
  @override
  void disconnect() {}
  @override
  List<MutationRecord> takeRecords() => [];
}
