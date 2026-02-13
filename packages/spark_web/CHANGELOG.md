# Changelog

All notable changes to `spark_web` will be documented in this file.

## 1.0.0-alpha.2

### Changed

- Updated `Node.contains` to accept `EventTarget?` instead of `Node?`. This fixes issues where `event.target` could not be passed directly to `contains`.

## 1.0.0-alpha.1

Initial release of the server-safe Web API abstraction.

### Added

**Core types** (`core.dart`)
- `EventTarget` — `addEventListener`, `removeEventListener`, `dispatchEvent`
- `Event` — `type`, `target`, `currentTarget`, `preventDefault`, `stopPropagation`
- `MouseEvent` — `clientX/Y`, `pageX/Y`, `screenX/Y`, `button`, modifier keys
- `KeyboardEvent` — `key`, `code`, `repeat`, `location`, modifier keys
- `InputEvent` — `data`, `inputType`, `isComposing`
- `Node` — Full tree traversal, `appendChild`, `removeChild`, `insertBefore`, `replaceChild`, `cloneNode`, `contains`
- `NodeList` — `length`, `item()`
- `MutationObserver` — `observe`, `disconnect`, `takeRecords`
- `MutationRecord` — `type`, `target`, `addedNodes`, `removedNodes`, `attributeName`, `oldValue`
- `MutationObserverInit` — configuration data class

**DOM types** (`dom.dart`)
- `Element` — `tagName`, `id`, `className`, `innerHTML`, `outerHTML`, `classList`, `attributes`, `querySelector`, `querySelectorAll`, `getAttribute`, `setAttribute`, `removeAttribute`, `hasAttribute`, `remove`, `append`
- `HTMLElement` — `innerText`, `hidden`, `title`, `style`, `shadowRoot`, `attachShadow`
- `HTMLDivElement`, `HTMLSpanElement`, `HTMLParagraphElement`
- `HTMLInputElement` — `value`, `type`, `placeholder`, `disabled`, `checked`, `name`
- `HTMLTextAreaElement` — `value`, `placeholder`, `disabled`, `rows`, `cols`
- `HTMLButtonElement` — `disabled`, `type`
- `HTMLSelectElement` — `value`, `selectedIndex`, `disabled`
- `HTMLOptionElement` — `value`, `text`, `selected`
- `HTMLAnchorElement` — `href`, `target`
- `HTMLImageElement` — `src`, `alt`, `width`, `height`
- `HTMLFormElement` — `action`, `method`, `submit()`, `reset()`, `reportValidity()`
- `HTMLLabelElement` — `htmlFor`
- `HTMLTemplateElement` — `content`
- `DocumentFragment` — `querySelector`, `querySelectorAll`
- `ShadowRoot` — `host`, `mode`, `adoptedStyleSheets`, `firstElementChild`
- `Document` — `createElement`, `createElementNS`, `createTextNode`, `createComment`, `createDocumentFragment`, `getElementById`, `querySelector`, `querySelectorAll`, `documentElement`, `body`, `head`
- `Text` — `data`, `wholeText`
- `Comment` — `data`

**Collection types** (`collections.dart`)
- `DOMTokenList` — `add`, `remove`, `toggle`, `contains`, `replace`, `item`
- `NamedNodeMap` — `item`, `getNamedItem`, `removeNamedItem`
- `Attr` — `name`, `value`

**CSS types** (`css.dart`)
- `CSSStyleSheet` — `replaceSync`, `replace`
- `CSSStyleDeclaration` — `getPropertyValue`, `setProperty`, `removeProperty`, `display`, `visibility`, `opacity`

**Window types** (`window.dart`)
- `Window` — `document`, `console`, `navigator`, `localStorage`, `sessionStorage`, `location`, `history`, `crypto`, `performance`, `customElements`, `alert`, `confirm`, `prompt`, `setTimeout`, `setInterval`, `requestAnimationFrame`, `btoa`, `atob`
- `Storage` — `getItem`, `setItem`, `removeItem`, `clear`, `key`, `length`
- `Location` — `href`, `protocol`, `host`, `hostname`, `port`, `pathname`, `search`, `hash`, `origin`, `assign`, `replace`, `reload`
- `History` — `pushState`, `replaceState`, `back`, `forward`, `go`, `state`, `length`
- `Navigator` — `userAgent`, `language`, `languages`, `onLine`, `clipboard`
- `Console` — `log`, `warn`, `error`, `info`, `debug`
- `Crypto` — `randomUUID()`
- `Performance` — `now()`
- `CustomElementRegistry` — `define`, `get`, `upgrade`, `whenDefined`
- `Clipboard` — `readText`, `writeText`

**Global singletons**
- `window` — Pre-initialized `Window` instance
- `document` — Pre-initialized `Document` instance
- `kIsBrowser` — `true` on browser, `false` on Dart VM

**Factory functions**
- `createMutationObserver()` — Platform-aware constructor
- `createEvent()` — Platform-aware constructor

**Server implementations**
- All types are no-ops or provide Dart-native fallbacks
- `Storage` backed by `Map`
- `Crypto.randomUUID()` via `dart:math`
- `btoa`/`atob` via `dart:convert`
- `Performance.now()` via `Stopwatch`
- `Clipboard` stores text in memory

**Browser implementations**
- All types wrap `package:web` DOM objects
- `.raw` property exposes the native JS object
