/// Server-side stub for adopted stylesheets.
///
/// On the server, we don't need to do anything with stylesheets since
/// they are rendered as `<style>` elements during SSR.
library;

/// Stub type for ShadowRoot on server.
class ShadowRoot {}

/// No-op: Creates a stylesheet (stub for server).
dynamic createStyleSheet(String cssText) {
  return null;
}

/// No-op: Sets adopted stylesheets (stub for server).
void setAdoptedStyleSheets(dynamic shadowRoot, List<String> cssTexts) {
  // No-op on server
}

/// No-op: Clears the stylesheet cache (stub for server).
void clearStyleSheetCache() {
  // No-op on server
}
