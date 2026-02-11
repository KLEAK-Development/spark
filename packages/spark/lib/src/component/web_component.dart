/// WebComponent base class for isomorphic Dart components.
///
/// This file provides a component system that works on both server (Dart VM)
/// and browser. Components can render HTML on the server and hydrate on the
/// browser to add interactivity.
///
/// Uses `package:spark_web` for a server-safe Web API abstraction that mirrors
/// the MDN Web API with identical naming.
library;

// spark_web provides the same API as the browser Web API, but works on both
// server and browser. On the server, types are no-ops. On the browser, they
// wrap the real package:web DOM objects.
import 'package:spark_web/spark_web.dart' as web;

import '../html/dsl.dart' as html;

// Re-export spark_web types for use in components.
// This allows component code to access web types via the spark.dart barrel.
export 'package:spark_web/spark_web.dart';

/// Abstract base class for Spark components.
///
/// Components extend this class to create isomorphic web components that
/// can be rendered on the server and hydrated on the browser.
///
/// ## Architecture
///
/// On the **server** (Dart VM):
/// - Components render HTML strings via static `render()` methods
/// - The `element` property is null
/// - Lifecycle callbacks are not invoked
///
/// On the **browser** (JavaScript):
/// - Components are hydrated by finding their elements in the DOM
/// - The `element` property contains the actual DOM element
/// - Lifecycle callbacks are invoked during hydration
///
/// ## Example
///
/// ```dart
/// class Counter extends WebComponent {
///   static const tag = 'my-counter';
///
///   @override
///   String get tagName => tag;
///
///   // Server-side rendering
///   static String render({int start = 0}) {
///     return '''
///       <$tag start="$start">
///         <template shadowrootmode="open">
///           <div>Count: <span id="val">$start</span></div>
///           <button id="btn">+</button>
///         </template>
///       </$tag>
///     ''';
///   }
///
///   // Client-side hydration
///   @override
///   void onMount() {
///     final btn = query('#btn');
///     btn?.addEventListener('click', (_) => print('Clicked!'));
///   }
/// }
///
/// // In web/main.dart
/// void main() {
///   hydrateComponents([Counter.new]);
/// }
/// ```
abstract class WebComponent {
  /// The custom element tag name (e.g., 'my-counter').
  String get tagName;

  /// Renders the component as HTML.
  ///
  /// Override this method to define the component's HTML structure.
  /// This is called on the server to generate initial HTML.
  html.Element render();

  /// The underlying DOM element (null on server, set during hydration).
  web.HTMLElement? _element;

  /// The shadow root of this component (if available).
  web.ShadowRoot? _shadowRoot;

  /// Reference to the MutationObserver for attribute changes (if any).
  web.MutationObserver? _attributeObserver;

  /// Gets the underlying DOM element.
  ///
  /// Throws [StateError] if accessed before hydration or on server.
  web.HTMLElement get element {
    if (_element == null) {
      throw StateError(
        'Element not available. Are you running on the server or before hydration?',
      );
    }
    return _element!;
  }

  /// Gets the shadow root of this component.
  ///
  /// Returns null if no shadow root is attached.
  web.ShadowRoot? get shadowRoot => _shadowRoot;

  /// Whether this component has been hydrated.
  bool get isHydrated => _element != null;

  /// Hydrates this component with the given DOM element.
  ///
  /// This is called internally by [hydrateComponents] and should not
  /// be called directly.
  void _hydrate(web.HTMLElement element) {
    _element = element;
    // Try to get the shadow root (may be attached via Declarative Shadow DOM)
    try {
      _shadowRoot = element.shadowRoot;
    } catch (_) {
      // Shadow root may not be available
    }

    // Set up attribute observation if needed
    _setupAttributeObserver();

    // Hook for subclasses to perform actions before initial update (e.g. style cleanup)
    onHydrating();

    // Notify initial attribute values (before onMount)
    _notifyInitialAttributes();

    onMount();
  }

  /// Called during hydration, before initial attributes are notified.
  ///
  /// Override this to perform setup steps that must happen before the first
  /// [attributeChangedCallback] (and subsequent [update]) occurs.
  void onHydrating() {}

  /// Sets up a MutationObserver to watch for attribute changes.
  void _setupAttributeObserver() {
    final attrs = observedAttributes;
    if (attrs.isEmpty || !web.kIsBrowser) return;

    _attributeObserver = web.createMutationObserver(_handleMutations);
    _attributeObserver!.observe(
      _element!,
      web.MutationObserverInit(
        attributes: true,
        attributeOldValue: true,
        attributeFilter: attrs,
      ),
    );
  }

  /// Handles mutation records from the MutationObserver.
  void _handleMutations(
    List<web.MutationRecord> mutations,
    web.MutationObserver observer,
  ) {
    for (final record in mutations) {
      if (record.type == 'attributes') {
        final name = record.attributeName;
        if (name != null) {
          final newValue = _element!.getAttribute(name);
          attributeChangedCallback(name, record.oldValue, newValue);
        }
      }
    }
  }

  /// Notifies initial attribute values during hydration.
  void _notifyInitialAttributes() {
    if (!web.kIsBrowser) return;
    for (final attr in observedAttributes) {
      final currentValue = _element!.getAttribute(attr);
      if (currentValue != null) {
        attributeChangedCallback(attr, null, currentValue);
      }
    }
  }

  /// Internal cleanup - disconnects observers and calls [onUnmount].
  // ignore: unused_element
  void _cleanup() {
    _attributeObserver?.disconnect();
    _attributeObserver = null;
    onUnmount();
  }

  /// Called when the component is mounted/hydrated in the browser.
  ///
  /// Override this method to add interactivity to your component.
  void onMount() {}

  /// Called when the component is unmounted from the DOM.
  ///
  /// Override this method to clean up resources (e.g., cancel subscriptions).
  void onUnmount() {}

  /// Returns a list of attribute names to observe for changes.
  ///
  /// Override this in subclasses to react to attribute changes.
  List<String> get observedAttributes => const [];

  /// Called when an observed attribute changes.
  void attributeChangedCallback(
    String name,
    String? oldValue,
    String? newValue,
  ) {}

  /// Sets an attribute on the element.
  ///
  /// If [value] is null, the attribute is removed.
  void setAttr(String name, String? value) {
    if (_element == null) return;
    if (value == null) {
      _element!.removeAttribute(name);
    } else {
      _element!.setAttribute(name, value);
    }
  }

  /// Removes an attribute from the element.
  void removeAttr(String name) {
    _element?.removeAttribute(name);
  }

  /// Checks if the element has the specified attribute.
  bool hasAttr(String name) {
    return _element?.hasAttribute(name) ?? false;
  }

  /// Toggles a boolean attribute on the element.
  bool toggleAttr(String name, [bool? force]) {
    if (_element == null) return false;

    final shouldAdd = force ?? !hasAttr(name);
    if (shouldAdd) {
      _element!.setAttribute(name, '');
    } else {
      _element!.removeAttribute(name);
    }
    return shouldAdd;
  }

  /// Reads an attribute value from the element.
  String prop(String key, [String fallback = '']) {
    if (_element == null) return fallback;
    return _element!.getAttribute(key) ?? fallback;
  }

  /// Reads an integer attribute value.
  int propInt(String key, [int fallback = 0]) {
    final value = prop(key);
    if (value.isEmpty) return fallback;
    return int.tryParse(value) ?? fallback;
  }

  /// Reads a double attribute value.
  double propDouble(String key, [double fallback = 0.0]) {
    final value = prop(key);
    if (value.isEmpty) return fallback;
    return double.tryParse(value) ?? fallback;
  }

  /// Reads a boolean attribute value.
  bool propBool(String key, [bool fallback = false]) {
    final value = prop(key);
    if (value.isEmpty) return fallback;
    return value != 'false' && value != '0';
  }

  /// Queries for an element within this component's shadow root or element.
  web.Element? query(String selector) {
    if (_shadowRoot != null) {
      return _shadowRoot!.querySelector(selector);
    }
    return _element?.querySelector(selector);
  }

  /// Queries for all matching elements within this component.
  List<web.Element> queryAll(String selector) {
    web.NodeList? nodes;
    if (_shadowRoot != null) {
      nodes = _shadowRoot!.querySelectorAll(selector);
    } else if (_element != null) {
      nodes = _element!.querySelectorAll(selector);
    }
    if (nodes == null) return [];

    final result = <web.Element>[];
    for (var i = 0; i < nodes.length; i++) {
      final item = nodes.item(i);
      if (item != null && item is web.Element) {
        result.add(item);
      }
    }
    return result;
  }

  /// Applies CSS strings as adopted stylesheets to this component's shadow root.
  ///
  /// Uses the modern `adoptedStyleSheets` API for efficient style management.
  /// On the server, this is a no-op.
  void adoptStyleSheets(List<String> cssTexts) {
    if (_shadowRoot == null) return;
    final sheets = cssTexts.map(createStyleSheet).toList();
    _shadowRoot!.adoptedStyleSheets = sheets;
  }
}

// ---------------------------------------------------------------------------
// Stylesheet cache — shared across all components for deduplication.
// ---------------------------------------------------------------------------

/// Cache of parsed CSSStyleSheet objects keyed by CSS content.
final Map<String, web.CSSStyleSheet> _stylesheetCache = {};

/// Creates or retrieves a cached [web.CSSStyleSheet] from the given CSS string.
///
/// This function uses the constructable stylesheets API which is more
/// efficient than creating `<style>` elements. Stylesheets are cached
/// so the same CSS content always returns the same instance.
web.CSSStyleSheet createStyleSheet(String cssText) {
  return _stylesheetCache.putIfAbsent(cssText, () {
    final sheet = web.createCSSStyleSheet();
    sheet.replaceSync(cssText);
    return sheet;
  });
}

/// Clears the stylesheet cache.
///
/// Useful for testing or when stylesheets should be re-parsed
/// (e.g., during hot reload).
void clearStyleSheetCache() {
  _stylesheetCache.clear();
}

/// Factory function type for creating component instances.
typedef ComponentFactory = Function;

/// Registry of component factories by tag name.
final Map<String, ComponentFactory> _componentRegistry = {};

/// Registers a component factory for hydration.
void registerComponent(String tagName, ComponentFactory factory) {
  _componentRegistry[tagName.toLowerCase()] = factory;
}

/// Hydrates all registered components found in the DOM.
void hydrateAll() {
  if (!web.kIsBrowser) return;

  for (final entry in _componentRegistry.entries) {
    final tagName = entry.key;
    final factory = entry.value;

    final elements = web.document.querySelectorAll(tagName);
    for (var i = 0; i < elements.length; i++) {
      final element = elements.item(i);
      if (element != null) {
        final component = factory();

        if (component is! WebComponent) {
          continue;
        }

        component._hydrate(element as web.HTMLElement);
      }
    }
  }
}

/// Convenience function to register multiple components and hydrate.
void hydrateComponents(Map<String, ComponentFactory> components) {
  for (final entry in components.entries) {
    registerComponent(entry.key, entry.value);
  }
  hydrateAll();
}
