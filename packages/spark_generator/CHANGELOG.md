## 1.0.0-alpha.12

- Added `notFoundPage` support to `SparkServerConfig` to correct CSP nonce handling on 404 pages.

## 1.0.0-alpha.11

- Fix issue where `staticHandler` was preventing `notFoundHandler` from being reached.

## 1.0.0-alpha.10
- Improve nullable Map in DTO serialization to omit null values using conditional entries.
- Fixed nullable nested object serialization in DTOs.

## 1.0.0-alpha.9

- Fix nullable Map serialization in endpoint generator

## 1.0.0-alpha.8

- add null-aware type parsing to endpoint generator

## 1.0.0-alpha.7 - 30-01-2026

- Fixed issue where components defined in base classes were not detected by the builder.

## 1.0.0-alpha.6 - 27-01-2026

- Internal improvements.

## 1.0.0-alpha.5 - 27-01-2026

- Fixed nested pages web entry generation (pages in subdirectories now generate correct web entry paths).
- Fixed component imports in web entries to use implementation files (`_base.impl.dart`) instead of source files.

## 1.0.0-alpha.4 - 27-01-2026

- Fixed web entry generation to avoid importing the page definition file. This allows using `dart:io` in pages.

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
