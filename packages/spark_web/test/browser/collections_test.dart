@TestOn('browser')
import 'package:spark_web/spark_web.dart' as spark;
import 'package:test/test.dart';

void main() {
  group('Browser Collections', () {
    test('DOMTokenList', () {
      final el = spark.document.createElement('div');
      el.classList.add('foo');
      expect(el.classList.contains('foo'), isTrue);
      el.classList.toggle('bar');
      expect(el.classList.contains('bar'), isTrue);
      el.classList.replace('foo', 'baz');
      expect(el.classList.contains('foo'), isFalse);
      expect(el.classList.contains('baz'), isTrue);
    });

    test('NamedNodeMap and Attr', () {
      final el = spark.document.createElement('div');
      el.setAttribute('id', 'foo');
      final attr = el.attributes.getNamedItem('id');
      expect(attr, isNotNull);
      expect(attr!.name, 'id');
      expect(attr.value, 'foo');
      attr.value = 'bar';
      expect(el.id, 'bar');
    });
  });
}
