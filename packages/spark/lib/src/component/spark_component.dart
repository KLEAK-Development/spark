import 'dart:async';

import '../html/dsl.dart' as html;
import '../style/style.dart';
import '../style/style_registry.dart';
import 'web_component.dart';
import 'vdom.dart' as vdom;

/// A reactive Web Component for Spark.
///
/// [SparkComponent] provides a declarative API for building components using
/// a Virtual DOM. It manages updates efficiently by comparing the new virtual
/// DOM with the previous one.
///
/// ## Lifecycle
///
/// 1. **Build**: The [build] method returns the virtual DOM structure.
/// 2. **Render (Server)**: [render] generates the initial HTML string.
/// 3. **Hydrate (Browser)**: The component attaches to the existing DOM.
/// 4. **Update**: State changes trigger [update], which re-runs [build]
///    and patches the DOM.
///
/// ## Example
///
/// ```dart
/// @Component(tag: 'my-counter')
/// class Counter extends SparkComponent with _$CounterSync {
///   @Attribute(observable: true)
///   int _value = 0;  // Private backing field
///
///   @override
///   html.Element build() {
///     return html.div(
///       ['Count: $value'],  // Use generated public getter
///       onClick: (_) => value++,  // Generated setter triggers update
///     );
///   }
/// }
/// ```
///
/// For reactive state that auto-updates the UI, use private fields (with `_` prefix)
/// and the generated public getter/setter will automatically trigger updates when
/// the value changes.
abstract class SparkComponent extends WebComponent {
  bool _updateScheduled = false;

  /// Called by generated setters when state changes.
  /// Batches multiple changes within same microtask into single update.
  void scheduleUpdate() {
    if (!_updateScheduled && isHydrated) {
      _updateScheduled = true;
      scheduleMicrotask(_performScheduledUpdate);
    }
  }

  void _performScheduledUpdate() {
    _updateScheduled = false;
    syncAttributes();
  }

  /// Builds the reactive Virtual DOM structure for this component.
  ///
  /// This method is called:
  /// - During server-side rendering to generate the initial HTML.
  /// - On the browser during hydration.
  /// - Whenever [update] is triggering (e.g., after state changes).
  ///
  /// Override this to define the component's UI. It should return a single
  /// root element (usually a `div` or similar container).
  html.Element build();

  /// Renders the component for SSR (Server-Side Rendering).
  ///
  /// Wraps the result of [build] in the component's custom element tag
  /// and includes a declarative shadow root template.
  ///
  /// **Note:** Do not override this method in subclasses. Override [build]
  /// instead to define your component's content.
  @override
  html.Element render() {
    final children = _buildWithStyles();
    return html.element(tagName, [
      html.template(shadowrootmode: 'open', children),
    ], attributes: dumpedAttributes);
  }

  /// Builds the component tree with styles automatically prepended.
  List<html.VNode> _buildWithStyles() {
    final children = build();
    final styles = adoptedStyleSheets;

    // Register styles for deduplication
    if (styles != null) {
      final css = styles.toCss();
      componentStyles.register(tagName, css);

      return [
        // Use inline style instead of link tag
        html.style([css]),
        children,
      ];
    }

    return [children];
  }

  /// Forces a re-render of the component.
  void update() {
    if (!isHydrated) return;

    // On the browser, styles are already applied via adoptedStyleSheets in onMount().
    // We only need the build() result, not the style element, to avoid CSP issues
    // with dynamically created <style> tags that wouldn't have a nonce.
    final newVdom = [build()];

    _wrapEventsInList(newVdom);

    final root = shadowRoot;
    if (root != null) {
      vdom.mountList(root, newVdom);
    } else {
      vdom.mountList(element, newVdom);
    }
  }

  /// Wraps events in a list of nodes.
  void _wrapEventsInList(List<html.VNode> nodes) {
    for (final node in nodes) {
      _wrapEvents(node);
    }
  }

  void _wrapEvents(html.VNode node) {
    if (node is html.Element) {
      final keys = node.events.keys.toList();
      for (final key in keys) {
        final original = node.events[key]!;
        node.events[key] = (arg) async {
          final result = original(arg);
          // Await if the handler returns a Future
          if (result is Future) {
            await result;
          }
          syncAttributes();
        };
      }
      for (final child in node.children) {
        _wrapEvents(child);
      }
    }
  }

  /// Called by generated code to sync fields to attributes.
  ///
  /// This should be overridden by the generated mixin or code.
  void syncAttributes() {}

  /// Returns a map of attributes to be rendered on the host element during SSR.
  Map<String, String> get dumpedAttributes;

  /// Returns the stylesheet to apply to this component's shadow DOM.
  ///
  /// Override this getter to provide component styles. The styles will be
  /// automatically applied to the shadow root during hydration using the
  /// efficient `adoptedStyleSheets` API.
  ///
  /// **Benefits:**
  /// - Styles are parsed once and cached
  /// - More efficient than creating `<style>` elements
  /// - Works seamlessly with type-safe CSS API
  ///
  /// **Note:** For SSR, you should still include styles in your template.
  /// This is only for browser-side hydration.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// Stylesheet? get adoptedStyleSheets => css({
  ///   ':host': .typed(
  ///     display: .block,
  ///     padding: .all(.px(16)),
  ///   ),
  ///   'button': .typed(
  ///     backgroundColor: .hex('#2196f3'),
  ///     color: .white,
  ///   ),
  /// });
  /// ```
  Stylesheet? get adoptedStyleSheets => null;

  @override
  void onMount() {
    super.onMount();

    // Apply adopted stylesheets if defined (for browser efficiency)
    final styles = adoptedStyleSheets;
    if (styles != null) {
      adoptStyleSheets([styles.toCss()]);

      // Remove the SSR-rendered <style> element since adoptedStyleSheets now handles styles.
      // This also ensures update() can patch correctly.
      final root = shadowRoot;
      if (root != null) {
        final firstChild = root.firstElementChild;
        // Check for style tag
        if (firstChild != null && firstChild.tagName.toLowerCase() == 'style') {
          firstChild.remove();
        }
      }
    }

    update();
  }

  @override
  void attributeChangedCallback(
    String name,
    String? oldValue,
    String? newValue,
  ) {
    if (oldValue != newValue) {
      update();
    }
  }
}
