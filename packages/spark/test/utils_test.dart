import 'package:test/test.dart';
import 'package:spark_framework/src/utils/props_serializer.dart';

void main() {
  group('Props Serializer', () {
    test('encodeProps encodes map to base64 json', () {
      final original = {'foo': 'bar', 'count': 42};
      final encoded = encodeProps(original);
      expect(encoded, isNotEmpty);
      expect(decodeProps(encoded), equals(original));
    });

    test('decodeProps handles empty string', () {
      expect(decodeProps(''), equals({}));
    });

    test('decodeProps returns empty map on invalid input', () {
      expect(decodeProps('not-base-64'), equals({}));
      expect(decodeProps('e30='), equals({})); // valid base64 '{}' -> {}
      // invalid json
      // 'not-json' base64 encoded is 'bm90LWpzb24='
      expect(decodeProps('bm90LWpzb24='), equals({}));
    });

    test('decodeProps handles complex nested data', () {
      final props = {
        'users': [
          {'id': 1},
          {'id': 2},
        ],
        'active': true,
        'meta': {'page': 1},
      };
      final encoded = encodeProps(props);
      expect(decodeProps(encoded), equals(props));
    });
  });

  group('Props Class', () {
    test('getString returns value or default', () {
      final props = Props({'name': 'Kevin'});
      expect(props.getString('name'), equals('Kevin'));
      expect(props.getString('missing', 'Guest'), equals('Guest'));
    });

    test('getInt handles various types', () {
      final props = Props({'count': 10, 'str': '20', 'dbl': 30.5});
      expect(props.getInt('count'), equals(10));
      expect(props.getInt('str'), equals(20));
      expect(props.getInt('dbl'), equals(30));
      expect(props.getInt('missing', 5), equals(5));
    });

    test('getDouble handles various types', () {
      final props = Props({'val': 10.5, 'int': 5, 'str': '2.5'});
      expect(props.getDouble('val'), equals(10.5));
      expect(props.getDouble('int'), equals(5.0));
      expect(props.getDouble('str'), equals(2.5));
    });

    test('getBool handles various types', () {
      final props = Props({
        't1': true,
        'f1': false,
        't2': 1,
        'f2': 0,
        't3': 'true',
        'f3': 'false',
        't4': '1',
      });
      expect(props.getBool('t1'), isTrue);
      expect(props.getBool('f1'), isFalse);
      expect(props.getBool('t2'), isTrue);
      expect(props.getBool('f2'), isFalse);
      expect(props.getBool('t3'), isTrue);
      expect(props.getBool('f3'), isFalse);
      expect(props.getBool('t4'), isTrue);
    });

    test('getNested', () {
      final props = Props({
        'user': {'name': 'Kevin'},
      });
      final user = props.getNested('user');
      expect(user, isA<Props>());
      expect(user.getString('name'), equals('Kevin'));
    });

    test('getList property type checking', () {
      final props = Props({
        'ids': [1, 2, 3],
        'names': ['a', 'b'],
      });
      expect(props.getList<int>('ids'), equals([1, 2, 3]));
      expect(props.getList<String>('names'), equals(['a', 'b']));
      expect(props.getList<String>('ids'), isEmpty); // Wrong type
    });
  });
}
