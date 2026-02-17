# Changelog

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
