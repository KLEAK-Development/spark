@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Server DOM', () {
    test('ServerNode properties and methods', () {
      final node = web.document.createTextNode('test');
      expect(node.nodeType, 3);
      expect(node.nodeName, '');
      expect(node.parentNode, isNull);
      expect(node.parentElement, isNull);
      expect(node.childNodes.length, 0);
      expect(node.firstChild, isNull);
      expect(node.lastChild, isNull);
      expect(node.nextSibling, isNull);
      expect(node.previousSibling, isNull);
      expect(node.textContent, 'test');
      expect(node.isConnected, isFalse);

      final other = web.document.createTextNode('other');
      expect(node.appendChild(other), other);
      expect(node.removeChild(other), other);
      expect(node.insertBefore(other, null), other);
      expect(node.replaceChild(other, other), other);
      expect(node.cloneNode(), node);
      expect(node.contains(null), isFalse);
      expect(node.hasChildNodes(), isFalse);
    });

    test('ServerElement properties and methods', () {
      final el = web.document.createElement('div');
      expect(el.nodeType, 1);
      expect(el.tagName, '');
      expect(el.id, '');
      el.id = 'foo';
      expect(el.className, '');
      el.className = 'bar';
      expect(el.innerHTML, '');
      el.innerHTML = '<span></span>';
      expect(el.outerHTML, '');
      expect(el.namespaceURI, isNull);
      expect(el.attributes.length, 0);
      expect(el.classList.length, 0);
      expect(el.getAttribute('id'), isNull);
      el.setAttribute('id', 'foo');
      el.removeAttribute('id');
      expect(el.hasAttribute('id'), isFalse);
      expect(el.querySelector('.foo'), isNull);
      expect(el.querySelectorAll('.foo').length, 0);
      expect(el.children.length, 0);
      el.remove();
      el.append(web.document.createTextNode('text'));
    });

    test('ServerHTMLElement properties and methods', () {
      final el = web.document.createElement('div') as web.HTMLElement;
      expect(el.innerText, '');
      el.innerText = 'foo';
      expect(el.hidden, isFalse);
      el.hidden = true;
      expect(el.title, '');
      el.title = 'bar';
      el.focus();
      el.blur();
      expect(el.style, isNotNull);
      expect(el.shadowRoot, isNull);
      expect(
        el.attachShadow(const web.ShadowRootInit(mode: 'open')),
        isNotNull,
      );
    });

    test('Specific element subclasses exist and can be instantiated', () {
      expect(web.document.createElement('input'), isA<web.HTMLInputElement>());
      expect(
        web.document.createElement('button'),
        isA<web.HTMLButtonElement>(),
      );
      expect(
        web.document.createElement('textarea'),
        isA<web.HTMLTextAreaElement>(),
      );
      expect(
        web.document.createElement('select'),
        isA<web.HTMLSelectElement>(),
      );
      expect(
        web.document.createElement('option'),
        isA<web.HTMLOptionElement>(),
      );
      expect(web.document.createElement('a'), isA<web.HTMLAnchorElement>());
      expect(web.document.createElement('img'), isA<web.HTMLImageElement>());
      expect(web.document.createElement('form'), isA<web.HTMLFormElement>());
      expect(web.document.createElement('label'), isA<web.HTMLLabelElement>());
      expect(
        web.document.createElement('template'),
        isA<web.HTMLTemplateElement>(),
      );
      expect(
        web.document.createElement('canvas'),
        isA<web.HTMLCanvasElement>(),
      );
      expect(web.document.createElement('video'), isA<web.HTMLVideoElement>());
      expect(web.document.createElement('audio'), isA<web.HTMLAudioElement>());
      expect(
        web.document.createElement('dialog'),
        isA<web.HTMLDialogElement>(),
      );
      expect(
        web.document.createElement('details'),
        isA<web.HTMLDetailsElement>(),
      );
      expect(web.document.createElement('slot'), isA<web.HTMLSlotElement>());
      expect(
        web.document.createElement('iframe'),
        isA<web.HTMLIFrameElement>(),
      );
      expect(web.document.createElement('table'), isA<web.HTMLTableElement>());
      expect(web.document.createElement('ol'), isA<web.HTMLOListElement>());
      expect(web.document.createElement('li'), isA<web.HTMLLIElement>());
    });

    test('ServerHTMLInputElement', () {
      final el = web.document.createElement('input') as web.HTMLInputElement;
      el.value = 'v';
      expect(el.value, ''); // Server impl returns ''
      el.type = 't';
      expect(el.type, '');
      el.placeholder = 'p';
      expect(el.placeholder, '');
      el.disabled = true;
      expect(el.disabled, isFalse);
      el.checked = true;
      expect(el.checked, isFalse);
      el.name = 'n';
      expect(el.name, '');
    });

    test('ServerHTMLButtonElement', () {
      final el = web.document.createElement('button') as web.HTMLButtonElement;
      el.disabled = true;
      expect(el.disabled, isFalse);
      el.type = 'submit';
      expect(el.type, '');
    });

    test('ServerHTMLTextAreaElement', () {
      final el =
          web.document.createElement('textarea') as web.HTMLTextAreaElement;
      el.value = 'v';
      expect(el.value, '');
      el.placeholder = 'p';
      expect(el.placeholder, '');
      el.disabled = true;
      expect(el.disabled, isFalse);
      el.rows = 10;
      expect(el.rows, 0);
      el.cols = 20;
      expect(el.cols, 0);
    });

    test('ServerHTMLSelectElement', () {
      final el = web.document.createElement('select') as web.HTMLSelectElement;
      el.value = 'v';
      expect(el.value, '');
      el.selectedIndex = 1;
      expect(el.selectedIndex, -1);
      el.disabled = true;
      expect(el.disabled, isFalse);
    });

    test('ServerHTMLOptionElement', () {
      final el = web.document.createElement('option') as web.HTMLOptionElement;
      el.value = 'v';
      expect(el.value, '');
      el.text = 't';
      expect(el.text, '');
      el.selected = true;
      expect(el.selected, isFalse);
    });

    test('ServerHTMLAnchorElement', () {
      final el = web.document.createElement('a') as web.HTMLAnchorElement;
      el.href = 'h';
      expect(el.href, '');
      el.target = 't';
      expect(el.target, '');
    });

    test('ServerHTMLImageElement', () {
      final el = web.document.createElement('img') as web.HTMLImageElement;
      el.src = 's';
      expect(el.src, '');
      el.alt = 'a';
      expect(el.alt, '');
      el.width = 100;
      expect(el.width, 0);
      el.height = 100;
      expect(el.height, 0);
    });

    test('ServerHTMLFormElement', () {
      final el = web.document.createElement('form') as web.HTMLFormElement;
      el.action = 'a';
      expect(el.action, '');
      el.method = 'm';
      expect(el.method, '');
      el.submit();
      el.reset();
      expect(el.reportValidity(), isTrue);
    });

    test('ServerHTMLLabelElement', () {
      final el = web.document.createElement('label') as web.HTMLLabelElement;
      el.htmlFor = 'f';
      expect(el.htmlFor, '');
    });

    test('ServerHTMLTemplateElement', () {
      final el =
          web.document.createElement('template') as web.HTMLTemplateElement;
      expect(el.content, isNotNull);
    });

    test('ServerHTMLCanvasElement', () {
      final el = web.document.createElement('canvas') as web.HTMLCanvasElement;
      el.width = 100;
      expect(el.width, 0);
      el.height = 100;
      expect(el.height, 0);
      expect(el.getContext(web.CanvasContextType.canvas2d), isNull);
      expect(el.toDataURL(), '');
    });

    test('ServerHTMLMediaElement', () {
      final el = web.document.createElement('video') as web.HTMLVideoElement;
      el.src = 's';
      expect(el.src, '');
      expect(el.currentSrc, '');
      el.currentTime = 10;
      expect(el.currentTime, 0);
      expect(el.duration, 0);
      expect(el.paused, isTrue);
      expect(el.ended, isFalse);
      el.loop = true;
      expect(el.loop, isFalse);
      el.volume = 0.5;
      expect(el.volume, 1);
      el.muted = true;
      expect(el.muted, isFalse);
      el.autoplay = true;
      expect(el.autoplay, isFalse);
      el.controls = true;
      expect(el.controls, isFalse);
      el.playbackRate = 2;
      expect(el.playbackRate, 1);
      expect(el.readyState, 0);
      expect(el.networkState, 0);
      el.preload = 'none';
      expect(el.preload, 'auto');
      el.play();
      el.pause();
      el.load();
    });

    test('ServerHTMLVideoElement', () {
      final el = web.document.createElement('video') as web.HTMLVideoElement;
      el.width = 100;
      expect(el.width, 0);
      el.height = 100;
      expect(el.height, 0);
      expect(el.videoWidth, 0);
      expect(el.videoHeight, 0);
      el.poster = 'p';
      expect(el.poster, '');
      el.playsInline = true;
      expect(el.playsInline, isFalse);
    });

    test('ServerHTMLDialogElement', () {
      final el = web.document.createElement('dialog') as web.HTMLDialogElement;
      el.open = true;
      expect(el.open, isFalse);
      el.returnValue = 'v';
      expect(el.returnValue, '');
      el.show();
      el.showModal();
      el.close();
    });

    test('ServerHTMLDetailsElement', () {
      final el =
          web.document.createElement('details') as web.HTMLDetailsElement;
      el.open = true;
      expect(el.open, isFalse);
      el.name = 'n';
      expect(el.name, '');
    });

    test('ServerHTMLSlotElement', () {
      final el = web.document.createElement('slot') as web.HTMLSlotElement;
      el.name = 'n';
      expect(el.name, '');
      expect(el.assignedNodes().length, 0);
      expect(el.assignedElements().length, 0);
    });

    test('ServerHTMLIFrameElement', () {
      final el = web.document.createElement('iframe') as web.HTMLIFrameElement;
      el.src = 's';
      expect(el.src, '');
      el.name = 'n';
      expect(el.name, '');
      el.allow = 'a';
      expect(el.allow, '');
      el.allowFullscreen = true;
      expect(el.allowFullscreen, isFalse);
      el.width = '100';
      expect(el.width, '');
      el.height = '100';
      expect(el.height, '');
      el.loading = 'lazy';
      expect(el.loading, '');
      el.referrerPolicy = 'no-referrer';
      expect(el.referrerPolicy, '');
    });

    test('ServerHTMLTableElement', () {
      final el = web.document.createElement('table') as web.HTMLTableElement;
      expect(el.caption, isNull);
      el.caption = null;
      expect(el.tHead, isNull);
      el.tHead = null;
      expect(el.tFoot, isNull);
      el.tFoot = null;
      expect(el.createTBody(), isNotNull);
      expect(el.insertRow(), isNotNull);
      el.deleteRow(0);
    });

    test('ServerHTMLTableSectionElement', () {
      // No factory for table section, but table.createTBody() returns one
      final el = (web.document.createElement('table') as web.HTMLTableElement)
          .createTBody();
      expect(el.insertRow(), isNotNull);
      el.deleteRow(0);
    });

    test('ServerHTMLTableRowElement', () {
      // No direct factory, but table.insertRow() returns one
      final el = (web.document.createElement('table') as web.HTMLTableElement)
          .insertRow();
      expect(el.rowIndex, -1);
      expect(el.sectionRowIndex, -1);
      expect(el.insertCell(), isNotNull);
      el.deleteCell(0);
    });

    test('ServerHTMLTableCellElement', () {
      final table = web.document.createElement('table') as web.HTMLTableElement;
      final row = table.insertRow();
      final el = row.insertCell();
      el.colSpan = 2;
      expect(el.colSpan, 1);
      el.rowSpan = 2;
      expect(el.rowSpan, 1);
      expect(el.cellIndex, -1);
    });

    test('ServerHTMLOListElement', () {
      final el = web.document.createElement('ol') as web.HTMLOListElement;
      el.reversed = true;
      expect(el.reversed, isFalse);
      el.start = 10;
      expect(el.start, 1);
      el.type = 'a';
      expect(el.type, '');
    });

    test('ServerHTMLLIElement', () {
      final el = web.document.createElement('li') as web.HTMLLIElement;
      el.value = 10;
      expect(el.value, 0);
    });

    test('ServerHTMLProgressElement', () {
      final el =
          web.document.createElement('progress') as web.HTMLProgressElement;
      el.value = 0.5;
      expect(el.value, 0);
      el.max = 100;
      expect(el.max, 1);
      expect(el.position, -1);
    });

    test('ServerHTMLMeterElement', () {
      final el = web.document.createElement('meter') as web.HTMLMeterElement;
      el.value = 0.5;
      expect(el.value, 0);
      el.min = 0;
      expect(el.min, 0);
      el.max = 1;
      expect(el.max, 1);
      el.low = 0.2;
      expect(el.low, 0);
      el.high = 0.8;
      expect(el.high, 1);
      el.optimum = 0.5;
      expect(el.optimum, 0.5);
    });

    test('ServerHTMLOutputElement', () {
      final el = web.document.createElement('output') as web.HTMLOutputElement;
      el.value = 'v';
      expect(el.value, '');
      el.defaultValue = 'd';
      expect(el.defaultValue, '');
      el.name = 'n';
      expect(el.name, '');
      expect(el.type, 'output');
      expect(el.htmlFor, isNotNull);
    });

    test('ServerDocumentFragment', () {
      final frag = web.document.createDocumentFragment();
      expect(frag.nodeType, 11);
      expect(frag.querySelector('.foo'), isNull);
      expect(frag.querySelectorAll('.foo').length, 0);
    });

    test('ServerShadowRoot', () {
      final sr = (web.document.createElement('div') as web.HTMLElement)
          .attachShadow(const web.ShadowRootInit(mode: 'open'));
      expect(sr.host, isNotNull);
      expect(sr.mode, 'open');
      expect(sr.firstElementChild, isNull);
      expect(sr.querySelector('.foo'), isNull);
      expect(sr.querySelectorAll('.foo').length, 0);
      expect(sr.adoptedStyleSheets.length, 0);
      sr.adoptedStyleSheets = [];
    });

    test('ServerDocument', () {
      expect(web.document.nodeType, 9);
      expect(web.document.documentElement, isNull);
      expect(web.document.body, isNull);
      expect(web.document.head, isNull);
      expect(web.document.createElementNS('ns', 'div'), isNotNull);
      expect(web.document.createComment('c'), isNotNull);
      expect(web.document.getElementById('id'), isNull);
      expect(web.document.activeElement, isNull);
      expect(web.document.querySelector('.foo'), isNull);
      expect(web.document.querySelectorAll('.foo').length, 0);
    });

    test('ServerText and ServerComment', () {
      final text = web.document.createTextNode('foo');
      text.data = 'bar';
      expect(text.data, 'bar');
      expect(text.wholeText, 'bar');
      expect(text.textContent, 'bar');
      text.textContent = 'baz';
      expect(text.data, 'baz');

      final comment = web.document.createComment('foo');
      comment.data = 'bar';
      expect(comment.data, 'bar');
      expect(comment.textContent, 'bar');
      comment.textContent = 'baz';
      expect(comment.data, 'baz');
    });
  });
}
