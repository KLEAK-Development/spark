# Spark CSS

A type-safe CSS style system for the Spark framework.

`spark_css` provides a comprehensive set of typed CSS value classes and a stylesheet API for building CSS in Dart. Instead of working with raw strings, you use typed constructors like `CssColor.hex()`, `CssLength.rem()`, and `CssDisplay.flex` that guarantee valid CSS output at compile time.

## Features

- **Type-Safe CSS Values**: Sealed classes for colors, lengths, spacing, display, position, flexbox, typography, borders, transitions, and more.
- **Stylesheet API**: `Style.typed` for individual rule sets and `css()` helper for multi-selector stylesheets.
- **CSS Shorthand Support**: `CssSpacing` handles 1, 2, 3, or 4 value shorthand for margin and padding.
- **CSS Functions**: Support for `calc()`, `min()`, `max()`, `clamp()`, and `fit-content()`.
- **CSS Variables**: Every value type supports `variable()` for CSS custom properties.
- **Automatic Minification**: CSS output is minified in production builds via the `dart.vm.product` flag.
- **Escape Hatches**: `raw()` factories and `.add()` method for properties not yet covered by typed constructors.
- **Zero Dependencies**: Pure Dart package with no runtime dependencies.

## Installation

```bash
dart pub add spark_css
```

## Usage

Import the package:

```dart
import 'package:spark_css/spark_css.dart';
```

### Creating a Style

Use `Style.typed` to build a type-safe set of CSS properties:

```dart
final style = Style.typed(
  display: CssDisplay.flex,
  padding: CssSpacing.all(CssLength.px(16)),
  backgroundColor: CssColor.hex('f5f5f5'),
  borderRadius: CssLength.px(8),
);

print(style.toCss());
// background-color: #f5f5f5;
// border-radius: 8px;
// display: flex;
// padding: 16px;
```

### Creating a Stylesheet

Use the `css()` helper to map selectors to styles:

```dart
final styles = css({
  ':host': Style.typed(
    display: CssDisplay.flex,
    flexDirection: CssFlexDirection.column,
    gap: CssLength.rem(1),
  ),
  ':host(.large)': Style.typed(
    padding: CssSpacing.all(CssLength.px(24)),
  ),
});

print(styles.toCss());
```

### Spacing Shorthand

`CssSpacing` mirrors CSS shorthand conventions:

```dart
// Single value (all sides)
padding: CssSpacing.all(CssLength.px(16)),

// Two values (vertical | horizontal)
margin: CssSpacing.symmetric(CssLength.px(10), CssLength.px(20)),

// Four values (top | right | bottom | left)
margin: CssSpacing.trbl(
  CssLength.px(10),
  CssLength.px(20),
  CssLength.px(30),
  CssLength.px(40),
),
```

### CSS Variables

Every value type supports CSS custom properties:

```dart
Style.typed(
  color: CssColor.variable('text-primary'),
  fontSize: CssLength.variable('font-size-base'),
)
```

### Custom Properties

For properties not covered by the typed constructors, use `.add()`:

```dart
final style = Style.typed(
  display: CssDisplay.grid,
);
style.add('grid-template-columns', 'repeat(3, 1fr)');
```

## Contributing

This package is part of the Spark framework. Contributions are welcome at [https://github.com/KLEAK-Development/spark](https://github.com/KLEAK-Development/spark).
