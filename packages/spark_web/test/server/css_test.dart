@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Server CSS', () {
    test('ServerCSSStyleSheet', () async {
      final sheet = web.createCSSStyleSheet();
      sheet.replaceSync('body { color: red; }');
      await sheet.replace('body { color: blue; }');
    });

    test('ServerCSSStyleDeclaration', () {
      final el = web.document.createElement('div') as web.HTMLElement;
      final style = el.style;
      expect(style.getPropertyValue('color'), '');
      style.setProperty('color', 'red');
      expect(style.removeProperty('color'), '');
      expect(style.display, '');
      style.display = 'block';
      expect(style.visibility, '');
      style.visibility = 'hidden';
      expect(style.opacity, '');
      style.opacity = '0.5';
    });
  });
}
