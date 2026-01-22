## 1.0.0-alpha.3 - 22-01-2025

### Breaking changes

- There is a new way to write Components. Please refer to the [documentation](https://spark.kleak.dev/docs/components) for more information.

### Features

- Added support for csp nonce on scripts and styles
- Fix @Component reactive attributes, Future event was not working properly, and changing value when there was async gap also.
- Fix method extraction in component generator

## 1.0.0-alpha.2

- Fixed primitives types (DartTime) to return text/plain instead of application/json in the ISO8601 format

## 1.0.0-alpha.1

- Initial version
