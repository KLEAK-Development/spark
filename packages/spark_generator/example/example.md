# spark_generator Examples

## Page Example

```dart
import 'package:spark_framework/spark.dart';

part 'home_page.g.dart';

@Page(path: '/')
class HomePage extends SparkPage<String> {
  @override
  Future<PageResponse<String>> loader(PageRequest request) async {
    return PageData('Welcome to Spark!');
  }

  @override
  String render(String data, PageRequest request) {
    return '''
      <!DOCTYPE html>
      <html>
        <head><title>Home</title></head>
        <body><h1>$data</h1></body>
      </html>
    ''';
  }
}
```

## Endpoint Example

```dart
import 'package:spark_framework/spark.dart';

part 'get_user_endpoint.g.dart';

@Endpoint(path: '/api/users/{id}', method: 'GET')
class GetUserEndpoint extends SparkEndpoint {
  @override
  Future<Map<String, dynamic>> handler(SparkRequest request) async {
    final userId = request.pathParamInt('id');
    return {'id': userId, 'name': 'John Doe'};
  }
}
```

## Endpoint with Request Body

```dart
import 'package:spark_framework/spark.dart';

part 'create_user_endpoint.g.dart';

class CreateUserDto {
  final String name;
  final String email;
  CreateUserDto(this.name, this.email);
}

@Endpoint(path: '/api/users', method: 'POST')
class CreateUserEndpoint extends SparkEndpointWithBody<CreateUserDto> {
  @override
  Future<Map<String, dynamic>> handler(
    SparkRequest request,
    CreateUserDto body,
  ) async {
    return {'id': 1, 'name': body.name, 'email': body.email};
  }
}
```

## Component Example

```dart
import 'package:spark_framework/spark.dart';

part 'counter.g.dart';

@Component(tag: 'my-counter')
class Counter extends SparkComponent with _$CounterSync {
  Counter({this.count = 0});

  @override
  String get tagName => 'my-counter';

  @Attribute(observable: true)
  int count;

  @override
  Element build() {
    return div([
      button(
        id: 'dec',
        ['-'],
        onClick: (_) => count--,
      ),
      span(id: 'val', [count]),
      button(
        id: 'inc',
        ['+'],
        onClick: (_) => count++,
      ),
    ]);
  }
}
```

## Running the Generator

```bash
# One-time build
dart run build_runner build

# Watch mode
dart run build_runner watch

# Clean and rebuild
dart run build_runner build --delete-conflicting-outputs
```
