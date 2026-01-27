import '../html/node.dart';
import 'page_request.dart';
import 'page_response.dart';
import '../style/style.dart';
import 'package:shelf/shelf.dart' show Middleware;

/// Abstract base class for Spark pages.
///
/// Pages are the entry points for your application's routes. Each page
/// must implement [loader] to fetch data and [render] to produce HTML.
///
/// The generic type [T] represents the data type returned by your loader.
/// This provides type safety between your loader and render methods.
///
/// ## Basic Usage
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
///     return '''
///       <h1>${data.name}</h1>
///       <p>${data.email}</p>
///     ''';
///   }
/// }
/// ```
///
/// ## Pages Without Data
///
/// For pages that don't need to load data, use `void` as the type:
///
/// ```dart
/// @Page(path: '/')
/// class HomePage extends SparkPage<void> {
///   @override
///   Future<PageResponse<void>> loader(PageRequest request) async {
///     return PageData(null);
///   }
///
///   @override
///   String render(void data, PageRequest request) {
///     return '<h1>Welcome!</h1>';
///   }
/// }
/// ```
///
/// ## With Components (Islands)
///
/// ```dart
/// @Page(path: '/counter')
/// class CounterPage extends SparkPage<void> {
///   @override
///   List<Type> get components => [Counter];
///
///   @override
///   Future<PageResponse<void>> loader(PageRequest request) async {
///     return PageData(null);
///   }
///
///   @override
///   String render(void data, PageRequest request) {
///     return Counter(start: 0).render();
///   }
/// }
/// ```
abstract class SparkPage<T> {
  /// Loads data for this page.
  ///
  /// This method is called before rendering and should return either:
  /// - [PageData] with the typed data to pass to [render]
  /// - [PageRedirect] to redirect to another page
  /// - [PageError] to display an error page
  ///
  /// The loader can perform async operations like fetching from APIs,
  /// reading from databases, making HTTP requests, etc.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// Future<PageResponse<User>> loader(PageRequest request) async {
  ///   final userId = request.pathParamInt('id');
  ///
  ///   // Fetch from external API
  ///   final response = await http.get(Uri.parse('$apiUrl/users/$userId'));
  ///   if (response.statusCode == 404) {
  ///     return PageRedirect('/404');
  ///   }
  ///
  ///   final user = User.fromJson(jsonDecode(response.body));
  ///   return PageData(user);
  /// }
  /// ```
  Future<PageResponse<T>> loader(PageRequest request);

  /// Renders the page HTML content.
  ///
  /// Receives the typed data returned by [loader] (if it returned [PageData])
  /// and the original request for access to path/query params.
  ///
  /// This method should return the body content (not a full HTML document).
  /// The framework wraps this in a complete HTML page with proper head,
  /// scripts, stylesheets, etc.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// dynamic render(User data, PageRequest request) {
  ///   return div([
  ///     h1(data.name),
  ///     p('Email: ${data.email}'),
  ///     a(href: "/users/${data.id}/edit", ['Edit Profile']),
  ///   ]);
  /// }
  /// ```
  Node render(T data, PageRequest request);

  /// Returns the list of island component types used by this page.
  ///
  /// These components will be registered for hydration on the client.
  /// Override this getter to declare which component types your page uses.
  ///
  /// The build system uses this list to generate a web-entrypoint that
  /// registers these components for hydration, without needing to import
  /// the page itself (allowing pages to use dart:io).
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// List<Type> get components => [
  ///   Counter,
  ///   UserCard,
  /// ];
  /// ```
  List<Type> get components => [];

  /// Returns the page title.
  ///
  /// Override this to provide a dynamic title based on the loaded data.
  /// The default implementation returns 'Spark App'.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// String title(User data, PageRequest request) {
  ///   return '${data.name} - User Profile';
  /// }
  /// ```
  String title(T data, PageRequest request) => 'Spark App';

  /// Additional content for the HTML `<head>` element.
  ///
  /// Use this for meta tags, link tags, or other head content.
  ///
  /// ## Example
  ///
  /// ```dart
  ///
  /// ```dart
  /// @override
  /// Object? get headContent => [
  ///   meta(name: 'description', content: 'User profile'),
  ///   link(rel: 'canonical', href: 'https://example.com/users'),
  /// ];
  /// ```
  Object? get headContent => null;

  /// Inline CSS styles for this page.
  ///
  /// These styles are included in a `<style>` tag in the page head.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// Stylesheet? get inlineStyles => css({
  ///   'main': Style(maxWidth: '800px', margin: '0 auto', padding: '20px'),
  ///   'h1': Style(color: '#333'),
  /// });
  /// ```
  Stylesheet? get inlineStyles => null;

  /// Additional stylesheets to load.
  ///
  /// Returns a list of stylesheet URLs to include in the page.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// List<String> get stylesheets => [
  ///   '/css/main.css',
  ///   'https://fonts.googleapis.com/css2?family=Inter&display=swap',
  /// ];
  /// ```
  List<String> get stylesheets => [];

  /// The language attribute for the HTML document.
  ///
  /// Override this to specify a different language for the page.
  /// The default is 'en' (English).
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// String get lang => 'es';
  /// ```
  String get lang => 'en';

  /// Additional scripts to load.
  ///
  /// Returns a list of script URLs to include in the page.
  /// These are loaded in addition to the page's hydration script.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// List<String> get additionalScripts => [
  ///   '/js/analytics.js',
  /// ];
  /// ```
  List<String> get additionalScripts => [];

  /// Middleware to apply to this page's route.
  ///
  /// Override this to provide middleware specific to this page.
  /// These middleware will be applied before the page loader is called.
  ///
  /// ## Example
  ///
  /// ```dart
  /// @override
  /// List<Middleware> get middleware => [
  ///   logRequests(),
  ///   authMiddleware(),
  /// ];
  /// ```
  List<Middleware> get middleware => [];
}
