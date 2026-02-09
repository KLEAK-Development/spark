/// Static file handler for serving compiled assets.
library;

import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

/// MIME type mappings for common file extensions.
const Map<String, String> _mimeTypes = {
  // JavaScript
  '.js': 'application/javascript',
  '.mjs': 'application/javascript',

  // CSS
  '.css': 'text/css',

  // HTML
  '.html': 'text/html',
  '.htm': 'text/html',

  // JSON
  '.json': 'application/json',

  // Images
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.webp': 'image/webp',

  // Fonts
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.eot': 'application/vnd.ms-fontobject',

  // Other
  '.xml': 'application/xml',
  '.txt': 'text/plain',
  '.pdf': 'application/pdf',
  '.zip': 'application/zip',
  '.wasm': 'application/wasm',
  '.map': 'application/json', // Source maps
};

/// Configuration for the static file handler.
class StaticHandlerConfig {
  /// The directory to serve files from.
  final String path;

  /// Whether to enable caching headers.
  final bool enableCaching;

  /// Cache-Control max-age in seconds for cacheable files.
  final int maxAge;

  /// Cache-Control max-age in seconds for HTML files (typically shorter).
  final int htmlMaxAge;

  /// Whether to enable gzip compression.
  final bool enableCompression;

  /// Whether to list directory contents when a directory is requested.
  final bool listDirectories;

  /// Default file to serve when a directory is requested.
  final String? defaultFile;

  /// Creates static handler configuration.
  const StaticHandlerConfig({
    required this.path,
    this.enableCaching = true,
    this.maxAge = 86400, // 1 day
    this.htmlMaxAge = 0, // No caching for HTML by default
    this.enableCompression = true,
    this.listDirectories = false,
    this.defaultFile = 'index.html',
  });
}

/// Creates a Shelf handler for serving static files.
///
/// ## Example
///
/// ```dart
/// final app = Router();
///
/// // Serve compiled assets from build/web
/// app.mount('/', createStaticHandler('build/web'));
///
/// // Or with configuration
/// app.mount('/', createStaticHandler(
///   'build/web',
///   config: StaticHandlerConfig(
///     path: 'build/web',
///     enableCaching: true,
///     maxAge: 86400,
///   ),
/// ));
/// ```
Handler createStaticHandler(String path, {StaticHandlerConfig? config}) {
  config ??= StaticHandlerConfig(path: path);

  return (Request request) async {
    var filePath = request.url.path;

    // Remove leading slash if present
    if (filePath.startsWith('/')) {
      filePath = filePath.substring(1);
    }

    // Construct full file path
    final fullPath = filePath.isEmpty
        ? config!.path
        : '${config!.path}/$filePath';

    // Check for directory traversal attacks
    final normalizedPath = File(fullPath).absolute.path;
    final basePath = Directory(config.path).absolute.path;
    if (!normalizedPath.startsWith(basePath)) {
      return Response.forbidden('Access denied');
    }

    final file = File(fullPath);
    final dir = Directory(fullPath);

    // Handle directory requests
    if (await dir.exists()) {
      if (config.defaultFile != null) {
        final defaultFile = File('$fullPath/${config.defaultFile}');
        if (await defaultFile.exists()) {
          return _serveFile(defaultFile, config, request);
        }
      }

      if (config.listDirectories) {
        return _listDirectory(dir, filePath);
      }

      return Response.notFound('Not found');
    }

    // Handle file requests
    if (await file.exists()) {
      return _serveFile(file, config, request);
    }

    return Response.notFound('Not found');
  };
}

/// Serves a file with appropriate headers.
Future<Response> _serveFile(
  File file,
  StaticHandlerConfig config,
  Request request,
) async {
  final extension = _getExtension(file.path);
  final mimeType = _mimeTypes[extension] ?? 'application/octet-stream';

  // Read file
  final bytes = await file.readAsBytes();

  // Build headers
  final headers = <String, Object>{'content-type': mimeType};

  // Add caching headers
  if (config.enableCaching) {
    final maxAge = extension == '.html' || extension == '.htm'
        ? config.htmlMaxAge
        : config.maxAge;

    if (maxAge > 0) {
      headers['cache-control'] = 'public, max-age=$maxAge';
    } else {
      headers['cache-control'] = 'no-cache, no-store, must-revalidate';
    }

    // Add ETag based on file modification time
    final stat = await file.stat();
    final etag = '"${stat.modified.millisecondsSinceEpoch}"';
    headers['etag'] = etag;

    // Check if client has cached version
    final ifNoneMatch = request.headers['if-none-match'];
    if (ifNoneMatch == etag) {
      return Response.notModified(headers: headers.cast<String, String>());
    }
  }

  // Check if client accepts gzip
  if (config.enableCompression && _shouldCompress(mimeType)) {
    final acceptEncoding = request.headers['accept-encoding'] ?? '';
    if (acceptEncoding.contains('gzip')) {
      final compressed = gzip.encode(bytes);
      headers['content-encoding'] = 'gzip';
      headers['content-length'] = compressed.length.toString();
      return Response.ok(compressed, headers: headers.cast<String, String>());
    }
  }

  headers['content-length'] = bytes.length.toString();
  return Response.ok(bytes, headers: headers.cast<String, String>());
}

/// Lists directory contents as HTML.
Response _listDirectory(Directory dir, String requestPath) {
  const htmlEscape = HtmlEscape();
  final safeRequestPath = htmlEscape.convert(requestPath);

  final buffer = StringBuffer();
  buffer.writeln('<!DOCTYPE html>');
  buffer.writeln(
    '<html><head><title>Index of /$safeRequestPath</title></head>',
  );
  buffer.writeln('<body><h1>Index of /$safeRequestPath</h1><ul>');

  if (requestPath.isNotEmpty) {
    buffer.writeln('<li><a href="../">..</a></li>');
  }

  for (final entity in dir.listSync()) {
    final name = entity.path.split('/').last;
    final isDir = entity is Directory;
    final safeName = htmlEscape.convert(name);
    final url = Uri.encodeComponent(name);

    buffer.writeln(
      '<li><a href="$url${isDir ? '/' : ''}">$safeName${isDir ? '/' : ''}</a></li>',
    );
  }

  buffer.writeln('</ul></body></html>');

  return Response.ok(buffer.toString(), headers: {'content-type': 'text/html'});
}

/// Gets the file extension from a path.
String _getExtension(String path) {
  final lastDot = path.lastIndexOf('.');
  if (lastDot == -1) return '';
  return path.substring(lastDot).toLowerCase();
}

/// Determines if a MIME type should be compressed.
bool _shouldCompress(String mimeType) {
  // Compress text-based and certain binary formats
  return mimeType.startsWith('text/') ||
      mimeType.startsWith('application/javascript') ||
      mimeType.startsWith('application/json') ||
      mimeType.startsWith('application/xml') ||
      mimeType == 'image/svg+xml' ||
      mimeType == 'application/wasm';
}
