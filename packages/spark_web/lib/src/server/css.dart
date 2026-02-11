/// Server-side implementations of CSS types.
library;

import '../css.dart';

class ServerCSSStyleSheet implements CSSStyleSheet {
  @override
  void replaceSync(String text) {}
  @override
  Future<CSSStyleSheet> replace(String text) async => this;
}

class ServerCSSStyleDeclaration implements CSSStyleDeclaration {
  @override
  String getPropertyValue(String property) => '';
  @override
  void setProperty(String property, String value, [String? priority]) {}
  @override
  String removeProperty(String property) => '';
  @override
  String get display => '';
  @override
  set display(String value) {}
  @override
  String get visibility => '';
  @override
  set visibility(String value) {}
  @override
  String get opacity => '';
  @override
  set opacity(String value) {}
}
