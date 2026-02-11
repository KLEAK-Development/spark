/// Browser implementations of DOM collection types.
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../core.dart';
import '../collections.dart';
import 'dom.dart';

// ---------------------------------------------------------------------------
// NodeList
// ---------------------------------------------------------------------------

class BrowserNodeList implements NodeList {
  final web.NodeList _native;
  BrowserNodeList(this._native);

  @override
  int get length => _native.length;

  @override
  Node? item(int index) {
    final node = _native.item(index);
    return node != null ? wrapNode(node) : null;
  }
}

// ---------------------------------------------------------------------------
// DOMTokenList
// ---------------------------------------------------------------------------

class BrowserDOMTokenList implements DOMTokenList {
  final web.DOMTokenList _native;
  BrowserDOMTokenList(this._native);

  @override
  int get length => _native.length;
  @override
  String? item(int index) => _native.item(index);
  @override
  bool contains(String token) => _native.contains(token);
  @override
  void add(String token) => _native.add(token);
  @override
  void remove(String token) => _native.remove(token);
  @override
  bool toggle(String token, [bool? force]) {
    if (force != null) return _native.toggle(token, force);
    return _native.toggle(token);
  }

  @override
  void replace(String oldToken, String newToken) =>
      _native.replace(oldToken, newToken);
}

// ---------------------------------------------------------------------------
// NamedNodeMap
// ---------------------------------------------------------------------------

class BrowserNamedNodeMap implements NamedNodeMap {
  final web.NamedNodeMap _native;
  BrowserNamedNodeMap(this._native);

  @override
  int get length => _native.length;
  @override
  Attr? item(int index) {
    final attr = _native.item(index);
    return attr != null ? BrowserAttr(attr) : null;
  }

  @override
  Attr? getNamedItem(String name) {
    final attr = _native.getNamedItem(name);
    return attr != null ? BrowserAttr(attr) : null;
  }

  @override
  Attr? removeNamedItem(String name) {
    final attr = _native.removeNamedItem(name);
    return BrowserAttr(attr);
  }
}

class BrowserAttr implements Attr {
  final web.Attr _native;
  BrowserAttr(this._native);

  @override
  String get name => _native.name;
  @override
  String get value => _native.value;
  @override
  set value(String val) => _native.value = val;
}
