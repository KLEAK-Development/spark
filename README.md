# Spark

A lightweight, isomorphic Server-Side Rendering (SSR) web framework for Dart.

Spark enables building interactive web applications with HTML-first delivery and efficient client-side interactivity through Custom Elements and Declarative Shadow DOM.

## Features

- **HTML-First Architecture** - Server sends fully formed HTML for instant display
- **Isomorphic Components** - Single Dart file defines both server and client logic
- **Zero-JS Initial Paint** - Declarative Shadow DOM eliminates JavaScript for first render
- **Typed CSS API** - Type-safe, autocompleted styling with `Style.typed`
- **Automatic OpenAPI Generation** - API documentation generated from code annotations
- **DTO Validation** - Automatic request body validation using annotations
- **Multi-Page Architecture** - Lightweight JavaScript bundles per route

## Installation

### Prerequisites

- Dart SDK 3.10.0 or higher

### Global CLI Installation

```bash
dart pub global activate spark_cli
```

### Project Dependency

Add to your `pubspec.yaml`:

```yaml
dependencies:
  spark_framework: ^1.0.0-alpha.2

dev_dependencies:
  spark_generator: ^1.0.0-alpha.3
  build_runner: ^2.4.0
```

## Quick Start

```bash
# Create a new project
spark init my_app

# Navigate to project
cd my_app

# Install dependencies
dart pub get

# Start development server
spark dev
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `spark init <name>` | Create a new project with starter templates |
| `spark dev` | Start development server with hot reload |
| `spark build` | Create production build |
| `spark openapi` | Generate OpenAPI 3.0 specification |

### Build Options

```bash
spark build              # Standard build
spark build -o dist      # Custom output directory
spark build -v           # Verbose output
spark build --no-clean   # Skip cleaning for faster rebuild
```

## Project Structure

```
my_app/
├── bin/
│   └── server.dart          # Server entry point
├── lib/
│   ├── components/          # @Component annotated web components
│   ├── endpoints/           # @Endpoint annotated API handlers
│   ├── pages/               # @Page annotated server-rendered pages
│   └── spark_router.g.dart  # Generated router
├── web/
│   └── main.dart            # Browser entry point
└── pubspec.yaml
```

## Core Concepts

### Components

Create interactive web components with the `@Component` annotation:

```dart
import 'package:spark_framework/spark.dart';

part 'my_counter.g.dart';

@Component(tag: MyCounter.tag)
class MyCounter extends SparkComponent with _$MyCounterSync {
  static const tag = 'my-counter';

  @override
  String get tagName => tag;

  @Attribute(observable: true)
  int count = 0;

  @override
  Element build() {
    return div([
      span(['Count: $count']),
      button(['+'], onClick: (_) => count++),
      button(['-'], onClick: (_) => count--),
    ]);
  }
}
```

### Pages

Create server-rendered pages with the `@Page` annotation:

```dart
import 'package:spark_framework/spark.dart';

class HomePageData {
  final String title;
  const HomePageData({required this.title});
}

@Page(path: '/')
class HomePage extends SparkPage<HomePageData> {
  @override
  Future<PageResponse<HomePageData>> loader(PageRequest request) async {
    return PageData(HomePageData(title: 'Welcome to Spark'));
  }

  @override
  Element render(HomePageData data, PageRequest request) {
    return div([
      h1(data.title),
      p('Build fast, interactive web apps with Dart.'),
    ]);
  }

  @override
  String title(HomePageData data, PageRequest request) => data.title;
}
```

### Endpoints

Create API endpoints with automatic OpenAPI documentation:

```dart
import 'package:spark_framework/spark.dart';

@Endpoint(
  path: '/api/hello',
  method: 'GET',
  summary: 'Say hello',
  description: 'Returns a greeting message',
)
class HelloEndpoint extends SparkEndpoint {
  @override
  Future<String> handler(SparkRequest request) async {
    return 'Hello World';
  }
}

// Endpoint with request body
@Endpoint(path: '/api/users', method: 'POST')
class CreateUserEndpoint extends SparkEndpointWithBody<UserDto> {
  @override
  Future<UserDto> handler(SparkRequest request, UserDto body) async {
    return body;
  }
}
```

### Validation Annotations

Available validation annotations for DTOs:

- `@NotEmpty` - Field must not be empty
- `@Length(min, max)` - String length constraints
- `@Min(value)` / `@Max(value)` - Numeric bounds
- `@Email` - Email format validation
- `@Pattern(regex)` - Custom regex validation
- `@IsNumeric` / `@IsBooleanString` - Type validation

## Packages

This monorepo contains three packages:

| Package | Description |
|---------|-------------|
| [spark_framework](packages/spark) | Core framework library |
| [spark_cli](packages/spark_cli) | Command-line tools |
| [spark_generator](packages/spark_generator) | Code generator for annotations |

## Documentation

Full documentation available at [spark.kleak.dev](https://spark.kleak.dev)

## License

MIT License - see [LICENSE](LICENSE) for details.
