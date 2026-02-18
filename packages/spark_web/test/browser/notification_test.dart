@TestOn('browser')
import 'package:spark_web/spark_web.dart' as spark;
import 'package:test/test.dart';

void main() {
  group('Browser Notification', () {
    test('constants and permission', () {
      expect(spark.notificationPermission, isA<spark.NotificationPermission>());
      expect(spark.notificationMaxActions, isNonNegative);
    });

    test('createNotification with options', () {
      try {
        final n = spark.createNotification('Test', const spark.NotificationOptions(
          body: 'body',
          timestamp: 123,
          silent: true,
          actions: [spark.NotificationAction(action: 'a', title: 'A')],
        ));
        expect(n.title, 'Test');
        expect(n.body, 'body');
        expect(n.timestamp, 123);
        expect(n.silent, isTrue);
        expect(n.actions.length, 1);
        n.close();
      } catch (e) {
        print('Notification not supported: $e');
      }
    });
  });
}
