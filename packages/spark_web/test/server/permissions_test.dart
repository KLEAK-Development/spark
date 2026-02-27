@TestOn('vm')
import 'package:spark_web/spark_web.dart' as web;
import 'package:test/test.dart';

void main() {
  group('Server Permissions', () {
    test('navigator.permissions is accessible', () {
      expect(web.window.navigator.permissions, isNotNull);
    });

    test('query returns PermissionStatus with state prompt', () async {
      final status = await web.window.navigator.permissions.query(
        const web.PermissionDescriptor(name: web.PermissionName.camera),
      );
      expect(status.state, web.PermissionState.prompt);
    });

    test('query returns correct name', () async {
      final status = await web.window.navigator.permissions.query(
        const web.PermissionDescriptor(name: web.PermissionName.geolocation),
      );
      expect(status.name, web.PermissionName.geolocation);
    });

    test('onchange getter/setter works', () async {
      final status = await web.window.navigator.permissions.query(
        const web.PermissionDescriptor(name: web.PermissionName.camera),
      );
      expect(status.onchange, isNull);

      void handler(web.Event event) {}
      status.onchange = handler;
      expect(status.onchange, handler);

      status.onchange = null;
      expect(status.onchange, isNull);
    });
  });
}
