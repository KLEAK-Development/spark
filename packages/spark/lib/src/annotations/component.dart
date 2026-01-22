/// Marks a class as an island component that can be hydrated on the client.
///
/// Components are interactive elements within pages that get hydrated
/// (become interactive) on the client side. They use Custom Elements
/// and Declarative Shadow DOM for instant rendering.
///
/// ## Usage
///
/// ```dart
/// @Component(tag: 'my-counter')
/// class Counter extends WebComponent {
///   @override
///   String get tagName => 'my-counter';
///
///   static String render({int start = 0}) {
///     return '''
///       <my-counter start="$start">
///         <template shadowrootmode="open">
///           <button>Count: <span id="val">$start</span></button>
///         </template>
///       </my-counter>
///     ''';
///   }
///
///   @override
///   void onMount() {
///     final btn = query('button')!;
///     final val = query('#val')!;
///     var count = propInt('start');
///
///     btn.onClick.listen((_) {
///       count++;
///       val.text = count.toString();
///     });
///   }
/// }
/// ```
///
/// The component will be automatically registered for hydration based on
/// which pages use it.
class Component {
  /// The custom element tag name.
  ///
  /// Must follow the custom element naming convention:
  /// - Must contain a hyphen (e.g., 'my-counter', not 'counter')
  /// - Must start with a lowercase letter
  /// - Cannot be a reserved name
  final String tag;

  /// Creates a component annotation with the given [tag] name.
  const Component({required this.tag});
}

/// Marks a field as a reactive attribute.
///
/// Changes to the attribute in the DOM will update this field,
/// and changes to this field (via `syncAttributes`) will update the DOM.
class Attribute {
  const Attribute();
}
