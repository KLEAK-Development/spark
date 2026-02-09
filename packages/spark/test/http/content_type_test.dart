@TestOn('vm')
library;

import 'package:spark_framework/spark.dart';
import 'package:test/test.dart';

void main() {
  group('ContentType.from', () {
    test('returns ContentType.json for application/json', () {
      expect(ContentType.from('application/json'), equals(ContentType.json));
    });

    test('returns ContentType.json for application/json with charset', () {
      expect(
        ContentType.from('application/json; charset=utf-8'),
        equals(ContentType.json),
      );
    });

    test('returns ContentType.formUrlEncoded for application/x-www-form-urlencoded', () {
      expect(
        ContentType.from('application/x-www-form-urlencoded'),
        equals(ContentType.formUrlEncoded),
      );
    });

    test('returns ContentType.multipart for multipart/form-data', () {
      expect(
        ContentType.from('multipart/form-data'),
        equals(ContentType.multipart),
      );
    });

    test('returns ContentType.multipart for multipart/form-data with boundary', () {
      expect(
        ContentType.from('multipart/form-data; boundary=something'),
        equals(ContentType.multipart),
      );
    });

    test('returns ContentType.text for text/*', () {
      expect(ContentType.from('text/plain'), equals(ContentType.text));
      expect(ContentType.from('text/html'), equals(ContentType.text));
      expect(ContentType.from('text/css'), equals(ContentType.text));
    });

    test('returns ContentType.binary for application/octet-stream', () {
      expect(
        ContentType.from('application/octet-stream'),
        equals(ContentType.binary),
      );
    });

    test('returns ContentType.unknown for unknown mime type', () {
      expect(ContentType.from('application/unknown'), equals(ContentType.unknown));
    });

    test('returns ContentType.unknown for null', () {
      expect(ContentType.from(null), equals(ContentType.unknown));
    });

    test('returns ContentType.unknown for empty string', () {
      expect(ContentType.from(''), equals(ContentType.unknown));
    });

    test('is case insensitive', () {
      expect(ContentType.from('APPLICATION/JSON'), equals(ContentType.json));
    });

    // These tests will fail with the current implementation because it uses contains()
    test('returns ContentType.unknown for invalid partial matches', () {
      expect(ContentType.from('not-application/json'), equals(ContentType.unknown));
      expect(ContentType.from('application/json-fake'), equals(ContentType.unknown));
      expect(ContentType.from('multipart/form-data-fake'), equals(ContentType.unknown));
    });
  });
}
