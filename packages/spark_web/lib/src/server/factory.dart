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

class ServerFocusEvent extends ServerEvent implements FocusEvent {
  ServerFocusEvent([String type = 'focus']) : super(type);
  @override
  EventTarget? get relatedTarget => null;
}

class ServerWheelEvent extends ServerMouseEvent implements WheelEvent {
  ServerWheelEvent() : super('wheel');
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
  dynamic get touches => null;
  @override
  dynamic get targetTouches => null;
  @override
  dynamic get changedTouches => null;
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
  dynamic get dataTransfer => null;
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
  ServerCustomEvent([String type = 'custom']) : super(type);
  @override
  dynamic get detail => null;
}
