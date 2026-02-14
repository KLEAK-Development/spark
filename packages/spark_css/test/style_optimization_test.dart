import 'package:test/test.dart';
import 'package:spark_css/spark_css.dart';

void main() {
  group('Style Optimization', () {
    test('caches toCss result', () {
      final style = Style(color: 'red');
      final css1 = style.toCss();
      final css2 = style.toCss();
      expect(css1, equals(css2));
      expect(
        identical(css1, css2),
        isTrue,
        reason: 'Should return exact same string object',
      );
    });

    test('invalidates cache on add', () {
      final style = Style(color: 'red');
      final css1 = style.toCss();
      expect(css1, contains('color: red;'));

      style.add('background', 'blue');
      final css2 = style.toCss();
      expect(css2, contains('color: red;'));
      expect(css2, contains('background: blue;'));
      expect(
        identical(css1, css2),
        isFalse,
        reason: 'Should return new string object',
      );

      final css3 = style.toCss();
      expect(
        identical(css2, css3),
        isTrue,
        reason: 'Should return cached string again',
      );
    });

    test('Stylesheet caches toCss result', () {
      final sheet = css({'.foo': Style(color: 'red')});
      final css1 = sheet.toCss();
      final css2 = sheet.toCss();
      expect(css1, equals(css2));
      expect(identical(css1, css2), isTrue);
    });
  });
}
