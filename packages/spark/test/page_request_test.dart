import 'package:shelf/shelf.dart' as shelf;
import 'package:spark_framework/spark.dart';
import 'package:test/test.dart';

/// Creates a SparkRequest wrapping a shelf Request with the given URL and options.
SparkRequest _makeRequest(
  String url, {
  String method = 'GET',
  Map<String, String> pathParams = const {},
  Map<String, String>? headers,
  String? body,
}) {
  return SparkRequest(
    shelfRequest: shelf.Request(
      method,
      Uri.parse(url),
      headers: headers,
      body: body,
    ),
    pathParams: pathParams,
  );
}

void main() {
  group('SparkRequest', () {
    group('basic properties', () {
      test('exposes method', () {
        final req = _makeRequest('http://localhost/', method: 'POST');
        expect(req.method, 'POST');
      });

      test('exposes path', () {
        final req = _makeRequest('http://localhost/users/123');
        expect(req.path, 'users/123');
      });

      test('exposes uri', () {
        final req = _makeRequest('http://localhost/test?a=1');
        expect(req.uri.toString(), 'http://localhost/test?a=1');
      });

      test('exposes headers', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'x-custom': 'value'},
        );
        expect(req.headers['x-custom'], 'value');
      });
    });

    group('pathParam', () {
      test('returns path parameter value', () {
        final req = _makeRequest(
          'http://localhost/users/42',
          pathParams: {'id': '42'},
        );
        expect(req.pathParam('id'), '42');
      });

      test('returns default value when parameter missing', () {
        final req = _makeRequest('http://localhost/');
        expect(req.pathParam('id', 'default'), 'default');
      });

      test('returns empty string as default when no default specified', () {
        final req = _makeRequest('http://localhost/');
        expect(req.pathParam('id'), '');
      });
    });

    group('pathParamInt', () {
      test('parses integer path parameter', () {
        final req = _makeRequest(
          'http://localhost/users/42',
          pathParams: {'id': '42'},
        );
        expect(req.pathParamInt('id'), 42);
      });

      test('returns default for missing parameter', () {
        final req = _makeRequest('http://localhost/');
        expect(req.pathParamInt('id', 5), 5);
      });

      test('returns default for non-integer value', () {
        final req = _makeRequest(
          'http://localhost/',
          pathParams: {'id': 'abc'},
        );
        expect(req.pathParamInt('id', 99), 99);
      });

      test('returns 0 as default when no default specified', () {
        final req = _makeRequest('http://localhost/');
        expect(req.pathParamInt('id'), 0);
      });
    });

    group('queryParam', () {
      test('returns query parameter value', () {
        final req = _makeRequest('http://localhost/?sort=name');
        expect(req.queryParam('sort'), 'name');
      });

      test('returns default when parameter missing', () {
        final req = _makeRequest('http://localhost/');
        expect(req.queryParam('sort', 'id'), 'id');
      });

      test('returns empty string as default', () {
        final req = _makeRequest('http://localhost/');
        expect(req.queryParam('sort'), '');
      });
    });

    group('queryParamInt', () {
      test('parses integer query parameter', () {
        final req = _makeRequest('http://localhost/?page=3');
        expect(req.queryParamInt('page'), 3);
      });

      test('returns default for missing parameter', () {
        final req = _makeRequest('http://localhost/');
        expect(req.queryParamInt('page', 1), 1);
      });

      test('returns default for non-integer value', () {
        final req = _makeRequest('http://localhost/?page=abc');
        expect(req.queryParamInt('page', 1), 1);
      });
    });

    group('queryParamDouble', () {
      test('parses double query parameter', () {
        final req = _makeRequest('http://localhost/?price=9.99');
        expect(req.queryParamDouble('price'), 9.99);
      });

      test('returns default for missing parameter', () {
        final req = _makeRequest('http://localhost/');
        expect(req.queryParamDouble('price', 0.5), 0.5);
      });

      test('returns default for non-numeric value', () {
        final req = _makeRequest('http://localhost/?price=free');
        expect(req.queryParamDouble('price', 0.0), 0.0);
      });
    });

    group('queryParamBool', () {
      test('returns true for "true"', () {
        final req = _makeRequest('http://localhost/?active=true');
        expect(req.queryParamBool('active'), isTrue);
      });

      test('returns true for "1"', () {
        final req = _makeRequest('http://localhost/?active=1');
        expect(req.queryParamBool('active'), isTrue);
      });

      test('returns false for "false"', () {
        final req = _makeRequest('http://localhost/?active=false');
        expect(req.queryParamBool('active'), isFalse);
      });

      test('returns false for "0"', () {
        final req = _makeRequest('http://localhost/?active=0');
        expect(req.queryParamBool('active'), isFalse);
      });

      test('returns default for missing parameter', () {
        final req = _makeRequest('http://localhost/');
        expect(req.queryParamBool('active', true), isTrue);
      });

      test('returns false for arbitrary string', () {
        final req = _makeRequest('http://localhost/?active=yes');
        expect(req.queryParamBool('active'), isFalse);
      });
    });

    group('queryParamAll', () {
      test('returns all values for repeated parameter', () {
        final req = _makeRequest('http://localhost/?tag=dart&tag=flutter');
        expect(req.queryParamAll('tag'), ['dart', 'flutter']);
      });

      test('returns empty list for missing parameter', () {
        final req = _makeRequest('http://localhost/');
        expect(req.queryParamAll('tag'), isEmpty);
      });

      test('returns single-element list for single value', () {
        final req = _makeRequest('http://localhost/?tag=dart');
        expect(req.queryParamAll('tag'), ['dart']);
      });
    });

    group('header', () {
      test('returns header value', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'authorization': 'Bearer token123'},
        );
        expect(req.header('authorization'), 'Bearer token123');
      });

      test('is case-insensitive', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'content-type': 'application/json'},
        );
        expect(req.header('content-type'), 'application/json');
      });

      test('returns null for missing header', () {
        final req = _makeRequest('http://localhost/');
        expect(req.header('x-missing'), isNull);
      });
    });

    group('cookies', () {
      test('parses single cookie', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'cookie': 'session=abc123'},
        );
        expect(req.cookies, {'session': 'abc123'});
      });

      test('parses multiple cookies', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'cookie': 'session=abc123; theme=dark; lang=en'},
        );
        expect(req.cookies, {
          'session': 'abc123',
          'theme': 'dark',
          'lang': 'en',
        });
      });

      test('handles cookie values containing equals sign', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'cookie': 'token=abc=def=ghi'},
        );
        expect(req.cookies['token'], 'abc=def=ghi');
      });

      test('returns empty map when no cookie header', () {
        final req = _makeRequest('http://localhost/');
        expect(req.cookies, isEmpty);
      });

      test('handles cookie with empty value', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'cookie': 'empty='},
        );
        expect(req.cookies['empty'], '');
      });
    });

    group('cookie', () {
      test('returns specific cookie value', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'cookie': 'session=abc; theme=dark'},
        );
        expect(req.cookie('theme'), 'dark');
      });

      test('returns null for missing cookie', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'cookie': 'session=abc'},
        );
        expect(req.cookie('missing'), isNull);
      });
    });

    group('readBody', () {
      test('reads request body as string', () async {
        final req = _makeRequest(
          'http://localhost/',
          method: 'POST',
          body: '{"name": "test"}',
        );
        expect(await req.readBody(), '{"name": "test"}');
      });

      test('reads empty body', () async {
        final req = _makeRequest('http://localhost/', method: 'POST', body: '');
        expect(await req.readBody(), '');
      });
    });

    group('mediaType', () {
      test('parses content-type header', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
        final mt = req.mediaType;
        expect(mt, isNotNull);
        expect(mt!.type, 'application');
        expect(mt.subtype, 'json');
      });

      test('returns null when no content-type header', () {
        final req = _makeRequest('http://localhost/');
        expect(req.mediaType, isNull);
      });

      test('returns null for malformed content-type', () {
        final req = _makeRequest(
          'http://localhost/',
          headers: {'content-type': ':::invalid:::'},
        );
        expect(req.mediaType, isNull);
      });
    });

    group('multipart', () {
      test('returns empty stream for non-multipart content type', () async {
        final req = _makeRequest(
          'http://localhost/',
          method: 'POST',
          headers: {'content-type': 'application/json'},
          body: '{}',
        );
        expect(await req.multipart.isEmpty, isTrue);
      });

      test('returns empty stream when no content-type', () async {
        final req = _makeRequest(
          'http://localhost/',
          method: 'POST',
          body: 'data',
        );
        expect(await req.multipart.isEmpty, isTrue);
      });
    });

    group('withContext', () {
      test('adds new context entries', () {
        final req = _makeRequest('http://localhost/');
        final updated = req.withContext({'user': 'alice' as Object});
        expect(updated.context['user'], 'alice');
      });

      test('preserves path params', () {
        final req = _makeRequest(
          'http://localhost/',
          pathParams: {'id': '1'},
        );
        final updated = req.withContext({'key': 'val' as Object});
        expect(updated.pathParams['id'], '1');
      });
    });

    group('withPathParams', () {
      test('merges new path params', () {
        final req = _makeRequest(
          'http://localhost/',
          pathParams: {'id': '1'},
        );
        final updated = req.withPathParams({'slug': 'hello'});
        expect(updated.pathParams['id'], '1');
        expect(updated.pathParams['slug'], 'hello');
      });

      test('overrides existing path params', () {
        final req = _makeRequest(
          'http://localhost/',
          pathParams: {'id': '1'},
        );
        final updated = req.withPathParams({'id': '2'});
        expect(updated.pathParams['id'], '2');
      });
    });

    group('queryParams', () {
      test('returns query parameters map', () {
        final req = _makeRequest('http://localhost/?a=1&b=2');
        expect(req.queryParams, {'a': '1', 'b': '2'});
      });

      test('returns empty map for no query string', () {
        final req = _makeRequest('http://localhost/');
        expect(req.queryParams, isEmpty);
      });
    });

    group('PageRequest typedef', () {
      test('PageRequest is alias for SparkRequest', () {
        final req = _makeRequest('http://localhost/');
        // PageRequest is a typedef for SparkRequest
        expect(req, isA<PageRequest>());
      });
    });
  });
}
