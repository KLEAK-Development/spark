import 'package:test/test.dart';
import 'package:spark_css/spark_css.dart';

void main() {
  group('Style', () {
    test('renders simple properties', () {
      final style = Style(color: 'red', fontSize: '12px');
      expect(style.toCss(), contains('color: red;'));
      expect(style.toCss(), contains('font-size: 12px;'));
    });

    test('renders added custom properties', () {
      final style = Style();
      style.add('--custom-var', '10px');
      expect(style.toCss(), contains('--custom-var: 10px;'));
    });

    test('renders mixed properties', () {
      final style = Style(color: 'blue');
      style.add('background-color', 'white');
      final css = style.toCss();
      expect(css, contains('color: blue;'));
      expect(css, contains('background-color: white;'));
    });

    test('renders nested stylesheet', () {
      final style = Style(
        color: 'red',
        css: css({'@media (max-width: 600px)': Style(color: 'blue')}),
      );
      final output = style.toCss();
      expect(output, contains('color: red;'));
      expect(output, contains('@media (max-width: 600px) {'));
      // The inner style properties are indented by Style.toCss but Stylesheet wraps them
      expect(output, contains('color: blue;'));
    });
  });

  group('Stylesheet', () {
    test('renders multiple rules', () {
      final sheet = css({
        'body': Style(margin: '0'),
        '.foo': Style(color: 'red'),
      });
      final output = sheet.toCss();
      expect(output, contains('body {'));
      expect(output, contains('margin: 0;'));
      expect(output, contains('.foo {'));
      expect(output, contains('color: red;'));
    });
  });

  test('respects minification settings (unminified in dev)', () {
    // In test environment (VM), dart.vm.product is false.
    // So we expect unminified CSS with indentation/newlines.
    final style = Style(color: 'red');
    final css = style.toCss();
    // Check for newline after property
    expect(css, contains(';\n'));
    // Check for indentation
    expect(css, contains('  color: red;'));
  });
}
