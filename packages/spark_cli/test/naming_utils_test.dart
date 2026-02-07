import 'package:test/test.dart';
import 'package:spark_cli/src/utils/naming_utils.dart';

void main() {
  group('toSnakeCase', () {
    test('converts PascalCase to snake_case', () {
      expect(toSnakeCase('MyCounter'), equals('my_counter'));
      expect(toSnakeCase('DashboardPage'), equals('dashboard_page'));
      expect(toSnakeCase('UserProfile'), equals('user_profile'));
    });

    test('converts camelCase to snake_case', () {
      expect(toSnakeCase('myCounter'), equals('my_counter'));
      expect(toSnakeCase('dashboardPage'), equals('dashboard_page'));
    });

    test('keeps snake_case as-is (lowered)', () {
      expect(toSnakeCase('my_counter'), equals('my_counter'));
      expect(toSnakeCase('dashboard_page'), equals('dashboard_page'));
    });

    test('lowercases already snake_case with uppercase', () {
      expect(toSnakeCase('My_Counter'), equals('my_counter'));
    });

    test('handles single word', () {
      expect(toSnakeCase('dashboard'), equals('dashboard'));
      expect(toSnakeCase('Dashboard'), equals('dashboard'));
    });

    test('handles empty string', () {
      expect(toSnakeCase(''), equals(''));
    });

    test('handles multiple uppercase transitions', () {
      expect(toSnakeCase('MyBigComponent'), equals('my_big_component'));
    });
  });

  group('toPascalCase', () {
    test('converts snake_case to PascalCase', () {
      expect(toPascalCase('my_counter'), equals('MyCounter'));
      expect(toPascalCase('dashboard_page'), equals('DashboardPage'));
      expect(toPascalCase('user_profile'), equals('UserProfile'));
    });

    test('converts PascalCase to PascalCase (round-trip)', () {
      expect(toPascalCase('MyCounter'), equals('MyCounter'));
      expect(toPascalCase('DashboardPage'), equals('DashboardPage'));
    });

    test('handles single word', () {
      expect(toPascalCase('dashboard'), equals('Dashboard'));
    });

    test('handles empty string', () {
      expect(toPascalCase(''), equals(''));
    });

    test('handles multiple segments', () {
      expect(toPascalCase('my_big_component'), equals('MyBigComponent'));
    });
  });

  group('toKebabCase', () {
    test('converts snake_case to kebab-case', () {
      expect(toKebabCase('my_counter'), equals('my-counter'));
      expect(toKebabCase('dashboard_page'), equals('dashboard-page'));
    });

    test('converts PascalCase to kebab-case', () {
      expect(toKebabCase('MyCounter'), equals('my-counter'));
      expect(toKebabCase('DashboardPage'), equals('dashboard-page'));
    });

    test('handles single word', () {
      expect(toKebabCase('dashboard'), equals('dashboard'));
    });

    test('handles empty string', () {
      expect(toKebabCase(''), equals(''));
    });
  });

  group('isValidComponentName', () {
    test('rejects single word (no hyphen possible)', () {
      expect(isValidComponentName('counter'), isFalse);
      expect(isValidComponentName('button'), isFalse);
      expect(isValidComponentName('dialog'), isFalse);
    });

    test('accepts snake_case with multiple segments', () {
      expect(isValidComponentName('my_counter'), isTrue);
      expect(isValidComponentName('user_card'), isTrue);
      expect(isValidComponentName('nav_bar'), isTrue);
    });

    test('accepts PascalCase with multiple segments', () {
      expect(isValidComponentName('MyCounter'), isTrue);
      expect(isValidComponentName('UserCard'), isTrue);
      expect(isValidComponentName('NavBar'), isTrue);
    });

    test('accepts multi-segment names', () {
      expect(isValidComponentName('my_big_component'), isTrue);
      expect(isValidComponentName('MyBigComponent'), isTrue);
    });
  });
}
