## 1.0.0-alpha.10

- Fixed init command generated code.
- Fix spark_cli tests: add spark_html_dsl and spark_vdom dependency overrides.

## 1.0.0-alpha.9

### Features

- Added `spark create` command for scaffolding pages, endpoints, and components.
- Added `spark mcp` subcommand for AI-assisted development via MCP server.
- Added `--poll` flag to `spark dev` command for enabling polling file watcher.
- Added `--verbose`/`-v` flag to `spark dev` command.
- Generated components are now placed inside their own snake_case folder.

### Improvements

- Refactored MCP server to use `json_rpc_2` package.
- Replaced synchronous file existence checks with asynchronous ones in MCP server.

## 1.0.0-alpha.8

- Updated dependencies.
- Spark init command create a working project

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
