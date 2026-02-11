# spark_web

Server-safe Web API abstraction for Dart, mirroring the [MDN Web API](https://developer.mozilla.org/en-US/docs/Web/API) naming exactly.

## Overview

`spark_web` provides a cross-platform Web API layer that works on both the **Dart VM (server)** and **dart2js/dart2wasm (browser)**.

- On the **browser**, types wrap the real `package:web` DOM objects.
- On the **server**, types are no-ops or provide Dart-native fallbacks (e.g., `Storage` backed by a `Map`, `Crypto.randomUUID()` via `dart:math`).

Because the naming matches MDN exactly, developers can look up any type or method on [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/API) and apply the same knowledge.

## Installation

```yaml
dependencies:
  spark_web:
    path: ../spark_web  # or from pub
```

## Usage

```dart
import 'package:spark_web/spark_web.dart' as web;

void main() {
  // DOM — same API as MDN
  final el = web.document.querySelector('#app');
  el?.classList.add('ready');
  el?.setAttribute('data-loaded', 'true');

  // Window
  web.window.localStorage.setItem('key', 'value');
  final uuid = web.window.crypto.randomUUID();

  // Events
  el?.addEventListener('click', (event) {
    print('Clicked: ${event.type}');
  });

  // Clipboard
  web.window.navigator.clipboard.writeText('Hello!');

  // Timers
  web.window.setTimeout(() => print('delayed'), 1000);
}
```

### Accessing the native `package:web` object

On the browser, every spark_web type wraps a native `package:web` object. Use `.raw` to access it:

```dart
final sparkElement = web.document.querySelector('div');
final nativeElement = sparkElement?.raw; // web.Element from package:web (null on server)
```

### Platform detection

```dart
if (web.kIsBrowser) {
  // Browser-only code
}
```

## Architecture

```
spark_web/lib/
├── spark_web.dart              # Barrel export + global singletons (window, document)
└── src/
    ├── api.dart                # Conditional import pivot (server ↔ browser)
    ├── core.dart               # EventTarget, Event, Node, NodeList, MutationObserver
    ├── dom.dart                # Element, HTMLElement, Document, ShadowRoot, Text, Comment
    ├── collections.dart        # DOMTokenList, NamedNodeMap, Attr
    ├── css.dart                # CSSStyleSheet, CSSStyleDeclaration
    ├── window.dart             # Window, Storage, Location, History, Navigator, Console, ...
    ├── server/                 # Server implementations (no-ops / Dart-native fallbacks)
    │   ├── factory.dart
    │   ├── dom.dart
    │   ├── collections.dart
    │   ├── css.dart
    │   └── window.dart
    └── browser/                # Browser implementations (wrap package:web)
        ├── factory.dart
        ├── dom.dart
        ├── collections.dart
        ├── css.dart
        └── window.dart
```

## API Coverage

The table below tracks what percentage of the [MDN Web API](https://developer.mozilla.org/en-US/docs/Web/API) is implemented. Contributions welcome!

### DOM Core

| API | Status | Notes |
|-----|--------|-------|
| `EventTarget` | ✅ Done | `addEventListener`, `removeEventListener`, `dispatchEvent` |
| `Event` | ✅ Done | `type`, `target`, `currentTarget`, `preventDefault`, `stopPropagation` |
| `MouseEvent` | ✅ Done | `clientX/Y`, `pageX/Y`, `screenX/Y`, `button`, modifier keys |
| `KeyboardEvent` | ✅ Done | `key`, `code`, `repeat`, `location`, modifier keys |
| `InputEvent` | ✅ Done | `data`, `inputType`, `isComposing` |
| `FocusEvent` | ❌ TODO | `relatedTarget` |
| `WheelEvent` | ❌ TODO | `deltaX`, `deltaY`, `deltaZ`, `deltaMode` |
| `TouchEvent` | ❌ TODO | `touches`, `targetTouches`, `changedTouches` |
| `PointerEvent` | ❌ TODO | `pointerId`, `width`, `height`, `pressure`, `pointerType` |
| `DragEvent` | ❌ TODO | `dataTransfer` |
| `AnimationEvent` | ❌ TODO | `animationName`, `elapsedTime`, `pseudoElement` |
| `TransitionEvent` | ❌ TODO | `propertyName`, `elapsedTime`, `pseudoElement` |
| `CustomEvent` | ❌ TODO | `detail` |
| `Node` | ✅ Done | Full tree traversal, `appendChild`, `removeChild`, `cloneNode`, etc. |
| `NodeList` | ✅ Done | `length`, `item()` |
| `MutationObserver` | ✅ Done | `observe`, `disconnect`, `takeRecords` |
| `MutationRecord` | ✅ Done | `type`, `target`, `addedNodes`, `removedNodes`, `attributeName` |
| `TreeWalker` | ❌ TODO | |
| `NodeIterator` | ❌ TODO | |
| `Range` | ❌ TODO | |
| `Selection` | ❌ TODO | |

### DOM Elements

| API | Status | Notes |
|-----|--------|-------|
| `Element` | ✅ Done | `tagName`, `id`, `className`, `innerHTML`, `classList`, `querySelector`, etc. |
| `HTMLElement` | ✅ Done | `innerText`, `hidden`, `title`, `style`, `shadowRoot`, `attachShadow` |
| `HTMLDivElement` | ✅ Done | |
| `HTMLSpanElement` | ✅ Done | |
| `HTMLParagraphElement` | ✅ Done | |
| `HTMLInputElement` | ✅ Done | `value`, `type`, `placeholder`, `disabled`, `checked`, `name` |
| `HTMLTextAreaElement` | ✅ Done | `value`, `placeholder`, `disabled`, `rows`, `cols` |
| `HTMLButtonElement` | ✅ Done | `disabled`, `type` |
| `HTMLSelectElement` | ✅ Done | `value`, `selectedIndex`, `disabled` |
| `HTMLOptionElement` | ✅ Done | `value`, `text`, `selected` |
| `HTMLAnchorElement` | ✅ Done | `href`, `target` |
| `HTMLImageElement` | ✅ Done | `src`, `alt`, `width`, `height` |
| `HTMLFormElement` | ✅ Done | `action`, `method`, `submit()`, `reset()`, `reportValidity()` |
| `HTMLLabelElement` | ✅ Done | `htmlFor` |
| `HTMLTemplateElement` | ✅ Done | `content` |
| `HTMLCanvasElement` | ❌ TODO | `getContext()`, `toDataURL()`, `width`, `height` |
| `HTMLVideoElement` | ❌ TODO | `src`, `play()`, `pause()`, `currentTime` |
| `HTMLAudioElement` | ❌ TODO | `src`, `play()`, `pause()` |
| `HTMLDialogElement` | ❌ TODO | `open`, `showModal()`, `close()`, `returnValue` |
| `HTMLDetailsElement` | ❌ TODO | `open` |
| `HTMLSlotElement` | ❌ TODO | `assignedNodes()`, `assignedElements()` |
| `HTMLIFrameElement` | ❌ TODO | `src`, `contentWindow`, `contentDocument` |
| `HTMLTableElement` | ❌ TODO | `rows`, `insertRow()`, `deleteRow()` |
| `HTMLTableRowElement` | ❌ TODO | `cells`, `insertCell()`, `deleteCell()` |
| `HTMLTableCellElement` | ❌ TODO | `colSpan`, `rowSpan` |
| `HTMLHeadingElement` | ❌ TODO | h1–h6 |
| `HTMLUListElement` | ❌ TODO | |
| `HTMLOListElement` | ❌ TODO | |
| `HTMLLIElement` | ❌ TODO | |
| `HTMLPreElement` | ❌ TODO | |
| `HTMLHRElement` | ❌ TODO | |
| `HTMLBRElement` | ❌ TODO | |
| `HTMLProgressElement` | ❌ TODO | `value`, `max` |
| `HTMLMeterElement` | ❌ TODO | `value`, `min`, `max`, `low`, `high`, `optimum` |
| `HTMLOutputElement` | ❌ TODO | `value` |

### Document & Fragments

| API | Status | Notes |
|-----|--------|-------|
| `Document` | ✅ Done | `createElement`, `createTextNode`, `querySelector`, `getElementById`, etc. |
| `DocumentFragment` | ✅ Done | `querySelector`, `querySelectorAll` |
| `ShadowRoot` | ✅ Done | `host`, `mode`, `adoptedStyleSheets`, `querySelector` |
| `Text` | ✅ Done | `data`, `wholeText` |
| `Comment` | ✅ Done | `data` |
| `DOMParser` | ❌ TODO | `parseFromString()` |
| `XMLSerializer` | ❌ TODO | `serializeToString()` |

### Collections

| API | Status | Notes |
|-----|--------|-------|
| `DOMTokenList` | ✅ Done | `add`, `remove`, `toggle`, `contains`, `replace` |
| `NamedNodeMap` | ✅ Done | `item`, `getNamedItem`, `removeNamedItem` |
| `Attr` | ✅ Done | `name`, `value` |
| `HTMLCollection` | ❌ TODO | `namedItem()` |
| `DOMStringMap` | ❌ TODO | dataset access |
| `DOMRect` | ❌ TODO | `x`, `y`, `width`, `height`, `top`, `right`, `bottom`, `left` |
| `DOMRectReadOnly` | ❌ TODO | |

### CSS

| API | Status | Notes |
|-----|--------|-------|
| `CSSStyleSheet` | ✅ Done | `replaceSync`, `replace` |
| `CSSStyleDeclaration` | ✅ Done | `getPropertyValue`, `setProperty`, `removeProperty`, `display`, `visibility`, `opacity` |
| `CSSRule` | ❌ TODO | |
| `CSSStyleRule` | ❌ TODO | |
| `CSSMediaRule` | ❌ TODO | |
| `CSSKeyframesRule` | ❌ TODO | |
| `CSSKeyframeRule` | ❌ TODO | |
| `MediaQueryList` | ❌ TODO | `matches`, `media`, `addListener()` |
| `StyleSheetList` | ❌ TODO | |

### Window & Globals

| API | Status | Notes |
|-----|--------|-------|
| `Window` | ✅ Done | `document`, `localStorage`, `setTimeout`, `requestAnimationFrame`, `btoa`/`atob`, etc. |
| `Storage` | ✅ Done | `getItem`, `setItem`, `removeItem`, `clear`, `key`, `length` |
| `Location` | ✅ Done | `href`, `protocol`, `host`, `pathname`, `search`, `hash`, `origin`, etc. |
| `History` | ✅ Done | `pushState`, `replaceState`, `back`, `forward`, `go`, `state` |
| `Navigator` | ✅ Done | `userAgent`, `language`, `languages`, `onLine`, `clipboard` |
| `Console` | ✅ Done | `log`, `warn`, `error`, `info`, `debug` |
| `Crypto` | ✅ Done | `randomUUID()` |
| `Performance` | ✅ Done | `now()` |
| `CustomElementRegistry` | ✅ Done | `define`, `get`, `upgrade`, `whenDefined` |
| `Clipboard` | ✅ Done | `readText`, `writeText` |
| `Screen` | ❌ TODO | `width`, `height`, `availWidth`, `availHeight`, `orientation` |
| `VisualViewport` | ❌ TODO | `width`, `height`, `offsetLeft`, `offsetTop`, `scale` |
| `BarProp` | ❌ TODO | `visible` |

### Async & Networking

| API | Status | Notes |
|-----|--------|-------|
| `fetch()` | ❌ TODO | Global fetch function |
| `Request` | ❌ TODO | |
| `Response` | ❌ TODO | |
| `Headers` | ❌ TODO | |
| `AbortController` | ❌ TODO | `signal`, `abort()` |
| `AbortSignal` | ❌ TODO | `aborted`, `reason` |
| `URL` | ❌ TODO | `href`, `origin`, `protocol`, `host`, `pathname`, `search`, `hash` |
| `URLSearchParams` | ❌ TODO | `get`, `set`, `append`, `delete`, `entries` |
| `WebSocket` | ❌ TODO | `send()`, `close()`, `readyState` |
| `EventSource` | ❌ TODO | Server-sent events |
| `XMLHttpRequest` | ❌ TODO | Legacy — consider skipping |
| `FormData` | ❌ TODO | `append`, `get`, `set`, `entries` |
| `Blob` | ❌ TODO | `size`, `type`, `text()`, `arrayBuffer()`, `slice()` |
| `File` | ❌ TODO | `name`, `lastModified`, `size`, `type` |
| `FileReader` | ❌ TODO | `readAsText()`, `readAsDataURL()`, `result` |

### Observers

| API | Status | Notes |
|-----|--------|-------|
| `MutationObserver` | ✅ Done | `observe`, `disconnect`, `takeRecords` |
| `IntersectionObserver` | ❌ TODO | `observe`, `disconnect`, `unobserve` |
| `ResizeObserver` | ❌ TODO | `observe`, `disconnect`, `unobserve` |
| `PerformanceObserver` | ❌ TODO | |

### Canvas & Graphics

| API | Status | Notes |
|-----|--------|-------|
| `CanvasRenderingContext2D` | ❌ TODO | Drawing primitives |
| `OffscreenCanvas` | ❌ TODO | |
| `ImageData` | ❌ TODO | |
| `Path2D` | ❌ TODO | |
| `WebGLRenderingContext` | ❌ TODO | Consider out of scope |
| `WebGL2RenderingContext` | ❌ TODO | Consider out of scope |

### Media

| API | Status | Notes |
|-----|--------|-------|
| `MediaStream` | ❌ TODO | |
| `MediaRecorder` | ❌ TODO | |
| `MediaDevices` | ❌ TODO | `getUserMedia()` |
| `AudioContext` | ❌ TODO | Web Audio API |

### Web Workers

| API | Status | Notes |
|-----|--------|-------|
| `Worker` | ❌ TODO | `postMessage()`, `terminate()` |
| `SharedWorker` | ❌ TODO | |
| `ServiceWorkerContainer` | ❌ TODO | |
| `BroadcastChannel` | ❌ TODO | `postMessage()`, `close()` |
| `MessageChannel` | ❌ TODO | |
| `MessagePort` | ❌ TODO | |

### Geometry & Layout

| API | Status | Notes |
|-----|--------|-------|
| `Element.getBoundingClientRect()` | ❌ TODO | Returns `DOMRect` |
| `Element.getClientRects()` | ❌ TODO | |
| `Element.scrollIntoView()` | ❌ TODO | |
| `Element.scrollTo()` | ❌ TODO | |
| `Element.scroll` properties | ❌ TODO | `scrollTop`, `scrollLeft`, `scrollWidth`, `scrollHeight` |
| `Element.client` properties | ❌ TODO | `clientWidth`, `clientHeight`, `clientTop`, `clientLeft` |
| `Element.offset` properties | ❌ TODO | `offsetWidth`, `offsetHeight`, `offsetTop`, `offsetLeft`, `offsetParent` |

### Miscellaneous

| API | Status | Notes |
|-----|--------|-------|
| `Crypto.getRandomValues()` | ❌ TODO | Typed array crypto |
| `SubtleCrypto` | ❌ TODO | `encrypt`, `decrypt`, `sign`, `verify`, `digest` |
| `TextEncoder` | ❌ TODO | `encode()` |
| `TextDecoder` | ❌ TODO | `decode()` |
| `structuredClone()` | ❌ TODO | |
| `queueMicrotask()` | ❌ TODO | |
| `Notification` | ❌ TODO | |
| `Geolocation` | ❌ TODO | |
| `Permissions` | ❌ TODO | |
| `FullScreen API` | ❌ TODO | `requestFullscreen()`, `exitFullscreen()` |

---

**Legend:** ✅ Done — ❌ TODO

> Not all MDN Web APIs are equally relevant for server-safe rendering. The coverage plan prioritizes APIs commonly used in component code (DOM, events, forms, CSS) over niche APIs (WebGL, Web Audio, WebRTC).
