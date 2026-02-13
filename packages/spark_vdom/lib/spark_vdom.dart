/// Spark VDOM - Virtual DOM engine for browser-side mounting, patching, and hydration.
///
/// Re-exports [spark_html_dsl] for convenience (node types + DSL helpers),
/// and adds the browser VDOM engine ([mount], [patch], [createNode], [mountList]).
///
/// ## Example
///
/// ```dart
/// import 'package:spark_vdom/spark_vdom.dart';
///
/// // Build a virtual DOM tree
/// final vNode = div(['Hello, world!'], className: 'greeting');
///
/// // Mount it into a real DOM element (browser only)
/// mount(document.querySelector('#app'), vNode);
/// ```
library;

export 'package:spark_html_dsl/spark_html_dsl.dart';
export 'src/vdom.dart';
