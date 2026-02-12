/// Server-side implementations of Window and related types.
///
/// Provides Dart-native fallbacks where possible (e.g., Storage backed by a
/// Map, Console backed by print, Crypto via dart:math).
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../core.dart';
import '../dom.dart' as iface;
import '../window.dart' as iface;
import 'dom.dart';

// ---------------------------------------------------------------------------
// Window
// ---------------------------------------------------------------------------

class ServerWindow extends ServerEventTarget implements iface.Window {
  final ServerDocument _document = ServerDocument();
  final ServerConsole _console = ServerConsole();
  final ServerNavigator _navigator = ServerNavigator();
  final ServerStorage _localStorage = ServerStorage();
  final ServerStorage _sessionStorage = ServerStorage();
  final ServerLocation _location = ServerLocation();
  final ServerHistory _history = ServerHistory();
  final ServerCrypto _crypto = ServerCrypto();
  final ServerPerformance _performance = ServerPerformance();
  final ServerCustomElementRegistry _customElements =
      ServerCustomElementRegistry();

  @override
  iface.Document get document => _document;
  @override
  iface.Console get console => _console;
  @override
  iface.Navigator get navigator => _navigator;
  @override
  iface.Storage get localStorage => _localStorage;
  @override
  iface.Storage get sessionStorage => _sessionStorage;
  @override
  iface.Location get location => _location;
  @override
  iface.History get history => _history;
  @override
  iface.Crypto get crypto => _crypto;
  @override
  iface.Performance get performance => _performance;
  @override
  iface.CustomElementRegistry get customElements => _customElements;

  @override
  void alert([String? message]) {}
  @override
  bool confirm([String? message]) => false;
  @override
  String? prompt([String? message, String? defaultValue]) => defaultValue;

  @override
  int setTimeout(void Function() callback, [int delay = 0]) {
    Timer(Duration(milliseconds: delay), callback);
    return 0;
  }

  @override
  void clearTimeout(int handle) {}

  @override
  int setInterval(void Function() callback, [int delay = 0]) {
    Timer.periodic(Duration(milliseconds: delay), (_) => callback());
    return 0;
  }

  @override
  void clearInterval(int handle) {}

  @override
  int requestAnimationFrame(void Function(num) callback) {
    Timer(const Duration(milliseconds: 16), () => callback(_performance.now()));
    return 0;
  }

  @override
  void cancelAnimationFrame(int handle) {}

  @override
  String btoa(String data) => base64Encode(utf8.encode(data));

  @override
  String atob(String encodedData) => utf8.decode(base64Decode(encodedData));
}

// ---------------------------------------------------------------------------
// Storage (backed by a Map on server)
// ---------------------------------------------------------------------------

class ServerStorage implements iface.Storage {
  final Map<String, String> _store = {};

  @override
  int get length => _store.length;
  @override
  String? key(int index) {
    if (index < 0 || index >= _store.length) return null;
    return _store.keys.elementAt(index);
  }

  @override
  String? getItem(String key) => _store[key];
  @override
  void setItem(String key, String value) => _store[key] = value;
  @override
  void removeItem(String key) => _store.remove(key);
  @override
  void clear() => _store.clear();
}

// ---------------------------------------------------------------------------
// Location
// ---------------------------------------------------------------------------

class ServerLocation implements iface.Location {
  @override
  String get href => '';
  @override
  set href(String value) {}
  @override
  String get protocol => '';
  @override
  String get host => '';
  @override
  String get hostname => '';
  @override
  String get port => '';
  @override
  String get pathname => '';
  @override
  String get search => '';
  @override
  String get hash => '';
  @override
  String get origin => '';
  @override
  void assign(String url) {}
  @override
  void replace(String url) {}
  @override
  void reload() {}
}

// ---------------------------------------------------------------------------
// History
// ---------------------------------------------------------------------------

class ServerHistory implements iface.History {
  @override
  int get length => 0;
  @override
  Object? get state => null;
  @override
  void pushState(Object? data, String title, [String? url]) {}
  @override
  void replaceState(Object? data, String title, [String? url]) {}
  @override
  void back() {}
  @override
  void forward() {}
  @override
  void go([int delta = 0]) {}
}

// ---------------------------------------------------------------------------
// Navigator
// ---------------------------------------------------------------------------

class ServerNavigator implements iface.Navigator {
  @override
  String get userAgent => 'Spark Server';
  @override
  String get language => 'en-US';
  @override
  List<String> get languages => const ['en-US'];
  @override
  bool get onLine => true;
  @override
  iface.Clipboard get clipboard => ServerClipboard();
}

// ---------------------------------------------------------------------------
// Console (delegates to print)
// ---------------------------------------------------------------------------

class ServerConsole implements iface.Console {
  @override
  void log(Object? message, [List<Object?>? args]) {}
  @override
  void warn(Object? message, [List<Object?>? args]) {}
  @override
  void error(Object? message, [List<Object?>? args]) {}
  @override
  void info(Object? message, [List<Object?>? args]) {}
  @override
  void debug(Object? message, [List<Object?>? args]) {}
}

// ---------------------------------------------------------------------------
// Crypto
// ---------------------------------------------------------------------------

class ServerCrypto implements iface.Crypto {
  @override
  String randomUUID() {
    final rnd = Random();
    String hex(int n) =>
        List.generate(n, (_) => rnd.nextInt(16).toRadixString(16)).join();
    return '${hex(8)}-${hex(4)}-4${hex(3)}-a${hex(3)}-${hex(12)}';
  }
}

// ---------------------------------------------------------------------------
// Performance
// ---------------------------------------------------------------------------

class ServerPerformance implements iface.Performance {
  final Stopwatch _stopwatch = Stopwatch()..start();
  @override
  double now() => _stopwatch.elapsedMicroseconds / 1000.0;
}

// ---------------------------------------------------------------------------
// CustomElementRegistry
// ---------------------------------------------------------------------------

class ServerCustomElementRegistry implements iface.CustomElementRegistry {
  @override
  void define(String name, Object constructor,
      [iface.ElementDefinitionOptions? options]) {}
  @override
  Object? get(String name) => null;
  @override
  void upgrade(Node root) {}
  @override
  Future<void> whenDefined(String name) async {}
}

// ---------------------------------------------------------------------------
// Clipboard (no-op on server)
// ---------------------------------------------------------------------------

class ServerClipboard extends ServerEventTarget implements iface.Clipboard {
  String _text = '';

  @override
  Future<String> readText() async => _text;

  @override
  Future<void> writeText(String data) async {
    _text = data;
  }
}
