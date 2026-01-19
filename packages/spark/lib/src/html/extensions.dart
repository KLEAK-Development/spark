/// Extensions for HTML elements.
library;

// Conditional import: Use package:web on browser, stubs on server
import 'package:web/web.dart'
    if (dart.library.io) '../component/stubs.dart'
    as web;

// Conditional import for JS callback conversion
import '../component/js_callback_web.dart'
    if (dart.library.io) '../component/js_callback_stub.dart'
    as js_callback;

/// Extensions on [web.EventTarget] to provide a more Dart-friendly API.
extension SparkEventTargetExtension on web.EventTarget {
  /// Adds an event listener to this target with automatic Dart-to-JS callback conversion.
  ///
  /// This is a convenience method that wraps [listener] using [jsCallback]
  /// and calls `addEventListener`.
  ///
  /// ```dart
  /// element.on('click', (e) {
  ///   print('Clicked!');
  /// });
  /// ```
  void on(String type, void Function(web.Event) listener, [bool? useCapture]) {
    // On the server, stubs.dart's EventTarget.addEventListener accepts dynamic callback
    // On the browser, we need to convert the Dart function to a JS callback
    final callback = js_callback.jsCallbackImpl(listener);

    // Use the helper to handle platform-specific type conversion (e.g. .toJS)
    js_callback.addEventListener(this, type, callback, useCapture);
  }
}
