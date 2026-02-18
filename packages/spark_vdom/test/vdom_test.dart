import 'package:test/test.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart';

import 'package:spark_vdom/spark_vdom.dart';

void main() {
  group('VDom mountList', () {
    test('mountList handles empty list', () {
      // This test verifies mountList doesn't crash with empty input
      expect(() => mountList(null, []), returnsNormally);
    });

    test('mountList handles single element', () {
      final nodes = [
        div(['Hello']),
      ];

      expect(() => mountList(null, nodes), returnsNormally);
    });

    test('mountList handles multiple elements', () {
      final nodes = [
        style(['body { margin: 0; }']),
        div(['Hello']),
        span(['World']),
      ];

      expect(() => mountList(null, nodes), returnsNormally);
    });

    test('mountList handles Text nodes', () {
      final nodes = [
        Text('Plain text'),
        div(['Element']),
      ];

      expect(() => mountList(null, nodes), returnsNormally);
    });
  });

  group('VDom createNode', () {
    test('createNode creates element from Element node', () {
      final node = div(['Test']);
      final domNode = createNode(node);
      expect(domNode, isNotNull);
    });

    test('createNode creates text from Text node', () {
      final node = Text('Hello');
      final domNode = createNode(node);
      expect(domNode, isNotNull);
    });

    test('createNode handles nested elements', () {
      final node = div([
        span(['Hello']),
        span(['World']),
      ]);
      final domNode = createNode(node);
      expect(domNode, isNotNull);
    });
  });

  group('VDom mount', () {
    test('mount handles single element', () {
      final node = div(['Test']);
      expect(() => mount(null, node), returnsNormally);
    });

    test('mount handles text node', () {
      final node = Text('Hello');
      expect(() => mount(null, node), returnsNormally);
    });
  });

  group('VDom patch', () {
    test('patch handles null realNode', () {
      expect(() => patch(null, div([])), returnsNormally);
    });
  });
}
