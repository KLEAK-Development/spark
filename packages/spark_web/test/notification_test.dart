import 'package:spark_web/spark_web.dart';
import 'package:test/test.dart';

void main() {
  group('NotificationDirection', () {
    test('constants', () {
      expect(NotificationDirection.auto.value, 'auto');
      expect(NotificationDirection.ltr.value, 'ltr');
      expect(NotificationDirection.rtl.value, 'rtl');
    });

    test('equality and hashCode', () {
      expect(NotificationDirection.auto, const NotificationDirection('auto'));
      expect(NotificationDirection.auto.hashCode, const NotificationDirection('auto').hashCode);
      expect(NotificationDirection.auto, isNot(NotificationDirection.ltr));
    });

    test('toString', () {
      expect(NotificationDirection.auto.toString(), 'NotificationDirection(auto)');
    });
  });

  group('NotificationPermission', () {
    test('constants', () {
      expect(NotificationPermission.defaultValue.value, 'default');
      expect(NotificationPermission.denied.value, 'denied');
      expect(NotificationPermission.granted.value, 'granted');
    });

    test('equality and hashCode', () {
      expect(NotificationPermission.granted, const NotificationPermission('granted'));
      expect(NotificationPermission.granted.hashCode, const NotificationPermission('granted').hashCode);
    });

    test('toString', () {
      expect(NotificationPermission.granted.toString(), 'NotificationPermission(granted)');
    });
  });

  group('NotificationAction', () {
    test('constructor', () {
      const action = NotificationAction(action: 'view', title: 'View', icon: 'view.png');
      expect(action.action, 'view');
      expect(action.title, 'View');
      expect(action.icon, 'view.png');
    });
  });

  group('NotificationOptions', () {
    test('constructor sets defaults', () {
      const options = NotificationOptions();
      expect(options.body, '');
      expect(options.dir, NotificationDirection.auto);
      expect(options.lang, '');
      expect(options.tag, '');
      expect(options.renotify, isFalse);
      expect(options.requireInteraction, isFalse);
      expect(options.silent, isNull);
    });

    test('constructor sets properties', () {
      const options = NotificationOptions(
        body: 'Hello',
        silent: true,
        timestamp: 12345,
        vibrate: [100, 200],
      );
      expect(options.body, 'Hello');
      expect(options.silent, isTrue);
      expect(options.timestamp, 12345);
      expect(options.vibrate, [100, 200]);
    });
  });
}
