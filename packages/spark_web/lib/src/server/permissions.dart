/// Server-side implementation of the Permissions API.
///
/// No-op on the server — always returns [PermissionState.prompt].
library;

import '../core.dart';
import '../permissions.dart' as iface;
import 'dom.dart';

// ---------------------------------------------------------------------------
// ServerPermissionStatus
// ---------------------------------------------------------------------------

class ServerPermissionStatus extends ServerEventTarget
    implements iface.PermissionStatus {
  final iface.PermissionName _name;

  ServerPermissionStatus(this._name);

  @override
  iface.PermissionState get state => iface.PermissionState.prompt;

  @override
  iface.PermissionName get name => _name;

  @override
  EventListener? onchange;
}

// ---------------------------------------------------------------------------
// ServerPermissions
// ---------------------------------------------------------------------------

class ServerPermissions implements iface.Permissions {
  @override
  Future<iface.PermissionStatus> query(
    iface.PermissionDescriptor descriptor,
  ) async =>
      ServerPermissionStatus(descriptor.name);
}
