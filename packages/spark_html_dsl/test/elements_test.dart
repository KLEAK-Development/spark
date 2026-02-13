import 'package:test/test.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart';
import 'package:spark_html_dsl/spark_html_dsl.dart' as dsl;

void main() {
  group('h() function', () {
    test('creates element with tag only', () {
      final el = h('custom-el');
      expect(el.tag, 'custom-el');
      expect(el.children, isEmpty);
    });

    test('sets id attribute', () {
      final el = h('div', id: 'my-id');
      expect(el.attributes['id'], 'my-id');
    });

    test('sets className as class attribute', () {
      final el = h('div', className: 'foo bar');
      expect(el.attributes['class'], 'foo bar');
    });

    test('merges extra attributes', () {
      final el = h(
        'div',
        id: 'x',
        attributes: {'data-x': '1', 'role': 'button'},
      );
      expect(el.attributes['id'], 'x');
      expect(el.attributes['data-x'], '1');
      expect(el.attributes['role'], 'button');
    });

    test('passes events through', () {
      void handler(dynamic _) {}
      final el = h('div', events: {'click': handler});
      expect(el.events['click'], isNotNull);
    });

    test('creates self-closing element', () {
      final el = h('hr', selfClosing: true);
      expect(el.selfClosing, isTrue);
      expect(el.toHtml(), '<hr />');
    });
  });

  group('Child normalization', () {
    test('converts String children to Text nodes', () {
      final el = h('div', children: ['hello']);
      expect(el.children.length, 1);
      expect(el.children.first, isA<Text>());
      expect((el.children.first as Text).text, 'hello');
    });

    test('passes through VNode children as-is', () {
      final child = Element('span');
      final el = h('div', children: [child]);
      expect(el.children.length, 1);
      expect(el.children.first, same(child));
    });

    test('skips null children', () {
      final el = h('div', children: [null, 'hello', null]);
      expect(el.children.length, 1);
    });

    test('flattens nested lists', () {
      final el = h(
        'div',
        children: [
          'a',
          ['b', 'c'],
        ],
      );
      expect(el.children.length, 3);
      expect((el.children[0] as Text).text, 'a');
      expect((el.children[1] as Text).text, 'b');
      expect((el.children[2] as Text).text, 'c');
    });

    test('converts non-string non-VNode children via toString', () {
      final el = h('div', children: [42]);
      expect(el.children.length, 1);
      expect((el.children.first as Text).text, '42');
    });

    test('handles empty children list', () {
      final el = h('div', children: []);
      expect(el.children, isEmpty);
    });

    test('handles null children parameter', () {
      final el = h('div');
      expect(el.children, isEmpty);
    });
  });

  group('Element.eventWrapper', () {
    tearDown(() {
      // Always restore
      Element.eventWrapper = null;
    });

    test('wraps events during construction when set', () {
      var wrapperCalled = false;
      Element.eventWrapper = (fn) {
        wrapperCalled = true;
        return fn;
      };

      h('div', events: {'click': (_) {}});
      expect(wrapperCalled, isTrue);
    });

    test('does not wrap events when eventWrapper is null', () {
      Element.eventWrapper = null;
      // Should not throw
      final el = h('div', events: {'click': (_) {}});
      expect(el.events['click'], isNotNull);
    });

    test('does not call wrapper for empty events', () {
      var wrapperCalled = false;
      Element.eventWrapper = (fn) {
        wrapperCalled = true;
        return fn;
      };

      h('div');
      expect(wrapperCalled, isFalse);
    });

    test('restores previous wrapper correctly', () {
      // Simulate what SparkComponent does: save, set, restore
      final prevWrapper = Element.eventWrapper;

      var called = false;
      Element.eventWrapper = (fn) {
        called = true;
        return fn;
      };

      h('button', events: {'click': (_) {}});
      expect(called, isTrue);

      Element.eventWrapper = prevWrapper;
      expect(Element.eventWrapper, isNull);
    });
  });

  group('DSL helpers coverage', () {
    test('all heading helpers render correctly', () {
      expect(h1('H1').toHtml(), '<h1>H1</h1>');
      expect(h2('H2').toHtml(), '<h2>H2</h2>');
      expect(h3('H3').toHtml(), '<h3>H3</h3>');
      expect(h4('H4').toHtml(), '<h4>H4</h4>');
      expect(h5('H5').toHtml(), '<h5>H5</h5>');
      expect(h6('H6').toHtml(), '<h6>H6</h6>');
    });

    test('sectioning elements', () {
      expect(article('x').toHtml(), '<article>x</article>');
      expect(aside('x').toHtml(), '<aside>x</aside>');
      expect(footer('x').toHtml(), '<footer>x</footer>');
      expect(header('x').toHtml(), '<header>x</header>');
      expect(dsl.main('x').toHtml(), '<main>x</main>');
      expect(nav('x').toHtml(), '<nav>x</nav>');
      expect(section('x').toHtml(), '<section>x</section>');
    });

    test('text content elements', () {
      expect(p('para').toHtml(), '<p>para</p>');
      expect(pre('code').toHtml(), '<pre>code</pre>');
      expect(blockquote('q').toHtml(), '<blockquote>q</blockquote>');
      expect(ol([li('1')]).toHtml(), '<ol><li>1</li></ol>');
      expect(ul([li('1')]).toHtml(), '<ul><li>1</li></ul>');
      expect(hr().toHtml(), '<hr />');
      expect(br().toHtml(), '<br />');
    });

    test('inline text elements', () {
      expect(code('x').toHtml(), '<code>x</code>');
      expect(em('x').toHtml(), '<em>x</em>');
      expect(i('x').toHtml(), '<i>x</i>');
      expect(s('x').toHtml(), '<s>x</s>');
      expect(small('x').toHtml(), '<small>x</small>');
      expect(strong('x').toHtml(), '<strong>x</strong>');
      expect(b('x').toHtml(), '<b>x</b>');
      expect(u('x').toHtml(), '<u>x</u>');
    });

    test('form elements', () {
      expect(
        form(
          [input(type: 'text')],
          action: '/submit',
          method: 'post',
        ).toHtml(),
        contains('<form'),
      );
      expect(label('Name', htmlFor: 'name').toHtml(), contains('for="name"'));
      expect(
        select([option('A', value: 'a')], name: 'sel').toHtml(),
        contains('<select'),
      );
      expect(textarea([], name: 'ta').toHtml(), contains('<textarea'));
    });

    test('meta and link elements', () {
      expect(
        meta(attributes: {'charset': 'utf-8'}).toHtml(),
        '<meta charset="utf-8" />',
      );
      expect(
        link(rel: 'stylesheet', href: 'style.css').toHtml(),
        '<link rel="stylesheet" href="style.css" />',
      );
    });

    test('script element', () {
      expect(
        script([], src: '/app.js', defer: true).toHtml(),
        '<script src="/app.js" defer></script>',
      );
    });

    test('template and style elements', () {
      expect(
        template(['slot'], shadowrootmode: 'open').toHtml(),
        contains('shadowrootmode="open"'),
      );
      expect(style(['.x{color:red}']).toHtml(), '<style>.x{color:red}</style>');
    });

    test('generic element helper', () {
      expect(
        element('my-component', ['child']).toHtml(),
        '<my-component>child</my-component>',
      );
    });
  });
}
