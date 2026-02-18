/// Server-side factory for creating platform implementations.
library;

import '../core.dart';
import '../css.dart' as iface;
import '../dom.dart' as iface;
import '../notification.dart' as iface;
import '../window.dart' as iface;
import 'css.dart';
import 'dom.dart';
import 'notification.dart';
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

/// Creates a server-side [MouseEvent].
MouseEvent createMouseEvent(String type) => ServerMouseEvent(type);

/// Creates a server-side [KeyboardEvent].
KeyboardEvent createKeyboardEvent(String type) => ServerKeyboardEvent(type);

/// Creates a server-side [FocusEvent].
FocusEvent createFocusEvent(String type) => ServerFocusEvent(type);

/// Creates a server-side [InputEvent].
InputEvent createInputEvent(String type) => ServerInputEvent(type);

/// Creates a server-side [WheelEvent].
WheelEvent createWheelEvent(String type) => ServerWheelEvent(type);

/// Creates a server-side [PointerEvent].
PointerEvent createPointerEvent(String type) => ServerPointerEvent(type);

/// Creates a server-side [TouchEvent].
TouchEvent createTouchEvent(String type) => ServerTouchEvent(type);

/// Creates a server-side [DragEvent].
DragEvent createDragEvent(String type) => ServerDragEvent(type);

/// Creates a server-side [AnimationEvent].
AnimationEvent createAnimationEvent(String type) => ServerAnimationEvent(type);

/// Creates a server-side [TransitionEvent].
TransitionEvent createTransitionEvent(String type) =>
    ServerTransitionEvent(type);

/// Creates a server-side [CustomEvent].
CustomEvent createCustomEvent(String type, [Object? detail]) =>
    ServerCustomEvent(type, detail);

/// Creates a server-side [CSSStyleSheet] (no-op).
iface.CSSStyleSheet createCSSStyleSheet() => ServerCSSStyleSheet();

/// Creates a server-side [Notification] (no-op).
iface.Notification createNotification(
  String title, [
  iface.NotificationOptions? options,
]) => ServerNotification(title, options);

/// Returns the notification permission on server (always `'default'`).
iface.NotificationPermission get notificationPermission =>
    iface.NotificationPermission.defaultValue;

/// Returns the max actions on server (always `0`).
int get notificationMaxActions => 0;

/// Requests notification permission on server (always returns `'default'`).
Future<iface.NotificationPermission> requestNotificationPermission() async =>
    iface.NotificationPermission.defaultValue;

// ---------------------------------------------------------------------------
// Server-side Event implementations
// ---------------------------------------------------------------------------

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

class ServerMouseEvent extends ServerEvent implements MouseEvent {
  ServerMouseEvent([String type = 'click']) : super(type);
  @override
  double get clientX => 0;
  @override
  double get clientY => 0;
  @override
  double get pageX => 0;
  @override
  double get pageY => 0;
  @override
  double get screenX => 0;
  @override
  double get screenY => 0;
  @override
  int get button => 0;
  @override
  int get buttons => 0;
  @override
  bool get altKey => false;
  @override
  bool get ctrlKey => false;
  @override
  bool get metaKey => false;
  @override
  bool get shiftKey => false;
}

class ServerKeyboardEvent extends ServerEvent implements KeyboardEvent {
  ServerKeyboardEvent([String type = 'keydown']) : super(type);
  @override
  String get key => '';
  @override
  String get code => '';
  @override
  bool get altKey => false;
  @override
  bool get ctrlKey => false;
  @override
  bool get metaKey => false;
  @override
  bool get shiftKey => false;
  @override
  bool get repeat => false;
  @override
  int get location => 0;
}

class ServerInputEvent extends ServerEvent implements InputEvent {
  ServerInputEvent([String type = 'input']) : super(type);
  @override
  String? get data => null;
  @override
  String get inputType => '';
  @override
  bool get isComposing => false;
}

class ServerFocusEvent extends ServerEvent implements FocusEvent {
  ServerFocusEvent([String type = 'focus']) : super(type);
  @override
  EventTarget? get relatedTarget => null;
}

class ServerWheelEvent extends ServerMouseEvent implements WheelEvent {
  ServerWheelEvent([String type = 'wheel']) : super(type);
  @override
  double get deltaX => 0;
  @override
  double get deltaY => 0;
  @override
  double get deltaZ => 0;
  @override
  int get deltaMode => 0;
}

class ServerPointerEvent extends ServerMouseEvent implements PointerEvent {
  ServerPointerEvent([String type = 'pointerdown']) : super(type);
  @override
  int get pointerId => 0;
  @override
  double get width => 1;
  @override
  double get height => 1;
  @override
  double get pressure => 0;
  @override
  double get tangentialPressure => 0;
  @override
  int get tiltX => 0;
  @override
  int get tiltY => 0;
  @override
  int get twist => 0;
  @override
  String get pointerType => '';
  @override
  bool get isPrimary => false;
}

class ServerTouchEvent extends ServerEvent implements TouchEvent {
  ServerTouchEvent([String type = 'touchstart']) : super(type);
  @override
  TouchList get touches => ServerTouchList();
  @override
  TouchList get targetTouches => ServerTouchList();
  @override
  TouchList get changedTouches => ServerTouchList();
  @override
  bool get altKey => false;
  @override
  bool get ctrlKey => false;
  @override
  bool get metaKey => false;
  @override
  bool get shiftKey => false;
}

class ServerDragEvent extends ServerMouseEvent implements DragEvent {
  ServerDragEvent([String type = 'drag']) : super(type);
  @override
  DataTransfer? get dataTransfer => ServerDataTransfer();
}

class ServerAnimationEvent extends ServerEvent implements AnimationEvent {
  ServerAnimationEvent([String type = 'animationend']) : super(type);
  @override
  String get animationName => '';
  @override
  double get elapsedTime => 0;
  @override
  String get pseudoElement => '';
}

class ServerTransitionEvent extends ServerEvent implements TransitionEvent {
  ServerTransitionEvent([String type = 'transitionend']) : super(type);
  @override
  String get propertyName => '';
  @override
  double get elapsedTime => 0;
  @override
  String get pseudoElement => '';
}

class ServerCustomEvent extends ServerEvent implements CustomEvent {
  final Object? _detail;
  ServerCustomEvent([String type = 'custom', this._detail]) : super(type);
  @override
  Object? get detail => _detail;
}

// ---------------------------------------------------------------------------
// Server-side Touch & DataTransfer implementations
// ---------------------------------------------------------------------------

class ServerTouch implements Touch {
  @override
  int get identifier => 0;
  @override
  EventTarget get target => ServerEventTarget();
  @override
  double get screenX => 0;
  @override
  double get screenY => 0;
  @override
  double get clientX => 0;
  @override
  double get clientY => 0;
  @override
  double get pageX => 0;
  @override
  double get pageY => 0;
  @override
  double get radiusX => 0;
  @override
  double get radiusY => 0;
  @override
  double get rotationAngle => 0;
  @override
  double get force => 0;
}

class ServerTouchList implements TouchList {
  @override
  int get length => 0;
  @override
  Touch? item(int index) => null;
}

class ServerDataTransfer implements DataTransfer {
  @override
  String get dropEffect => 'none';
  @override
  set dropEffect(String value) {}
  @override
  String get effectAllowed => 'uninitialized';
  @override
  set effectAllowed(String value) {}
  @override
  List<String> get types => const [];
  @override
  void setData(String format, String data) {}
  @override
  String getData(String format) => '';
  @override
  void clearData([String? format]) {}
}
