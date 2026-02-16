/// Notification API types matching the MDN Web API.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification
library;

import 'core.dart';

// ---------------------------------------------------------------------------
// NotificationDirection
// ---------------------------------------------------------------------------

/// Direction for notification text display.
///
/// Use the predefined constants ([auto], [ltr], [rtl]) or construct with a
/// raw string for forward-compatibility with future spec values.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/dir
class NotificationDirection {
  /// The underlying string value (e.g. `'auto'`, `'ltr'`, `'rtl'`).
  final String value;

  /// Creates a direction from a raw string value.
  ///
  /// Prefer the predefined constants when possible. Use this constructor
  /// for values not yet covered by this library.
  const NotificationDirection(this.value);

  /// Adopts the browser's language setting direction.
  static const auto = NotificationDirection('auto');

  /// Left-to-right.
  static const ltr = NotificationDirection('ltr');

  /// Right-to-left.
  static const rtl = NotificationDirection('rtl');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationDirection && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NotificationDirection($value)';
}

// ---------------------------------------------------------------------------
// NotificationPermission
// ---------------------------------------------------------------------------

/// Permission state for the Notification API.
///
/// Use the predefined constants ([defaultValue], [denied], [granted]) or
/// construct with a raw string for forward-compatibility.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/permission_static
class NotificationPermission {
  /// The underlying string value (e.g. `'default'`, `'denied'`, `'granted'`).
  final String value;

  /// Creates a permission from a raw string value.
  ///
  /// Prefer the predefined constants when possible. Use this constructor
  /// for values not yet covered by this library.
  const NotificationPermission(this.value);

  /// User choice is unknown; behaves as [denied].
  static const defaultValue = NotificationPermission('default');

  /// User explicitly denied notifications.
  static const denied = NotificationPermission('denied');

  /// User explicitly granted notifications.
  static const granted = NotificationPermission('granted');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPermission && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NotificationPermission($value)';
}

// ---------------------------------------------------------------------------
// NotificationAction
// ---------------------------------------------------------------------------

/// Describes an action button shown in a notification.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/NotificationAction
class NotificationAction {
  /// A string identifying the user action to be displayed on the notification.
  final String action;

  /// A string containing action text to be shown to the user.
  final String title;

  /// A string containing the URL of an icon to display with the action.
  final String? icon;

  const NotificationAction({
    required this.action,
    required this.title,
    this.icon,
  });
}

// ---------------------------------------------------------------------------
// NotificationOptions
// ---------------------------------------------------------------------------

/// Options for creating a [Notification].
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/Notification#options
class NotificationOptions {
  /// The body text of the notification.
  final String body;

  /// The direction in which to display the notification.
  final NotificationDirection dir;

  /// The notification's language, as a BCP 47 language tag.
  final String lang;

  /// An identifying tag for the notification.
  final String tag;

  /// The URL of the icon to be displayed.
  final String? icon;

  /// The URL of the badge image.
  final String? badge;

  /// The URL of an image to be displayed in the notification.
  final String? image;

  /// Arbitrary data associated with the notification.
  final Object? data;

  /// Whether the user should be re-notified when a notification with the
  /// same [tag] replaces an old one.
  final bool renotify;

  /// Whether the notification should remain active until the user clicks
  /// or dismisses it.
  final bool requireInteraction;

  /// Whether the notification should be silent.
  final bool? silent;

  /// A timestamp (milliseconds since epoch) associated with the notification.
  final int? timestamp;

  /// A vibration pattern for the device's vibration hardware.
  final List<int>? vibrate;

  /// A list of actions to display in the notification.
  final List<NotificationAction>? actions;

  const NotificationOptions({
    this.body = '',
    this.dir = NotificationDirection.auto,
    this.lang = '',
    this.tag = '',
    this.icon,
    this.badge,
    this.image,
    this.data,
    this.renotify = false,
    this.requireInteraction = false,
    this.silent,
    this.timestamp,
    this.vibrate,
    this.actions,
  });
}

// ---------------------------------------------------------------------------
// Notification
// ---------------------------------------------------------------------------

/// A system notification displayed to the user.
///
/// Create instances via the [createNotification] factory function.
/// Use [notificationPermission] to check and [requestNotificationPermission]
/// to request the current permission state.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification
abstract class Notification implements EventTarget {
  /// The title of the notification.
  String get title;

  /// The body text of the notification.
  String get body;

  /// The text direction of the notification.
  NotificationDirection get dir;

  /// The language of the notification.
  String get lang;

  /// The ID tag of the notification.
  String get tag;

  /// The URL of the notification icon.
  String get icon;

  /// The URL of the notification badge.
  String get badge;

  /// The URL of the notification image.
  String get image;

  /// Arbitrary data associated with the notification.
  Object? get data;

  /// Whether the user is re-notified when an existing notification is
  /// replaced by a new one with the same [tag].
  bool get renotify;

  /// Whether the notification stays active until the user clicks or
  /// dismisses it.
  bool get requireInteraction;

  /// Whether the notification is silent.
  bool? get silent;

  /// The timestamp associated with the notification (milliseconds since epoch).
  int? get timestamp;

  /// The vibration pattern for the device.
  List<int>? get vibrate;

  /// The list of actions available on this notification.
  List<NotificationAction> get actions;

  /// Programmatically closes the notification.
  ///
  /// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/close
  void close();
}
