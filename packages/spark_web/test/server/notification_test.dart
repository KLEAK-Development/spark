@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Server Notification', () {
    test('createNotification', () {
      final n = web.createNotification(
        'Hello',
        const web.NotificationOptions(
          body: 'World',
          tag: 'foo',
          icon: 'bar.png',
          badge: 'baz.png',
          image: 'img.png',
          data: {'a': 1},
          renotify: true,
          requireInteraction: true,
          silent: true,
          timestamp: 123,
          vibrate: [1, 2],
          actions: [web.NotificationAction(action: 'a', title: 'A')],
        ),
      );

      expect(n.title, 'Hello');
      expect(n.body, 'World');
      expect(n.dir, web.NotificationDirection.auto);
      expect(n.lang, '');
      expect(n.tag, 'foo');
      expect(n.icon, 'bar.png');
      expect(n.badge, 'baz.png');
      expect(n.image, 'img.png');
      expect(n.data, equals({'a': 1}));
      expect(n.renotify, isTrue);
      expect(n.requireInteraction, isTrue);
      expect(n.silent, isTrue);
      expect(n.timestamp, 123);
      expect(n.vibrate, equals([1, 2]));
      expect(n.actions.length, 1);
      n.close();
    });

    test('permission and actions', () async {
      expect(
        web.notificationPermission,
        web.NotificationPermission.defaultValue,
      );
      expect(web.notificationMaxActions, 0);
      expect(
        await web.requestNotificationPermission(),
        web.NotificationPermission.defaultValue,
      );
    });
  });
}
