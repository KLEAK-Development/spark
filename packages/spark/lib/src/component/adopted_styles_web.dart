/// Browser-specific implementation for adopted stylesheets.
///
/// This file provides utilities to create and apply CSSStyleSheet objects
/// to shadow roots using the adoptedStyleSheets API.
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Cache of parsed CSSStyleSheet objects keyed by CSS content.
final Map<String, web.CSSStyleSheet> _stylesheetCache = {};

/// Creates or retrieves a cached CSSStyleSheet from the given CSS string.
///
/// This function uses the constructable stylesheets API which is more
/// efficient than creating `<style>` elements.
///
/// ## Example
///
/// ```dart
/// final sheet = createStyleSheet('body { color: red; }');
/// ```
web.CSSStyleSheet createStyleSheet(String cssText) {
  // Check cache first
  if (_stylesheetCache.containsKey(cssText)) {
    return _stylesheetCache[cssText]!;
  }

  // Create new stylesheet
  final sheet = web.CSSStyleSheet(web.CSSStyleSheetInit());
  sheet.replaceSync(cssText);

  // Cache it
  _stylesheetCache[cssText] = sheet;

  return sheet;
}

/// Applies the given CSS strings as adopted stylesheets to a shadow root.
///
/// This is more efficient than creating `<style>` elements because:
/// - Stylesheets can be shared across multiple shadow roots
/// - CSS is only parsed once and cached
/// - The browser can optimize stylesheet application
///
/// ## Example
///
/// ```dart
/// setAdoptedStyleSheets(shadowRoot, [
///   ':host { display: block; }',
///   '.button { padding: 8px; }',
/// ]);
/// ```
void setAdoptedStyleSheets(web.ShadowRoot shadowRoot, List<String> cssTexts) {
  final sheets = cssTexts.map(createStyleSheet).toList();
  shadowRoot.adoptedStyleSheets = sheets.toJS;
}

/// Clears the stylesheet cache.
///
/// This is useful for testing or when you want to force stylesheets to be
/// re-parsed (e.g., during hot reload).
void clearStyleSheetCache() {
  _stylesheetCache.clear();
}
