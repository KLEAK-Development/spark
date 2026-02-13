@TestOn('browser')
library;

import 'package:spark_vdom/vdom_web.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart';
import 'package:test/test.dart';
import 'package:spark_web/spark_web.dart' as web;

void main() {
  group('VDOM Attributes', () {
    test('removes attributes that are no longer present', () {
      // 1. Create initial state with disabled attribute
      final vNode1 = button(
        attributes: {'disabled': 'true', 'id': 'btn'},
        ['Click me'],
      );
      final element = createNode(vNode1) as web.HTMLElement;

      expect(element.hasAttribute('disabled'), isTrue);
      expect(element.id, 'btn');

      // 2. Create new state without disabled attribute
      final vNode2 = button(attributes: {'id': 'btn'}, ['Click me']);

      // 3. Patch the element
      patch(element, vNode2);

      // 4. Verify disabled attribute is removed
      expect(
        element.hasAttribute('disabled'),
        isFalse,
        reason: 'Attribute should be removed',
      );
      expect(element.id, 'btn', reason: 'Other attributes should persist');
    });

    test('updates existing attributes', () {
      final vNode1 = div(attributes: {'class': 'foo'}, []);
      final element = createNode(vNode1) as web.HTMLElement;
      expect(element.className, 'foo');

      final vNode2 = div(attributes: {'class': 'bar'}, []);
      patch(element, vNode2);

      expect(element.className, 'bar');
    });

    test('adds new attributes', () {
      final vNode1 = div(attributes: {'class': 'foo'}, []);
      final element = createNode(vNode1) as web.HTMLElement;

      final vNode2 = div(attributes: {'class': 'foo', 'data-new': 'true'}, []);
      patch(element, vNode2);

      expect(element.getAttribute('data-new'), 'true');
    });
  });
}
