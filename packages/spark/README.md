# Spark Framework

A lightweight, isomorphic SSR web framework for Dart that enables Server-Side Rendering with interactive "islands" of client-side logic using Custom Elements and Declarative Shadow DOM.

## Features

- **HTML-first**: Server sends fully formed HTML for instant display.
- **Isomorphic Components**: Single Dart file defines both server and client logic.
- **Zero-JS Initial Paint**: Uses Declarative Shadow DOM for immediate rendering.
- **Typed CSS**: Type-safe, autocompleted styling API (`Style.typed`).
- **Automatic OpenAPI**: Generate OpenAPI specifications directly from your code.
- **DTO Validation**: Automatic request body validation using annotations.
- **Multi-Page Architecture**: Each route has its own lightweight JavaScript bundle.

## Installation

Add dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  spark_framework: ^1.0.0-alpha.1
```

Install the CLI tool globally:

```bash
dart pub global activate spark_cli
```

## CLI Usage

The `spark` CLI helps you manage your project lifecycle.

- **Initialize a new project**:

  ```bash
  spark init my_app
  ```

- **Run development server** (with hot reload):

  ```bash
  spark dev
  ```

- **Build for production**:

  ```bash
  spark build
  ```

- **Generate OpenAPI specification**:
  ```bash
  spark openapi
  ```

## Quick Start

### 1. Create a Component

Create a reusable component with typed styling and isomorphic logic.

```dart
import 'package:spark_framework/spark.dart';

part 'counter.g.dart';

@Component(tag: Counter.tag)
class Counter extends SparkComponent with _\$CounterSync {
  Counter({this.count = 0, this.label = 'Count'});

  static const tag = 'my-counter';

  @override
  String get tagName => tag;

  @Attribute(observable: true)
  int count;

  String label;

  @override
  Element build() {
    return div([
      style([
        css({
          ':host': .typed(
            display: .inlineBlock,
            padding: .all(.px(16)),
            border: CssBorder(
              width: .px(1),
              style: .solid,
              color: .hex('#ccc'),
            ),
            borderRadius: .px(8),
            fontFamily: .raw('sans-serif'),
          ),
          'button': .typed(
            cursor: .pointer,
            padding: .symmetric(vertical: .px(4), horizontal: .px(8)),
            margin: .symmetric(horizontal: .px(4)),
          ),
        }).toCss(),
      ]),
      span([label, ': ']),
      span(id: 'val', [count]),
      button(
        id: 'inc',
        onClick: (_) {
          count++;
        },
        ['+'],
      ),
      button(
        id: 'dec',
        onClick: (_) {
          count--;
        },
        ['-'],
      ),
    ]);
  }
}
```

### 3. Server Route

Serve your component using a Shelf handler.

```dart
import 'package:spark_framework/spark.dart';
import 'package:spark_framework/server.dart';
import 'package:your_package_name/spark_router.g.dart';

void main() async {
  final server = await createSparkServer(
    SparkServerConfig(
      port: 8080,
    ),
  );
  print('Server running at http://localhost:\${server.port}');
}
```

## Core Concepts

### Styling with Typed CSS

Spark provides a type-safe API for writing CSS, reducing errors and providing autocomplete.

```dart
final myStyle = Style.typed(
  width: CssLength.percent(100),
  height: CssLength.vh(100),
  display: CssDisplay.grid,
  gridTemplateColumns: 'repeat(3, 1fr)', // Complex values can still use strings
  gap: CssLength.rem(2),
  margin: CssSpacing.symmetric(
    vertical: CssLength.px(20),
    horizontal: CssLength.px(0),
  ),
  color: CssColor.rgb(50, 50, 50),
);
```

### Endpoints & Validation

Define robust API endpoints with automatic validation and documentation.

```dart
@Endpoint(path: '/api/users', method: 'POST')
class CreateUser extends SparkEndpoint<CreateUserDto> {
  @override
  Future<Response> handler(SparkRequest req, CreateUserDto body) async {
    // body is automatically validated and typed
    return Response.ok({'id': 123, 'name': body.name});
  }
}

class CreateUserDto {
  @NotEmpty(message: 'Name is required')
  @Length(min: 2, max: 50)
  final String name;

  @Email()
  final String email;

  CreateUserDto({required this.name, required this.email});
}
```

### Validation Annotations

Supported annotations include:

- `@NotEmpty`, `@Length`, `@Min`, `@Max`
- `@Email`, `@Pattern`, `@IsNumeric`, `@IsBooleanString`

## Project Structure

A typical Spark project looks like this:

```
my_app/
├── bin/
│   └── server.dart      # Server entry point
├── lib/
│   ├── components/      # Isomorphic components
│   ├── endpoints/       # API endpoints
│   └── pages/           # Page layouts
├── web/
│   └── main.dart        # Browser entry points
├── pubspec.yaml
└── README.md
```

## License

MIT
