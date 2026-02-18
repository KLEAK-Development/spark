@TestOn('browser')
library;

import 'package:spark_vdom/vdom_web.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart' as html;
import 'package:test/test.dart';
import 'package:spark_web/spark_web.dart' as web;

void main() {
  group('vdom_web', () {
    late web.HTMLDivElement parent;

    setUp(() {
      parent = web.document.createElement('div') as web.HTMLDivElement;
      web.document.body!.appendChild(parent);
    });

    tearDown(() {
      parent.remove();
    });

    test('mount/mountList returns early if parent is not web.Node', () {
      mount(Object(), html.div([]));
      mountList(Object(), [html.div([])]);
    });

    test('patch returns early if realNode is not web.Node', () {
      patch(Object(), html.div([]));
    });

    test('mount detects SVG context from parent element', () {
      final svgParent = web.document.createElementNS(
        'http://www.w3.org/2000/svg',
        'svg',
      );
      mount(svgParent, html.h('circle'));
      final circle = svgParent.firstChild as web.Element;
      expect(circle.namespaceURI, 'http://www.w3.org/2000/svg');
    });

    test('mountList detects SVG context from parent element', () {
      final svgParent = web.document.createElementNS(
        'http://www.w3.org/2000/svg',
        'svg',
      );
      mountList(svgParent, [html.h('circle')]);
      final circle = svgParent.firstChild as web.Element;
      expect(circle.namespaceURI, 'http://www.w3.org/2000/svg');
    });

    test('mountList works with ShadowRoot', () {
      final div = web.document.createElement('div');
      final shadow =
          (div as dynamic).attachShadow(web.ShadowRootInit(mode: 'open'))
              as web.ShadowRoot;
      mountList(shadow, [
        html.div(['hello']),
      ]);
      expect(shadow.firstChild, isNotNull);
      expect(shadow.firstChild!.textContent, 'hello');
    });

    test('patch handles ShadowRoot branches', () {
      final div = web.document.createElement('div');
      final shadow =
          (div as dynamic).attachShadow(web.ShadowRootInit(mode: 'open'))
              as web.ShadowRoot;

      // 1. mount branch
      patch(shadow, html.div(['initial']));
      expect(shadow.firstChild!.textContent, 'initial');

      // 2. patch firstChild if it exists
      patch(shadow, html.div(['updated']));
      expect(shadow.firstChild!.textContent, 'updated');

      // 3. patch firstElementChild if vNode is Element and it exists
      final vNode = html.div(['element-patch']);
      patch(shadow, vNode);
      expect(shadow.firstElementChild!.textContent, 'element-patch');
    });

    test('patch replaces node when type mismatch (text vs element)', () {
      final textNode = web.document.createTextNode('old text');
      parent.appendChild(textNode);

      patch(textNode, html.div([html.Text('new element')]));
      expect(parent.firstChild, isA<web.Element>());
      expect(parent.firstChild!.textContent, 'new element');

      final elNode = parent.firstChild!;
      patch(elNode, html.Text('back to text'));
      expect(parent.firstChild, isA<web.Text>());
      expect(parent.firstChild!.textContent, 'back to text');
    });

    test('patch replaces element when tag mismatch', () {
      final div = web.document.createElement('div');
      parent.appendChild(div);

      patch(div, html.h('span', children: [html.Text('new span')]));
      expect(parent.firstChild, isA<web.Element>());
      expect((parent.firstChild as web.Element).tagName.toLowerCase(), 'span');
    });

    test('createNode handles RawHtml', () {
      final vNode = html.RawHtml('<p>raw</p>');
      final node = createNode(vNode);
      expect(node.tagName.toLowerCase(), 'span');
      expect(node.innerHTML, '<p>raw</p>');
    });

    test('createNode handles unknown node types', () {
      final node = createNode(_UnknownNode());
      expect(node.nodeType, 8); // Comment
      expect(node.textContent, 'Unknown Node');
    });

    test('_updateAttributes handles null and boolean values', () {
      final el = web.document.createElement('div');

      // Null removes attribute
      el.setAttribute('test', 'value');
      patch(el, html.div([], attributes: {'test': null}));
      expect(el.hasAttribute('test'), isFalse);

      // Boolean true adds empty attribute
      patch(el, html.div([], attributes: {'checked': true}));
      expect(el.hasAttribute('checked'), isTrue);
      expect(el.getAttribute('checked'), '');

      // Boolean false removes attribute
      patch(el, html.div([], attributes: {'checked': false}));
      expect(el.hasAttribute('checked'), isFalse);
    });

    test('_updateAttributes syncs input value property', () {
      final input = web.document.createElement('input') as web.HTMLInputElement;
      parent.appendChild(input);

      input.value = 'user typed';
      patch(input, html.input(value: 'forced value'));
      expect(input.value, 'forced value');
    });

    test('_updateEvents triggers listener and uses cache', () {
      bool called = false;
      final vNode = html.div([], onClick: (_) => called = true);
      final el = createNode(vNode) as web.HTMLElement;
      parent.appendChild(el);

      el.dispatchEvent(web.createMouseEvent('click'));
      expect(called, isTrue);

      // Patch with same handler, should not re-add listener
      called = false;
      patch(el, vNode);
      el.dispatchEvent(web.createMouseEvent('click'));
      expect(called, isTrue);
    });

    test('_updateEvents handles handler replacement', () {
      int count = 0;
      final vNode1 = html.div([], onClick: (_) => count += 1);
      final el = createNode(vNode1) as web.HTMLElement;
      parent.appendChild(el);

      el.dispatchEvent(web.createMouseEvent('click'));
      expect(count, 1);

      // Replace handler
      final vNode2 = html.div([], onClick: (_) => count += 10);
      patch(el, vNode2);

      el.dispatchEvent(web.createMouseEvent('click'));
      expect(count, 11);
    });

    test('_cleanupNode cleans up nested listeners', () {
      final initialSize = listenersConfigSize;

      final vNode = html.div([
        html.h('button', events: {'click': (_) {}}),
        html.div([
          html.h('span', events: {'click': (_) {}}),
        ]),
      ]);

      mount(parent, vNode);
      expect(listenersConfigSize, initialSize + 4);

      // Remove the whole tree
      mountList(parent, []);
      expect(listenersConfigSize, initialSize);
    });

    test('_cleanupNode is called during patch replacement', () {
      final initialSize = listenersConfigSize;

      mount(parent, html.div([html.Text('initial')]));
      expect(listenersConfigSize, initialSize + 1);

      patch(parent.firstChild!, html.Text('replaced'));
      expect(listenersConfigSize, initialSize);
    });

    test('_isIgnorable handles comments and whitespace text', () {
      final comment = web.document.createComment('test');
      final whitespace = web.document.createTextNode('  \n  ');

      mountList(parent, [
        html.div(['content']),
      ]);
      final el = parent.firstChild!;

      parent.insertBefore(comment, el);
      parent.appendChild(whitespace);

      mount(parent, html.div(['updated']));
      expect(parent.querySelector('div')!.textContent, 'updated');
      expect(parent.childNodes.length, 3);
    });
  });

  group('vdom_web memory leak', () {
    late web.HTMLDivElement parent;

    setUp(() {
      parent = web.document.createElement('div') as web.HTMLDivElement;
      web.document.body!.appendChild(parent);
    });

    tearDown(() {
      parent.remove();
    });

    test('listeners are cleaned up when nodes are removed via mountList', () {
      final initialSize = listenersConfigSize;
      final vNode = html.div([html.span('Click me')], onClick: (_) {});
      mountList(parent, [vNode]);
      expect(listenersConfigSize, greaterThan(initialSize));
      mountList(parent, []);
      expect(listenersConfigSize, equals(initialSize));
    });

    test(
      'listeners are cleaned up when nodes are removed via patch (replaceChild)',
      () {
        final initialSize = listenersConfigSize;
        final vNode1 = html.div([html.span('Click me')], onClick: (_) {});
        mount(parent, vNode1);
        expect(listenersConfigSize, greaterThan(initialSize));
        final vNode2 = html.span('No listeners');
        mount(parent, vNode2);
        mountList(parent, []);
        expect(listenersConfigSize, equals(initialSize));
      },
    );
  });
}

class _UnknownNode extends html.Node {
  @override
  String toHtml() => '';
}
