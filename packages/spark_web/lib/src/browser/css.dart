/// Browser implementations of CSS types.
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../css.dart';

// ---------------------------------------------------------------------------
// CSSStyleSheet
// ---------------------------------------------------------------------------

class BrowserCSSStyleSheet implements CSSStyleSheet {
  final web.CSSStyleSheet _native;
  BrowserCSSStyleSheet(this._native);

  web.CSSStyleSheet get native => _native;

  @override
  void replaceSync(String text) => _native.replaceSync(text);

  @override
  Future<CSSStyleSheet> replace(String text) async {
    await _native.replace(text).toDart;
    return this;
  }
}

// ---------------------------------------------------------------------------
// CSSStyleDeclaration
// ---------------------------------------------------------------------------

class BrowserCSSStyleDeclaration implements CSSStyleDeclaration {
  final web.CSSStyleDeclaration _native;
  BrowserCSSStyleDeclaration(this._native);

  @override
  String getPropertyValue(String property) =>
      _native.getPropertyValue(property);
  @override
  void setProperty(String property, String value, [String? priority]) =>
      _native.setProperty(property, value, priority ?? '');
  @override
  String removeProperty(String property) => _native.removeProperty(property);

  @override
  String get display => _native.display;
  @override
  set display(String value) => _native.display = value;
  @override
  String get visibility => _native.visibility;
  @override
  set visibility(String value) => _native.visibility = value;
  @override
  String get opacity => _native.opacity;
  @override
  set opacity(String value) => _native.opacity = value;
}
