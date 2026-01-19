/// Stub implementation of jsCallback for server-side.
library;

import 'stubs.dart'
    show Event, MutationObserver, MutationRecord, MutationObserverInit;

/// On the server, just return the callback as-is.
/// The stubs will accept any callback type.
dynamic jsCallbackImpl(void Function(Event) callback) => callback;

/// Adds a listener to the target (server stub).
void addEventListener(
  dynamic target,
  String type,
  dynamic callback,
  bool? useCapture,
) {
  // stubs.EventTarget accepts dynamic
  target.addEventListener(type, callback, useCapture);
}

/// Stub for MutationObserver callback conversion.
dynamic toMutationCallback(
  void Function(List<MutationRecord>, MutationObserver) callback,
) {
  return callback;
}

MutationObserverInit toMutationObserverInit(List<String> attrs) {
  return MutationObserverInit(
    attributes: true,
    attributeOldValue: true,
    attributeFilter: attrs.map((s) => s).toList(),
  );
}
