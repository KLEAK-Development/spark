/// Browser implementations of Window and related types.
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../core.dart';
import '../dom.dart' as iface;
import '../window.dart' as iface;
import 'dom.dart';

// ---------------------------------------------------------------------------
// Window
// ---------------------------------------------------------------------------

class BrowserWindow extends BrowserEventTarget implements iface.Window {
  BrowserWindow(web.Window native) : super(native);

  web.Window get _win => raw as web.Window;

  @override
  iface.Document get document => BrowserDocument(_win.document);
  @override
  iface.Console get console => BrowserConsole(web.console);
  @override
  iface.Navigator get navigator => BrowserNavigator(_win.navigator);
  @override
  iface.Storage get localStorage => BrowserStorage(_win.localStorage);
  @override
  iface.Storage get sessionStorage => BrowserStorage(_win.sessionStorage);
  @override
  iface.Location get location => BrowserLocation(_win.location);
  @override
  iface.History get history => BrowserHistory(_win.history);
  @override
  iface.Crypto get crypto => BrowserCrypto(_win.crypto);
  @override
  iface.Performance get performance => BrowserPerformance(_win.performance);
  @override
  iface.CustomElementRegistry get customElements =>
      BrowserCustomElementRegistry(_win.customElements);

  @override
  void alert([String? message]) => _win.alert(message ?? '');
  @override
  bool confirm([String? message]) => _win.confirm(message ?? '');
  @override
  String? prompt([String? message, String? defaultValue]) =>
      _win.prompt(message ?? '', defaultValue ?? '');

  @override
  int setTimeout(void Function() callback, [int delay = 0]) =>
      _win.setTimeout(callback.toJS, delay.toJS);
  @override
  void clearTimeout(int handle) => _win.clearTimeout(handle);
  @override
  int setInterval(void Function() callback, [int delay = 0]) =>
      _win.setInterval(callback.toJS, delay.toJS);
  @override
  void clearInterval(int handle) => _win.clearInterval(handle);

  @override
  int requestAnimationFrame(void Function(num) callback) =>
      _win.requestAnimationFrame(((JSNumber time) {
        callback(time.toDartDouble);
      }).toJS);
  @override
  void cancelAnimationFrame(int handle) =>
      _win.cancelAnimationFrame(handle);

  @override
  String btoa(String data) => _win.btoa(data);
  @override
  String atob(String encodedData) => _win.atob(encodedData);
}

// ---------------------------------------------------------------------------
// Storage
// ---------------------------------------------------------------------------

class BrowserStorage implements iface.Storage {
  final web.Storage _native;
  BrowserStorage(this._native);

  @override
  int get length => _native.length;
  @override
  String? key(int index) => _native.key(index);
  @override
  String? getItem(String key) => _native.getItem(key);
  @override
  void setItem(String key, String value) => _native.setItem(key, value);
  @override
  void removeItem(String key) => _native.removeItem(key);
  @override
  void clear() => _native.clear();
}

// ---------------------------------------------------------------------------
// Location
// ---------------------------------------------------------------------------

class BrowserLocation implements iface.Location {
  final web.Location _native;
  BrowserLocation(this._native);

  @override
  String get href => _native.href;
  @override
  set href(String value) => _native.href = value;
  @override
  String get protocol => _native.protocol;
  @override
  String get host => _native.host;
  @override
  String get hostname => _native.hostname;
  @override
  String get port => _native.port;
  @override
  String get pathname => _native.pathname;
  @override
  String get search => _native.search;
  @override
  String get hash => _native.hash;
  @override
  String get origin => _native.origin;
  @override
  void assign(String url) => _native.assign(url);
  @override
  void replace(String url) => _native.replace(url);
  @override
  void reload() => _native.reload();
}

// ---------------------------------------------------------------------------
// History
// ---------------------------------------------------------------------------

class BrowserHistory implements iface.History {
  final web.History _native;
  BrowserHistory(this._native);

  @override
  int get length => _native.length;
  @override
  dynamic get state => _native.state;
  @override
  void pushState(dynamic data, String title, [String? url]) =>
      _native.pushState(data?.toJS, title, url);
  @override
  void replaceState(dynamic data, String title, [String? url]) =>
      _native.replaceState(data?.toJS, title, url);
  @override
  void back() => _native.back();
  @override
  void forward() => _native.forward();
  @override
  void go([int delta = 0]) => _native.go(delta);
}

// ---------------------------------------------------------------------------
// Navigator
// ---------------------------------------------------------------------------

class BrowserNavigator implements iface.Navigator {
  final web.Navigator _native;
  BrowserNavigator(this._native);

  @override
  String get userAgent => _native.userAgent;
  @override
  String get language => _native.language;
  @override
  List<String> get languages => _native.languages.toDart.map((js) => js.toDart).toList();
  @override
  bool get onLine => _native.onLine;
}

// ---------------------------------------------------------------------------
// Console
// ---------------------------------------------------------------------------

class BrowserConsole implements iface.Console {
  final web.$Console _native;
  BrowserConsole(this._native);

  @override
  void log(dynamic message, [List<dynamic>? args]) =>
      _native.log(message.toString().toJS);
  @override
  void warn(dynamic message, [List<dynamic>? args]) =>
      _native.warn(message.toString().toJS);
  @override
  void error(dynamic message, [List<dynamic>? args]) =>
      _native.error(message.toString().toJS);
  @override
  void info(dynamic message, [List<dynamic>? args]) =>
      _native.info(message.toString().toJS);
  @override
  void debug(dynamic message, [List<dynamic>? args]) =>
      _native.debug(message.toString().toJS);
}

// ---------------------------------------------------------------------------
// Crypto
// ---------------------------------------------------------------------------

class BrowserCrypto implements iface.Crypto {
  final web.Crypto _native;
  BrowserCrypto(this._native);

  @override
  String randomUUID() => _native.randomUUID();
}

// ---------------------------------------------------------------------------
// Performance
// ---------------------------------------------------------------------------

class BrowserPerformance implements iface.Performance {
  final web.Performance _native;
  BrowserPerformance(this._native);

  @override
  double now() => _native.now();
}

// ---------------------------------------------------------------------------
// CustomElementRegistry
// ---------------------------------------------------------------------------

class BrowserCustomElementRegistry implements iface.CustomElementRegistry {
  final web.CustomElementRegistry _native;
  BrowserCustomElementRegistry(this._native);

  @override
  void define(String name, dynamic constructor, [dynamic options]) =>
      _native.define(name, constructor as JSFunction);
  @override
  dynamic get(String name) => _native.get(name);
  @override
  void upgrade(Node root) => _native.upgrade(root.raw as web.Node);
  @override
  Future<void> whenDefined(String name) =>
      _native.whenDefined(name).toDart.then((_) {});
}
