import 'dart:io';

import 'package:shelf/shelf.dart';

extension RequestClientIp on Request {
  /// The client's IP address.
  ///
  /// This first checks the `x-forwarded-for` header and returns the first
  /// address if present. Otherwise, it falls back to the connection info's
  /// remote address.
  String? get clientIp {
    // Check X-Forwarded-For header (may contain multiple IPs)
    final forwarded = headers['x-forwarded-for'];
    if (forwarded != null && forwarded.isNotEmpty) {
      // Take the first IP (original client)
      return forwarded.split(',').first.trim();
    }

    // Check X-Real-IP header
    final realIp = headers['x-real-ip'];
    if (realIp != null && realIp.isNotEmpty) {
      return realIp.trim();
    }

    // Fall back to connection info
    final connectionInfo =
        context['shelf.io.connection_info'] as HttpConnectionInfo?;
    return connectionInfo?.remoteAddress.address;
  }
}
