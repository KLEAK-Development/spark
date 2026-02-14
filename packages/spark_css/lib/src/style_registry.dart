/// Registry for storing component styles for server-side deduplication.
///
/// This registry allows components to register their styles once, and then reference
/// them via a URL in the generated HTML. This avoids duplicating styles in the
/// initial HTML payload.
library;

/// Global registry instance.
final ComponentStyleRegistry componentStyles = ComponentStyleRegistry();

/// Registry for component CSS.
class ComponentStyleRegistry {
  final Map<String, String> _styles = {};

  /// Registers CSS for a component tag.
  ///
  /// Safe to call multiple times for the same tag; subsequent calls
  /// will overwrite the previous value (which should be identical).
  void register(String tagName, String css) {
    _styles[tagName] = css;
  }

  /// Gets the registered CSS for a component tag.
  String? get(String tagName) => _styles[tagName];

  /// Clears all registered styles.
  void clear() {
    _styles.clear();
  }
}
