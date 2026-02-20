@TestOn('browser')
import 'dart:typed_data';
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Blob (Browser)', () {
    test('instantiates from string', () async {
      final blob = web.createBlob(['hello'], 'text/plain');
      expect(blob.size, 5);
      expect(blob.type, 'text/plain');
      expect(await blob.text(), 'hello');
    });

    test('instantiates from multiple parts', () async {
      final blob = web.createBlob(['a', 'b', 'c']);
      expect(blob.size, 3);
      expect(await blob.text(), 'abc');
    });

    test('slice() works', () async {
      final blob = web.createBlob(['helloworld']);
      final sliced = blob.slice(0, 5);
      expect(sliced.size, 5);
      expect(await sliced.text(), 'hello');
    });

    test('arrayBuffer() works', () async {
      final blob = web.createBlob(['abc']);
      final buffer = await blob.arrayBuffer();
      final bytes = Uint8List.view(buffer);
      expect(bytes, equals([97, 98, 99]));
    });

    test('stream() works', () async {
      final blob = web.createBlob(['abc']);
      final stream = blob.stream();
      final chunks = await stream.toList();
      expect(chunks.length, isPositive);
      final allBytes = Uint8List.fromList(chunks.expand((c) => c).toList());
      expect(allBytes, equals([97, 98, 99]));
    });
  });
}
