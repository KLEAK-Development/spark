/// Example Counter component demonstrating Spark Framework usage.
///
/// This component shows how to:
/// - Define a custom element tag
/// - Render HTML with Declarative Shadow DOM
/// - Hydrate the component on the client
/// - Handle user interactions
library;

import 'package:spark_framework/spark.dart';

/// A simple counter component that demonstrates SSR with hydration.
///
/// This component demonstrates the use of [observedAttributes] and
/// [attributeChangedCallback] to react to attribute changes at runtime.
///
/// ## Server Usage
///
/// ```dart
/// final html = Counter(value: 5, label: 'Clicks').render();
/// ```
///
/// ## Browser Usage
///
/// ```dart
/// void main() {
///   hydrateComponents({'my-counter': Counter.new});
/// }
/// ```
class Counter extends WebComponent {
  /// The custom element tag name.
  static const tag = 'my-counter';

  /// The initial counter value.
  final int value;

  /// The label text displayed next to the counter.
  final String label;

  /// Creates a new Counter component.
  ///
  /// - [value]: The initial counter value (default: 0).
  /// - [label]: The label text (default: 'Count').
  Counter({this.value = 0, this.label = 'Count'}) : _count = value;

  // Element references for updating the UI
  HTMLSpanElement? _valueSpan;
  HTMLSpanElement? _labelSpan;

  // Current counter value (mutable for runtime updates)
  int _count = 0;

  @override
  String get tagName => tag;

  /// Observe 'value' and 'label' attributes for changes.
  @override
  List<String> get observedAttributes => ['value', 'label'];

  /// Renders the Counter component as HTML.
  ///
  /// This is called on the server to generate the initial HTML.
  /// The `<template shadowrootmode="open">` enables Declarative Shadow DOM,
  /// allowing the component to render immediately without JavaScript.
  @override
  Element render() {
    return element(
      tag,
      [
        template(shadowrootmode: 'open', [
          style([
            '''
          :host {
            display: block;
            padding: 16px;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            max-width: 200px;
            font-family: system-ui, -apple-system, sans-serif;
          }
          .counter-display {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
          }
          .label {
            font-size: 14px;
            color: #666;
          }
          .value {
            font-size: 24px;
            font-weight: bold;
            color: #2196f3;
            min-width: 48px;
            text-align: center;
          }
          .buttons {
            display: flex;
            gap: 8px;
          }
          button {
            width: 36px;
            height: 36px;
            font-size: 18px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.2s;
          }
          .decrement {
            background-color: #f44336;
            color: white;
          }
          .decrement:hover {
            background-color: #d32f2f;
          }
          .increment {
            background-color: #4caf50;
            color: white;
          }
          .increment:hover {
            background-color: #388e3c;
          }
          button:active {
            transform: scale(0.95);
          }
          ''',
          ]),
          div(className: 'counter-display', [
            span(id: 'label', className: 'label', ['$label:']),
            span(id: 'val', className: 'value', [value]),
          ]),
          div(className: 'buttons', [
            button(id: 'dec', className: 'decrement', ['−']),
            button(id: 'inc', className: 'increment', ['+']),
          ]),
        ]),
      ],
      attributes: {'value': value, 'label': label},
    );
  }

  /// Called when an observed attribute changes.
  ///
  /// This is called:
  /// - For initial attribute values during hydration (before [onMount])
  /// - Whenever 'value' or 'label' attributes are changed at runtime
  @override
  void attributeChangedCallback(
    String name,
    String? oldValue,
    String? newValue,
  ) {
    switch (name) {
      case 'value':
        _count = propInt('value', 0);
        _valueSpan?.innerText = _count.toString();
      case 'label':
        _labelSpan?.innerText = '${prop('label', 'Count')}:';
    }
  }

  /// Called when the component is hydrated in the browser.
  ///
  /// At this point, the shadow DOM has already been rendered by the browser
  /// using Declarative Shadow DOM. We just need to attach event listeners.
  ///
  /// Note: [attributeChangedCallback] has already been called for initial
  /// attribute values before this method is invoked.
  @override
  void onMount() {
    // Query and store element references for use in attributeChangedCallback
    _valueSpan = query('#val') as HTMLSpanElement?;
    _labelSpan = query('#label') as HTMLSpanElement?;
    final incButton = query('#inc') as HTMLButtonElement?;
    final decButton = query('#dec') as HTMLButtonElement?;

    if (_valueSpan == null || incButton == null || decButton == null) {
      print('Warning: Counter could not find required elements');
      return;
    }

    // Attach event listeners using simplified .on() syntax
    incButton.on('click', (Event e) {
      _count++;
      setAttr('value', _count.toString());
    });

    decButton.on('click', (Event e) {
      _count--;
      setAttr('value', _count.toString());
    });
  }
}
