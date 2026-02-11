/// Stub implementation of jsCallback for server-side.
library;

import 'package:spark_web/spark_web.dart'
    show Event, MutationObserver, MutationRecord, MutationObserverInit;

/// On the server, just return the callback as-is.
/// The stubs will accept any callback type.
dynamic jsCallbackImpl(void Function(Event) callback) => callback;

/// Adds a listener to the target (server stub).
/// On the server, this is a no-op since there's no real DOM.
void addEventListener(
  dynamic target,
  String type,
  dynamic callback,
  bool? useCapture,
) {
  // No-op on server
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
