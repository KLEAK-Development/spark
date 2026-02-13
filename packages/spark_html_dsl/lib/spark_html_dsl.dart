/// Spark HTML DSL - Virtual DOM node types and HTML element helpers.
///
/// Provides [Node], [Text], [RawHtml], and [Element] node types,
/// plus a full set of HTML tag helpers ([div], [span], [h1], [button], etc.)
/// for building declarative HTML structures.
///
/// ## Example
///
/// ```dart
/// import 'package:spark_html_dsl/spark_html_dsl.dart';
///
/// final page = div([
///   h1('Hello, world!'),
///   p('Welcome to Spark.'),
/// ], className: 'container');
///
/// print(page.toHtml());
/// ```
library;

export 'src/node.dart';
export 'src/elements.dart';
