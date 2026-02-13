@TestOn('browser')
library;

import 'package:spark_vdom/vdom_web.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart' as html;
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  group('vdom_web memory leak', () {
    late web.HTMLDivElement parent;

    setUp(() {
      parent = web.document.createElement('div') as web.HTMLDivElement;
      web.document.body!.appendChild(parent);
    });

    tearDown(() {
      parent.remove();
      // Ensure we clean up any remaining listeners to avoid polluting other tests
      // We can't easily do this without a way to clear _listenersConfig or unmount everything
      // But since we are testing leaks, we rely on the tests to clean up.
    });

    test('listeners are cleaned up when nodes are removed via mountList', () {
      final initialSize = listenersConfigSize;

      // Mount a node with an event listener
      final vNode = html.div([html.span('Click me')], onClick: (_) {});

      mountList(parent, [vNode]);

      expect(
        listenersConfigSize,
        greaterThan(initialSize),
        reason: 'Listener should be registered',
      );

      // Unmount the node
      mountList(parent, []);

      expect(
        listenersConfigSize,
        equals(initialSize),
        reason: 'Listener should be cleaned up',
      );
    });

    test(
      'listeners are cleaned up when nodes are removed via patch (replaceChild)',
      () {
        final initialSize = listenersConfigSize;

        // Mount a node with an event listener
        final vNode1 = html.div([html.span('Click me')], onClick: (_) {});

        mount(parent, vNode1);

        expect(
          listenersConfigSize,
          greaterThan(initialSize),
          reason: 'Listener should be registered',
        );

        // Replace the node with a node without listeners (different tag to force replaceChild)
        final vNode2 = html.span('No listeners');

        // mount calls patch internally if significant child exists
        mount(parent, vNode2);

        // Validate that we have cleaned up the old listeners.
        // The new node (span) will have 1 listener config entry.
        // The old nodes (div + span) had 2.
        // So if clean up worked, we should have initialSize + 1.
        // If not, initialSize + 3.

        // To be absolutely sure, let's unmount everything
        mountList(parent, []);

        expect(
          listenersConfigSize,
          equals(initialSize),
          reason: 'All listeners should be cleaned up after clearing parent',
        );
      },
    );
  });
}
