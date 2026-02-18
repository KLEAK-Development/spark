@TestOn('browser')
library;

import 'package:spark_vdom/vdom_web.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart' as html;
import 'package:test/test.dart';
import 'package:spark_web/spark_web.dart' as web;

void main() {
  group('vdom_web coverage', () {
    late web.HTMLDivElement parent;

    setUp(() {
      parent = web.document.createElement('div') as web.HTMLDivElement;
      web.document.body!.appendChild(parent);
    });

    tearDown(() {
      parent.remove();
    });

    test('mount handles all ignorable children', () {
      parent.appendChild(web.document.createComment('comment'));
      parent.appendChild(web.document.createTextNode('   '));

      final vNode = html.div(['new content']);
      mount(parent, vNode);

      expect(parent.childNodes.length, 3);
      expect(parent.lastChild!.textContent, 'new content');
    });

    test('mountList handles SVG detection for ShadowRoot', () {
      final div = web.document.createElement('div');
      final shadow =
          (div as dynamic).attachShadow(web.ShadowRootInit(mode: 'open'))
              as web.ShadowRoot;

      mountList(shadow, [html.h('circle')]);

      final circle = shadow.firstChild as web.Element;
      expect(circle.tagName.toLowerCase(), 'circle');
    });

    test('patch replaces text node when parentNode is null', () {
      final textNode = web.document.createTextNode('standalone');
      patch(textNode, html.div(['test']));
      expect(textNode.textContent, 'standalone');
    });

    test(
      'patch replaces element node with text when mismatch and has parent',
      () {
        final el = web.document.createElement('div');
        parent.appendChild(el);
        patch(el, html.Text('new text'));
        expect(parent.firstChild, isA<web.Text>());
      },
    );

    test(
      'patch replaces text node with element when mismatch and has parent',
      () {
        final text = web.document.createTextNode('text');
        parent.appendChild(text);
        patch(text, html.div(['new div']));
        expect(parent.firstChild, isA<web.Element>());
      },
    );

    test('_patchElement removes extra nodes', () {
      final vNode1 = html.div([html.span('1'), html.span('2')]);
      mount(parent, vNode1);
      final div = parent.firstChild as web.Element;
      expect(div.childNodes.length, 2);

      final vNode2 = html.div([html.span('1')]);
      patch(div, vNode2);
      expect(div.childNodes.length, 1);
    });

    test('patch replaces element node with another tag and has parent', () {
      final div = web.document.createElement('div');
      parent.appendChild(div);
      patch(div, html.h('span'));
      expect(parent.firstChild, isA<web.Element>());
      expect((parent.firstChild as web.Element).tagName.toLowerCase(), 'span');
    });

    test('mount handles unknown node type', () {
      mount(parent, _UnknownNode());
      expect(parent.firstChild!.nodeType, 8); // Comment
    });

    test('_patchElement removes multiple extra nodes', () {
      final vNode1 = html.div([html.span('1'), html.span('2'), html.span('3')]);
      mount(parent, vNode1);
      final div = parent.firstChild as web.Element;

      final vNode2 = html.div([html.span('1')]);
      patch(div, vNode2);
      expect(div.childNodes.length, 1);
    });

    test('patch replaces element node when parentNode is null', () {
      final el = web.document.createElement('div');
      patch(el, html.span(['test']));
      expect(el.tagName.toLowerCase(), 'div');
    });

    test('patch element tag mismatch when parentNode is null', () {
      final el = web.document.createElement('div');
      patch(el, html.h('span'));
      expect(el.tagName.toLowerCase(), 'div');
    });

    test('_updateAttributes skips update when value matches', () {
      final el = web.document.createElement('div');
      el.setAttribute('title', 'test');

      patch(el, html.div([], attributes: {'title': 'test'}));
      expect(el.getAttribute('title'), 'test');
    });

    test('_updateEvents handles events not starting with "on"', () {
      bool called = false;
      final vNode = html.h(
        'div',
        children: [],
        events: {'click': (_) => called = true},
      );
      final el = createNode(vNode) as web.HTMLElement;
      parent.appendChild(el);

      el.dispatchEvent(web.createMouseEvent('click'));
      expect(called, isTrue);
    });

    test('_updateEvents listener handles missing data-spark-id gracefully', () {
      bool called = false;
      final vNode = html.div([], onClick: (_) => called = true);
      final el = createNode(vNode) as web.HTMLElement;
      parent.appendChild(el);

      el.removeAttribute('data-spark-id');

      el.dispatchEvent(web.createMouseEvent('click'));
      expect(called, isFalse);
    });

    test('_updateEvents listener handles non-existent ID gracefully', () {
      bool called = false;
      final vNode = html.h(
        'div',
        children: [],
        events: {'click': (_) => called = true},
      );
      final el = createNode(vNode) as web.HTMLElement;
      parent.appendChild(el);

      el.setAttribute('data-spark-id', 'non-existent');

      el.dispatchEvent(web.createMouseEvent('click'));
      expect(called, isFalse);
    });

    test('_updateAttributes skips input value sync when already matching', () {
      final input = web.document.createElement('input') as web.HTMLInputElement;
      input.value = 'match';

      patch(input, html.input(value: 'match'));
      expect(input.value, 'match');
    });

    test('patch ShadowRoot with Text node when empty', () {
      final div = web.document.createElement('div');
      final shadow =
          (div as dynamic).attachShadow(web.ShadowRootInit(mode: 'open'))
              as web.ShadowRoot;

      patch(shadow, html.Text('hello'));
      expect(shadow.firstChild!.textContent, 'hello');
    });

    test('patch ShadowRoot with Text node when not empty', () {
      final div = web.document.createElement('div');
      final shadow =
          (div as dynamic).attachShadow(web.ShadowRootInit(mode: 'open'))
              as web.ShadowRoot;
      shadow.appendChild(web.document.createTextNode('initial'));

      patch(shadow, html.Text('updated'));
      expect(shadow.firstChild!.textContent, 'updated');
    });

    test('patch ShadowRoot with Element when it only has Text node', () {
      final div = web.document.createElement('div');
      final shadow =
          (div as dynamic).attachShadow(web.ShadowRootInit(mode: 'open'))
              as web.ShadowRoot;
      shadow.appendChild(web.document.createTextNode('initial text'));

      patch(shadow, html.div(['new element']));
      expect(shadow.firstChild, isA<web.Element>());
      expect(shadow.firstChild!.textContent, 'new element');
    });

    test('mountList with ShadowRoot triggers SVG detection branch', () {
      final div = web.document.createElement('div');
      final shadow =
          (div as dynamic).attachShadow(web.ShadowRootInit(mode: 'open'))
              as web.ShadowRoot;

      mountList(shadow, [
        html.div(['test']),
      ]);
      expect(shadow.firstChild!.textContent, 'test');
    });

    test('mount with non-Element parent skips SVG detection', () {
      final fragment = web.document.createDocumentFragment();
      mount(fragment, html.div(['test']));
      expect(fragment.firstChild!.textContent, 'test');
    });

    test('mountList with non-Element parent skips SVG detection', () {
      final fragment = web.document.createDocumentFragment();
      mountList(fragment, [
        html.div(['test']),
      ]);
      expect(fragment.firstChild!.textContent, 'test');
    });

    test('mount/mountList with non-web.Node returns early', () {
      expect(() => mount(Object(), html.div([])), returnsNormally);
      expect(() => mountList(Object(), [html.div([])]), returnsNormally);
    });

    test('patch with non-web.Node returns early', () {
      expect(() => patch(Object(), html.div([])), returnsNormally);
    });

    test('nextId setter coverage', () {
      final current = nextId;
      nextId = current + 1;
      expect(nextId, current + 1);
      nextId = current;
    });

    test('isIgnorable coverage', () {
      final comment = web.document.createComment('test');
      expect(isIgnorable(comment), isTrue);

      final text = web.document.createTextNode('   ');
      expect(isIgnorable(text), isTrue);

      final significant = web.document.createTextNode('content');
      expect(isIgnorable(significant), isFalse);
    });

    test('_isIgnorable nodeType 8 (Comment)', () {
      final comment = web.document.createComment('comment');
      mount(parent, html.div(['content']));
      final div = parent.firstChild!;
      parent.insertBefore(comment, div);

      mountList(parent, [
        html.div(['new content']),
      ]);
      expect(parent.querySelector('div')!.textContent, 'new content');
    });

    test('mount detects SVG context from element namespace', () {
      final svg = web.document.createElementNS(
        'http://www.w3.org/2000/svg',
        'svg',
      );
      mount(svg, html.h('circle'));
      expect(
        (svg.firstChild as web.Element).namespaceURI,
        'http://www.w3.org/2000/svg',
      );
    });

    test('mountList detects SVG context from element namespace', () {
      final svg = web.document.createElementNS(
        'http://www.w3.org/2000/svg',
        'svg',
      );
      mountList(svg, [html.h('circle')]);
      expect(
        (svg.firstChild as web.Element).namespaceURI,
        'http://www.w3.org/2000/svg',
      );
    });

    test('_updateAttributes preserves data-spark-id', () {
      final el = web.document.createElement('div');
      el.setAttribute('data-spark-id', 'test-id');

      patch(el, html.div([]));
      expect(el.getAttribute('data-spark-id'), 'test-id');
    });

    test('patch with html.Text hits the textContent update branch', () {
      final text = web.document.createTextNode('old');
      parent.appendChild(text);
      patch(text, html.Text('new'));
      expect(text.textContent, 'new');
    });

    test('patch with non-Text node falsifies line 103', () {
      final text = web.document.createTextNode('text');
      parent.appendChild(text);
      patch(text, html.div([]));
      expect(parent.firstChild, isA<web.Element>());
    });

    test('_updateEvents handles events starting with "on"', () {
      bool called = false;
      final vNode = html.h(
        'div',
        children: [],
        events: {'onClick': (_) => called = true},
      );
      final el = createNode(vNode) as web.HTMLElement;
      parent.appendChild(el);

      el.dispatchEvent(web.createMouseEvent('click'));
      expect(called, isTrue);
    });

    test('_patchElement hits the loop and loop termination', () {
      final vNode1 = html.div([html.span('1')]);
      mount(parent, vNode1);
      final div = parent.firstChild as web.Element;

      final vNode2 = html.div([]);
      patch(div, vNode2);
      expect(div.childNodes.length, 0);
    });

    test('patch with html.Element hits the element branch', () {
      final el = web.document.createElement('div');
      parent.appendChild(el);
      patch(el, html.div([]));
      expect(parent.firstChild, isA<web.Element>());
    });

    test('_patchElement hits the loop', () {
      final vNode1 = html.div([html.span('1')]);
      mount(parent, vNode1);
      final div = parent.firstChild as web.Element;

      final vNode2 = html.div([html.span('2')]);
      patch(div, vNode2);
      expect(div.childNodes.length, 1);
      expect(div.firstChild!.textContent, '2');
    });

    test('_patchElement with empty original hits the append branch', () {
      final vNode1 = html.div([]);
      mount(parent, vNode1);
      final div = parent.firstChild as web.Element;

      final vNode2 = html.div([html.span('new')]);
      patch(div, vNode2);
      expect(div.childNodes.length, 1);
    });

    test('mountList hits the append branch for multiple nodes', () {
      mountList(parent, [html.div('1'), html.div('2')]);
      expect(parent.childNodes.length, 2);
    });

    test('_updateEvents listener handles event not in config', () {
      bool called = false;
      final vNode = html.h(
        'div',
        children: [],
        events: {'click': (_) => called = true},
      );
      final el = createNode(vNode) as web.HTMLElement;
      parent.appendChild(el);

      final vNode2 = html.div([]);
      patch(el, vNode2);

      el.dispatchEvent(web.createMouseEvent('click'));
      expect(called, isFalse);
    });
  });
}

class _UnknownNode extends html.Node {
  @override
  String toHtml() => '';
}
