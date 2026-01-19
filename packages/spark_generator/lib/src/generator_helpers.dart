import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

/// Validates that the element is a class.
void validateClassElement(Element element, String annotationName) {
  if (element is! ClassElement) {
    throw InvalidGenerationSourceError(
      '@$annotationName can only be applied to classes',
      element: element,
    );
  }
}

/// Checks if the class extends the given superclass.
bool checkInheritance(ClassElement element, String superclassName) {
  var current = element.supertype;
  while (current != null) {
    if (current.element.name == superclassName) {
      return true;
    }
    current = current.element.supertype;
  }
  return false;
}

/// Parses path parameters from the route pattern.
/// Supports both :param and {param} formats.
List<String> parsePathParams(String path) {
  final colonsPattern = RegExp(r':(\w+)');
  final bracketsPattern = RegExp(r'\{(\w+)\}');

  final colons = colonsPattern.allMatches(path).map((m) => m.group(1)!);
  final brackets = bracketsPattern.allMatches(path).map((m) => m.group(1)!);

  return [...colons, ...brackets];
}

/// Converts path pattern to shelf_router format <param>.
/// Supports both :param and {param} formats in input.
String convertToShelfPath(String path) {
  var newPath = path.replaceAllMapped(
    RegExp(r':(\w+)'),
    (m) => '<${m.group(1)}>',
  );
  newPath = newPath.replaceAllMapped(
    RegExp(r'\{(\w+)\}'),
    (m) => '<${m.group(1)}>',
  );
  return newPath;
}
