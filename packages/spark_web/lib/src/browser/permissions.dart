/// Browser implementation of the Permissions API wrapping `package:web`.
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../core.dart';
import '../permissions.dart' as iface;
import 'dom.dart';

// ---------------------------------------------------------------------------
// BrowserPermissionStatus
// ---------------------------------------------------------------------------

class BrowserPermissionStatus extends BrowserEventTarget
    implements iface.PermissionStatus {
  final web.PermissionStatus _native;

  BrowserPermissionStatus(this._native) : super(_native);

  @override
  iface.PermissionState get state => iface.PermissionState(_native.state);

  @override
  iface.PermissionName get name => iface.PermissionName(_native.name);

  @override
  EventListener? get onchange => _onchange;
  EventListener? _onchange;

  @override
  set onchange(EventListener? callback) {
    _onchange = callback;
    if (callback != null) {
      _native.onchange = ((web.Event event) {
        callback(BrowserEvent(event));
      }).toJS;
    } else {
      _native.onchange = null;
    }
  }
}

// ---------------------------------------------------------------------------
// BrowserPermissions
// ---------------------------------------------------------------------------

class BrowserPermissions implements iface.Permissions {
  final web.Permissions _native;

  BrowserPermissions(this._native);

  @override
  Future<iface.PermissionStatus> query(
    iface.PermissionDescriptor descriptor,
  ) async {
    final jsDescriptor = _toJsDescriptor(descriptor);
    final status = await _native.query(jsDescriptor).toDart;
    return BrowserPermissionStatus(status);
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

JSObject _toJsDescriptor(iface.PermissionDescriptor descriptor) {
  final map = <String, Object?>{'name': descriptor.name.value};

  if (descriptor is iface.PushPermissionDescriptor) {
    map['userVisibleOnly'] = descriptor.userVisibleOnly;
  } else if (descriptor is iface.MidiPermissionDescriptor) {
    map['sysex'] = descriptor.sysex;
  } else if (descriptor is iface.DevicePermissionDescriptor) {
    if (descriptor.deviceId != null) {
      map['deviceId'] = descriptor.deviceId;
    }
  }

  return map.jsify() as JSObject;
}
