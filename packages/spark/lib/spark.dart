/// Spark Framework - Lightweight isomorphic SSR for Dart.
///
/// This library provides the core building blocks for creating isomorphic
/// web components that can be rendered on the server and hydrated in the browser.
/// It exports the base [WebComponent] class, the [SparkComponent] for vDOM-based
/// components, and other shared utilities.
///
/// ## Libraries
///
/// - `package:spark/spark.dart`: Core isomorphic library. Import this in your
///   components and shared code.
/// - `package:spark/server.dart`: Server-side utilities (rendering, routing).
///   Import this only in your server entry point (e.g., `bin/server.dart`).
///
/// ## Quick Start
///
/// 1. Import this library in your components:
///    ```dart
///    import 'package:spark/spark.dart';
///    ```
///
/// 2. Create a reactive component by extending [SparkComponent]:
///    ```dart
///    @Component(tag: 'my-counter')
///    class Counter extends SparkComponent {
///      @Attribute(observable: true)
///      int count = 0;
///
///      @override
///      html.Element build() {
///        return html.div(
///          ['Count: $count'],
///          onClick: (_) => count++,
///        );
///      }
///    }
///    ```
///
/// 3. Register components in your browser entry point:
///    ```dart
///    // web/main.dart
///    void main() {
///      Counter.register();
///    }
///    ```
///
/// ## Server-Side Rendering (SSR)
///
/// For server-side rendered pages, use the `@Page` annotation and
/// `SparkPage` class. See `package:spark/server.dart` for details.
library;

export 'src/component/component.dart' hide Text, Element, Request, Response;
export 'src/utils/utils.dart';
export 'src/annotations/annotations.dart';
export 'src/page/page.dart';
export 'src/endpoint/endpoint.dart';
export 'src/html/dsl.dart';
export 'src/style/style.dart';
export 'src/style/style_registry.dart';
export 'src/style/css_types/css_types.dart';
export 'src/errors/errors.dart';
export 'src/http/content_type.dart';
export 'src/http/cookie.dart';
