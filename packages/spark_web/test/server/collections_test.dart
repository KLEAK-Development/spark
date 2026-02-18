@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Server Collections', () {
    test('ServerNodeList', () {
      final el = web.document.createElement('div');
      final list = el.childNodes;
      expect(list.length, 0);
      expect(list.item(0), isNull);
    });

    test('ServerDOMTokenList', () {
      final el = web.document.createElement('div');
      final tokens = el.classList;
      expect(tokens.length, 0);
      expect(tokens.item(0), isNull);
      expect(tokens.contains('foo'), isFalse);
      tokens.add('foo');
      tokens.remove('foo');
      expect(tokens.toggle('foo'), isFalse);
      expect(tokens.toggle('foo', true), isTrue);
      tokens.replace('foo', 'bar');
    });

    test('ServerNamedNodeMap', () {
      final el = web.document.createElement('div');
      final map = el.attributes;
      expect(map.length, 0);
      expect(map.item(0), isNull);
      expect(map.getNamedItem('id'), isNull);
      expect(map.removeNamedItem('id'), isNull);
    });
  });
}
