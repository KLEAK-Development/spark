# Spark CLI

Command-line interface for the Spark Framework - a Dart web framework for building server-side rendered applications with interactive islands.

## Features

- **Project scaffolding** - Quickly bootstrap new Spark projects with `spark init`
- **Hot reload development** - Fast development cycle with automatic hot reload using `spark dev`
- **Production builds** - Optimized builds with native server compilation using `spark build`
- **OpenAPI generation** - Automatic API documentation from your endpoints with `spark openapi`

## Installation

Add `spark_cli` as a dev dependency in your `pubspec.yaml`:

```yaml
dev_dependencies:
  spark_cli: ^1.0.0
```

Or install globally:

```bash
dart pub global activate spark_cli
```

## Commands

| Command             | Description                              |
| ------------------- | ---------------------------------------- |
| `spark init <name>` | Create a new Spark project               |
| `spark dev`         | Start development server with hot reload |
| `spark build`       | Build for production                     |
| `spark openapi`     | Generate OpenAPI specification           |

### spark init

Creates a new Spark project with a complete starter template including a counter component, home page, and API endpoint.

```bash
spark init my_app
```

This generates:

- `pubspec.yaml` - Project configuration
- `bin/server.dart` - Server entry point
- `lib/pages/home_page.dart` - Example page with SSR
- `lib/components/counter.dart` - Interactive island component
- `lib/endpoints/endpoints.dart` - Example API endpoint
- `analysis_options.yaml` - Linting configuration
- `.gitignore` - Git ignore rules

### spark dev

Starts the development server with:

- **Hot reload** - Dart code changes are instantly applied
- **Live reload** - Browser automatically refreshes on changes
- **Watch mode** - Automatic code generation via `build_runner`

```bash
spark dev
```

The development server monitors your files and:

1. Runs `build_runner watch` for code generation
2. Starts the server with VM service for hot reload
3. Automatically restarts when router configuration changes
4. Triggers browser refresh on file changes

### spark build

Builds your Spark application for production deployment.

```bash
spark build
```

**Options:**

| Option          | Default | Description                           |
| --------------- | ------- | ------------------------------------- |
| `--clean`       | `true`  | Clean build directory before building |
| `-v, --verbose` | `false` | Show verbose build output             |
| `-o, --output`  | `build` | Output directory path                 |

**Build phases:**

1. Clean build directory (optional)
2. Run code generation with `build_runner`
3. Compile server to native executable
4. Compile web assets with dart2js (O2 optimization)
5. Copy static assets
6. Clean up development artifacts

**Examples:**

```bash
# Standard production build
spark build

# Build to custom directory
spark build -o dist

# Build without cleaning
spark build --no-clean

# Verbose output
spark build -v
```

### spark openapi

Generates an OpenAPI 3.0 specification from your `@Endpoint` annotations.

```bash
spark openapi
```

**Options:**

| Option         | Default        | Description      |
| -------------- | -------------- | ---------------- |
| `-o, --output` | `openapi.json` | Output file path |

**Features:**

- Automatically discovers endpoints annotated with `@Endpoint`
- Extracts path parameters, request bodies, and response types
- Infers error responses from thrown exceptions
- Supports validation annotations for schema constraints
- Generates component schemas for DTOs

**Examples:**

```bash
# Generate to default location
spark openapi

# Generate to custom file
spark openapi -o api-spec.json
```

## Quick Start

1. Create a new project:

   ```bash
   spark init my_app
   cd my_app
   ```

2. Install dependencies:

   ```bash
   dart pub get
   ```

3. Start development:

   ```bash
   spark dev
   ```

4. Open http://localhost:8080 in your browser

5. When ready for production:
   ```bash
   spark build
   ```

## Related Packages

- [spark_framework](https://pub.dev/packages/spark_framework) - Core Spark Framework
- [spark_generator](https://pub.dev/packages/spark_generator) - Code generation for Spark

## Links

- [Documentation](https://spark.kleak.dev)
- [GitHub Repository](https://github.com/KLEAK-Development/spark)
- [Issue Tracker](https://github.com/KLEAK-Development/spark/issues)
