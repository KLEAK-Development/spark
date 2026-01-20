import '../http/cookie.dart';

/// Sealed class representing possible responses from a page loader.
///
/// A loader can return one of:
/// - [PageData] - Render the page with the provided typed data
/// - [PageRedirect] - Redirect to another URL
/// - [PageError] - Render an error page
///
/// ## Usage
///
/// ```dart
/// @override
/// Future<PageResponse<User>> loader(PageRequest request) async {
///   final userId = request.pathParamInt('id');
///
///   if (userId <= 0) {
///     return PageError.badRequest('Invalid user ID');
///   }
///
///   final user = await fetchUser(userId);
///   if (user == null) {
///     return PageRedirect('/404');
///   }
///
///   return PageData(user);
/// }
/// ```
sealed class PageResponse<T> {
  const PageResponse();
}

/// Response containing typed data to render the page.
///
/// The [data] field contains the typed result from your loader that will
/// be passed to the page's `render()` method.
///
/// ## Usage
///
/// ```dart
/// // Return typed data
/// return PageData(user);
///
/// // With custom status code
/// return PageData(user, statusCode: 201);
///
/// // With additional headers
/// return PageData(user, headers: {'X-Custom': 'value'});
/// ```
final class PageData<T> extends PageResponse<T> {
  /// The typed data to pass to the page's render method.
  final T data;

  /// HTTP status code for the response.
  ///
  /// Defaults to 200 (OK).
  final int statusCode;

  /// Additional HTTP headers for the response.
  final Map<String, String> headers;

  /// List of cookies to set in the response.
  final List<Cookie> cookies;

  /// Creates a page data response with the given [data].
  const PageData(
    this.data, {
    this.statusCode = 200,
    this.headers = const {},
    this.cookies = const [],
  });
}

/// Response indicating a redirect to another URL.
///
/// Use this to redirect users to a different page, for example after
/// authentication or when a resource has moved.
///
/// ## Usage
///
/// ```dart
/// // Basic redirect (302 Found)
/// return PageRedirect('/login');
///
/// // Permanent redirect (301)
/// return PageRedirect.permanent('/new-location');
///
/// // Temporary redirect (307)
/// return PageRedirect.temporary('/maintenance');
///
/// // With custom status code
/// return PageRedirect('/other', statusCode: 303);
/// ```
final class PageRedirect extends PageResponse<Never> {
  /// The URL to redirect to.
  ///
  /// Can be an absolute path (`/users/123`) or a full URL.
  final String location;

  /// HTTP status code for the redirect.
  ///
  /// Common values:
  /// - 301: Permanent redirect (cached by browsers)
  /// - 302: Found (temporary redirect, default)
  /// - 303: See Other (redirect after POST)
  /// - 307: Temporary Redirect (preserves method)
  /// - 308: Permanent Redirect (preserves method)
  final int statusCode;

  /// Additional HTTP headers for the response.
  final Map<String, String> headers;

  /// Creates a redirect response to the given [location].
  ///
  /// List of cookies to set in the response.
  final List<Cookie> cookies;

  /// Creates a redirect response to the given [location].
  ///
  /// Defaults to status code 302 (Found).
  const PageRedirect(
    this.location, {
    this.statusCode = 302,
    this.headers = const {},
    this.cookies = const [],
  });

  /// Creates a permanent redirect (301 Moved Permanently).
  ///
  /// Use this when a resource has permanently moved to a new location.
  /// Browsers will cache this redirect.
  const PageRedirect.permanent(
    String location, {
    List<Cookie> cookies = const [],
  }) : this(location, statusCode: 301, cookies: cookies);

  /// Creates a temporary redirect (307 Temporary Redirect).
  ///
  /// Use this for temporary redirects that preserve the HTTP method.
  const PageRedirect.temporary(
    String location, {
    List<Cookie> cookies = const [],
  }) : this(location, statusCode: 307, cookies: cookies);

  /// Creates a "See Other" redirect (303 See Other).
  ///
  /// Use this to redirect after a POST request to a GET endpoint.
  const PageRedirect.seeOther(
    String location, {
    List<Cookie> cookies = const [],
  }) : this(location, statusCode: 303, cookies: cookies);
}

/// Response for rendering an error page.
///
/// Use this to display error pages with appropriate HTTP status codes.
///
/// ## Usage
///
/// ```dart
/// // Generic server error (500)
/// return PageError('Something went wrong');
///
/// // Not found (404)
/// return PageError.notFound('User not found');
///
/// // Bad request (400)
/// return PageError.badRequest('Invalid ID format');
///
/// // Forbidden (403)
/// return PageError.forbidden('Access denied');
///
/// // With additional data for the error page
/// return PageError(
///   'Validation failed',
///   statusCode: 422,
///   data: {'errors': validationErrors},
/// );
/// ```
final class PageError extends PageResponse<Never> {
  /// The error message to display.
  final String message;

  /// HTTP status code for the error.
  ///
  /// Defaults to 500 (Internal Server Error).
  final int statusCode;

  /// Additional data for the error page template.
  final Map<String, dynamic> data;

  /// Creates an error response with the given [message].
  ///
  /// Defaults to status code 500 (Internal Server Error).
  /// List of cookies to set in the response.
  final List<Cookie> cookies;

  /// Creates an error response with the given [message].
  ///
  /// Defaults to status code 500 (Internal Server Error).
  const PageError(
    this.message, {
    this.statusCode = 500,
    this.data = const {},
    this.cookies = const [],
  });

  /// Creates a 404 Not Found error.
  const PageError.notFound([
    String message = 'Page not found',
    List<Cookie> cookies = const [],
  ]) : this(message, statusCode: 404, cookies: cookies);

  /// Creates a 403 Forbidden error.
  const PageError.forbidden([
    String message = 'Access denied',
    List<Cookie> cookies = const [],
  ]) : this(message, statusCode: 403, cookies: cookies);

  /// Creates a 400 Bad Request error.
  const PageError.badRequest([
    String message = 'Bad request',
    List<Cookie> cookies = const [],
  ]) : this(message, statusCode: 400, cookies: cookies);

  /// Creates a 401 Unauthorized error.
  const PageError.unauthorized([
    String message = 'Unauthorized',
    List<Cookie> cookies = const [],
  ]) : this(message, statusCode: 401, cookies: cookies);
}
