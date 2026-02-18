@TestOn('browser')
import 'package:spark_web/spark_web.dart' as spark;
import 'package:spark_web/src/browser/dom.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  group('Browser DOM Wrapping', () {
    test('wrapNode handles various types', () {
      expect(wrapNode(web.document.createElement('div')), isA<spark.HTMLDivElement>());
      expect(wrapNode(web.document.createElement('span')), isA<spark.HTMLSpanElement>());
      expect(wrapNode(web.document.createElement('input')), isA<spark.HTMLInputElement>());
      expect(wrapNode(web.document.createElement('button')), isA<spark.HTMLButtonElement>());
      expect(wrapNode(web.document.createElement('textarea')), isA<spark.HTMLTextAreaElement>());
      expect(wrapNode(web.document.createElement('select')), isA<spark.HTMLSelectElement>());
      expect(wrapNode(web.document.createElement('option')), isA<spark.HTMLOptionElement>());
      expect(wrapNode(web.document.createElement('a')), isA<spark.HTMLAnchorElement>());
      expect(wrapNode(web.document.createElement('img')), isA<spark.HTMLImageElement>());
      expect(wrapNode(web.document.createElement('form')), isA<spark.HTMLFormElement>());
      expect(wrapNode(web.document.createElement('label')), isA<spark.HTMLLabelElement>());
      expect(wrapNode(web.document.createElement('template')), isA<spark.HTMLTemplateElement>());
      expect(wrapNode(web.document.createElement('canvas')), isA<spark.HTMLCanvasElement>());
      expect(wrapNode(web.document.createElement('video')), isA<spark.HTMLVideoElement>());
      expect(wrapNode(web.document.createElement('audio')), isA<spark.HTMLAudioElement>());
      expect(wrapNode(web.document.createElement('dialog')), isA<spark.HTMLDialogElement>());
      expect(wrapNode(web.document.createElement('details')), isA<spark.HTMLDetailsElement>());
      expect(wrapNode(web.document.createElement('slot')), isA<spark.HTMLSlotElement>());
      expect(wrapNode(web.document.createElement('iframe')), isA<spark.HTMLIFrameElement>());
      expect(wrapNode(web.document.createElement('table')), isA<spark.HTMLTableElement>());
      expect(wrapNode(web.document.createElement('progress')), isA<spark.HTMLProgressElement>());
      expect(wrapNode(web.document.createElement('meter')), isA<spark.HTMLMeterElement>());
      expect(wrapNode(web.document.createElement('output')), isA<spark.HTMLOutputElement>());
      
      final table = web.document.createElement('table') as web.HTMLTableElement;
      expect(wrapNode(table.createTBody()), isA<spark.HTMLTableSectionElement>());
      expect(wrapNode(table.insertRow()), isA<spark.HTMLTableRowElement>());
      
      expect(wrapNode(web.document.createElement('ol')), isA<spark.HTMLOListElement>());
      expect(wrapNode(web.document.createElement('li')), isA<spark.HTMLLIElement>());
      expect(wrapNode(web.document.createElement('p')), isA<spark.HTMLParagraphElement>());
      
      expect(wrapNode(web.document.createTextNode('foo')), isA<spark.Text>());
      expect(wrapNode(web.document.createComment('foo')), isA<spark.Comment>());
      expect(wrapNode(web.document.createDocumentFragment()), isA<spark.DocumentFragment>());
      
      final div = web.document.createElement('div');
      final shadow = div.attachShadow(web.ShadowRootInit(mode: 'open'));
      expect(wrapNode(shadow), isA<spark.ShadowRoot>());
    });

    test('wrapEvent handles various types', () {
      expect(wrapEvent(web.MouseEvent('click')), isA<spark.MouseEvent>());
      expect(wrapEvent(web.KeyboardEvent('keydown')), isA<spark.KeyboardEvent>());
      expect(wrapEvent(web.FocusEvent('focus')), isA<spark.FocusEvent>());
      expect(wrapEvent(web.InputEvent('input')), isA<spark.InputEvent>());
      expect(wrapEvent(web.WheelEvent('wheel')), isA<spark.WheelEvent>());
      expect(wrapEvent(web.PointerEvent('pointerdown')), isA<spark.PointerEvent>());
      expect(wrapEvent(web.AnimationEvent('animationend')), isA<spark.AnimationEvent>());
      expect(wrapEvent(web.TransitionEvent('transitionend')), isA<spark.TransitionEvent>());
      expect(wrapEvent(web.Event('foo')), isA<spark.Event>());
    });
  });

  group('BrowserNode', () {
    test('Node operations', () {
      final div = spark.document.createElement('div');
      final span = spark.document.createElement('span');
      
      div.appendChild(span);
      expect(div.firstChild, isNotNull);
      expect(div.firstChild!.nodeName.toLowerCase(), 'span');
      expect(div.hasChildNodes(), isTrue);
      
      final text = spark.document.createTextNode('hello');
      div.insertBefore(text, span);
      expect(div.firstChild, isA<spark.Text>());
      
      div.replaceChild(spark.document.createElement('b'), text);
      expect(div.firstChild!.nodeName.toLowerCase(), 'b');
      
      div.removeChild(div.firstChild!);
      expect(div.firstChild!.nodeName.toLowerCase(), 'span');
      
      expect(div.contains(span), isTrue);
      
      final clone = div.cloneNode(true);
      expect(clone.nodeName, div.nodeName);
      
      div.textContent = 'new content';
      expect(div.textContent, 'new content');
      
      expect(div.parentNode, isNull);
      spark.document.body!.appendChild(div);
      expect(div.parentNode, isNotNull);
      expect(div.isConnected, isTrue);
      div.remove();
    });
  });

  group('BrowserElement', () {
    test('Element operations', () {
      final el = spark.document.createElement('div');
      el.id = 'my-id';
      expect(el.id, 'my-id');
      el.className = 'foo bar';
      expect(el.className, 'foo bar');
      expect(el.classList.contains('foo'), isTrue);
      
      el.setAttribute('data-test', 'value');
      expect(el.getAttribute('data-test'), 'value');
      expect(el.hasAttribute('data-test'), isTrue);
      el.removeAttribute('data-test');
      expect(el.hasAttribute('data-test'), isFalse);
      
      el.innerHTML = '<span>inner</span>';
      expect(el.innerHTML, contains('span'));
      expect(el.outerHTML, contains('div'));
      
      final span = el.querySelector('span');
      expect(span, isNotNull);
      expect(el.querySelectorAll('span').length, 1);
      
      expect(el.children.length, 1);
      
      el.append(spark.document.createElement('b'));
      expect(el.children.length, 2);
    });
  });

  group('BrowserHTMLElement', () {
    test('HTMLElement operations', () {
      final el = spark.document.createElement('div') as spark.HTMLElement;
      el.innerText = 'foo';
      expect(el.innerText, 'foo');
      el.hidden = true;
      expect(el.hidden, isTrue);
      el.title = 'hint';
      expect(el.title, 'hint');
      
      el.style.setProperty('color', 'red');
      expect(el.style.getPropertyValue('color'), 'red');
      
      el.focus();
      el.blur();
      
      final shadow = el.attachShadow(const spark.ShadowRootInit(mode: 'open'));
      expect(el.shadowRoot, isNotNull);
      expect(shadow.mode, 'open');
      expect(shadow.host.raw, el.raw);
    });

    test('BrowserHTMLOutputElement', () {
      final el = spark.document.createElement('output') as spark.HTMLOutputElement;
      el.value = 'foo';
      expect(el.value, 'foo');
      el.defaultValue = 'bar';
      expect(el.defaultValue, 'bar');
      el.name = 'test';
      expect(el.name, 'test');
      expect(el.htmlFor, isNotNull);
    });

    test('BrowserHTMLProgressElement', () {
      final el = spark.document.createElement('progress') as spark.HTMLProgressElement;
      el.value = 0.5;
      expect(el.value, 0.5);
      el.max = 1.0;
      expect(el.max, 1.0);
      expect(el.position, isNonNegative);
    });

    test('BrowserHTMLMeterElement', () {
      final el = spark.document.createElement('meter') as spark.HTMLMeterElement;
      el.min = 0;
      expect(el.min, 0);
      el.max = 100;
      expect(el.max, 100);
      el.value = 50;
      expect(el.value, 50);
      el.low = 10;
      expect(el.low, 10);
      el.high = 90;
      expect(el.high, 90);
      el.optimum = 50;
      expect(el.optimum, 50);
    });
  });

  group('MutationObserver', () {
    test('observe changes', () async {
      final div = spark.document.createElement('div');
      final observer = spark.createMutationObserver((mutations, obs) {
      });
      
      observer.observe(div, const spark.MutationObserverInit(childList: true));
      div.appendChild(spark.document.createElement('span'));
      
      await Future.delayed(const Duration(milliseconds: 50));
      observer.disconnect();
      expect(observer.takeRecords(), isA<List<spark.MutationRecord>>());
    });
  });
}
