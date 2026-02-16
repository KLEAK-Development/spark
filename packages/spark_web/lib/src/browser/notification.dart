/// Browser implementation of the Notification API wrapping `package:web`.
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:web/web.dart' as web;

import '../notification.dart' as iface;
import 'dom.dart';

// ---------------------------------------------------------------------------
// BrowserNotification
// ---------------------------------------------------------------------------

class BrowserNotification extends BrowserEventTarget
    implements iface.Notification {
  final web.Notification _native;

  /// Creates a browser notification by constructing the native JS Notification.
  BrowserNotification(String title, [iface.NotificationOptions? options])
      : this._wrap(_createNative(title, options));

  /// Wraps an existing native [web.Notification].
  BrowserNotification._wrap(this._native) : super(_native);

  static web.Notification _createNative(
    String title, [
    iface.NotificationOptions? options,
  ]) {
    if (options == null) return web.Notification(title);

    final webOptions = web.NotificationOptions(
      body: options.body,
      dir: options.dir.value,
      lang: options.lang,
      tag: options.tag,
      renotify: options.renotify,
      requireInteraction: options.requireInteraction,
    );

    if (options.icon != null) webOptions.icon = options.icon!;
    if (options.badge != null) webOptions.badge = options.badge!;
    if (options.image != null) webOptions.image = options.image!;
    if (options.data != null) webOptions.data = options.data.jsify();
    if (options.silent != null) webOptions.silent = options.silent;
    if (options.timestamp != null) webOptions.timestamp = options.timestamp!;

    if (options.vibrate != null) {
      webOptions.vibrate =
          options.vibrate!.map((v) => v.toJS).toList().toJS;
    }

    if (options.actions != null) {
      webOptions.actions = options.actions!
          .map(
            (a) => web.NotificationAction(
              action: a.action,
              title: a.title,
            )..icon = a.icon ?? '',
          )
          .toList()
          .toJS;
    }

    return web.Notification(title, webOptions);
  }

  // -- Instance properties --

  @override
  String get title => _native.title;

  @override
  String get body => _native.body;

  @override
  iface.NotificationDirection get dir =>
      iface.NotificationDirection(_native.dir);

  @override
  String get lang => _native.lang;

  @override
  String get tag => _native.tag;

  @override
  String get icon => _native.icon;

  @override
  String get badge => _native.badge;

  @override
  String get image {
    final raw = (_native as JSObject)['image'];
    return (raw as JSString?)?.toDart ?? '';
  }

  @override
  Object? get data => _native.data.dartify();

  @override
  bool get renotify {
    final raw = (_native as JSObject)['renotify'];
    return (raw as JSBoolean?)?.toDart ?? false;
  }

  @override
  bool get requireInteraction => _native.requireInteraction;

  @override
  bool? get silent => _native.silent;

  @override
  int? get timestamp {
    final raw = (_native as JSObject)['timestamp'];
    if (raw == null) return null;
    return (raw as JSNumber).toDartInt;
  }

  @override
  List<int>? get vibrate {
    final raw = (_native as JSObject)['vibrate'];
    if (raw == null) return null;
    return (raw as JSArray)
        .toDart
        .map((e) => (e as JSNumber).toDartInt)
        .toList();
  }

  @override
  List<iface.NotificationAction> get actions {
    final raw = (_native as JSObject)['actions'];
    if (raw == null) return const [];
    return (raw as JSArray<web.NotificationAction>)
        .toDart
        .map(
          (a) => iface.NotificationAction(
            action: a.action,
            title: a.title,
            icon: a.icon,
          ),
        )
        .toList();
  }

  // -- Instance methods --

  @override
  void close() => _native.close();
}

// ---------------------------------------------------------------------------
// Static helpers (exposed via factory functions)
// ---------------------------------------------------------------------------

/// Returns the current notification permission.
iface.NotificationPermission getNotificationPermission() =>
    iface.NotificationPermission(web.Notification.permission);

/// Returns the maximum number of actions supported.
int getNotificationMaxActions() {
  final raw = (globalContext['Notification']! as JSObject)['maxActions'];
  return (raw as JSNumber?)?.toDartInt ?? 0;
}

/// Requests permission to show notifications.
Future<iface.NotificationPermission>
    browserRequestNotificationPermission() =>
        web.Notification.requestPermission().toDart.then(
          (js) => iface.NotificationPermission(js.toDart),
        );
