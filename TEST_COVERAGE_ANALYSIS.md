# Test Coverage Analysis

## Overview

Spark is a Dart monorepo with three packages: `spark` (core framework), `spark_cli` (CLI tool), and `spark_generator` (code generator). This analysis maps every source module against its test coverage and identifies gaps.

**Current State**: 46 test files cover ~108 source files. Estimated overall coverage is **~40%**, with critical infrastructure modules entirely untested.

---

## Package-by-Package Breakdown

### 1. `spark` (Core Framework)

| Source Module | Test File | Est. Coverage | Priority |
|---|---|---|---|
| `annotations/` (6 files) | *None* | **0%** | High |
| `component/spark_component.dart` | `component_test.dart` (partial) | ~40% | High |
| `component/web_component.dart` | `component_test.dart` (partial) | ~40% | High |
| `component/vdom.dart` | `component/vdom_test.dart` | ~70% | Low |
| `endpoint/spark_endpoint.dart` | *None* | **0%** | High |
| `errors/errors.dart` | `api_error_test.dart` | ~50% | Medium |
| `html/dsl.dart` | `html_test.dart` | ~60% | Medium |
| `html/elements.dart` | *None* | **0%** | High |
| `html/extensions.dart` | *None* | **0%** | Medium |
| `html/node.dart` | `html/node_test.dart` | ~80% | Low |
| `http/content_type.dart` | *None* | **0%** | Medium |
| `http/cookie.dart` | `cookie_test.dart` | ~90% | Low |
| `page/page_request.dart` | *None directly* | **~10%** | **Critical** |
| `page/page_response.dart` | `page_response_test.dart` | ~70% | Low |
| `page/spark_page.dart` | `page_test.dart` (partial) | ~40% | Medium |
| `server/render_page.dart` | `server_test.dart`, `render_page_test.dart`, `render_page_xss_test.dart` | ~85% | Low |
| `server/request_extensions.dart` | `server/request_extensions_test.dart` | ~70% | Low |
| `server/static_handler.dart` | `server_test.dart` (config only) | **<5%** | **Critical** |
| `server/request_ip_extension.dart` | *None* | **0%** | Medium |
| `style/style.dart` | `style_test.dart` | ~50% | Medium |
| `style/style_registry.dart` | `global_style_registry_test.dart` | ~70% | Low |
| `style/css_types/` (14 files) | `css_types_test.dart` | ~60% | Medium |
| `utils/utils.dart` | `utils_test.dart` | ~80% | Low |
| `utils/props_serializer.dart` | `utils_test.dart` | ~80% | Low |

### 2. `spark_cli` (CLI Tool)

| Source Module | Test File | Est. Coverage | Priority |
|---|---|---|---|
| `commands/init_command.dart` | `init_command_test.dart`, `init_command_content_test.dart` | ~80% | Low |
| `commands/dev_command.dart` | `dev_command_test.dart`, `dev_command_regression_test.dart` | ~70% | Low |
| `commands/build_command.dart` | `build_command_test.dart`, `build_command_hidden_files_test.dart` | ~75% | Low |
| `commands/openapi_command.dart` | `openapi_command_test.dart`, `openapi_automation_test.dart`, `openapi_validation_test.dart` | ~70% | Low |
| `command_runner.dart` | *None* | **0%** | Medium |
| `console/console_output.dart` | *None* | **0%** | Low |
| `errors/dev_error.dart` | *None* | **0%** | Medium |
| `errors/dev_error_collector.dart` | *None* | **0%** | Medium |
| `errors/dev_error_type.dart` | *None* | **0%** | Low |
| `io/process_runner.dart` | *None* | **0%** | Medium |
| `parsers/build_runner_parser.dart` | *None* | **0%** | **Critical** |
| `utils/build_runner_utils.dart` | *None* | **0%** | High |
| `utils/directory_utils.dart` | *None* | **0%** | Low |

### 3. `spark_generator` (Code Generator)

| Source Module | Test File | Est. Coverage | Priority |
|---|---|---|---|
| `component_generator.dart` | `component_generator_test.dart` | ~40% | High |
| `endpoint_generator.dart` | `endpoint_generator_test.dart` + 5 supporting tests | ~70% | Medium |
| `page_generator.dart` | `page_generator_test.dart` | **~20%** | High |
| `router_builder.dart` | `router_builder_test.dart` | ~50% | Medium |
| `web_entry_builder.dart` | `web_entry_builder_test.dart`, `nested_web_entry_test.dart` | ~30% | Medium |
| `generator_helpers.dart` | *None directly* | **0%** | High |
| `builder.dart` | *None* | 0% (trivial) | Low |

---

## Top Recommendations

### 1. `SparkRequest` / `PageRequest` — No dedicated tests (Critical)

**File**: `packages/spark/lib/src/page/page_request.dart` (303 lines)

This is the primary request abstraction that every page handler interacts with. It contains:

- **Parameter extraction**: `pathParam()`, `pathParamInt()`, `queryParam()`, `queryParamInt()`, `queryParamDouble()`, `queryParamBool()`, `queryParamAll()` — each with default value handling and type coercion
- **Cookie parsing**: Splits on `;` then `=`, with special handling for values containing `=`
- **Multipart stream parsing**: Creates `MimeMultipartTransformer` bound to the request body stream, with boundary extraction from Content-Type
- **`MultipartPart`**: Header param extraction via regex, `readString()` for UTF-8 decoding
- **Context management**: `withContext()` and `withPathParams()` for middleware chaining

**Recommended tests**:
- Each `pathParam*` and `queryParam*` method with present values, missing values, and unparseable values
- Cookie parsing with: no cookies, single cookie, multiple cookies, cookies with `=` in values, empty values
- Multipart parsing: valid multipart body, missing boundary, non-multipart content-type
- `withContext()` preserves existing context and adds new entries
- `withPathParams()` merges correctly

### 2. `static_handler.dart` — Only config defaults tested (Critical)

**File**: `packages/spark/lib/src/server/static_handler.dart` (273 lines)

This serves all compiled assets in production. The current test (`server_test.dart:72-79`) only verifies `StaticHandlerConfig` defaults. The actual handler logic is entirely untested:

- **Directory traversal prevention** (`normalizedPath.startsWith(basePath)`) — a security-critical code path with zero test coverage
- **ETag-based caching**: Generates ETags from file modification time, handles `If-None-Match` to return 304
- **Gzip compression**: Conditionally compresses based on `Accept-Encoding` and MIME type
- **MIME type detection**: Maps 24 file extensions to MIME types, falls back to `application/octet-stream`
- **Directory listing**: Generates HTML index pages when enabled
- **`simpleStaticHandler()`**: A separate simplified handler, also untested

**Recommended tests** (using temp directories with real files):
- Serve a known file and verify content + correct Content-Type header
- Request a path like `../../etc/passwd` and verify 403 response
- Request with `If-None-Match` matching ETag → expect 304
- Request with `Accept-Encoding: gzip` for a `.js` file → verify `Content-Encoding: gzip`
- Request a directory with `defaultFile` set → verify `index.html` is served
- Request a non-existent file → verify 404
- Directory listing enabled → verify HTML response with file links

### 3. `BuildRunnerParser` — Complex regex parsing with zero tests (Critical)

**File**: `packages/spark_cli/lib/src/parsers/build_runner_parser.dart` (155 lines)

This parser is the sole mechanism for extracting structured errors from `build_runner` output during development. It uses 5 regex patterns and a stateful multi-line buffering system:

- `[SEVERE] path:line:column: message` — extracts file location and error message
- `[ERROR] builder on package:path:` — extracts builder failure
- `error: Message (at path:line:column)` — Dart error format
- `error: Message` — simple error format
- `Could not generate \`file\`` — code generation failure
- Multi-line error buffering with end-of-block detection (`[INFO]`, `[FINE]`, `Succeeded`, empty line)

**Recommended tests**:
- One test per regex pattern with valid input, verifying extracted fields
- Multi-line error: SEVERE line followed by context lines, then empty line → single error with context
- `finalize()` flushes any remaining buffered error
- `clear()` resets all state
- Interleaved patterns: SEVERE followed by another SEVERE should flush the first
- Lines that match no pattern while not in an error block → ignored

### 4. `annotations/` — Entire directory untested (High)

**File**: `packages/spark/lib/src/annotations/` (6 files)

While these are primarily marker classes, the `validator.dart` file contains 10 validator annotations (`NotEmpty`, `Email`, `Min`, `Max`, `Length`, `Pattern`, `IsNumeric`, `IsDate`, `IsBooleanString`, `IsString`) and `openapi.dart` contains complex data structures (`OpenApi`, `SecurityScheme`, `SecuritySchemeFlow`, `Parameter`, `ExternalDocumentation`). The `Endpoint` annotation has 12 properties.

**Recommended tests**:
- Verify each validator can be constructed with expected parameters
- Verify `Endpoint` annotation stores all 12 properties correctly
- Verify OpenAPI structures hold nested data (e.g., `SecurityScheme` with flows)

### 5. `endpoint/spark_endpoint.dart` — Core abstraction untested (High)

**File**: `packages/spark/lib/src/endpoint/spark_endpoint.dart`

Defines `SparkEndpoint` and `SparkEndpointWithBody<T>`, the abstract base classes for all API endpoints. While abstract, the default middleware behavior and the class hierarchy are important contracts.

**Recommended tests**:
- Verify default `middleware` returns the inner handler unchanged
- Verify the type parameter `T` is preserved in `SparkEndpointWithBody`

### 6. `page_generator.dart` — Only 4 tests, ~20% coverage (High)

**File**: `packages/spark_generator/lib/src/page_generator.dart` (144 lines)

Only basic page handler, path params, component detection, and cookie handling are tested. Missing coverage for:

- Pages with multiple HTTP methods
- Middleware pipeline generation
- `PageRedirect` handling (code path at line 123-128)
- `PageError` response handling
- Custom status codes and headers

**Recommended tests**:
- Page with POST + GET methods
- Page with middleware returning modified request
- Page handler that returns a `PageRedirect`
- Page handler that returns a `PageError`

### 7. `generator_helpers.dart` — Utility functions with zero direct tests (High)

**File**: `packages/spark_generator/lib/src/generator_helpers.dart` (51 lines)

Contains 4 functions used by all generators:
- `validateClassElement()` — validates annotations are on classes
- `checkInheritance()` — checks class extends a specific base
- `parsePathParams()` — extracts `:param` from route patterns
- `convertToShelfPath()` — converts `:param`/`{param}` to `<param>`

**Recommended tests**:
- `parsePathParams('/users/:id/posts/:postId')` → `['id', 'postId']`
- `convertToShelfPath('/users/:id')` → `'/users/<id>'`
- `convertToShelfPath('/users/{id}')` → `'/users/<id>'`
- Edge cases: paths with no params, trailing slashes, special characters

### 8. `component_generator.dart` — Only ~40% coverage (High)

**File**: `packages/spark_generator/lib/src/component_generator.dart` (863 lines)

The largest generator file has only 6 tests. Notable gaps:
- `onMount()` method handling (lines 607-620)
- `adoptedStyleSheets` getter generation
- Error conditions: missing `render()` method, missing `static tag` field
- Complex type serialization in attributes (only primitives tested)

### 9. `spark_cli` error infrastructure — Entirely untested (Medium)

**Files**: `dev_error.dart` (152 lines), `dev_error_collector.dart` (105 lines), `dev_error_type.dart` (26 lines)

The error collection and formatting system is what developers see when builds fail. `DevErrorCollector.printSummary()` has complex formatting with box-drawing characters and grouped-by-type output. `DevError` has 6 factory constructors and a `location` getter with conditional formatting.

**Recommended tests**:
- Each `DevError` factory constructor sets correct type and fields
- `DevError.location` formats as `file:line:column` with null handling
- `DevErrorCollector.add/clear/clearType` manage the error list correctly
- `DevErrorCollector.errorsByType` groups correctly

### 10. `build_runner_utils.dart` — Build orchestration untested (Medium)

**File**: `packages/spark_cli/lib/src/utils/build_runner_utils.dart` (128 lines)

Orchestrates `dart run build_runner` commands. `runBuild()` and `startWatch()` construct commands, pipe output through the parser, and check exit codes. While command tests exercise some of this indirectly, the stream-piping and parser-integration logic is not directly verified.

---

## Test Quality Observations

### Strengths
- **XSS protection tests** (`render_page_xss_test.dart`) — methodically test all user-controlled inputs for HTML injection
- **Integration-style command tests** — use real temp directories and mocked processes for realistic scenarios
- **Generator tests** — use `resolveSources()` for realistic code generation verification
- **Cookie tests** — thorough coverage of parsing and Set-Cookie formatting

### Weaknesses
1. **Almost no error/failure path tests** — tests primarily verify happy paths. No tests verify what happens when invalid input is provided to parsers, generators, or request handlers.
2. **No negative tests in generators** — no "should throw" or "should produce error" test cases for invalid annotations or missing required fields.
3. **String-matching fragility** — generator tests check for substring presence rather than parsing generated code, making them brittle to formatting changes.
4. **Suppressed output verification** — CLI tests use `zoneSpecification` to suppress `print()` output but never verify what was printed, missing UI regression bugs.
5. **No multipart/streaming tests** — `SparkRequest.multipart` and `MultipartPart` have zero coverage despite handling file uploads.

---

## Summary: Where to Start

If you can only add tests in a few areas, focus on these in order:

1. **`SparkRequest` (page_request.dart)** — Most impactful: every page handler depends on it
2. **`static_handler.dart`** — Security-critical: directory traversal and caching logic
3. **`BuildRunnerParser`** — Developer experience: silent error misses break the dev workflow
4. **`annotations/validator.dart`** — Correctness: validators are used in generated endpoint code
5. **`page_generator.dart`** — Expand from 4 tests to cover redirect/error/middleware paths
6. **`generator_helpers.dart`** — Small file, easy wins, used by all generators
