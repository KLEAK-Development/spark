/// Stub classes for server-side rendering.
///
/// These classes mimic the browser DOM API so that component code can be
/// imported on the Dart VM without crashing. On the server, these stubs
/// are used; on the browser, the real `package:web` classes are used.
///
/// This file implementation uses a "Universal Stub" pattern where types
/// generally extend [JSAny] which implements [noSuchMethod]. This allows
/// code accessing new or missing Web APIs (like `window.crypto.randomUUID()`)
/// to run on the server without crashing (it just returns more stubs) and
/// without analysis errors (thanks to dynamic global variables).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

// =============================================================================
// Universal Stub
// =============================================================================

/// A base stub class that swallows all method calls and property accesses.
///
/// This allows server-side code to "call" any browser API without crashing.
/// It returns validation-safe defaults where possible or new stubs.
class JSAny {
  const JSAny();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // For getters, return a new JSAny stub so chains like .foo.bar.baz work.
    if (invocation.isGetter) {
      return const JSAny();
    }
    // For setters, just ignore.
    if (invocation.isSetter) {
      return null;
    }
    // For methods, return a new stub.
    return const JSAny();
  }

  /// Returns actual self for .toJS to support the extension property
  dynamic get toJS => this;

  // Useful to avoid "Instance of 'JSAny'" appearing in rendered HTML if a stub leaks.
  @override
  String toString() => '';
}

// =============================================================================
// Event Stubs
// =============================================================================

/// Stub for browser Event class.
class Event extends JSAny {
  Event(String type);
  void preventDefault() {}
}

/// Stub for browser MouseEvent class.
class MouseEvent extends Event {
  MouseEvent(super.type);
}

/// Stub for browser KeyboardEvent class.
class KeyboardEvent extends Event {
  KeyboardEvent(super.type);
}

// =============================================================================
// EventTarget Stub
// =============================================================================

/// Stub for browser EventTarget class.
class EventTarget extends JSAny {
  void addEventListener(String type, dynamic callback, [dynamic options]) {}
  void removeEventListener(String type, dynamic callback, [dynamic options]) {}
  bool dispatchEvent(Event event) => false;
}

/// Extension to mimic .toJS on functions (for stubs).
extension FunctionToJS on Function {
  dynamic get toJS => this;
}

/// Extension to mimic .toJS on strings (for stubs).
extension StringToJS on String {
  dynamic get toJS => this;
}

/// Extension to mimic .toJS on lists (for stubs).
extension ListToJS<T> on List<T> {
  dynamic get toJS => this;
}

// =============================================================================
// Node Stub
// =============================================================================

/// Stub for browser Node class.
class Node extends EventTarget {
  Node? get parentNode => null;
  Node? get firstChild => null;
  Node? get lastChild => null;
  Node? get nextSibling => null;
  Node? get previousSibling => null;
  String get textContent => '';
  set textContent(String value) {}
  Node appendChild(Node node) => node;
  Node removeChild(Node node) => node;
  Node insertBefore(Node node, Node? child) => node;
  Node replaceChild(Node node, Node oldChild) => node;
  Node cloneNode([bool deep = false]) => this;
  bool contains(Node? other) => false;
  bool get isConnected => false;
}

// =============================================================================
// Element Stubs
// =============================================================================

/// Stub for browser Element class.
class Element extends Node {
  String get tagName => '';
  String get id => '';
  set id(String value) {}
  String get className => '';
  set className(String value) {}
  String get innerHTML => '';
  set innerHTML(String value) {}
  String get outerHTML => '';
  set outerHTML(String value) {}

  String? getAttribute(String name) => null;
  void setAttribute(String name, String value) {}
  void removeAttribute(String name) {}
  bool hasAttribute(String name) => false;

  Element? querySelector(String selectors) => null;
  NodeList querySelectorAll(String selectors) => NodeList();

  void remove() {}
  void append(dynamic node) {}
}

// =============================================================================
// HTMLElement Stubs
// =============================================================================

/// Stub for browser HTMLElement class.
class HTMLElement extends Element {
  String get innerText => '';
  set innerText(String value) {}
  bool get hidden => false;
  set hidden(bool value) {}
  String get title => '';
  set title(String value) {}

  DOMTokenList get classList => DOMTokenList();
  dynamic get style => _StyleStub();

  /// The shadow root attached to this element (if any).
  ShadowRoot? get shadowRoot => null;

  /// Click event stream stub.
  Stream<MouseEvent> get onClick => const Stream.empty();
}

class _StyleStub extends JSAny {
  void setProperty(String property, String value) {}
  String getPropertyValue(String property) => '';
  set display(String value) {}
  String get display => '';
}

/// Stub for browser DOMTokenList class (used by classList).
class DOMTokenList extends JSAny {
  void add(String token) {}
  void remove(String token) {}
  bool contains(String token) => false;
  void toggle(String token, [bool? force]) {}
  void replace(String oldToken, String newToken) {}
  int get length => 0;
  String? item(int index) => null;
}

/// Stub for browser HTMLDivElement class.
class HTMLDivElement extends HTMLElement {}

/// Stub for browser HTMLSpanElement class.
class HTMLSpanElement extends HTMLElement {}

/// Stub for browser HTMLParagraphElement class.
class HTMLParagraphElement extends HTMLElement {}

/// Stub for browser HTMLButtonElement class.
class HTMLButtonElement extends HTMLElement {
  bool get disabled => false;
  set disabled(bool value) {}
  String get type => '';
  set type(String value) {}
}

/// Stub for browser HTMLInputElement class.
class HTMLInputElement extends HTMLElement {
  String get value => '';
  set value(String value) {}
  String get type => '';
  set type(String value) {}
  String get placeholder => '';
  set placeholder(String value) {}
  bool get disabled => false;
  set disabled(bool value) {}
  bool get checked => false;
  set checked(bool value) {}

  /// Input event stream stub.
  Stream<Event> get onInput => const Stream.empty();

  /// Change event stream stub.
  Stream<Event> get onChange => const Stream.empty();
}

/// Stub for browser HTMLTextAreaElement class.
class HTMLTextAreaElement extends HTMLElement {
  String get value => '';
  set value(String value) {}
  String get placeholder => '';
  set placeholder(String value) {}
  bool get disabled => false;
  set disabled(bool value) {}
  int get rows => 0;
  set rows(int value) {}
  int get cols => 0;
  set cols(int value) {}
}

/// Stub for browser HTMLSelectElement class.
class HTMLSelectElement extends HTMLElement {
  String get value => '';
  set value(String value) {}
  int get selectedIndex => -1;
  set selectedIndex(int value) {}
  bool get disabled => false;
  set disabled(bool value) {}
}

/// Stub for browser HTMLOptionElement class.
class HTMLOptionElement extends HTMLElement {
  String get value => '';
  set value(String value) {}
  String get text => '';
  set text(String value) {}
  bool get selected => false;
  set selected(bool value) {}
}

/// Stub for browser HTMLAnchorElement class.
class HTMLAnchorElement extends HTMLElement {
  String get href => '';
  set href(String value) {}
  String get target => '';
  set target(String value) {}
}

/// Stub for browser HTMLImageElement class.
class HTMLImageElement extends HTMLElement {
  String get src => '';
  set src(String value) {}
  String get alt => '';
  set alt(String value) {}
  int get width => 0;
  set width(int value) {}
  int get height => 0;
  set height(int value) {}
}

/// Stub for browser HTMLFormElement class.
class HTMLFormElement extends HTMLElement {
  String get action => '';
  set action(String value) {}
  String get method => '';
  set method(String value) {}
  void submit() {}
  void reset() {}
  bool reportValidity() => true;
}

/// Stub for browser HTMLLabelElement class.
class HTMLLabelElement extends HTMLElement {
  String get htmlFor => '';
  set htmlFor(String value) {}
}

/// Stub for browser HTMLTemplateElement class.
class HTMLTemplateElement extends HTMLElement {
  DocumentFragment get content => DocumentFragment();
}

// =============================================================================
// NodeList Stub
// =============================================================================

/// Stub for browser NodeList class.
class NodeList extends JSAny {
  final List<Node> _items = [];

  int get length => _items.length;

  Node? item(int index) {
    if (index < 0 || index >= _items.length) return null;
    return _items[index];
  }
}

// =============================================================================
// Document Stubs
// =============================================================================

/// Stub for browser DocumentFragment class.
class DocumentFragment extends Node {
  Element? querySelector(String selectors) => null;
  NodeList querySelectorAll(String selectors) => NodeList();
}

/// Stub for browser Document class.
class Document extends Node {
  Element? get documentElement => null;
  Element? get body => null;
  Element? get head => null;

  Element? getElementById(String id) => null;
  Element? querySelector(String selectors) => null;
  NodeList querySelectorAll(String selectors) => NodeList();

  Element createElement(String tagName) => Element();
  DocumentFragment createDocumentFragment() => DocumentFragment();
}

// =============================================================================
// ShadowRoot Stub
// =============================================================================

/// Stub for browser ShadowRoot class.
class ShadowRoot extends DocumentFragment {
  Element get host => Element();
  String get mode => 'open';
  Element? get firstElementChild => null;

  @override
  Element? querySelector(String selectors) => null;

  @override
  NodeList querySelectorAll(String selectors) => NodeList();
}

// =============================================================================
// Window Stub
// =============================================================================

/// Stub for browser Window class.
class Window extends EventTarget {
  Document get document => Document();
  final Console console = Console();
  final Crypto crypto = Crypto();
  final Performance performance = Performance();
  final Navigator navigator = Navigator();

  // Storage stubs backed by a Map
  final StorageStub _localStorage = StorageStub();
  final StorageStub _sessionStorage = StorageStub();

  StorageStub get localStorage => _localStorage;
  StorageStub get sessionStorage => _sessionStorage;

  dynamic get location => _LocationStub();
  dynamic get history => _HistoryStub();

  void alert(String message) {
    print('Checking alert: $message');
  }

  bool confirm(String message) {
    print('Checking confirm: $message');
    return false;
  }

  String? prompt(String message, [String? defaultValue]) {
    print('Checking prompt: $message');
    return defaultValue;
  }

  // Timers
  int setTimeout(void Function() callback, int delay) {
    Timer(Duration(milliseconds: delay), callback);
    return 0; // Timer ID simulation (naive)
  }

  void clearTimeout(int handle) {
    // No-op in naive implementation
  }

  int setInterval(void Function() callback, int delay) {
    Timer.periodic(Duration(milliseconds: delay), (_) => callback());
    return 0;
  }

  void clearInterval(int handle) {
    // No-op
  }

  // Base64
  String btoa(String data) {
    return base64Encode(utf8.encode(data));
  }

  String atob(String encoded) {
    return utf8.decode(base64Decode(encoded));
  }

  // Animation Frame
  int requestAnimationFrame(void Function(num) callback) {
    // Execute on next event loop tick roughly
    Timer(const Duration(milliseconds: 16), () => callback(performance.now()));
    return 0;
  }

  void cancelAnimationFrame(int handle) {}
}

class Crypto extends JSAny {
  String randomUUID() {
    final rnd = Random();
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    // where x is 0-9a-f and y is 8-b
    String hex(int length) =>
        List.generate(length, (_) => rnd.nextInt(16).toRadixString(16)).join();

    return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
  }
}

class Console extends JSAny {
  void log(dynamic message, [List<dynamic>? args]) {}
  void warn(dynamic message, [List<dynamic>? args]) {}
  void error(dynamic message, [List<dynamic>? args]) {}
  void info(dynamic message, [List<dynamic>? args]) {}
  void debug(dynamic message, [List<dynamic>? args]) {}
}

class Performance extends JSAny {
  final Stopwatch _stopwatch = Stopwatch()..start();

  double now() {
    return _stopwatch.elapsedMicroseconds / 1000.0;
  }
}

class Navigator extends JSAny {
  String get userAgent => 'Spark';
  String get language => 'en-US';
  List<String> get languages => ['en-US'];
  bool get onLine => true;
}

class _LocationStub extends JSAny {
  String get href => '';
  set href(String value) {}
  String get pathname => '';
  String get search => '';
  String get hash => '';
  void reload() {}
  void assign(String url) {}
  void replace(String url) {}
}

class _HistoryStub extends JSAny {
  void pushState(dynamic data, String title, [String? url]) {}
  void replaceState(dynamic data, String title, [String? url]) {}
  void back() {}
  void forward() {}
  void go([int delta = 0]) {}
}

class StorageStub extends JSAny {
  String? getItem(String key) => null;
  void setItem(String key, String value) {}
  void removeItem(String key) {}
  void clear() {}
  int get length => 0;
  String? key(int index) => null;
}

// =============================================================================
// CustomElementRegistry Stub
// =============================================================================

/// Stub for browser CustomElementRegistry class.
class CustomElementRegistry extends JSAny {
  void define(String name, dynamic constructor, [dynamic options]) {}
  dynamic get(String name) => null;
  void upgrade(Node root) {}
  Future<void> whenDefined(String name) async {}
}

// =============================================================================
// Global Stubs
// =============================================================================
// Key: Declare these as `dynamic` or base `JSAny` type to allow property
// access (like window.crypto) to pass analyzer checks on the server.
// Since `Window` extends `JSAny` and has `noSuchMethod`, it's safe at runtime.
// By typing them as `dynamic` here, we silence strict strict typing checks.

/// Stub for the global window object.
final dynamic window = Window();

/// Stub for the global document object.
final dynamic document = Document();

/// Stub for the global customElements registry.
final dynamic customElements = CustomElementRegistry();

/// Stub for global console
final dynamic console = Console();

// =============================================================================
// MutationObserver Stubs
// =============================================================================

/// Stub for browser MutationObserver class.
class MutationObserver extends JSAny {
  MutationObserver(dynamic callback);
  void observe(Node target, [MutationObserverInit? options]) {}
  void disconnect() {}
  List<MutationRecord> takeRecords() => [];
}

/// Stub for browser MutationObserverInit class.
class MutationObserverInit extends JSAny {
  MutationObserverInit({
    bool? childList,
    bool? attributes,
    bool? characterData,
    bool? subtree,
    bool? attributeOldValue,
    bool? characterDataOldValue,
    dynamic attributeFilter,
  });
}

/// Stub for browser MutationRecord class.
class MutationRecord extends JSAny {
  String get type => '';
  String? get attributeName => null;
  String? get oldValue => null;
  Node? get target => null;
  NodeList get addedNodes => NodeList();
  NodeList get removedNodes => NodeList();
  Node? get previousSibling => null;
  Node? get nextSibling => null;
}
