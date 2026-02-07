/// Converts a string (PascalCase, camelCase, or snake_case) to snake_case.
String toSnakeCase(String input) {
  if (input.isEmpty) return input;

  // If already snake_case (contains underscores), normalize and return
  if (input.contains('_')) {
    return input.toLowerCase();
  }

  // PascalCase or camelCase → snake_case
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (i > 0 &&
        char.toUpperCase() == char &&
        char.toLowerCase() != char) {
      buffer.write('_');
    }
    buffer.write(char.toLowerCase());
  }
  return buffer.toString();
}

/// Converts a string to PascalCase.
String toPascalCase(String input) {
  final snake = toSnakeCase(input);
  return snake.split('_').map((word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1);
  }).join();
}

/// Converts a string to kebab-case.
String toKebabCase(String input) {
  return toSnakeCase(input).replaceAll('_', '-');
}

/// Checks if the input name can produce a valid web component tag name.
///
/// Web component custom element names must contain a hyphen (-).
/// This means the name must have at least two segments when converted
/// (e.g. `my_counter` → `my-counter`, `MyCounter` → `my-counter`).
/// A single word like `counter` cannot produce a valid tag.
bool isValidComponentName(String input) {
  final snake = toSnakeCase(input);
  return snake.contains('_');
}
