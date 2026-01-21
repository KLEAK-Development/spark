import 'package:test/test.dart';
import 'package:spark_framework/src/html/dsl.dart';

// Conditional import - use browser implementation in browser, stub in VM
import 'package:spark_framework/src/component/vdom_web.dart'
    if (dart.library.io) 'vdom_test_stub.dart';

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
}
