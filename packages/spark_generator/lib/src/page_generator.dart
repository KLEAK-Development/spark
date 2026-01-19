import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:spark_framework/spark.dart' show Page;
import 'package:spark_generator/src/generator_helpers.dart' as helpers;

/// Generator that processes @Page annotations.
///
/// For each page class, generates:
/// - A handler function that creates PageRequest and calls loader/render
/// - Route registration info for the router builder
class PageGenerator extends GeneratorForAnnotation<Page> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    helpers.validateClassElement(element, 'Page');

    // Verify the class extends SparkPage
    if (!helpers.checkInheritance(element as ClassElement, 'SparkPage')) {
      throw InvalidGenerationSourceError(
        '@Page classes must extend SparkPage<T>',
        element: element,
      );
    }

    final className = element.name;
    final path = annotation.read('path').stringValue;
    final methods = annotation
        .read('methods')
        .listValue
        .map((e) => e.toStringValue()!)
        .toList();

    // Parse path parameters from the route pattern
    final pathParams = helpers.parsePathParams(path);

    // Convert path pattern to shelf_router format
    // /users/:id -> /users/<id>
    final shelfPath = helpers.convertToShelfPath(path);

    // Get the generic type parameter T from SparkPage<T>

    final buffer = StringBuffer();

    // Generate the route info annotation for the aggregating builder
    buffer.writeln('// Route: $path');
    buffer.writeln('// Methods: $methods');
    buffer.writeln('// Path params: $pathParams');
    buffer.writeln();

    // Generate static route info constant
    buffer.writeln('/// Route information for [$className].');
    buffer.writeln('const _\$${className}Route = (');
    buffer.writeln("  path: '$shelfPath',");
    buffer.writeln('  methods: <String>$methods,');
    buffer.writeln(
      '  pathParams: <String>[${pathParams.map((p) => "'$p'").join(', ')}],',
    );
    buffer.writeln('  className: \'$className\',');
    buffer.writeln(');');
    buffer.writeln();

    // Generate the handler function
    buffer.writeln('/// Handler for [$className] at `$path`.');
    buffer.writeln('Future<Response> _\$handle$className(');
    buffer.writeln('  Request request,');
    for (final param in pathParams) {
      buffer.writeln('  String $param,');
    }
    buffer.writeln(') async {');
    buffer.writeln('  final page = $className();');

    buffer.writeln('  var pipeline = const Pipeline();');
    buffer.writeln('  for (final middleware in page.middleware) {');
    buffer.writeln('    pipeline = pipeline.addMiddleware(middleware);');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  final handler = (Request req) async {');
    buffer.writeln('    final pageRequest = PageRequest(');
    buffer.writeln('      shelfRequest: req,');
    buffer.writeln('      pathParams: {');
    for (final param in pathParams) {
      buffer.writeln("        '$param': $param,");
    }
    buffer.writeln('      },');
    buffer.writeln('    );');
    buffer.writeln();
    buffer.writeln('    final response = await page.loader(pageRequest);');
    buffer.writeln();
    buffer.writeln('    return switch (response) {');
    // Check if the page overrides the components getter
    // We want to generate the script if the page or any of its parents (except SparkPage)
    // defines components.
    final componentsGetter = element.lookUpGetter(
      name: 'components',
      library: element.library,
    );
    final hasComponents =
        componentsGetter != null &&
        componentsGetter.enclosingElement.name != 'SparkPage';

    String? scriptName;
    if (hasComponents) {
      if (buildStep.inputId.path.startsWith('lib/pages/')) {
        scriptName =
            "'${buildStep.inputId.path.substring('lib/pages/'.length).replaceAll('.dart', '.dart.js')}'";
      } else {
        scriptName =
            "'${buildStep.inputId.pathSegments.last.replaceAll('.dart', '.dart.js')}'";
      }
    } else {
      scriptName = 'null';
    }
    buffer.writeln(
      "      PageData(:final data, :final statusCode, :final headers) =>",
    );
    buffer.writeln(
      "        _\$renderPageResponse(page, data, pageRequest, statusCode, headers, $scriptName),",
    );
    buffer.writeln(
      '      PageRedirect(:final location, :final statusCode, :final headers) =>',
    );
    buffer.writeln(
      "        Response(statusCode, headers: {...headers, 'location': location}),",
    );
    buffer.writeln('      PageError(:final message, :final statusCode) =>');
    buffer.writeln('        _\$renderErrorResponse(message, statusCode),');
    buffer.writeln('    };');
    buffer.writeln('  };');
    buffer.writeln();
    buffer.writeln('  return pipeline.addHandler(handler)(request);');
    buffer.writeln('}');

    return buffer.toString();
  }
}
