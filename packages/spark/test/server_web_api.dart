import 'package:spark_framework/src/component/stubs.dart';
import 'package:test/test.dart';

void main() {
  test('Crypto generates UUID', () {
    final uuid = window.crypto.randomUUID();
    print('UUID: $uuid');
    expect(uuid, isNotEmpty);
    expect(uuid.length, 36);
  });

  test('Base64 encoding/decoding', () {
    final original = 'Hello World';
    final encoded = window.btoa(original);
    final decoded = window.atob(encoded);
    expect(encoded, equals('SGVsbG8gV29ybGQ='));
    expect(decoded, equals(original));
  });

  test('LocalStorage is stateless no-op', () {
    window.localStorage.setItem('key', 'value');
    // Should be null because server stubs don't persist state
    expect(window.localStorage.getItem('key'), isNull);
  });

  test('Console logs do not crash', () {
    window.console.log('Testing console.log');
  });

  test('Navigator properties', () {
    expect(window.navigator.userAgent, equals('Spark'));
  });
}
