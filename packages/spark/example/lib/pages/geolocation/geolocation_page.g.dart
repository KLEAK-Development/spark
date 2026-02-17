// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geolocation_page.dart';

// **************************************************************************
// PageGenerator
// **************************************************************************

// Route: /geolocation
// Methods: [GET]
// Path params: []

/// Route information for [GeolocationPage].
const _$GeolocationPageRoute = (
  path: '/geolocation',
  methods: <String>[GET],
  pathParams: <String>[],
  className: 'GeolocationPage',
);

/// Handler for [GeolocationPage] at `/geolocation`.
Future<Response> _$handleGeolocationPage(Request request) async {
  final page = GeolocationPage();
  var pipeline = const Pipeline();
  for (final middleware in page.middleware) {
    pipeline = pipeline.addMiddleware(middleware);
  }

  final handler = (Request req) async {
    final pageRequest = PageRequest(shelfRequest: req, pathParams: {});

    final response = await page.loader(pageRequest);

    return switch (response) {
      PageData(
        :final data,
        :final statusCode,
        :final headers,
        :final cookies,
      ) =>
        _$renderPageResponse(
          page,
          data,
          pageRequest,
          statusCode,
          headers,
          cookies,
          'geolocation/geolocation_page.dart.js',
          req.context['spark.nonce'] as String?,
        ),
      PageRedirect(
        :final location,
        :final statusCode,
        :final headers,
        :final cookies,
      ) =>
        Response(
          statusCode,
          headers: {
            ...headers,
            'location': location,
            if (cookies.isNotEmpty)
              HttpHeaders.setCookieHeader: cookies
                  .map((c) => c.toString())
                  .toList(),
          },
        ),
      PageError(:final message, :final statusCode, :final cookies) =>
        _$renderErrorResponse(message, statusCode, cookies),
    };
  };

  return pipeline.addHandler(handler)(request);
}
