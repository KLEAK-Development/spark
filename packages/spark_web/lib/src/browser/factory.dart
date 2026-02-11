/// Browser-side factory for creating platform implementations.
library;

import 'package:web/web.dart' as web;

import '../core.dart';
import '../css.dart' as iface;
import '../dom.dart' as iface;
import '../window.dart' as iface;
import 'css.dart';
import 'dom.dart';
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

/// Creates a browser [CSSStyleSheet] via the constructable stylesheets API.
iface.CSSStyleSheet createCSSStyleSheet() =>
    BrowserCSSStyleSheet(web.CSSStyleSheet(web.CSSStyleSheetInit()));
