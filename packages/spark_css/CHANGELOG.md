# Changelog

## 1.0.0-alpha.1

- Initial release extracted from `spark_framework` package.
- Core style types: `Style`, `Stylesheet`, `CssStyle`, `css()` helper.
- Component style registry: `ComponentStyleRegistry`, `componentStyles`.
- Type-safe CSS value system: `CssColor`, `CssLength`, `CssSpacing`, `CssDisplay`, `CssPosition`, `CssFlex`, `CssOverflow`, `CssFont`, `CssText`, `CssCursor`, `CssNumber`, `CssBorder`, `CssTransition`.
- CSS minification support via `dart.vm.product` flag.
- Pure Dart package with zero runtime dependencies.
