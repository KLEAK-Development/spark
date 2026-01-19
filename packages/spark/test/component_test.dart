import 'package:test/test.dart';
import 'package:spark_framework/spark.dart';

// Concrete implementation for testing
class TestComponent extends WebComponent {
  @override
  String get tagName => 'test-component';

  @override
  Element render() => element(tagName, []);
}

void main() {
  group('WebComponent (Server Side)', () {
    test('is not hydrated by default', () {
      final component = TestComponent();
      expect(component.isHydrated, isFalse);
    });

    test('accessing element throws StateError when not hydrated', () {
      final component = TestComponent();
      expect(() => component.element, throwsStateError);
    });

    test('prop returns fallback when not hydrated', () {
      final component = TestComponent();
      expect(component.prop('foo', 'bar'), equals('bar'));
      expect(component.prop('foo'), equals(''));
    });

    test('propInt returns fallback when not hydrated', () {
      final component = TestComponent();
      expect(component.propInt('count', 10), equals(10));
      expect(component.propInt('count'), equals(0));
    });

    test('propDouble returns fallback when not hydrated', () {
      final component = TestComponent();
      expect(component.propDouble('ratio', 1.5), equals(1.5));
      expect(component.propDouble('ratio'), equals(0.0));
    });

    test('propBool returns fallback when not hydrated', () {
      final component = TestComponent();
      expect(component.propBool('active', true), isTrue);
      expect(component.propBool('active'), isFalse);
    });

    test('query returns null when not populated', () {
      final component = TestComponent();
      expect(component.query('.any'), isNull);
    });

    test('queryAll returns empty list when not populated', () {
      final component = TestComponent();
      expect(component.queryAll('.any'), isEmpty);
    });
  });
}
