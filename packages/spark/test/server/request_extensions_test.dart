import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:spark_framework/src/server/request_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('RequestClientIp', () {
    test('returns ip from x-forwarded-for header', () {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'x-forwarded-for': '1.2.3.4, 5.6.7.8'},
      );
      expect(request.clientIp, '1.2.3.4');
    });

    test('returns null if x-forwarded-for is empty', () {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'x-forwarded-for': ''},
      );
      expect(request.clientIp, null);
    });

    test('returns ip from connection info if header is missing', () {
      final connectionInfo = _MockHttpConnectionInfo(
        InternetAddress('9.8.7.6', type: InternetAddressType.IPv4),
      );

      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        context: {'shelf.io.connection_info': connectionInfo},
      );
      expect(request.clientIp, '9.8.7.6');
    });

    test('prioritizes header over connection info', () {
      final connectionInfo = _MockHttpConnectionInfo(
        InternetAddress('9.8.7.6', type: InternetAddressType.IPv4),
      );
      final request = Request(
        'GET',
        Uri.parse('http://localhost/'),
        headers: {'x-forwarded-for': '1.2.3.4'},
        context: {'shelf.io.connection_info': connectionInfo},
      );
      expect(request.clientIp, '1.2.3.4');
    });

    test('returns null if both missing', () {
      final request = Request('GET', Uri.parse('http://localhost/'));
      expect(request.clientIp, null);
    });
  });
}

class _MockHttpConnectionInfo implements HttpConnectionInfo {
  @override
  final InternetAddress remoteAddress;

  _MockHttpConnectionInfo(this.remoteAddress);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
