import 'package:spark_web/spark_web.dart';
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

  test('LocalStorage is backed by Map on server', () {
    window.localStorage.setItem('key', 'value');
    expect(window.localStorage.getItem('key'), equals('value'));
    window.localStorage.removeItem('key');
  });

  test('Console logs do not crash', () {
    window.console.log('Testing console.log');
  });

  test('Navigator properties', () {
    expect(window.navigator.userAgent, equals('Spark Server'));
  });
}
