import 'package:test/test.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart';

void main() {
  group('HTML DSL', () {
    group('Node', () {
      test('Text renders escaped text', () {
        final text = Text('Hello <World>');
        expect(text.toHtml(), equals('Hello &lt;World&gt;'));
      });

      test('RawHtml renders properly', () {
        final raw = RawHtml('<div>Raw Content</div>');
        expect(raw.toHtml(), equals('<div>Raw Content</div>'));
      });
    });

    group('Element', () {
      test('renders basic element with tag', () {
        final el = Element('div');
        expect(el.toHtml(), equals('<div></div>'));
      });

      test('renders element with attributes', () {
        final el = Element('div', attributes: {'id': 'foo', 'class': 'bar'});
        expect(el.toHtml(), equals('<div id="foo" class="bar"></div>'));
      });

      test('escapes attribute values', () {
        final el = Element('div', attributes: {'data-val': '"quote"'});
        expect(el.toHtml(), equals('<div data-val="&quot;quote&quot;"></div>'));
      });

      test('renders boolean attributes correctly', () {
        final el = Element(
          'input',
          attributes: {'checked': true, 'disabled': false},
          selfClosing: true,
        );
        expect(el.toHtml(), equals('<input checked />'));
      });

      test('renders children', () {
        final el = Element(
          'ul',
          children: [
            Element('li', children: [Text('Item 1')]),
            Element('li', children: [Text('Item 2')]),
          ],
        );
        expect(el.toHtml(), equals('<ul><li>Item 1</li><li>Item 2</li></ul>'));
      });

      test('self-closing elements render correctly', () {
        final el = Element('br', selfClosing: true);
        expect(el.toHtml(), equals('<br />'));
      });

      test('self-closing elements with children fall back to normal tag', () {
        final el = Element(
          'div',
          selfClosing: true,
          children: [Text('content')],
        );
        expect(el.toHtml(), equals('<div>content</div>'));
      });
    });

    group('Elements Helpers', () {
      test('div helper', () {
        expect(div([Text('content')]).toHtml(), equals('<div>content</div>'));
        expect(div('content').toHtml(), equals('<div>content</div>'));
      });

      test('span helper with attributes', () {
        expect(
          span('text', id: 's1', className: 'cls').toHtml(),
          equals('<span id="s1" class="cls">text</span>'),
        );
      });

      test('img helper (self-closing)', () {
        expect(
          img(src: 'img.png', alt: 'image').toHtml(),
          equals('<img src="img.png" alt="image" />'),
        );
      });

      test('nested helpers', () {
        final html = div([
          h1('Title'),
          p('Paragraph'),
          button(
            'Click',
            onClick: (_) {},
          ), // onClick is ignored in toHtml but valid in DSL
        ]);
        expect(
          html.toHtml(),
          equals(
            '<div><h1>Title</h1><p>Paragraph</p><button>Click</button></div>',
          ),
        );
      });

      test('input helper', () {
        expect(
          input(type: 'text', name: 'user', value: 'kevin').toHtml(),
          equals('<input type="text" name="user" value="kevin" />'),
        );
      });

      test('a helper with onClick', () {
        final el = a('Link', href: '#', onClick: (_) {});
        expect(el.toHtml(), equals('<a href="#">Link</a>'));
      });
    });
  });
}
