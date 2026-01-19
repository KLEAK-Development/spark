import 'dart:convert';
import 'package:spark_framework/spark.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('SparkRequest Multipart', () {
    test('parses multipart fields and files', () async {
      final boundary = 'boundary';
      final body =
          '--$boundary\r\n'
          'content-disposition: form-data; name="field1"\r\n'
          '\r\n'
          'value1\r\n'
          '--$boundary\r\n'
          'content-disposition: form-data; name="file1"; filename="test.txt"\r\n'
          'content-type: text/plain\r\n'
          '\r\n'
          'file content\r\n'
          '--$boundary--\r\n';

      final request = Request(
        'POST',
        Uri.parse('http://localhost/upload'),
        headers: {'content-type': 'multipart/form-data; boundary=$boundary'},
        body: body,
      );

      final sparkRequest = SparkRequest(shelfRequest: request, pathParams: {});

      final parts = await sparkRequest.multipart.toList();
      expect(parts, hasLength(2));

      // Check field
      final fieldPart = parts[0];
      expect(fieldPart.name, 'field1');
      expect(fieldPart.filename, isNull);
      expect(await fieldPart.readString(), 'value1');

      // Check file
      final filePart = parts[1];
      expect(filePart.name, 'file1');
      expect(filePart.filename, 'test.txt');
      expect(await utf8.decodeStream(filePart.stream), 'file content');
    });

    test('returns empty stream for non-multipart request', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/upload'),
        body: 'simple body',
      );

      final sparkRequest = SparkRequest(shelfRequest: request, pathParams: {});

      expect(await sparkRequest.multipart.isEmpty, isTrue);
    });
  });
}
