/// Server-side factory for creating platform implementations.
library;

import '../core.dart';
import '../dom.dart' as iface;
import '../window.dart' as iface;
import 'dom.dart';
import 'window.dart';

/// Creates a server-side [Window] instance.
iface.Window createWindow() => ServerWindow();

/// Creates a server-side [Document] instance.
iface.Document createDocument() => ServerDocument();

/// Creates a server-side [MutationObserver].
MutationObserver createMutationObserver(MutationCallback callback) =>
    ServerMutationObserver(callback);

/// Creates a server-side [Event].
Event createEvent(String type) => ServerEvent(type);

/// Server-side [Event] implementation.
class ServerEvent implements Event {
  final String _type;
  ServerEvent(this._type);
  @override
  String get type => _type;
  @override
  EventTarget? get target => null;
  @override
  EventTarget? get currentTarget => null;
  @override
  bool get bubbles => false;
  @override
  bool get cancelable => false;
  @override
  void preventDefault() {}
  @override
  void stopPropagation() {}
  @override
  void stopImmediatePropagation() {}
  @override
  dynamic get raw => null;
}
