/// Conditional import pivot.
///
/// On the browser (dart:js_interop available), exports the browser factory.
/// On the server (dart:io available), exports the server factory.
library;

export 'server/factory.dart'
    if (dart.library.js_interop) 'browser/factory.dart';
