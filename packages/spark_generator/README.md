# spark_generator

Code generator for the Spark Framework. Processes `@Page`, `@Endpoint`, and `@Component` annotations to generate route handlers and component hydration code.

## Features

- **PageGenerator** - Generates handlers for `@Page` annotated classes
- **EndpointGenerator** - Generates handlers for `@Endpoint` annotated API classes
- **ComponentGenerator** - Generates hydration code for `@Component` annotated web components
- **RouterBuilder** - Aggregates all routes into `createSparkRouter()` and `createSparkServer()` functions

## Quick Start

Add to your `pubspec.yaml`:

```yaml
dependencies:
  spark_framework: ^1.0.0

dev_dependencies:
  spark_generator: ^1.0.0
  build_runner: ^2.4.0
```

Run the generator:

```bash
dart run build_runner build
```

Or watch for changes:

```bash
dart run build_runner watch
```

## Documentation

See `example/example.md` for usage examples.
