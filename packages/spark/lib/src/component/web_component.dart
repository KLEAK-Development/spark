/// WebComponent base class for isomorphic Dart components.
///
/// This file provides a component system that works on both server (Dart VM)
/// and browser. Components can render HTML on the server and hydrate on the
/// browser to add interactivity.
///
/// The approach uses composition rather than inheritance to work with
/// the modern `package:web` extension types.
library;

// Conditional import: Use package:web on browser, stubs on server
import 'package:web/web.dart' if (dart.library.io) 'stubs.dart' as web;

// Conditional import for JS callback conversion
import '../html/dsl.dart' as html;
import 'js_callback_web.dart'
    if (dart.library.io) 'js_callback_stub.dart'
    as js_callback;

// Conditional import for adopted stylesheets
import 'adopted_styles_web.dart'
    if (dart.library.io) 'adopted_styles_stub.dart'
    as adopted_styles;

// Re-export DOM types for use in components
export 'package:web/web.dart' if (dart.library.io) 'stubs.dart' hide Node;

export 'query_stubs.dart' if (dart.library.html) 'query_web.dart';

/// Whether we are running in a browser environment.
///
/// This is true when compiled to JavaScript, false on Dart VM.
const bool kIsBrowser = bool.fromEnvironment('dart.library.js_interop');

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
///     btn?.onClick.listen((_) => print('Clicked!'));
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
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// dynamic render() {
  ///   return element(tagName, [
  ///     template(shadowrootmode: 'open', [
  ///       style([...]),
  ///       div([...]),
  ///     ]),
  ///   ], attributes: {'start': start});
  /// }
  /// ```
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

    // Notify initial attribute values (before onMount)
    _notifyInitialAttributes();

    onMount();
  }

  /// Sets up a MutationObserver to watch for attribute changes.
  void _setupAttributeObserver() {
    final attrs = observedAttributes;
    if (attrs.isEmpty || !kIsBrowser) return;

    final callback = js_callback.toMutationCallback(_handleMutations);
    _attributeObserver = web.MutationObserver(callback);
    _attributeObserver!.observe(
      _element!,
      js_callback.toMutationObserverInit(attrs),
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
    if (!kIsBrowser) return;
    for (final attr in observedAttributes) {
      final currentValue = _element!.getAttribute(attr);
      if (currentValue != null) {
        attributeChangedCallback(attr, null, currentValue);
      }
    }
  }

  /// Internal cleanup - disconnects observers and calls [onUnmount].
  ///
  /// Call this method when a component is removed from the DOM to
  /// properly clean up resources.
  // ignore: unused_element
  void _cleanup() {
    _attributeObserver?.disconnect();
    _attributeObserver = null;
    onUnmount();
  }

  /// Called when the component is mounted/hydrated in the browser.
  ///
  /// Override this method to add interactivity to your component.
  /// The shadow DOM will already be rendered (thanks to Declarative Shadow DOM).
  void onMount() {}

  /// Called when the component is unmounted from the DOM.
  ///
  /// Override this method to clean up resources (e.g., cancel subscriptions).
  void onUnmount() {}

  /// Returns a list of attribute names to observe for changes.
  ///
  /// Override this in subclasses to react to attribute changes.
  /// When an observed attribute changes, [attributeChangedCallback] is called.
  ///
  /// **Note:** Use lowercase attribute names (HTML normalizes to lowercase).
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// List<String> get observedAttributes => ['disabled', 'count', 'label'];
  /// ```
  List<String> get observedAttributes => const [];

  /// Called when an observed attribute changes.
  ///
  /// Override this method to react to attribute changes at runtime.
  /// This is called:
  /// - For each observed attribute with a value during hydration (before [onMount])
  /// - Whenever an observed attribute is added, changed, or removed
  ///
  /// - [name]: The attribute name that changed
  /// - [oldValue]: The previous value (null if attribute was added)
  /// - [newValue]: The new value (null if attribute was removed)
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void attributeChangedCallback(String name, String? oldValue, String? newValue) {
  ///   switch (name) {
  ///     case 'disabled':
  ///       _updateDisabledState(newValue != null);
  ///     case 'count':
  ///       _updateCount(int.tryParse(newValue ?? '') ?? 0);
  ///   }
  /// }
  /// ```
  void attributeChangedCallback(
    String name,
    String? oldValue,
    String? newValue,
  ) {}

  /// Sets an attribute on the element.
  ///
  /// If [value] is null, the attribute is removed.
  /// If the attribute is in [observedAttributes], [attributeChangedCallback]
  /// will be triggered by the MutationObserver.
  ///
  /// Does nothing if not hydrated or running on server.
  ///
  /// ## Example
  ///
  /// ```dart
  /// setAttr('count', '5');     // Sets count="5"
  /// setAttr('disabled', '');   // Sets disabled="" (boolean attribute)
  /// setAttr('count', null);    // Removes the count attribute
  /// ```
  void setAttr(String name, String? value) {
    if (_element == null) return;
    if (value == null) {
      _element!.removeAttribute(name);
    } else {
      _element!.setAttribute(name, value);
    }
  }

  /// Removes an attribute from the element.
  ///
  /// If the attribute is in [observedAttributes], [attributeChangedCallback]
  /// will be triggered by the MutationObserver with [newValue] as null.
  ///
  /// Does nothing if not hydrated or running on server.
  void removeAttr(String name) {
    _element?.removeAttribute(name);
  }

  /// Checks if the element has the specified attribute.
  ///
  /// Returns false if not hydrated or running on server.
  bool hasAttr(String name) {
    return _element?.hasAttribute(name) ?? false;
  }

  /// Toggles a boolean attribute on the element.
  ///
  /// If [force] is provided:
  /// - true: adds the attribute
  /// - false: removes the attribute
  ///
  /// If [force] is not provided, toggles the current state.
  ///
  /// Returns the new state (true if attribute exists, false if removed).
  ///
  /// ## Example
  ///
  /// ```dart
  /// toggleAttr('disabled');        // Toggle current state
  /// toggleAttr('disabled', true);  // Force add
  /// toggleAttr('disabled', false); // Force remove
  /// ```
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
  ///
  /// Returns [fallback] if the attribute is not set or if running on server.
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
  ///
  /// Returns true if the attribute exists and is not 'false' or '0'.
  bool propBool(String key, [bool fallback = false]) {
    final value = prop(key);
    if (value.isEmpty) return fallback;
    return value != 'false' && value != '0';
  }

  /// Queries for an element within this component's shadow root or element.
  ///
  /// First checks the shadow root (if available), then falls back to
  /// the element itself.
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
      if (item != null) {
        result.add(item as web.Element);
      }
    }
    return result;
  }

  /// Applies CSS strings as adopted stylesheets to this component's shadow root.
  ///
  /// This uses the modern [adoptedStyleSheets](https://developer.mozilla.org/en-US/docs/Web/API/ShadowRoot/adoptedStyleSheets)
  /// API which is more efficient than creating `<style>` elements because:
  /// - Stylesheets can be shared across multiple shadow roots
  /// - CSS is only parsed once and cached
  /// - The browser can optimize stylesheet application
  ///
  /// **Note:** This only works in the browser. On the server (during SSR),
  /// this is a no-op since styles should be rendered as `<style>` elements.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// void onMount() {
  ///   adoptStyleSheets([
  ///     ':host { display: block; padding: 16px; }',
  ///     'button { background: blue; color: white; }',
  ///   ]);
  /// }
  /// ```
  void adoptStyleSheets(List<String> cssTexts) {
    if (_shadowRoot == null) return;
    adopted_styles.setAdoptedStyleSheets(_shadowRoot!, cssTexts);
  }
}

/// Factory function type for creating component instances.
typedef ComponentFactory = Function;

/// Registry of component factories by tag name.
final Map<String, ComponentFactory> _componentRegistry = {};

/// Registers a component factory for hydration.
///
/// Call this for each component type before calling [hydrateComponents].
///
/// ## Example
///
/// ```dart
/// void main() {
///   registerComponent('my-counter', Counter.new);
///   hydrateAll();
/// }
/// ```
void registerComponent(String tagName, ComponentFactory factory) {
  _componentRegistry[tagName.toLowerCase()] = factory;
}

/// Hydrates all registered components found in the DOM.
///
/// This function:
/// 1. Finds all elements matching registered component tags
/// 2. Creates component instances
/// 3. Calls [WebComponent.onMount] on each
///
/// ## Example
///
/// ```dart
/// void main() {
///   registerComponent('my-counter', Counter.new);
///   registerComponent('my-button', Button.new);
///   hydrateAll();
/// }
/// ```
void hydrateAll() {
  if (!kIsBrowser) return;

  for (final entry in _componentRegistry.entries) {
    final tagName = entry.key;
    final factory = entry.value;

    final elements = web.document.querySelectorAll(tagName);
    for (var i = 0; i < elements.length; i++) {
      final element = elements.item(i);
      if (element != null) {
        // Custom elements are HTMLElement instances by definition
        final component = factory();

        // Skip hydration if not a WebComponent
        if (component is! WebComponent) {
          continue;
        }

        component._hydrate(element as web.HTMLElement);
      }
    }
  }
}

/// Convenience function to register multiple components and hydrate.
///
/// ## Example
///
/// ```dart
/// void main() {
///   hydrateComponents({
///     'my-counter': Counter.new,
///     'my-button': Button.new,
///   });
/// }
/// ```
void hydrateComponents(Map<String, ComponentFactory> components) {
  for (final entry in components.entries) {
    registerComponent(entry.key, entry.value);
  }
  hydrateAll();
}

/// Wraps a Dart function as a JavaScript callback for event handlers.
///
/// Use this when attaching event listeners:
///
/// ```dart
/// element.addEventListener('click', jsCallback((event) {
///   // handle click
/// }));
/// ```
///
/// On the server (Dart VM), this returns the function as-is since
/// the stubs accept any callback type.
dynamic jsCallback(void Function(web.Event) callback) {
  return js_callback.jsCallbackImpl(callback);
}
