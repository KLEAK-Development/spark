# Changelog

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
