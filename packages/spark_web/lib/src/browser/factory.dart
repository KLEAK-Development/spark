/// Browser-side factory for creating platform implementations.
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../core.dart';
import '../css.dart' as iface;
import '../dom.dart' as iface;
import '../notification.dart' as iface;
import '../window.dart' as iface;
import 'css.dart';
import 'dom.dart';
import 'notification.dart';
import 'window.dart';

/// Creates a browser [Window] wrapping the global window.
iface.Window createWindow() => BrowserWindow(web.window);

/// Creates a browser [Document] wrapping the global document.
iface.Document createDocument() => BrowserDocument(web.document);

/// Creates a browser [MutationObserver].
MutationObserver createMutationObserver(MutationCallback callback) =>
    BrowserMutationObserver(callback);

/// Creates a browser [Event].
Event createEvent(String type) => BrowserEvent(web.Event(type));

/// Creates a browser [MouseEvent].
MouseEvent createMouseEvent(String type) => BrowserMouseEvent(web.MouseEvent(type));

/// Creates a browser [KeyboardEvent].
KeyboardEvent createKeyboardEvent(String type) => BrowserKeyboardEvent(web.KeyboardEvent(type));

/// Creates a browser [FocusEvent].
FocusEvent createFocusEvent(String type) => BrowserFocusEvent(web.FocusEvent(type));

/// Creates a browser [InputEvent].
InputEvent createInputEvent(String type) => BrowserInputEvent(web.InputEvent(type));

/// Creates a browser [WheelEvent].
WheelEvent createWheelEvent(String type) => BrowserWheelEvent(web.WheelEvent(type));

/// Creates a browser [PointerEvent].
PointerEvent createPointerEvent(String type) => BrowserPointerEvent(web.PointerEvent(type));

/// Creates a browser [TouchEvent].
TouchEvent createTouchEvent(String type) => BrowserTouchEvent(web.TouchEvent(type));

/// Creates a browser [DragEvent].
DragEvent createDragEvent(String type) => BrowserDragEvent(web.DragEvent(type));

/// Creates a browser [AnimationEvent].
AnimationEvent createAnimationEvent(String type) => BrowserAnimationEvent(web.AnimationEvent(type));

/// Creates a browser [TransitionEvent].
TransitionEvent createTransitionEvent(String type) => BrowserTransitionEvent(web.TransitionEvent(type));

/// Creates a browser [CustomEvent].
CustomEvent createCustomEvent(String type, [Object? detail]) =>
    BrowserCustomEvent(web.CustomEvent(type, web.CustomEventInit(detail: detail.jsify())));

/// Creates a browser [CSSStyleSheet] via the constructable stylesheets API.
iface.CSSStyleSheet createCSSStyleSheet() =>
    BrowserCSSStyleSheet(web.CSSStyleSheet(web.CSSStyleSheetInit()));

/// Creates a browser [Notification].
iface.Notification createNotification(
  String title, [
  iface.NotificationOptions? options,
]) => BrowserNotification(title, options);

/// Returns the current notification permission state.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/permission_static
iface.NotificationPermission get notificationPermission =>
    getNotificationPermission();

/// Returns the maximum number of actions supported by the device/user agent.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/maxActions_static
int get notificationMaxActions => getNotificationMaxActions();

/// Requests permission to show notifications.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Notification/requestPermission_static
Future<iface.NotificationPermission> requestNotificationPermission() =>
    browserRequestNotificationPermission();
