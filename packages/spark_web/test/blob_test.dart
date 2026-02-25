@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Blob (Server)', () {
    test('instantiates and has properties', () {
      final blob = web.createBlob(['hello'], 'text/plain');
      expect(blob.size, 0);
      expect(blob.type, '');
      expect(blob.raw, isNull);
    });

    test('methods return default values', () async {
      final blob = web.createBlob();
      expect(await blob.text(), '');
      expect((await blob.arrayBuffer()).lengthInBytes, 0);
      expect(blob.slice(), isNotNull);
      expect(await blob.stream().isEmpty, isTrue);
    });
  });
}
