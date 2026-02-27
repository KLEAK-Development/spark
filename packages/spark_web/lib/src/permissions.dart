/// Permissions API types matching the MDN Web API.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Permissions_API
library;

import 'core.dart';

// ---------------------------------------------------------------------------
// PermissionState
// ---------------------------------------------------------------------------

/// The state of a permission.
///
/// Use the predefined constants ([granted], [denied], [prompt]) or construct
/// with a raw string for forward-compatibility with future spec values.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/PermissionStatus/state
class PermissionState {
  /// The underlying string value (e.g. `'granted'`, `'denied'`, `'prompt'`).
  final String value;

  /// Creates a state from a raw string value.
  ///
  /// Prefer the predefined constants when possible. Use this constructor
  /// for values not yet covered by this library.
  const PermissionState(this.value);

  /// The user has granted the permission.
  static const granted = PermissionState('granted');

  /// The user has denied the permission.
  static const denied = PermissionState('denied');

  /// The user has not yet granted or denied the permission.
  static const prompt = PermissionState('prompt');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionState && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PermissionState($value)';
}

// ---------------------------------------------------------------------------
// PermissionName
// ---------------------------------------------------------------------------

/// The name of a permission that can be queried.
///
/// Use the predefined constants or construct with a raw string for
/// forward-compatibility with future spec values.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Permissions/query#name
class PermissionName {
  /// The underlying string value.
  final String value;

  /// Creates a permission name from a raw string value.
  ///
  /// Prefer the predefined constants when possible.
  const PermissionName(this.value);

  static const geolocation = PermissionName('geolocation');
  static const notifications = PermissionName('notifications');
  static const push = PermissionName('push');
  static const persistentStorage = PermissionName('persistent-storage');
  static const clipboardRead = PermissionName('clipboard-read');
  static const clipboardWrite = PermissionName('clipboard-write');
  static const camera = PermissionName('camera');
  static const microphone = PermissionName('microphone');
  static const backgroundFetch = PermissionName('background-fetch');
  static const backgroundSync = PermissionName('background-sync');

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PermissionName && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PermissionName($value)';
}

// ---------------------------------------------------------------------------
// PermissionDescriptor
// ---------------------------------------------------------------------------

/// Describes a permission to query.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Permissions/query#descriptor
class PermissionDescriptor {
  /// The name of the permission to query.
  final PermissionName name;

  const PermissionDescriptor({required this.name});
}

// ---------------------------------------------------------------------------
// PushPermissionDescriptor
// ---------------------------------------------------------------------------

/// Descriptor for querying push notification permissions.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Permissions/query
class PushPermissionDescriptor extends PermissionDescriptor {
  /// Whether the push subscription will only be used for messages whose
  /// effect is made visible to the user.
  final bool userVisibleOnly;

  const PushPermissionDescriptor({this.userVisibleOnly = false})
    : super(name: PermissionName.push);
}

// ---------------------------------------------------------------------------
// MidiPermissionDescriptor
// ---------------------------------------------------------------------------

/// Descriptor for querying MIDI permissions.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Permissions/query
class MidiPermissionDescriptor extends PermissionDescriptor {
  /// Whether system-exclusive messages are needed.
  final bool sysex;

  const MidiPermissionDescriptor({this.sysex = false})
    : super(name: const PermissionName('midi'));
}

// ---------------------------------------------------------------------------
// DevicePermissionDescriptor
// ---------------------------------------------------------------------------

/// Descriptor for querying device permissions (camera, microphone).
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Permissions/query
class DevicePermissionDescriptor extends PermissionDescriptor {
  /// The device ID to query permission for, or `null` for any device.
  final String? deviceId;

  const DevicePermissionDescriptor({required super.name, this.deviceId});
}

// ---------------------------------------------------------------------------
// PermissionStatus
// ---------------------------------------------------------------------------

/// The status of a permission.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/PermissionStatus
abstract class PermissionStatus implements EventTarget {
  /// The current state of the permission.
  PermissionState get state;

  /// The name of the permission.
  PermissionName get name;

  /// Called when the permission state changes.
  EventListener? get onchange;
  set onchange(EventListener? callback);
}

// ---------------------------------------------------------------------------
// Permissions
// ---------------------------------------------------------------------------

/// Provides methods for querying and requesting permissions.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Permissions
abstract class Permissions {
  /// Queries the status of a given permission.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Permissions/query
  Future<PermissionStatus> query(PermissionDescriptor descriptor);
}
