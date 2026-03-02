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
- **Feat**: Added `CssScrollBehavior` sealed class for `scroll-behavior` property with `.auto`, `.smooth` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssTextOverflow` sealed class for `text-overflow` property with `.clip`, `.ellipsis` keywords, `.value()` for custom strings, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssAspectRatio` sealed class for `aspect-ratio` property with `.auto` keyword, `.ratio()`, `.number()`, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssPlaceItems` sealed class for `place-items` shorthand property with align and optional justify parameters, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssPlaceContent` sealed class for `place-content` shorthand property with `CssAlignContent` and optional `CssJustifyContent` parameters, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssPlaceSelf` sealed class for `place-self` shorthand property with `CssAlignSelf` and optional `CssJustifySelf` parameters, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssJustifySelf` sealed class for `justify-self` property with `.auto`, `.normal`, `.stretch`, `.start`, `.end`, `.center`, `.left`, `.right`, `.baseline`, `.firstBaseline`, `.lastBaseline`, `.selfStart`, `.selfEnd` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssIsolation` sealed class for `isolation` property with `.auto`, `.isolate` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssMixBlendMode` sealed class for `mix-blend-mode` property with `.normal`, `.multiply`, `.screen`, `.overlay`, `.darken`, `.lighten`, `.colorDodge`, `.colorBurn`, `.hardLight`, `.softLight`, `.difference`, `.exclusion`, `.hue`, `.saturation`, `.color`, `.luminosity` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssBackgroundBlendMode` sealed class for `background-blend-mode` property with `.normal`, `.multiply`, `.screen`, `.overlay`, `.darken`, `.lighten`, `.colorDodge`, `.colorBurn`, `.hardLight`, `.softLight`, `.difference`, `.exclusion`, `.hue`, `.saturation`, `.color`, `.luminosity` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssContain` sealed class for `contain` property with `.none`, `.strict`, `.content` keyword shortcuts, `.size`, `.layout`, `.style`, `.paint` individual keyword constants, and `.flags()` factory for composing individual containment values, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssWillChange` sealed class for `will-change` property with `.auto`, `.scrollPosition`, `.contents` keywords and `.properties()` factory for arbitrary CSS property names, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssTouchAction` sealed class for `touch-action` property with `.auto`, `.none`, `.manipulation` standalone keywords, `.panX`, `.panLeft`, `.panRight`, `.panY`, `.panUp`, `.panDown`, `.pinchZoom` combinable keywords, and `.combine()` factory, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssUserSelect` sealed class for `user-select` property with `.none`, `.auto`, `.text`, `.all`, `.contain` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssHyphens` sealed class for `hyphens` property with `.none`, `.manual`, `.auto` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssScrollPadding` sealed class for `scroll-padding` property with `.all()`, `.symmetric()`, `.only()` factories, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssOverscrollBehavior` sealed class for `overscroll-behavior` property with `.auto`, `.contain`, `.none` keywords, `.xy()` for two-value syntax, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssAppearance` sealed class for `appearance` property with `.none`, `.auto`, `.menulistButton`, `.textfield` keywords, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssTabSize` sealed class for `tab-size` property with `.number()`, `.length()` factories, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssCaretColor` sealed class for `caret-color` property with `.auto` keyword, `.color()` factory, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssScrollSnapType` sealed class for `scroll-snap-type` property with `.none` keyword, `.axis()` factory with optional strictness, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssScrollSnapAlign` sealed class for `scroll-snap-align` property with `.none`, `.start`, `.end`, `.center` keywords, `.pair()` for two-value syntax, plus `.variable()`, `.raw()`, and `.global()` escape hatches.
- **Feat**: Added `CssScrollMargin` sealed class for `scroll-margin` property with `.all()`, `.symmetric()`, `.only()` factories, plus `.variable()`, `.raw()`, and `.global()` escape hatches.

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
