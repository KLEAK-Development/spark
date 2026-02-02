## 1.0.0-alpha.7

- Fixed an issue where hidden files (starting with `.`) were not being copied from `web` to `build/web` during `spark build`.

## 1.0.0-alpha.6

- Implement CSS minification logic and enable it during the build process for server and client compilation.
- Switch CSS minification to use the `dart.vm.product` flag, remove custom build flags, and add new tests for minification behavior.

## 1.0.0-alpha.5 - 30-01-2026

- Updated dependencies.

## 1.0.0-alpha.4 - 27-01-2026

- Fixed `spark dev` hang when using a project with no components.

## 1.0.0-alpha.3

- Fixed OpenAPI generation to correctly detect and document ApiError subclasses and SparkHttpException
- Fixed OpenAPI generation to correctly document handler that return String and num
- Fixed OpenAPI generation to correctly document handler that return primitive types (DateTime)
- Fixed dev_dependencies to target spark_generator version 1.0.0-alpha.2 instead of spark_framework

## 1.0.0-alpha.2

- Fixed pubspec.yaml to use versioned dependencies instead of local paths

## 1.0.0-alpha.1

- Initial version
