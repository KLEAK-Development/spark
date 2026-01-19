/// Marks a class as a page that will be registered with the Spark router.
///
/// Pages are the entry points for your application's routes. Each page class
/// must extend [SparkPage] and will be automatically registered with the
/// generated router.
///
/// ## Usage
///
/// ```dart
/// @Page(path: '/users/:id')
/// class UserPage extends SparkPage<User> {
///   @override
///   Future<PageResponse<User>> loader(PageRequest request) async {
///     final userId = request.pathParamInt('id');
///     final user = await fetchUser(userId);
///     if (user == null) return PageRedirect('/404');
///     return PageData(user);
///   }
///
///   @override
///   String render(User data, PageRequest request) {
///     return '<h1>${data.name}</h1>';
///   }
/// }
/// ```
///
/// ## Path Parameters
///
/// Use `:paramName` syntax for path parameters:
/// - `/users/:id` - Single parameter
/// - `/posts/:postId/comments/:commentId` - Multiple parameters
///
/// Parameters are available via [PageRequest.pathParams].
class Page {
  /// The URL path pattern for this page.
  ///
  /// Supports path parameters using `:paramName` syntax:
  /// - `/users/:id`
  /// - `/posts/:postId/comments/:commentId`
  final String path;

  /// HTTP methods this page responds to.
  ///
  /// Defaults to `['GET']`. Common values:
  /// - `['GET']` - Read-only pages
  /// - `['GET', 'POST']` - Pages with form submissions
  final List<String> methods;

  /// Creates a page annotation with the given [path].
  ///
  /// The [methods] parameter defaults to `['GET']`.
  const Page({required this.path, this.methods = const ['GET']});
}
