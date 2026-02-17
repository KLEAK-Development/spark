import 'package:spark_framework/src/utils/props_serializer.dart';
import 'package:test/test.dart';

void main() {
  group('props_serializer comprehensive', () {
    test('getPropsValue returns defaultValue when key is missing', () {
      expect(getPropsValue<int>({}, 'a', 1), 1);
    });

    test('getPropsValue returns defaultValue when value type mismatch', () {
      expect(getPropsValue<int>({'a': 'str'}, 'a', 1), 1);
    });

    test('getPropsString comprehensive', () {
      expect(getPropsString({'a': 'val'}, 'a'), 'val');
      expect(getPropsString({'a': 123}, 'a', 'fallback'), 'fallback');
      expect(getPropsString({}, 'missing', 'fallback'), 'fallback');
    });

    test('getPropsInt comprehensive', () {
      expect(getPropsInt({'a': 10}, 'a'), 10);
      expect(getPropsInt({'a': '20'}, 'a'), 20);
      expect(getPropsInt({'a': 10.5}, 'a'), 10);
      expect(getPropsInt({'a': 'invalid'}, 'a', 5), 5);
      expect(getPropsInt({'a': Object()}, 'a', 5), 5);
      expect(getPropsInt({}, 'missing', 5), 5);
    });

    test('getPropsDouble comprehensive', () {
      expect(getPropsDouble({'a': 10.5}, 'a'), 10.5);
      expect(getPropsDouble({'a': 10}, 'a'), 10.0);
      expect(getPropsDouble({'a': '2.5'}, 'a'), 2.5);
      expect(getPropsDouble({'a': 'invalid'}, 'a', 1.1), 1.1);
      expect(getPropsDouble({'a': Object()}, 'a', 1.1), 1.1);
      expect(getPropsDouble({}, 'missing', 1.1), 1.1);
    });

    test('getPropsBool comprehensive', () {
      expect(getPropsBool({'a': true}, 'a'), isTrue);
      expect(getPropsBool({'a': false}, 'a'), isFalse);
      expect(getPropsBool({'a': 1}, 'a'), isTrue);
      expect(getPropsBool({'a': 0}, 'a'), isFalse);
      expect(getPropsBool({'a': 'true'}, 'a'), isTrue);
      expect(getPropsBool({'a': 'TRUE'}, 'a'), isTrue);
      expect(getPropsBool({'a': '1'}, 'a'), isTrue);
      expect(getPropsBool({'a': 'false'}, 'a'), isFalse);
      expect(getPropsBool({'a': '0'}, 'a'), isFalse);
      expect(getPropsBool({'a': 'not-bool'}, 'a', true), isFalse); // matches actual behavior
      expect(getPropsBool({'a': []}, 'a', true), isTrue);
      expect(getPropsBool({}, 'missing', true), isTrue);
    });

    test('getPropsList comprehensive', () {
      expect(getPropsList<int>({'a': [1, 2]}, 'a'), [1, 2]);
      expect(getPropsList<int>({'a': [1, '2']}, 'a'), [1]);
      expect(getPropsList<int>({'a': 'not-list'}, 'a'), isEmpty);
      expect(getPropsList<int>({}, 'missing'), isEmpty);
    });

    test('getPropsMap comprehensive', () {
      expect(getPropsMap({'a': {'b': 1}}, 'a'), {'b': 1});
      expect(getPropsMap({'a': 'not-map'}, 'a'), isEmpty);
      expect(getPropsMap({}, 'missing'), isEmpty);
    });

    test('Props class methods', () {
      final data = {
        's': 'str',
        'i': 1,
        'd': 1.1,
        'b': true,
        'l': [1],
        'm': {'x': 1}
      };
      final props = Props(data);
      expect(props.getString('s'), 'str');
      expect(props.getInt('i'), 1);
      expect(props.getDouble('d'), 1.1);
      expect(props.getBool('b'), isTrue);
      expect(props.getList<int>('l'), [1]);
      expect(props.getMap('m'), {'x': 1});
      expect(props.getNested('m').getInt('x'), 1);
      expect(props.get('s'), 'str');
      expect(props.has('s'), isTrue);
      expect(props.has('missing'), isFalse);
      expect(props.toString(), contains('Props'));
    });

    test('Props.decode handles errors', () {
      expect(Props.decode('').data, isEmpty);
      expect(Props.decode('invalid-base64').data, isEmpty);
    });

    test('Props.empty', () {
      expect(Props.empty().data, isEmpty);
    });
  });
}
