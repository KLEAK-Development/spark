import 'package:test/test.dart';
import 'package:spark_css/spark_css.dart';

void main() {
  group('ComponentStyleRegistry', () {
    setUp(() {
      componentStyles.clear();
    });

    test('should register and retrieve styles', () {
      componentStyles.register('my-component', '.class { color: red; }');
      expect(
        componentStyles.get('my-component'),
        equals('.class { color: red; }'),
      );
    });

    test('should return null for unknown styles', () {
      expect(componentStyles.get('unknown-component'), isNull);
    });

    test('should overwrite existing styles', () {
      componentStyles.register('my-component', '.class { color: red; }');
      componentStyles.register('my-component', '.class { color: blue; }');
      expect(
        componentStyles.get('my-component'),
        equals('.class { color: blue; }'),
      );
    });

    test('should clear all styles', () {
      componentStyles.register('comp1', 'style1');
      componentStyles.register('comp2', 'style2');
      componentStyles.clear();
      expect(componentStyles.get('comp1'), isNull);
      expect(componentStyles.get('comp2'), isNull);
    });
  });
}
