@TestOn('browser')
library;

import 'package:spark_framework/src/component/vdom_web.dart';
import 'package:spark_framework/src/html/dsl.dart' as html;
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  group('vdom_web hydration focus', () {
    late web.HTMLDivElement parent;

    setUp(() {
      parent = web.document.createElement('div') as web.HTMLDivElement;
      web.document.body!.appendChild(parent);
    });

    tearDown(() {
      parent.remove();
    });

    test('ignores comments during hydration and preserves existing element', () {
      // Setup DOM: <div><!-- comment --><input /></div>
      final comment = web.document.createComment(' comment ');
      final input = web.document.createElement('input') as web.HTMLInputElement;
      input.id = 'my-input';

      parent.appendChild(comment);
      parent.appendChild(input);

      // Focus the input
      input.focus();
      expect(
        web.document.activeElement,
        input,
        reason: 'Input should be focused initially',
      );

      // Hydrate with VDOM matching the input
      final vNode = html.input(id: 'my-input');

      // We expect mountList to patch the existing input,
      // ignoring the comment.
      // If it doesn't ignore the comment, it might try to patch the comment
      // with the input (replacing it) and remove the original input, losing focus.
      mountList(parent, [vNode]);

      final newInput =
          parent.querySelector('#my-input') as web.HTMLInputElement?;

      expect(newInput, isNotNull);
      // specific check: the element instance should be the EXACT SAME one
      expect(
        newInput,
        equals(input),
        reason: 'Should reuse existing input element',
      );

      // Check focus is still there
      expect(
        web.document.activeElement,
        input,
        reason: 'Input should remain focused',
      );
    });

    test(
      'does not overwrite input value if it matches, preserving selection',
      () {
        final input =
            web.document.createElement('input') as web.HTMLInputElement;
        input.id = 'val-input';
        input.value = 'test';
        parent.appendChild(input);

        final vNode = html.input(id: 'val-input', value: 'test');

        mountList(parent, [vNode]);

        expect(input.value, 'test');
      },
    );
  });
}
