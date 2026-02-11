/// Window and related browser API types matching the MDN Web API.
library;

import 'core.dart';
import 'dom.dart';

// ---------------------------------------------------------------------------
// Window
// ---------------------------------------------------------------------------

/// The global window object.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Window
abstract class Window implements EventTarget {
  Document get document;
  Console get console;
  Navigator get navigator;
  Storage get localStorage;
  Storage get sessionStorage;
  Location get location;
  History get history;
  Crypto get crypto;
  Performance get performance;
  CustomElementRegistry get customElements;

  // Dialogs
  void alert([String? message]);
  bool confirm([String? message]);
  String? prompt([String? message, String? defaultValue]);

  // Timers
  int setTimeout(void Function() callback, [int delay = 0]);
  void clearTimeout(int handle);
  int setInterval(void Function() callback, [int delay = 0]);
  void clearInterval(int handle);

  // Animation
  int requestAnimationFrame(void Function(num highResTime) callback);
  void cancelAnimationFrame(int handle);

  // Encoding
  String btoa(String data);
  String atob(String encodedData);
}

// ---------------------------------------------------------------------------
// Storage
// ---------------------------------------------------------------------------

/// Provides access to session or local storage.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Storage
abstract class Storage {
  int get length;
  String? key(int index);
  String? getItem(String key);
  void setItem(String key, String value);
  void removeItem(String key);
  void clear();
}

// ---------------------------------------------------------------------------
// Location
// ---------------------------------------------------------------------------

/// Represents the URL of the current document.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Location
abstract class Location {
  String get href;
  set href(String value);
  String get protocol;
  String get host;
  String get hostname;
  String get port;
  String get pathname;
  String get search;
  String get hash;
  String get origin;

  void assign(String url);
  void replace(String url);
  void reload();
}

// ---------------------------------------------------------------------------
// History
// ---------------------------------------------------------------------------

/// Allows manipulation of the browser session history.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/History
abstract class History {
  int get length;
  Object? get state;

  void pushState(Object? data, String title, [String? url]);
  void replaceState(Object? data, String title, [String? url]);
  void back();
  void forward();
  void go([int delta = 0]);
}

// ---------------------------------------------------------------------------
// Navigator
// ---------------------------------------------------------------------------

/// Information about the user agent.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Navigator
abstract class Navigator {
  String get userAgent;
  String get language;
  List<String> get languages;
  bool get onLine;
  Clipboard get clipboard;
}

// ---------------------------------------------------------------------------
// Console
// ---------------------------------------------------------------------------

/// Provides access to the debugging console.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Console
abstract class Console {
  void log(Object? message, [List<Object?>? args]);
  void warn(Object? message, [List<Object?>? args]);
  void error(Object? message, [List<Object?>? args]);
  void info(Object? message, [List<Object?>? args]);
  void debug(Object? message, [List<Object?>? args]);
}

// ---------------------------------------------------------------------------
// Crypto
// ---------------------------------------------------------------------------

/// Provides access to cryptographic functions.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Crypto
abstract class Crypto {
  String randomUUID();
}

// ---------------------------------------------------------------------------
// Performance
// ---------------------------------------------------------------------------

/// Provides access to performance-related information.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Performance
abstract class Performance {
  double now();
}

// ---------------------------------------------------------------------------
// CustomElementRegistry
// ---------------------------------------------------------------------------

/// Registry for custom elements.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/CustomElementRegistry
abstract class CustomElementRegistry {
  void define(String name, Object constructor, [Object? options]);
  Object? get(String name);
  void upgrade(Node root);
  Future<void> whenDefined(String name);
}

// ---------------------------------------------------------------------------
// Clipboard
// ---------------------------------------------------------------------------

/// Provides read and write access to the system clipboard.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard
abstract class Clipboard implements EventTarget {
  /// Reads text from the system clipboard.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/readText
  Future<String> readText();

  /// Writes text to the system clipboard.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Clipboard/writeText
  Future<void> writeText(String data);
}
