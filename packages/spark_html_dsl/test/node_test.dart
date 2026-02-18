import 'dart:async';
import 'package:spark_html_dsl/src/node.dart';
import 'package:test/test.dart';

void main() {
  group('Element.toHtml() nonce injection', () {
    test('injects nonce into style tag when Zone has spark.cspNonce', () {
      final styleElement = Element(
        'style',
        children: [Text('.foo { color: red; }')],
      );

      final html = runZoned(
        () => styleElement.toHtml(),
        zoneValues: {'spark.cspNonce': 'test-nonce-123'},
      );

      expect(html, contains('nonce="test-nonce-123"'));
      expect(html, contains('<style nonce="test-nonce-123">'));
    });

    test('does not inject nonce when Zone has no spark.cspNonce', () {
      final styleElement = Element(
        'style',
        children: [Text('.foo { color: red; }')],
      );

      final html = styleElement.toHtml();

      expect(html, isNot(contains('nonce=')));
      expect(html, equals('<style>.foo { color: red; }</style>'));
    });

    test('does not inject nonce into non-style tags', () {
      final divElement = Element('div', children: [Text('Hello')]);

      final html = runZoned(
        () => divElement.toHtml(),
        zoneValues: {'spark.cspNonce': 'test-nonce-123'},
      );

      expect(html, isNot(contains('nonce=')));
      expect(html, equals('<div>Hello</div>'));
    });

    test('does not override existing nonce attribute', () {
      final styleElement = Element(
        'style',
        attributes: {'nonce': 'existing-nonce'},
        children: [Text('.foo {}')],
      );

      final html = runZoned(
        () => styleElement.toHtml(),
        zoneValues: {'spark.cspNonce': 'zone-nonce'},
      );

      expect(html, contains('nonce="existing-nonce"'));
      expect(html, isNot(contains('zone-nonce')));
    });

    test('ignores empty nonce string in Zone', () {
      final styleElement = Element('style', children: [Text('.foo {}')]);

      final html = runZoned(
        () => styleElement.toHtml(),
        zoneValues: {'spark.cspNonce': ''},
      );

      expect(html, isNot(contains('nonce=')));
    });
  });

  group('Node.toString()', () {
    test('Text.toString() equals toHtml()', () {
      final node = Text('hello');
      expect(node.toString(), node.toHtml());
    });

    test('RawHtml.toString() equals toHtml()', () {
      final node = RawHtml('<div></div>');
      expect(node.toString(), node.toHtml());
    });

    test('Element.toString() equals toHtml()', () {
      final node = Element('div');
      expect(node.toString(), node.toHtml());
    });
  });

  group('Edge cases in Node', () {
    test('ignores non-string nonce in Zone', () {
      final styleElement = Element('style', children: [Text('.foo {}')]);

      final html = runZoned(
        () => styleElement.toHtml(),
        zoneValues: {'spark.cspNonce': 123},
      );

      expect(html, isNot(contains('nonce=')));
    });

    test('ignores null attribute values', () {
      final el = Element('div', attributes: {'data-foo': null});
      expect(el.toHtml(), '<div></div>');
    });

    test('ignores false attribute values', () {
      final el = Element('div', attributes: {'hidden': false});
      expect(el.toHtml(), '<div></div>');
    });

    test('Element constructor defaults', () {
      final node = Element('div');
      expect(node.tag, 'div');
      expect(node.attributes, isEmpty);
      expect(node.events, isEmpty);
      expect(node.children, isEmpty);
      expect(node.selfClosing, isFalse);
    });
  });
}
