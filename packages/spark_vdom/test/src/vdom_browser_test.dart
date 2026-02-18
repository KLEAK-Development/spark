@TestOn('browser')
library;

import 'package:spark_vdom/vdom_web.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart';
import 'package:test/test.dart';
import 'package:spark_web/spark_web.dart' as web;

void main() {
  group('SVG Hydration', () {
    test('creates standard HTML elements in XHTML namespace', () {
      final node = div([]);
      final el = createNode(node) as web.Element;
      expect(el.tagName.toLowerCase(), 'div');
      // Create a reference element to check default namespace
      final ref = web.document.createElement('div');
      expect(el.namespaceURI, ref.namespaceURI);
    });

    test('creates SVG elements in SVG namespace', () {
      final node = h('svg', children: []);
      final el = createNode(node) as web.Element;
      expect(el.tagName.toLowerCase(), 'svg');
      expect(el.namespaceURI, 'http://www.w3.org/2000/svg');
    });

    test('propagates SVG context to children', () {
      final node = h(
        'svg',
        children: [
          h('circle', attributes: {'cx': 50, 'cy': 50, 'r': 40}),
          h(
            'g',
            children: [
              h('rect', attributes: {'width': 100, 'height': 100}),
            ],
          ),
        ],
      );

      final svg = createNode(node) as web.Element;
      expect(svg.namespaceURI, 'http://www.w3.org/2000/svg');

      final circle = svg.children.item(0)!;
      expect(circle.tagName.toLowerCase(), 'circle');
      expect(circle.namespaceURI, 'http://www.w3.org/2000/svg');

      final g = svg.children.item(1)!;
      expect(g.tagName.toLowerCase(), 'g');
      expect(g.namespaceURI, 'http://www.w3.org/2000/svg');

      final rect = g.children.item(0)!;
      expect(rect.tagName.toLowerCase(), 'rect');
      expect(rect.namespaceURI, 'http://www.w3.org/2000/svg');
    });

    test('handles tag collision (title) correctly', () {
      // HTML Title
      final htmlNode = div([
        title(['Hello']),
      ]);
      final htmlDiv = createNode(htmlNode) as web.Element;
      final htmlTitle = htmlDiv.children.item(0)!;

      expect(htmlTitle.tagName.toLowerCase(), 'title');
      // Should match standard HTML namespace (or null in some browsers, but essentially NOT svg)
      expect(htmlTitle.namespaceURI, isNot('http://www.w3.org/2000/svg'));

      // SVG Title
      final svgNode = h(
        'svg',
        children: [
          title(['SVG Title']),
        ],
      );
      final svg = createNode(svgNode) as web.Element;
      final svgTitle = svg.children.item(0)!;

      expect(svgTitle.tagName.toLowerCase(), 'title');
      expect(svgTitle.namespaceURI, 'http://www.w3.org/2000/svg');
    });

    test('foreignObject switches back to HTML context', () {
      final node = h(
        'svg',
        children: [
          h(
            'foreignObject',
            children: [
              div(['I am HTML']),
            ],
          ),
        ],
      );

      final svg = createNode(node) as web.Element;
      final fo = svg.children.item(0)!;
      expect(
        fo.tagName,
        'foreignObject',
      ); // Case sensitive in SVG? Usually lower in DOM
      expect(fo.namespaceURI, 'http://www.w3.org/2000/svg');

      final htmlDiv = fo.children.item(0)!;
      expect(htmlDiv.tagName.toLowerCase(), 'div');
      expect(htmlDiv.namespaceURI, isNot('http://www.w3.org/2000/svg'));
    });
  });
}
