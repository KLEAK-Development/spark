/// DOM collection types matching the MDN Web API.
library;

// ---------------------------------------------------------------------------
// DOMTokenList
// ---------------------------------------------------------------------------

/// A set of space-separated tokens (e.g., CSS classes via [Element.classList]).
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList
abstract class DOMTokenList {
  int get length;
  String? item(int index);
  bool contains(String token);
  void add(String token);
  void remove(String token);
  bool toggle(String token, [bool? force]);
  void replace(String oldToken, String newToken);
}

// ---------------------------------------------------------------------------
// NamedNodeMap
// ---------------------------------------------------------------------------

/// A collection of [Attr] objects.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/NamedNodeMap
abstract class NamedNodeMap {
  int get length;
  Attr? item(int index);
  Attr? getNamedItem(String name);
  Attr? removeNamedItem(String name);
}

/// An attribute on an [Element].
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Attr
abstract class Attr {
  String get name;
  String get value;
  set value(String val);
}
