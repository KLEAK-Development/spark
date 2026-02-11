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
