# Changelog

## 1.0.0-alpha.5 (unpublished)

### Added

- **Feat**: Added `CssBackground` sealed class for the `background` shorthand property with `.none`, `.color()`, `.shorthand()` (assembles full shorthand with `position / size` slash syntax), `.layers()` (multiple backgrounds), plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssGridTemplateColumns` sealed class for `grid-template-columns` with `.none`, `.subgrid`, `.tracks()`, `.repeat()`, `.autoFill()`, `.autoFit()`, plus `.variable()`, `.raw()`, and `.global()`.
- **Feat**: Added `CssTrackSize` sealed class for individual grid track sizes with `.fr()`, `.length()`, `.minmax()`, `.fitContent()`, and `.raw()`.
- **Feat**: Added `accent-color` CSS property support via `CssColor? accentColor` parameter in `Style.typed()`.
- **Feat**: Added `CssAnimation` sealed class for the `animation` shorthand property with `.none`, single animation (name, duration, timingFunction, delay, iterationCount, direction, fillMode, playState), `.multiple()`, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssAnimationDirection`, `CssAnimationFillMode`, `CssAnimationPlayState`, and `CssAnimationIterationCount` sealed classes for animation sub-properties. Reuses existing `CssDuration` and `CssTimingFunction` from `CssTransition`.
- **Feat**: Added `CssBorderCollapse` sealed class for `border-collapse` property with `.separate`, `.collapse` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `border-top-color`, `border-right-color`, `border-bottom-color`, and `border-left-color` CSS property support via `CssColor?` parameters in `Style.typed()`.
- **Feat**: Added `CssBoxSizing` sealed class for `box-sizing` property with `.contentBox`, `.borderBox` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssContent` sealed class for `content` property with `.normal`, `.none` keywords, `.value()` for arbitrary content, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssJustifyItems` sealed class for `justify-items` property with `.normal`, `.stretch`, `.start`, `.end`, `.center`, `.left`, `.right`, `.baseline`, `.firstBaseline`, `.lastBaseline` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssListStyle` sealed class for `list-style` shorthand property with `.none` keyword, shorthand constructor with optional `type`, `position`, and `image` parameters, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssListStyleType` sealed class with `.disc`, `.circle`, `.square`, `.decimal`, `.none` keywords.
- **Feat**: Added `CssListStylePosition` sealed class with `.inside`, `.outside` keywords.
- **Feat**: Added `CssObjectFit` sealed class for `object-fit` property with `.fill`, `.contain`, `.cover`, `.none`, `.scaleDown` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssPointerEvents` sealed class for `pointer-events` property with `.auto`, `.none`, `.visiblePainted`, `.visibleFill`, `.visibleStroke`, `.visible`, `.painted`, `.fill`, `.stroke`, `.all` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssResize` sealed class for `resize` property with `.none`, `.both`, `.horizontal`, `.vertical`, `.block`, `.inline` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.

### Changed

- **Breaking Change**: `Style.typed()` `background` parameter changed from `String?` to `CssBackground?`.
- **Breaking Change**: `Style.typed()` `gridTemplateColumns` parameter changed from `String?` to `CssGridTemplateColumns?`.

### Deprecated

- **Deprecated**: The `Style()` untyped constructor is now deprecated in favor of `Style.typed()`. All CSS properties are now available as typed parameters.

## 1.0.0-alpha.4

### Added

- **Feat**: Added `CssTransitionProperty` sealed class with typed constants for common animatable CSS properties (`all`, `opacity`, `transform`, `backgroundColor`, `color`, `width`, `height`, `margin`, `padding`, `border`, `borderRadius`, `boxShadow`, `top`, `right`, `bottom`, `left`, `visibility`, `fontSize`, `lineHeight`, `letterSpacing`, `gap`) plus `variable()` and `raw()` constructors.
- **Feat**: Added `CssDuration` sealed class with `ms()`, `s()`, `variable()`, and `raw()` constructors for type-safe CSS duration values.

### Changed

- **Breaking Change**: `CssTransition` now accepts `CssTransitionProperty` instead of `String` for the `property` parameter, and `CssDuration` instead of `String` for `duration` and `delay` parameters.

## 1.0.0-alpha.3

### Added

- **Coverage**: Achieved 100% test coverage across the entire package.
- **Feat**: Moved `CssAngle` to its own file (`css_angle.dart`) and added support for CSS variables and global values.
- **Test**: Implemented Zone-based minification testing, enabling full coverage of production CSS output logic.

### Changed

- **Breaking Change**: `CssFilter.hueRotate` now accepts a `CssAngle` instead of a `num`.
- **Breaking Change**: `CssGradientDirection.angle` now accepts a `CssAngle` instead of a `String`.

## 1.0.0-alpha.2

### Added

- **Feat**: Massive expansion of the type-safe CSS system and integration into `Style.typed`.
  - Added `CssBackgroundImage` with support for `url()`, `linear-gradient()`, and `radial-gradient()`.
  - Added background control types: `CssBackgroundSize`, `CssBackgroundPosition`, `CssBackgroundRepeat`, `CssBackgroundClip`, `CssBackgroundOrigin`, `CssBackgroundAttachment`.
  - Added layout and spacing types: `CssFlexShorthand`, `CssZIndex`, `CssOutline`, `CssOutlineOffset`.
  - Added visual effect types: `CssBoxShadow`, `CssTransform`, `CssFilter`, `CssBackdropFilter`.
  - Added typography types: `CssTextShadow`, `CssFontStyle`, `CssTextDecoration`, `CssTextTransform`, `CssWhiteSpace`, `CssWordBreak`.
  - Added `CssBorderRadius` and `CssFlexShorthand`.
  - **Breaking Change**: Updated `Style.typed` to use these new types for its parameters, significantly improving type safety and developer experience.

## 1.0.0-alpha.1

- Initial release extracted from `spark_framework` package.
- Core style types: `Style`, `Stylesheet`, `CssStyle`, `css()` helper.
- Component style registry: `ComponentStyleRegistry`, `componentStyles`.
- Type-safe CSS value system: `CssColor`, `CssLength`, `CssSpacing`, `CssDisplay`, `CssPosition`, `CssFlex`, `CssOverflow`, `CssFont`, `CssText`, `CssCursor`, `CssNumber`, `CssBorder`, `CssTransition`.
- CSS minification support via `dart.vm.product` flag.
- Pure Dart package with zero runtime dependencies.
