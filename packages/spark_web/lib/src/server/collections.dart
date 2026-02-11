/// Server-side implementations of DOM collection types.
library;

import '../core.dart';
import '../collections.dart';

class ServerNodeList implements NodeList {
  final List<Node> _items;
  ServerNodeList([List<Node>? items]) : _items = items ?? const [];
  @override
  int get length => _items.length;
  @override
  Node? item(int index) =>
      (index >= 0 && index < _items.length) ? _items[index] : null;
}

class ServerDOMTokenList implements DOMTokenList {
  @override
  int get length => 0;
  @override
  String? item(int index) => null;
  @override
  bool contains(String token) => false;
  @override
  void add(String token) {}
  @override
  void remove(String token) {}
  @override
  bool toggle(String token, [bool? force]) => force ?? false;
  @override
  void replace(String oldToken, String newToken) {}
}

class ServerNamedNodeMap implements NamedNodeMap {
  @override
  int get length => 0;
  @override
  Attr? item(int index) => null;
  @override
  Attr? getNamedItem(String name) => null;
  @override
  Attr? removeNamedItem(String name) => null;
}
