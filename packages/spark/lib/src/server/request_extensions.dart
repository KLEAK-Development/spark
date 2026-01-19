import 'package:shelf/shelf.dart';

const _providersKey = 'providers';

extension RequestSet on Request {
  /// set a function to create a lazy value [T]
  /// use it before using `request.get<T>()`
  Request set<T>(T Function() create) {
    final providers = context[_providersKey] as Map<String, dynamic>? ?? {};
    return change(
      context: {
        ...context,
        _providersKey: {...providers, '$T': create},
      },
    );
  }
}

extension RequestGet on Request {
  /// get [T] from the context
  /// use it after using `request.set<T>()`
  T get<T>() {
    final providers = (context[_providersKey] as Map<String, dynamic>?) ?? {};
    final value = providers['$T'];
    if (value == null) {
      throw StateError('''
request.get<$T>() called with a request context that does not contain a $T.
This can happen if $T was not provided to the request context.

Here is an example on how to provide a String
  ```dart
  // _middleware.dart
  Middleware middleware($T value) {
    return (handler) {
      return (request) async {
        return handler(request.set(() => value));
      };
    };
  }
  ```
''');
    }
    return (value as T Function())();
  }
}

extension RequestGetPathParameter on Request {
  /// get value of the query parameter [key] in the shelf_router/params context
  String getPathParameter(String key) {
    final params =
        (context['shelf_router/params'] as Map<String, String>?) ??
        <String, String>{};
    if (!params.containsKey(key)) {
      throw StateError('''
request.getPathParameter($key) called with a request context that does not contain a value in context['shelf_router/params'][$key].
This can happen if $key was not provided to the shelf_router path params context.

Here is an example on how to provide a path parameter
  ```dart
  // router.dart
  final router = Router()
    ..put(
      '/<todoId|\\d+>',
      Pipeline()
          .addMiddleware(update_todo.middleware())
          .addHandler(update_todo.handler),
    )

  //  middleware.dart
  Middleware middleware() => Pipeline()
    .addMiddleware(provide<TodoIdPathParameter>(
        (request) => int.parse(request.getPathParameter('todoId'))))
    .middleware;
  ```
''');
    }
    return params[key]!;
  }
}
