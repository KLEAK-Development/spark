/// Server-safe Web API for Dart.
///
/// This library mirrors the MDN Web API with identical naming, so developers
/// can rely on MDN documentation for reference. It works on both the Dart VM
/// (server) and dart2js (browser).
///
/// On the **browser**, types wrap the real `package:web` DOM objects.
/// On the **server**, types are no-ops or provide Dart-native fallbacks
/// (e.g., `Storage` is backed by a `Map`, `Crypto.randomUUID()` uses
/// `dart:math`).
///
/// ## Usage
///
/// ```dart
/// import 'package:spark_web/spark_web.dart' as web;
///
/// // Same API as MDN — works on both server and browser.
/// web.window.localStorage.setItem('key', 'value');
/// web.document.querySelector('#app')?.classList.add('ready');
/// ```
///
/// ## Accessing the native object
///
/// On the browser, every spark_web type wraps a native `package:web` object.
/// If you need the raw JS object (e.g., for third-party interop), use the
/// [raw] property:
///
/// ```dart
/// final native = element.raw; // Returns web.Element on browser, null on server
/// ```
library;

import 'src/api.dart' as impl;

// Re-export all interface types.
export 'src/core.dart';
export 'src/dom.dart';
export 'src/collections.dart';
export 'src/css.dart';
export 'src/window.dart';

// Re-export factory functions (platform-aware constructors).
export 'src/api.dart' show createMutationObserver, createEvent, createCSSStyleSheet;

// ---------------------------------------------------------------------------
// Global singletons — matching the browser's global objects.
// ---------------------------------------------------------------------------

import 'src/window.dart' as w;
import 'src/dom.dart' as d;

/// The global window object.
///
/// On browser: wraps the real `window`.
/// On server: a no-op implementation with Dart-native fallbacks.
final w.Window window = impl.createWindow();

/// The global document object.
///
/// On browser: wraps the real `document`.
/// On server: a no-op implementation.
final d.Document document = impl.createDocument();

/// Whether the code is running in a browser environment.
///
/// `true` when compiled to JavaScript, `false` on the Dart VM.
const bool kIsBrowser = bool.fromEnvironment('dart.library.js_interop');
