@TestOn('browser')
import 'package:spark_web/spark_web.dart' as spark;
import 'package:test/test.dart';

void main() {
  group('Browser Window', () {
    test('Timer methods', () async {
      bool called = false;
      spark.window.setTimeout(() {
        called = true;
      }, 10);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(called, isTrue);
      
      final handle = spark.window.setInterval(() {}, 100);
      spark.window.clearInterval(handle);
    });

    test('Encoding methods', () {
      expect(spark.window.btoa('hello'), 'aGVsbG8=');
      expect(spark.window.atob('aGVsbG8='), 'hello');
    });

    test('Navigator and Storage', () {
      expect(spark.window.navigator.userAgent, isNotEmpty);
      expect(spark.window.localStorage, isNotNull);
      expect(spark.window.sessionStorage, isNotNull);
      
      spark.window.localStorage.setItem('spark_test', 'value');
      expect(spark.window.localStorage.getItem('spark_test'), 'value');
      spark.window.localStorage.removeItem('spark_test');
    });

    test('Location and History', () {
      expect(spark.window.location.href, isNotEmpty);
      expect(spark.window.history.length, isPositive);
    });

    test('Performance', () {
      expect(spark.window.performance.now(), isPositive);
    });

    test('Crypto', () {
      expect(spark.window.crypto.randomUUID(), hasLength(36));
    });
  });
}
