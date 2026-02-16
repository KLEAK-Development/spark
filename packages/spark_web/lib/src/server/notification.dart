/// Server-side implementation of the Notification API.
///
/// No-op on the server — notifications are a browser-only concept.
/// Properties return values from the options passed at construction time,
/// which is useful for server-side testing.
library;

import '../notification.dart' as iface;
import 'dom.dart';

// ---------------------------------------------------------------------------
// ServerNotification
// ---------------------------------------------------------------------------

class ServerNotification extends ServerEventTarget
    implements iface.Notification {
  final String _title;
  final iface.NotificationOptions _options;

  ServerNotification(this._title, [iface.NotificationOptions? options])
    : _options = options ?? const iface.NotificationOptions();

  @override
  String get title => _title;

  @override
  String get body => _options.body;

  @override
  iface.NotificationDirection get dir => _options.dir;

  @override
  String get lang => _options.lang;

  @override
  String get tag => _options.tag;

  @override
  String get icon => _options.icon ?? '';

  @override
  String get badge => _options.badge ?? '';

  @override
  String get image => _options.image ?? '';

  @override
  Object? get data => _options.data;

  @override
  bool get renotify => _options.renotify;

  @override
  bool get requireInteraction => _options.requireInteraction;

  @override
  bool? get silent => _options.silent;

  @override
  int? get timestamp => _options.timestamp;

  @override
  List<int>? get vibrate => _options.vibrate;

  @override
  List<iface.NotificationAction> get actions => _options.actions ?? const [];

  @override
  void close() {}
}
