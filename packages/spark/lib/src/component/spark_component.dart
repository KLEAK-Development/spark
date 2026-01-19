import '../html/dsl.dart' as html;
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
/// class Counter extends SparkComponent {
///   @Attribute(observable: true)
///   int value = 0;
///
///   @override
///   html.Element build() {
///     return html.div(
///       ['Count: $value'],
///       onClick: (_) => value++,
///     );
///   }
/// }
/// ```
abstract class SparkComponent extends WebComponent {
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
    return html.element(tagName, [
      html.template(shadowrootmode: 'open', [build()]),
    ], attributes: dumpedAttributes);
  }

  /// Forces a re-render of the component.
  void update() {
    if (!isHydrated) return;

    final newVdom = build();

    _wrapEvents(newVdom);

    final root = shadowRoot;
    if (root != null) {
      vdom.mount(root, newVdom);
    } else {
      vdom.mount(element, newVdom);
    }
  }

  void _wrapEvents(html.Node node) {
    if (node is html.Element) {
      final keys = node.events.keys.toList();
      for (final key in keys) {
        final original = node.events[key]!;
        node.events[key] = (arg) {
          original(arg);
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

  @override
  void onMount() {
    super.onMount();
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

  /// Returns a map of attributes to be rendered on the host element during SSR.
  Map<String, String> get dumpedAttributes;
}
