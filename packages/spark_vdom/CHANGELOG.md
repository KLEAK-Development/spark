# Changelog

## 1.0.0-alpha.5

### Fixed

- **VDOM**: Prevented accidental closing of `dialog` and `details` elements by avoiding the removal of the browser-managed `open` attribute unless explicitly changed in the VDOM.
- **VDOM**: Fixed `InvalidStateError` when calling `showModal()` on elements not yet in the Document.
- **VDOM**: Improved property synchronization for `open`, `checked`, and `value` (extended to `textarea` and `select`) to ensure DOM state consistency.

## 1.0.0-alpha.4

### Added

- **Testing**: Achieved 100% code coverage for the entire package.
- **Testing**: Restructured tests to mirror the `lib/` directory (`test/src/`).
- **Testing**: Added comprehensive coverage for SVG context propagation, ShadowRoot patching, hydration edge cases, and resource cleanup.
- **Internal**: Exposed `nextId` and `isIgnorable` for testing purposes via `@visibleForTesting`.

## 1.0.0-alpha.3

### Added

- Added explicit handling for `ShadowRoot` in `mount` and `mountList` to support mounting Virtual DOM trees directly into component shadow roots.

## 1.0.0-alpha.2

### Fixed

- Removed debug print statements from `patch()`.
- **Refactor**: Replaced `package:web` dependency with `package:spark_web` for improved type safety and consistency.
- **Refactor**: Event handlers now receive raw `spark_web.Event` objects directly.

## 1.0.0-alpha.1

- Initial release extracted from `spark` framework package.
- Browser VDOM engine: `mount()`, `mountList()`, `patch()`, `createNode()`.
- Efficient DOM diffing and patching for attributes, events, and children.
- Conditional export: browser implementation with server/VM stubs.
- Depends on `spark_html_dsl` for node types.
