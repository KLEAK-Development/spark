/// Core Web API types: EventTarget, Event, and related types.
///
/// These mirror the MDN Web API exactly so developers can rely on MDN
/// documentation for reference.
library;

// ---------------------------------------------------------------------------
// Callback types
// ---------------------------------------------------------------------------

/// Callback type for event listeners.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener
typedef EventListener = void Function(Event event);

/// Callback type for MutationObserver.
typedef MutationCallback = void Function(
  List<MutationRecord> mutations,
  MutationObserver observer,
);

// ---------------------------------------------------------------------------
// EventTarget
// ---------------------------------------------------------------------------

/// Base interface for objects that can receive events.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/EventTarget
abstract class EventTarget {
  /// Registers an event listener on this target.
  void addEventListener(String type, EventListener? callback);

  /// Removes a previously registered event listener.
  void removeEventListener(String type, EventListener? callback);

  /// Dispatches an event to this target.
  bool dispatchEvent(Event event);

  /// The underlying platform object.
  ///
  /// On browser: the native JS object from `package:web`.
  /// On server: `null`.
  ///
  /// Used internally by the Spark framework. Application code should
  /// not rely on this property.
  dynamic get raw;
}

// ---------------------------------------------------------------------------
// Event
// ---------------------------------------------------------------------------

/// Represents an event that takes place on an [EventTarget].
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Event
abstract class Event {
  /// The type of the event (e.g., 'click', 'input').
  String get type;

  /// The target to which the event was dispatched.
  EventTarget? get target;

  /// The target whose event listener is currently being invoked.
  EventTarget? get currentTarget;

  /// Whether the event bubbles up through the DOM.
  bool get bubbles;

  /// Whether the event can be cancelled.
  bool get cancelable;

  /// Cancels the event's default action.
  void preventDefault();

  /// Stops further propagation of the event.
  void stopPropagation();

  /// Stops propagation and prevents other listeners on the same target.
  void stopImmediatePropagation();

  /// The underlying platform object.
  dynamic get raw;
}

/// A mouse event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent
abstract class MouseEvent implements Event {
  double get clientX;
  double get clientY;
  double get pageX;
  double get pageY;
  double get screenX;
  double get screenY;
  int get button;
  int get buttons;
  bool get altKey;
  bool get ctrlKey;
  bool get metaKey;
  bool get shiftKey;
}

/// A keyboard event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
abstract class KeyboardEvent implements Event {
  String get key;
  String get code;
  bool get altKey;
  bool get ctrlKey;
  bool get metaKey;
  bool get shiftKey;
  bool get repeat;
  int get location;
}

/// An input event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/InputEvent
abstract class InputEvent implements Event {
  String? get data;
  String get inputType;
  bool get isComposing;
}

/// A focus event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/FocusEvent
abstract class FocusEvent implements Event {
  EventTarget? get relatedTarget;
}

/// A wheel event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/WheelEvent
abstract class WheelEvent implements MouseEvent {
  static const int DOM_DELTA_PIXEL = 0;
  static const int DOM_DELTA_LINE = 1;
  static const int DOM_DELTA_PAGE = 2;

  double get deltaX;
  double get deltaY;
  double get deltaZ;
  int get deltaMode;
}

/// A pointer event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent
abstract class PointerEvent implements MouseEvent {
  int get pointerId;
  double get width;
  double get height;
  double get pressure;
  double get tangentialPressure;
  int get tiltX;
  int get tiltY;
  int get twist;
  String get pointerType;
  bool get isPrimary;
}

/// A touch event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent
abstract class TouchEvent implements Event {
  // TouchList is not wrapped yet — expose as dynamic for now.
  dynamic get touches;
  dynamic get targetTouches;
  dynamic get changedTouches;
  bool get altKey;
  bool get ctrlKey;
  bool get metaKey;
  bool get shiftKey;
}

/// A drag event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/DragEvent
abstract class DragEvent implements MouseEvent {
  // DataTransfer is not wrapped yet — expose as dynamic for now.
  dynamic get dataTransfer;
}

/// An animation event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/AnimationEvent
abstract class AnimationEvent implements Event {
  String get animationName;
  double get elapsedTime;
  String get pseudoElement;
}

/// A transition event.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/TransitionEvent
abstract class TransitionEvent implements Event {
  String get propertyName;
  double get elapsedTime;
  String get pseudoElement;
}

/// A custom event with arbitrary detail data.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/CustomEvent
abstract class CustomEvent implements Event {
  dynamic get detail;
}

// ---------------------------------------------------------------------------
// Forward declarations for types referenced across files.
// ---------------------------------------------------------------------------

/// See [observers.dart] for the full definition — re-exported here to
/// break the circular dependency between core.dart and observers.dart.
abstract class MutationObserver {
  void observe(Node target, [MutationObserverInit? options]);
  void disconnect();
  List<MutationRecord> takeRecords();
}

/// Initialization options for [MutationObserver.observe].
class MutationObserverInit {
  final bool? childList;
  final bool? attributes;
  final bool? characterData;
  final bool? subtree;
  final bool? attributeOldValue;
  final bool? characterDataOldValue;
  final List<String>? attributeFilter;

  const MutationObserverInit({
    this.childList,
    this.attributes,
    this.characterData,
    this.subtree,
    this.attributeOldValue,
    this.characterDataOldValue,
    this.attributeFilter,
  });
}

/// A single mutation record observed by a [MutationObserver].
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/MutationRecord
abstract class MutationRecord {
  String get type;
  Node get target;
  NodeList get addedNodes;
  NodeList get removedNodes;
  Node? get previousSibling;
  Node? get nextSibling;
  String? get attributeName;
  String? get oldValue;
}

// ---------------------------------------------------------------------------
// Node (declared here to avoid circular imports)
// ---------------------------------------------------------------------------

/// A DOM Node.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Node
abstract class Node implements EventTarget {
  static const int ELEMENT_NODE = 1;
  static const int TEXT_NODE = 3;
  static const int COMMENT_NODE = 8;
  static const int DOCUMENT_NODE = 9;
  static const int DOCUMENT_FRAGMENT_NODE = 11;

  int get nodeType;
  String get nodeName;

  Node? get parentNode;
  Node? get parentElement;
  NodeList get childNodes;
  Node? get firstChild;
  Node? get lastChild;
  Node? get nextSibling;
  Node? get previousSibling;

  String? get textContent;
  set textContent(String? value);

  bool get isConnected;

  Node appendChild(Node child);
  Node removeChild(Node child);
  Node insertBefore(Node newNode, Node? referenceNode);
  Node replaceChild(Node newChild, Node oldChild);
  Node cloneNode([bool deep = false]);
  bool contains(Node? other);
  bool hasChildNodes();
}

/// A list of [Node] objects.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/NodeList
abstract class NodeList {
  int get length;
  Node? item(int index);
}
