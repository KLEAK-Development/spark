import 'dart:convert';
import 'package:shelf/shelf.dart' as shelf;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../server/request_extensions.dart';

/// Request context for page loaders.
///
/// Provides access to the underlying Shelf request along with
/// parsed path parameters, query parameters, and other utilities.
///
/// ## Usage
///
/// ```dart
/// @override
/// Future<PageResponse<User>> loader(PageRequest request) async {
///   // Path parameters from route pattern
///   final userId = request.pathParamInt('id');
///
///   // Query parameters from URL
///   final page = request.queryParamInt('page', 1);
///   final sortBy = request.queryParam('sort', 'name');
///
///   // Headers
///   final authHeader = request.header('authorization');
///
///   // Cookies
///   final sessionId = request.cookie('session_id');
///
///   // Access context added by middleware
///   final user = request.context['user'] as User?;
///
///   // ...
/// }
/// ```
class SparkRequest {
  /// The underlying Shelf request.
  final shelf.Request shelfRequest;

  /// Path parameters extracted from the URL pattern.
  ///
  /// For a route `/users/:id` and URL `/users/123`,
  /// this would be `{'id': '123'}`.
  final Map<String, String> pathParams;

  /// Creates a page request wrapping a Shelf request.
  const SparkRequest({required this.shelfRequest, required this.pathParams});

  /// Query parameters from the URL.
  ///
  /// For URL `/users?sort=name&order=asc`,
  /// this would be `{'sort': 'name', 'order': 'asc'}`.
  Map<String, String> get queryParams => shelfRequest.url.queryParameters;

  /// All query parameters including duplicates.
  ///
  /// For URL `/users?tag=dart&tag=flutter`,
  /// this would be `{'tag': ['dart', 'flutter']}`.
  Map<String, List<String>> get queryParamsAll =>
      shelfRequest.url.queryParametersAll;

  /// HTTP headers from the request.
  Map<String, String> get headers => shelfRequest.headers;

  /// The full requested URI.
  Uri get uri => shelfRequest.requestedUri;

  /// The HTTP method (GET, POST, etc.).
  String get method => shelfRequest.method;

  /// The URL path.
  String get path => shelfRequest.url.path;

  /// Request context for middleware-added data.
  ///
  /// This is where middleware like authentication adds user data:
  /// ```dart
  /// final user = request.context['user'] as User?;
  /// ```
  Map<String, Object> get context => shelfRequest.context;

  /// Gets a value from the request context provided via middleware.
  ///
  /// This forwards to `shelfRequest.get<T>()`.
  T get<T>() => shelfRequest.get<T>();

  /// Gets a path parameter by name.
  ///
  /// Returns [defaultValue] if the parameter doesn't exist.
  ///
  /// ```dart
  /// final id = request.pathParam('id', '0');
  /// ```
  String pathParam(String name, [String defaultValue = '']) {
    return pathParams[name] ?? defaultValue;
  }

  /// Gets a path parameter as an integer.
  ///
  /// Returns [defaultValue] if the parameter doesn't exist or isn't a valid int.
  ///
  /// ```dart
  /// final id = request.pathParamInt('id');
  /// final page = request.pathParamInt('page', 1);
  /// ```
  int pathParamInt(String name, [int defaultValue = 0]) {
    final value = pathParams[name];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Gets a query parameter by name.
  ///
  /// Returns [defaultValue] if the parameter doesn't exist.
  ///
  /// ```dart
  /// final sort = request.queryParam('sort', 'name');
  /// ```
  String queryParam(String name, [String defaultValue = '']) {
    return queryParams[name] ?? defaultValue;
  }

  /// Gets a query parameter as an integer.
  ///
  /// Returns [defaultValue] if the parameter doesn't exist or isn't a valid int.
  ///
  /// ```dart
  /// final page = request.queryParamInt('page', 1);
  /// final limit = request.queryParamInt('limit', 20);
  /// ```
  int queryParamInt(String name, [int defaultValue = 0]) {
    final value = queryParams[name];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Gets a query parameter as a double.
  ///
  /// Returns [defaultValue] if the parameter doesn't exist or isn't a valid double.
  double queryParamDouble(String name, [double defaultValue = 0.0]) {
    final value = queryParams[name];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// Gets a query parameter as a boolean.
  ///
  /// Returns `true` if the value is 'true' or '1', [defaultValue] otherwise.
  ///
  /// ```dart
  /// final includeDeleted = request.queryParamBool('deleted', false);
  /// ```
  bool queryParamBool(String name, [bool defaultValue = false]) {
    final value = queryParams[name];
    if (value == null) return defaultValue;
    return value == 'true' || value == '1';
  }

  /// Gets all values for a query parameter.
  ///
  /// Useful for parameters that can appear multiple times:
  /// ```dart
  /// // URL: /posts?tag=dart&tag=flutter
  /// final tags = request.queryParamAll('tag'); // ['dart', 'flutter']
  /// ```
  List<String> queryParamAll(String name) {
    return queryParamsAll[name] ?? [];
  }

  /// Gets a header value by name (case-insensitive).
  ///
  /// ```dart
  /// final contentType = request.header('content-type');
  /// final auth = request.header('authorization');
  /// ```
  String? header(String name) => headers[name.toLowerCase()];

  /// Gets all cookies from the request.
  ///
  /// Parses the Cookie header into a map of name-value pairs.
  Map<String, String> get cookies {
    final cookieHeader = header('cookie');
    if (cookieHeader == null) return {};

    return Map.fromEntries(
      cookieHeader.split(';').map((cookie) {
        final parts = cookie.trim().split('=');
        return MapEntry(
          parts[0],
          parts.length > 1 ? parts.sublist(1).join('=') : '',
        );
      }),
    );
  }

  /// Gets a specific cookie value by name.
  ///
  /// ```dart
  /// final sessionId = request.cookie('session_id');
  /// ```
  String? cookie(String name) => cookies[name];

  /// Reads the request body as a string.
  ///
  /// Use this for form data or JSON payloads.
  ///
  /// ```dart
  /// final body = await request.readBody();
  /// final data = jsonDecode(body);
  /// ```
  Future<String> readBody() => shelfRequest.readAsString();

  /// Creates a new SparkRequest with additional context.
  ///
  /// Useful for adding data in middleware.
  SparkRequest withContext(Map<String, Object> additionalContext) {
    return SparkRequest(
      shelfRequest: shelfRequest.change(
        context: {...shelfRequest.context, ...additionalContext},
      ),
      pathParams: pathParams,
    );
  }

  /// Creates a new SparkRequest with modified path parameters.
  SparkRequest withPathParams(Map<String, String> newPathParams) {
    return SparkRequest(
      shelfRequest: shelfRequest,
      pathParams: {...pathParams, ...newPathParams},
    );
  }

  /// PARSES the request body as a multipart stream.
  ///
  /// This allows processing large file uploads without loading the entire body into memory.
  /// Use [MultipartPart.readString] for text fields and [MultipartPart.stream] for files.
  Stream<MultipartPart> get multipart {
    final contentType = mediaType;
    if (contentType == null ||
        contentType.type != 'multipart' ||
        contentType.subtype != 'form-data') {
      return const Stream.empty();
    }

    final boundary = contentType.parameters['boundary'];
    if (boundary == null) {
      return const Stream.empty();
    }

    return MimeMultipartTransformer(
      boundary,
    ).bind(shelfRequest.read()).map((part) => MultipartPart(part));
  }

  /// Helper to get generic MediaType.
  MediaType? get mediaType {
    final contentType = header('content-type');
    if (contentType == null) return null;
    try {
      return MediaType.parse(contentType);
    } catch (_) {
      return null;
    }
  }
}

/// Represents a part in a multipart request.
class MultipartPart {
  final MimeMultipart _original;

  MultipartPart(this._original);

  /// The headers of this part.
  Map<String, String> get headers => _original.headers;

  /// The stream of bytes for this part.
  Stream<List<int>> get stream => _original;

  String? _getHeaderParam(String headerName, String paramName) {
    final headerValue = headers[headerName];
    if (headerValue == null) return null;

    // Simple regex to extract parameter values like name="value"
    final regex = RegExp('$paramName="?([^";]+)"?');
    final match = regex.firstMatch(headerValue);
    return match?.group(1);
  }

  /// The name of the form field.
  String? get name => _getHeaderParam('content-disposition', 'name');

  /// The filename if this part is a file.
  String? get filename => _getHeaderParam('content-disposition', 'filename');

  /// Reads the part content as a string (utf8 decoded).
  Future<String> readString() async {
    return utf8.decodeStream(_original);
  }
}

/// Legacy alias for backward compatibility.
typedef PageRequest = SparkRequest;
