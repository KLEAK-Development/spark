# Spark CSS

A type-safe CSS style system for the Spark framework.

`spark_css` provides a comprehensive set of typed CSS value classes and a stylesheet API for building CSS in Dart. Instead of working with raw strings, you use typed constructors like `CssColor.hex()`, `CssLength.rem()`, and `CssDisplay.flex` that guarantee valid CSS output at compile time.

## Features

- **Type-Safe CSS Values**: Sealed classes for colors, lengths, spacing, display, position, flexbox, typography, borders, transitions, filters, transforms, shadows, cursors, backgrounds, and more.
- **Stylesheet API**: `Style.typed` for individual rule sets and `css()` helper for multi-selector stylesheets.
- **CSS Shorthand Support**: `CssSpacing` and `CssBorderRadius` handle 1–4 value shorthand for margin, padding, and border-radius.
- **CSS Functions**: Support for `calc()`, `min()`, `max()`, `clamp()`, and `fit-content()`.
- **CSS Variables**: Every value type supports `variable()` for CSS custom properties.
- **Global Keywords**: Every value type supports `global()` for `inherit`, `initial`, `unset`, `revert`, and `revert-layer`.
- **Filters & Transforms**: Full `CssFilter` and `CssTransform` APIs with composition support.
- **Gradients & Backgrounds**: Linear and radial gradients, plus typed background-size, position, repeat, clip, origin, and attachment.
- **Shadows**: `CssBoxShadow` and `CssTextShadow` with multi-shadow support.
- **Automatic Minification**: CSS output is minified in production builds via the `dart.vm.product` flag.
- **Component Style Registry**: Server-side style deduplication via `componentStyles`.
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
  borderRadius: CssBorderRadius.all(CssLength.px(8)),
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

// Named parameters for specific sides
margin: CssSpacing.sides(top: CssLength.px(10), left: CssLength.px(20)),
```

### Border Radius Shorthand

`CssBorderRadius` follows the same shorthand pattern:

```dart
// Single value (all corners)
borderRadius: CssBorderRadius.all(CssLength.px(8)),

// Two values (topLeft+bottomRight | topRight+bottomLeft)
borderRadius: CssBorderRadius.symmetric(CssLength.px(8), CssLength.px(4)),

// Four values (topLeft | topRight | bottomRight | bottomLeft)
borderRadius: CssBorderRadius.trbl(
  CssLength.px(8),
  CssLength.px(4),
  CssLength.px(8),
  CssLength.px(4),
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

### Global Keywords

Every value type supports CSS global keywords via `CssGlobal`:

```dart
Style.typed(
  display: CssDisplay.global(CssGlobal.inherit),
  color: CssColor.global(CssGlobal.unset),
)
```

Available globals: `inherit`, `initial`, `unset`, `revert`, `revertLayer`.

### Filters

`CssFilter` supports all CSS filter functions:

```dart
Style.typed(
  filter: CssFilter.blur(CssLength.px(4)),
)

// Compose multiple filters
Style.typed(
  filter: CssFilter.compose([
    CssFilter.grayscalePercent(50),
    CssFilter.blur(CssLength.px(2)),
  ]),
)

// Backdrop filter
Style.typed(
  backdropFilter: CssFilter.blur(CssLength.px(10)),
)
```

Available filters: `blur`, `brightness`, `contrast`, `dropShadow`, `grayscale`, `hueRotate`, `invert`, `opacity`, `saturate`, `sepia`. Each has both unitless and percent variants (e.g. `brightness` / `brightnessPercent`).

### Transforms

`CssTransform` supports all 2D transform functions:

```dart
Style.typed(
  transform: CssTransform.rotate(CssAngle.deg(45)),
)

// Compose multiple transforms
Style.typed(
  transform: CssTransform.list([
    CssTransform.translate(CssLength.px(10), CssLength.px(20)),
    CssTransform.scale(1.5),
    CssTransform.rotate(CssAngle.deg(45)),
  ]),
)
```

Available transforms: `translate`, `translateX`, `translateY`, `scale`, `scaleX`, `scaleY`, `rotate`, `skew`, `skewX`, `skewY`, `matrix`.

### Shadows

`CssBoxShadow` and `CssTextShadow` support single and multiple shadows:

```dart
// Box shadow
Style.typed(
  boxShadow: CssBoxShadow(
    x: CssLength.px(0),
    y: CssLength.px(4),
    blur: CssLength.px(8),
    color: CssColor.rgba(0, 0, 0, 0.1),
  ),
)

// Multiple box shadows
Style.typed(
  boxShadow: CssBoxShadow.multiple([
    CssBoxShadow(
      x: CssLength.px(0),
      y: CssLength.px(2),
      blur: CssLength.px(4),
      color: CssColor.rgba(0, 0, 0, 0.1),
    ),
    CssBoxShadow(
      x: CssLength.px(0),
      y: CssLength.px(8),
      blur: CssLength.px(16),
      color: CssColor.rgba(0, 0, 0, 0.1),
      inset: true,
    ),
  ]),
)

// Text shadow
Style.typed(
  textShadow: CssTextShadow(
    x: CssLength.px(1),
    y: CssLength.px(1),
    blur: CssLength.px(2),
    color: CssColor.rgba(0, 0, 0, 0.3),
  ),
)
```

### Gradients & Backgrounds

`CssBackgroundImage` supports linear and radial gradients:

```dart
// Linear gradient
Style.typed(
  backgroundImage: CssBackgroundImage.linearGradient(
    direction: CssGradientDirection.toRight,
    stops: [
      CssGradientStop(CssColor.hex('ff0000')),
      CssGradientStop(CssColor.hex('0000ff')),
    ],
  ),
)

// Radial gradient with stop offsets
Style.typed(
  backgroundImage: CssBackgroundImage.radialGradient(
    shape: CssRadialShape.circle,
    stops: [
      CssGradientStop(CssColor.hex('ff0000'), CssLength.percent(0)),
      CssGradientStop(CssColor.hex('0000ff'), CssLength.percent(100)),
    ],
  ),
)
```

Typed background properties: `backgroundSize`, `backgroundPosition`, `backgroundRepeat`, `backgroundClip`, `backgroundOrigin`, `backgroundAttachment`.

### Transitions

`CssTransition` uses typed parameters for property names, durations, and timing functions:

```dart
Style.typed(
  transition: CssTransition.simple(
    CssTransitionProperty.opacity,
    CssDuration.ms(200),
    CssTimingFunction.easeInOut,
  ),
)

// Full control with delay
CssTransition(
  property: CssTransitionProperty.transform,
  duration: CssDuration.s(0.3),
  timingFunction: CssTimingFunction.easeInOut,
  delay: CssDuration.ms(100),
)

// Multiple transitions
Style.typed(
  transition: CssTransition.multiple([
    CssTransition.simple(CssTransitionProperty.opacity, CssDuration.ms(200)),
    CssTransition.simple(CssTransitionProperty.transform, CssDuration.ms(300)),
  ]),
)

// Raw escape hatches for unsupported values
CssTransitionProperty.raw('max-width')
CssDuration.raw('200ms')

// Custom timing function
CssTimingFunction.cubicBezier(0.4, 0, 0.2, 1)
```

### Flex Shorthand

`CssFlexShorthand` provides the `flex` shorthand with smart validation:

```dart
// flex: auto
Style.typed(flex: CssFlexShorthand.auto)

// flex: 1 (grow only)
Style.typed(flex: CssFlexShorthand(grow: 1))

// flex: 1 0 auto (grow, shrink, basis)
Style.typed(flex: CssFlexShorthand(grow: 1, shrink: 0, basis: CssLength.auto))
```

### Font Families

`CssFontFamily` supports named fonts, generic families, and font stacks:

```dart
// Generic family
Style.typed(fontFamily: CssFontFamily.sansSerif)

// Named font
Style.typed(fontFamily: CssFontFamily.named('Inter'))

// Font stack with fallbacks
Style.typed(
  fontFamily: CssFontFamily.stack([
    CssFontFamily.named('Inter'),
    CssFontFamily.named('Helvetica'),
    CssFontFamily.sansSerif,
  ]),
)
```

### Outline

`CssOutline` provides the outline shorthand:

```dart
Style.typed(
  outline: CssOutline(
    width: CssLength.px(2),
    style: CssBorderStyle.solid,
    color: CssColor.hex('0066ff'),
  ),
  outlineOffset: CssLength.px(2),
)
```

### Cursors

`CssCursor` covers all standard CSS cursors plus custom URL cursors:

```dart
Style.typed(cursor: CssCursor.pointer)

// Custom cursor with fallback
Style.typed(
  cursor: CssCursor.url('custom.cur', fallback: CssCursor.pointer),
)
```

### Modern Viewport Units

`CssLength` supports modern viewport units alongside classic ones:

```dart
// Dynamic viewport units
height: CssLength.dvh(100),
width: CssLength.dvw(100),

// Small viewport units
height: CssLength.svh(100),

// Large viewport units
height: CssLength.lvh(100),
```

### Custom Properties

For properties not covered by the typed constructors, use `.add()`:

```dart
final style = Style.typed(
  display: CssDisplay.grid,
);
style.add('grid-template-columns', 'repeat(3, 1fr)');
```

### Component Style Registry

For server-side rendering, `componentStyles` provides style deduplication:

```dart
componentStyles.register('my-button', buttonStyles.toCss());

// Later, retrieve registered CSS
final css = componentStyles.get('my-button');
```

## Contributing

This package is part of the Spark framework. Contributions are welcome at [https://github.com/KLEAK-Development/spark](https://github.com/KLEAK-Development/spark).
