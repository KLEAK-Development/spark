/// Spark CSS - Type-safe CSS style system for Dart.
///
/// Provides [Style], [Stylesheet], and a comprehensive set of CSS value types
/// for building type-safe stylesheets in Dart.
///
/// ## Example
///
/// ```dart
/// import 'package:spark_css/spark_css.dart';
///
/// final styles = css({
///   ':host': Style.typed(
///     display: CssDisplay.flex,
///     padding: CssSpacing.all(CssLength.px(16)),
///     backgroundColor: CssColor.hex('f5f5f5'),
///   ),
/// });
/// ```
library;

export 'src/style.dart';
export 'src/style_registry.dart';
export 'src/css_types/css_types.dart';
