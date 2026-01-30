import 'dart:io';

import 'package:shelf/shelf.dart';

extension RequestClientIp on Request {
  /// The client's IP address.
  ///
  /// This first checks the `x-forwarded-for` header and returns the first
  /// address if present. Otherwise, it falls back to the connection info's
  /// remote address.
  String? get clientIp {
    final forwardedFor = headers['x-forwarded-for'];
    if (forwardedFor != null && forwardedFor.isNotEmpty) {
      final parts = forwardedFor.split(',');
      if (parts.isNotEmpty) {
        return parts.first.trim();
      }
    }

    final connectionInfo = context['shelf.io.connection_info'];
    if (connectionInfo != null) {
      final info = connectionInfo as HttpConnectionInfo;
      return info.remoteAddress.address;
    }

    return null;
  }
}
