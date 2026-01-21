/// Stub implementation for VM tests
/// Provides no-op implementations that allow tests to compile and run in VM mode
library;

final _cache = <String, Object>{};

dynamic createStyleSheet(String cssText) {
  // In VM mode, just cache the CSS text as a string
  if (!_cache.containsKey(cssText)) {
    _cache[cssText] = Object();
  }
  return _cache[cssText];
}

void setAdoptedStyleSheets(dynamic shadowRoot, List<String> cssTexts) {
  // No-op in VM
}

void clearStyleSheetCache() {
  _cache.clear();
}
