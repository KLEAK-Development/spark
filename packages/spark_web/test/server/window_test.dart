@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Server Window', () {
    test('Window properties', () {
      expect(web.window.document, isNotNull);
      expect(web.window.console, isNotNull);
      expect(web.window.navigator, isNotNull);
      expect(web.window.localStorage, isNotNull);
      expect(web.window.sessionStorage, isNotNull);
      expect(web.window.location, isNotNull);
      expect(web.window.history, isNotNull);
      expect(web.window.crypto, isNotNull);
      expect(web.window.performance, isNotNull);
      expect(web.window.customElements, isNotNull);
    });

    test('Window dialogs', () {
      web.window.alert('foo');
      expect(web.window.confirm('foo'), isFalse);
      expect(web.window.prompt('foo', 'bar'), 'bar');
    });

    test('Timers', () async {
      web.window.setTimeout(() {}, 10);
      web.window.clearTimeout(0);
      web.window.setInterval(() {}, 10);
      web.window.clearInterval(0);
    });

    test('requestAnimationFrame', () async {
      web.window.requestAnimationFrame((_) {});
      web.window.cancelAnimationFrame(0);
    });

    test('Encoding', () {
      expect(web.window.btoa('foo'), 'Zm9v');
      expect(web.window.atob('Zm9v'), 'foo');
    });

    test('ServerStorage', () {
      final storage = web.window.localStorage;
      storage.setItem('foo', 'bar');
      expect(storage.getItem('foo'), 'bar');
      expect(storage.length, 1);
      expect(storage.key(0), 'foo');
      expect(storage.key(1), isNull);
      storage.removeItem('foo');
      expect(storage.length, 0);
      storage.setItem('a', 'b');
      storage.clear();
      expect(storage.length, 0);
    });

    test('ServerLocation', () {
      final loc = web.window.location;
      loc.href = 'foo'; expect(loc.href, '');
      expect(loc.protocol, '');
      expect(loc.host, '');
      expect(loc.hostname, '');
      expect(loc.port, '');
      expect(loc.pathname, '');
      expect(loc.search, '');
      expect(loc.hash, '');
      expect(loc.origin, '');
      loc.assign('foo');
      loc.replace('foo');
      loc.reload();
    });

    test('ServerHistory', () {
      final hist = web.window.history;
      expect(hist.length, 0);
      expect(hist.state, isNull);
      hist.pushState(null, 'foo');
      hist.replaceState(null, 'foo');
      hist.back();
      hist.forward();
      hist.go();
    });

    test('ServerNavigator', () {
      final nav = web.window.navigator;
      expect(nav.userAgent, 'Spark Server');
      expect(nav.language, 'en-US');
      expect(nav.languages, equals(['en-US']));
      expect(nav.onLine, isTrue);
      expect(nav.clipboard, isNotNull);
      expect(nav.geolocation, isNotNull);
    });

    test('ServerConsole', () {
      final console = web.window.console;
      console.log('foo');
      console.warn('foo');
      console.error('foo');
      console.info('foo');
      console.debug('foo');
    });

    test('ServerCrypto', () {
      final crypto = web.window.crypto;
      final uuid = crypto.randomUUID();
      expect(uuid.length, 36);
      expect(uuid[14], '4'); // Version 4
    });

    test('ServerPerformance', () {
      final perf = web.window.performance;
      expect(perf.now(), isNonNegative);
    });

    test('ServerCustomElementRegistry', () async {
      final reg = web.window.customElements;
      reg.define('foo', Object());
      expect(reg.get('foo'), isNull);
      reg.upgrade(web.document.createElement('div'));
      await reg.whenDefined('foo');
    });

    test('ServerClipboard', () async {
      final cb = web.window.navigator.clipboard;
      await cb.writeText('foo');
      expect(await cb.readText(), 'foo');
    });
  });
}
