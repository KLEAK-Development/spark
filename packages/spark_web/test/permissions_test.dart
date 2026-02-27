import 'package:spark_web/spark_web.dart';
import 'package:test/test.dart';

void main() {
  group('PermissionState', () {
    test('constants', () {
      expect(PermissionState.granted.value, 'granted');
      expect(PermissionState.denied.value, 'denied');
      expect(PermissionState.prompt.value, 'prompt');
    });

    test('equality and hashCode', () {
      expect(PermissionState.granted, const PermissionState('granted'));
      expect(
        PermissionState.granted.hashCode,
        const PermissionState('granted').hashCode,
      );
      expect(PermissionState.granted, isNot(PermissionState.denied));
    });

    test('toString', () {
      expect(PermissionState.granted.toString(), 'PermissionState(granted)');
    });
  });

  group('PermissionName', () {
    test('constants have correct values', () {
      expect(PermissionName.geolocation.value, 'geolocation');
      expect(PermissionName.notifications.value, 'notifications');
      expect(PermissionName.push.value, 'push');
      expect(PermissionName.persistentStorage.value, 'persistent-storage');
      expect(PermissionName.clipboardRead.value, 'clipboard-read');
      expect(PermissionName.clipboardWrite.value, 'clipboard-write');
      expect(PermissionName.camera.value, 'camera');
      expect(PermissionName.microphone.value, 'microphone');
      expect(PermissionName.backgroundFetch.value, 'background-fetch');
      expect(PermissionName.backgroundSync.value, 'background-sync');
    });

    test('equality and hashCode', () {
      expect(PermissionName.camera, const PermissionName('camera'));
      expect(
        PermissionName.camera.hashCode,
        const PermissionName('camera').hashCode,
      );
      expect(PermissionName.camera, isNot(PermissionName.microphone));
    });

    test('toString', () {
      expect(PermissionName.camera.toString(), 'PermissionName(camera)');
    });
  });

  group('PermissionDescriptor', () {
    test('constructor sets name', () {
      const descriptor = PermissionDescriptor(name: PermissionName.camera);
      expect(descriptor.name, PermissionName.camera);
    });
  });

  group('PushPermissionDescriptor', () {
    test('name is push', () {
      const descriptor = PushPermissionDescriptor();
      expect(descriptor.name, PermissionName.push);
    });

    test('userVisibleOnly defaults to false', () {
      const descriptor = PushPermissionDescriptor();
      expect(descriptor.userVisibleOnly, isFalse);
    });

    test('userVisibleOnly can be set', () {
      const descriptor = PushPermissionDescriptor(userVisibleOnly: true);
      expect(descriptor.userVisibleOnly, isTrue);
    });
  });

  group('MidiPermissionDescriptor', () {
    test('name is midi', () {
      const descriptor = MidiPermissionDescriptor();
      expect(descriptor.name.value, 'midi');
    });

    test('sysex defaults to false', () {
      const descriptor = MidiPermissionDescriptor();
      expect(descriptor.sysex, isFalse);
    });

    test('sysex can be set', () {
      const descriptor = MidiPermissionDescriptor(sysex: true);
      expect(descriptor.sysex, isTrue);
    });
  });

  group('DevicePermissionDescriptor', () {
    test('accepts name and optional deviceId', () {
      const descriptor = DevicePermissionDescriptor(
        name: PermissionName.camera,
      );
      expect(descriptor.name, PermissionName.camera);
      expect(descriptor.deviceId, isNull);
    });

    test('accepts deviceId', () {
      const descriptor = DevicePermissionDescriptor(
        name: PermissionName.microphone,
        deviceId: 'abc123',
      );
      expect(descriptor.name, PermissionName.microphone);
      expect(descriptor.deviceId, 'abc123');
    });
  });
}
