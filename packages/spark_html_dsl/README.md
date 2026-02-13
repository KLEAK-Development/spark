# Spark HTML DSL

A lightweight, declarative HTML DSL and Virtual DOM library for Dart.

`spark_html_dsl` provides a set of type-safe helpers to build HTML structures in Dart code. It is the foundation of the Spark framework's view layer but can be used independently for generating HTML strings (SSR) or constructing Virtual DOM trees.

## Features

- **Declarative Syntax**: Build HTML structures using Dart functions (`div`, `span`, `h1`, etc.).
- **Virtual DOM Nodes**: Provides `Node`, `Element`, `Text`, and `RawHtml` classes.
- **Type-Safe Attributes**: extensive support for standard HTML attributes.
- **Event Listeners**: Attach event handlers like `onClick`, `onInput`, etc.
- **Server-Side Rendering (SSR)**: Call `.toHtml()` on any node to generate an HTML string.
- **Zero Dependencies**: Built on standard Dart libraries.

## Installation

Add it to your `pubspec.yaml`:

```bash
dart pub add spark_html_dsl
```

## Usage

Import the package and start building your UI:

```dart
import 'package:spark_html_dsl/spark_html_dsl.dart';

void main() {
  // Create a Virtual DOM tree
  final vNode = div(
    [
      h1('Hello, Spark!'),
      p(
        ['This is a declarative HTML structure.'],
        className: 'lead',
      ),
      button(
        ['Click me'],
        onClick: (_) => print('Clicked!'),
        disabled: true,
      ),
    ],
    id: 'app',
    className: 'container',
  );

  // Generate HTML string (useful for SSR)
  print(vNode.toHtml());
  // Output:
  // <div id="app" class="container">
  //   <h1>Hello, Spark!</h1>
  //   <p class="lead">This is a declarative HTML structure.</p>
  //   <button disabled="true">Click me</button>
  // </div>
}
```

## Determining Node Types

- **`Element`**: Represents an HTML tag (e.g., `div(...)`).
- **`Text`**: Represents a text node. Strings passed to children lists are automatically converted to `Text` nodes.
- **`RawHtml`**: Represents raw HTML content (use with caution).

## Contributing

This package is part of the Spark framework. Contributions are welcome at [https://github.com/KLEAK-Development/spark](https://github.com/KLEAK-Development/spark).
