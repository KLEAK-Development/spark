# Spark VDOM

A lightweight Virtual DOM engine for the Spark framework.

`spark_vdom` provides the browser-side runtime for mounting, patching, and hydrating Virtual DOM trees created with [spark_html_dsl](https://pub.dev/packages/spark_html_dsl). It efficiently updates the real DOM to match your virtual node structure.

## Features

- **Mounting**: Attach a Virtual DOM tree to a real DOM element.
- **Micro-Patching**: Efficiently diffs and updates only the changed parts of the DOM.
- **Hydration**: Reuses existing DOM nodes (e.g., from server-side rendering) to minimize initial paint time.
- **Event Delegation**: Automatically manages event listeners.
- **SVG Support**: Correctly handles SVG namespaces and attributes.

## Installation

Add it to your `pubspec.yaml`:

```bash
dart pub add spark_vdom
```

## Usage

Import `spark_vdom` (which exports `spark_html_dsl` for convenience) and mount your app:

```dart
import 'package:spark_vdom/spark_vdom.dart';
import 'package:web/web.dart' as web;

void main() {
  // 1. Create a Virtual DOM tree
  final vNode = div(
    [
      h1('Hello, World!'),
      button(
        ['Click Me'],
        onClick: (_) => web.window.alert('Clicked!'),
      ),
    ],
    id: 'app',
  );

  // 2. Mount it to the DOM
  final root = web.document.querySelector('#root');
  if (root != null) {
    mount(root, vNode);
  }
}
```

## How It Works

1.  **Create VNodes**: Use the `spark_html_dsl` helpers (`div`, `span`, etc.) to create a lightweight virtual representation of your UI.
2.  **Mount**: The `mount()` function takes a real DOM element and a VNode. It creates the corresponding real DOM nodes and appends them.
3.  **Patch**: When your state changes and you create a new VNode tree, `patch(realNode, newVNode)` compares the old and new trees and updates the real DOM with the minimum number of operations.

## Contributing

This package is part of the Spark framework. Contributions are welcome at [https://github.com/KLEAK-Development/spark](https://github.com/KLEAK-Development/spark).
