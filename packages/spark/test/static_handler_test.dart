import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:spark_framework/src/server/static_handler.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('static_handler_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// Helper to create a shelf Request.
  Request _request(
    String path, {
    Map<String, String>? headers,
  }) {
    return Request('GET', Uri.parse('http://localhost/$path'), headers: headers);
  }

  /// Helper to write a file with content into the temp directory.
  Future<File> _writeFile(String relativePath, String content) async {
    final file = File('${tempDir.path}/$relativePath');
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    return file;
  }

  group('createStaticHandler', () {
    group('file serving', () {
      test('serves existing file with correct content', () async {
        await _writeFile('hello.txt', 'Hello World');
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('hello.txt'));

        expect(response.statusCode, 200);
        expect(await response.readAsString(), 'Hello World');
      });

      test('serves correct MIME type for .js files', () async {
        await _writeFile('app.js', 'console.log("hi")');
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('app.js'));

        expect(response.statusCode, 200);
        expect(response.headers['content-type'], 'application/javascript');
      });

      test('serves correct MIME type for .css files', () async {
        await _writeFile('style.css', 'body {}');
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('style.css'));

        expect(response.headers['content-type'], 'text/css');
      });

      test('serves correct MIME type for .html files', () async {
        await _writeFile('page.html', '<html></html>');
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('page.html'));

        expect(response.headers['content-type'], 'text/html');
      });

      test('serves correct MIME type for .json files', () async {
        await _writeFile('data.json', '{}');
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('data.json'));

        expect(response.headers['content-type'], 'application/json');
      });

      test('serves correct MIME type for .wasm files', () async {
        await _writeFile('module.wasm', 'wasm-content');
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('module.wasm'));

        expect(response.headers['content-type'], 'application/wasm');
      });

      test('serves application/octet-stream for unknown extension', () async {
        await _writeFile('data.xyz', 'binary');
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('data.xyz'));

        expect(response.headers['content-type'], 'application/octet-stream');
      });

      test('returns 404 for non-existent file', () async {
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('missing.txt'));

        expect(response.statusCode, 404);
      });

      test('includes content-length header', () async {
        await _writeFile('sized.txt', 'ABCDE');
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            enableCaching: false,
            enableCompression: false,
          ),
        );
        final response = await handler(_request('sized.txt'));

        expect(response.headers['content-length'], '5');
      });
    });

    group('directory traversal prevention', () {
      test('blocks path traversal with ../', () async {
        // Create a file outside the served directory
        final parentFile = File('${tempDir.parent.path}/secret.txt');
        await parentFile.writeAsString('secret');
        addTearDown(() async {
          if (await parentFile.exists()) await parentFile.delete();
        });

        await _writeFile('safe.txt', 'safe');
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('../secret.txt'));

        expect(response.statusCode, 403);
        expect(await response.readAsString(), 'Access denied');
      });
    });

    group('default file', () {
      test('serves index.html when requesting directory root', () async {
        await _writeFile('index.html', '<html>Index</html>');
        final handler = createStaticHandler(tempDir.path);
        // Empty path = directory root
        final response = await handler(_request(''));

        expect(response.statusCode, 200);
        expect(await response.readAsString(), '<html>Index</html>');
      });

      test('serves custom default file', () async {
        await _writeFile('home.html', '<html>Home</html>');
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            defaultFile: 'home.html',
          ),
        );
        final response = await handler(_request(''));

        expect(response.statusCode, 200);
        expect(await response.readAsString(), '<html>Home</html>');
      });

      test('returns 404 when default file not found in directory', () async {
        // Create a subdirectory without index.html
        await Directory('${tempDir.path}/subdir').create();
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            defaultFile: null,
          ),
        );
        final response = await handler(_request('subdir'));

        expect(response.statusCode, 404);
      });
    });

    group('caching', () {
      test('adds ETag header when caching is enabled', () async {
        await _writeFile('cached.js', 'var x = 1;');
        final handler = createStaticHandler(tempDir.path);
        final response = await handler(_request('cached.js'));

        expect(response.headers['etag'], isNotNull);
        expect(response.headers['etag'], startsWith('"'));
        expect(response.headers['etag'], endsWith('"'));
      });

      test('sets cache-control with max-age for non-HTML', () async {
        await _writeFile('style.css', 'body {}');
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            maxAge: 3600,
          ),
        );
        final response = await handler(_request('style.css'));

        expect(
          response.headers['cache-control'],
          'public, max-age=3600',
        );
      });

      test('sets no-cache for HTML files with htmlMaxAge=0', () async {
        await _writeFile('page.html', '<html></html>');
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            htmlMaxAge: 0,
          ),
        );
        final response = await handler(_request('page.html'));

        expect(
          response.headers['cache-control'],
          'no-cache, no-store, must-revalidate',
        );
      });

      test('returns 304 when If-None-Match matches ETag', () async {
        await _writeFile('cached.js', 'var x = 1;');
        final handler = createStaticHandler(tempDir.path);

        // First request to get the ETag
        final firstResponse = await handler(_request('cached.js'));
        final etag = firstResponse.headers['etag']!;

        // Second request with If-None-Match
        final response = await handler(
          _request('cached.js', headers: {'if-none-match': etag}),
        );

        expect(response.statusCode, 304);
      });

      test('returns 200 when If-None-Match does not match', () async {
        await _writeFile('cached.js', 'var x = 1;');
        final handler = createStaticHandler(tempDir.path);

        final response = await handler(
          _request('cached.js', headers: {'if-none-match': '"stale"'}),
        );

        expect(response.statusCode, 200);
      });

      test('does not include cache headers when caching disabled', () async {
        await _writeFile('plain.js', 'var x = 1;');
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            enableCaching: false,
          ),
        );
        final response = await handler(_request('plain.js'));

        expect(response.headers['etag'], isNull);
        expect(response.headers['cache-control'], isNull);
      });
    });

    group('compression', () {
      test('compresses text-based files when client accepts gzip', () async {
        await _writeFile('app.js', 'var x = 1;' * 100);
        final handler = createStaticHandler(tempDir.path);

        final response = await handler(
          _request('app.js', headers: {'accept-encoding': 'gzip, deflate'}),
        );

        expect(response.headers['content-encoding'], 'gzip');
      });

      test('does not compress when client does not accept gzip', () async {
        await _writeFile('app.js', 'var x = 1;');
        final handler = createStaticHandler(tempDir.path);

        final response = await handler(_request('app.js'));

        expect(response.headers['content-encoding'], isNull);
      });

      test('does not compress binary files like images', () async {
        await _writeFile('image.png', 'fake-png-data');
        final handler = createStaticHandler(tempDir.path);

        final response = await handler(
          _request('image.png', headers: {'accept-encoding': 'gzip'}),
        );

        expect(response.headers['content-encoding'], isNull);
      });

      test('does not compress when compression is disabled', () async {
        await _writeFile('app.js', 'var x = 1;');
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            enableCompression: false,
          ),
        );

        final response = await handler(
          _request('app.js', headers: {'accept-encoding': 'gzip'}),
        );

        expect(response.headers['content-encoding'], isNull);
      });
    });

    group('directory listing', () {
      test('lists directory contents when enabled', () async {
        await _writeFile('subdir/file1.txt', 'a');
        await _writeFile('subdir/file2.txt', 'b');
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            listDirectories: true,
            defaultFile: null,
          ),
        );
        final response = await handler(_request('subdir'));

        expect(response.statusCode, 200);
        expect(response.headers['content-type'], 'text/html');
        final body = await response.readAsString();
        expect(body, contains('file1.txt'));
        expect(body, contains('file2.txt'));
        expect(body, contains('Index of /subdir'));
      });

      test('does not list directories when disabled', () async {
        await Directory('${tempDir.path}/empty').create();
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            listDirectories: false,
            defaultFile: null,
          ),
        );
        final response = await handler(_request('empty'));

        expect(response.statusCode, 404);
      });

      test('includes parent link for non-root directories', () async {
        await _writeFile('sub/file.txt', 'data');
        final handler = createStaticHandler(
          tempDir.path,
          config: StaticHandlerConfig(
            path: tempDir.path,
            listDirectories: true,
            defaultFile: null,
          ),
        );
        final response = await handler(_request('sub'));
        final body = await response.readAsString();

        expect(body, contains('<a href="../">'));
      });
    });
  });

  group('simpleStaticHandler', () {
    test('serves existing file', () async {
      await _writeFile('hello.txt', 'Hello');
      final handler = simpleStaticHandler(tempDir.path);
      final response = await handler(_request('hello.txt'));

      expect(response.statusCode, 200);
    });

    test('returns correct MIME type', () async {
      await _writeFile('app.js', 'code');
      final handler = simpleStaticHandler(tempDir.path);
      final response = await handler(_request('app.js'));

      expect(response.headers['content-type'], 'application/javascript');
    });

    test('returns 404 for missing file', () async {
      final handler = simpleStaticHandler(tempDir.path);
      final response = await handler(_request('nope.txt'));

      expect(response.statusCode, 404);
    });
  });

  group('StaticHandlerConfig', () {
    test('has correct default values', () {
      const config = StaticHandlerConfig(path: '/web');
      expect(config.path, '/web');
      expect(config.enableCaching, isTrue);
      expect(config.maxAge, 86400);
      expect(config.htmlMaxAge, 0);
      expect(config.enableCompression, isTrue);
      expect(config.listDirectories, isFalse);
      expect(config.defaultFile, 'index.html');
    });

    test('accepts custom values', () {
      const config = StaticHandlerConfig(
        path: '/assets',
        enableCaching: false,
        maxAge: 1800,
        htmlMaxAge: 300,
        enableCompression: false,
        listDirectories: true,
        defaultFile: 'home.html',
      );
      expect(config.enableCaching, isFalse);
      expect(config.maxAge, 1800);
      expect(config.htmlMaxAge, 300);
      expect(config.enableCompression, isFalse);
      expect(config.listDirectories, isTrue);
      expect(config.defaultFile, 'home.html');
    });
  });
}
