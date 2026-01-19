/// Browser implementation of jsCallback using dart:js_interop.
library;

import 'dart:js_interop';
import 'package:web/web.dart'
    show
        Event,
        EventTarget,
        EventListener,
        MutationCallback,
        MutationObserver,
        MutationRecord,
        MutationObserverInit;

/// On the browser, convert the Dart function to a JS function.
/// Uses a typed function signature as required by dart:js_interop.
dynamic jsCallbackImpl(void Function(Event) callback) {
  return callback.toJS;
}

/// Adds a listener to the target with safe type conversion.
void addEventListener(
  dynamic target,
  String type,
  dynamic callback,
  bool? useCapture,
) {
  // Cast to EventTarget from package:web
  // We accept dynamic target to handle the conditional import type mismatch
  // between the extension (which sees web.EventTarget or stubs.EventTarget)
  // and this library which sees web.EventTarget.
  final eventTarget = target as EventTarget;
  final eventListener = callback as EventListener;

  if (useCapture != null) {
    eventTarget.addEventListener(type, eventListener, useCapture.toJS);
  } else {
    eventTarget.addEventListener(type, eventListener);
  }
}

/// Converts a Dart MutationObserver callback to a JS function.
MutationCallback toMutationCallback(
  void Function(List<MutationRecord>, MutationObserver) callback,
) {
  return ((JSArray<MutationRecord> mutations, MutationObserver observer) {
    callback(mutations.toDart, observer);
  }).toJS;
}

MutationObserverInit toMutationObserverInit(List<String> attrs) {
  return MutationObserverInit(
    attributes: true,
    attributeOldValue: true,
    attributeFilter: attrs.map((s) => s.toJS).toList().toJS,
  );
}
