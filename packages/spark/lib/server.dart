/// Spark Framework Server Utilities.
///
/// This library provides server-side utilities for rendering HTML pages,
/// routing, and serving static files. It includes the `SparkServer` implementation
/// and helpers for SSR.
///
/// **Note:** This library uses `dart:io` and should strictly not be imported
/// in code that targets the browser.
///
/// ## Usage with Pages
///
/// For the recommended annotation-based approach:
///
/// ```dart
/// // lib/pages/user_page.dart
/// @Page(path: '/users/:id')
/// class UserPage extends SparkPage<User> {
///   @override
///   Future<PageResponse<User>> loader(PageRequest request) async {
///     final user = await fetchUser(request.pathParamInt('id'));
///     return PageData(user);
///   }
///
///   @override
///   String render(User data, PageRequest request) {
///     return '<h1>${data.name}</h1>';
///   }
/// }
///
/// // bin/server.dart
/// void main() async {
///   final server = await createSparkServer(SparkServerConfig(
///     port: 8080,
///   ));
///   print('Running at http://localhost:${server.port}');
/// }
/// ```
///
/// ## Manual Usage
///
/// For manual routing without code generation:
///
/// ```dart
/// import 'package:spark_framework/server.dart';
/// import 'package:shelf/shelf.dart';
/// import 'package:shelf/shelf_io.dart';
///
/// void main() async {
///   final app = Router();
///
///   app.get('/', (req) {
///     final html = Counter(start: 100).render();
///     return Response.ok(
///       renderPage(
///         title: 'Home',
///         content: html,
///         scriptName: 'home.dart.js',
///       ),
///       headers: {'content-type': 'text/html'},
///     );
///   });
///
///   // Serve compiled JS files
///   app.mount('/', createStaticHandler('build/web'));
///
///   await serve(app.call, 'localhost', 8080);
/// }
/// ```
library;

export 'src/server/server.dart';
export 'src/annotations/annotations.dart';
export 'src/page/page.dart';
export 'src/endpoint/endpoint.dart';
export 'src/errors/errors.dart';
export 'src/http/content_type.dart';
