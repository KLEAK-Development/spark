/// Extensions for HTML elements.
library;

import 'package:spark_web/spark_web.dart' as web;

/// Extensions on [web.EventTarget] to provide a more Dart-friendly API.
extension SparkEventTargetExtension on web.EventTarget {
  /// Adds an event listener to this target.
  ///
  /// This is a convenience method that delegates to [addEventListener].
  /// The spark_web abstraction handles the Dart-to-JS conversion automatically
  /// on the browser. On the server, this is a no-op.
  ///
  /// ```dart
  /// element.on('click', (e) {
  ///   print('Clicked!');
  /// });
  /// ```
  void on(String type, void Function(web.Event) listener) {
    addEventListener(type, listener);
  }
}
