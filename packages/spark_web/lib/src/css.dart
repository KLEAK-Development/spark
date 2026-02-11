/// CSS-related types matching the MDN Web API.
library;

// ---------------------------------------------------------------------------
// CSSStyleSheet
// ---------------------------------------------------------------------------

/// A CSS stylesheet that can be constructed and applied to shadow roots.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleSheet
abstract class CSSStyleSheet {
  /// Synchronously replaces the content of the stylesheet.
  void replaceSync(String text);

  /// Asynchronously replaces the content of the stylesheet.
  Future<CSSStyleSheet> replace(String text);
}

// ---------------------------------------------------------------------------
// CSSStyleDeclaration
// ---------------------------------------------------------------------------

/// Represents an element's inline CSS styles.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleDeclaration
abstract class CSSStyleDeclaration {
  String getPropertyValue(String property);
  void setProperty(String property, String value, [String? priority]);
  String removeProperty(String property);

  // Common shorthand properties for convenience.
  String get display;
  set display(String value);
  String get visibility;
  set visibility(String value);
  String get opacity;
  set opacity(String value);
}
