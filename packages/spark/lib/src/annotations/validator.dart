/// Base class for all validators.
abstract class Validator {
  const Validator();
}

/// Validates that a string is not empty.
class NotEmpty extends Validator {
  final String? message;
  const NotEmpty({this.message});
}

/// Validates that a string is a valid email.
class Email extends Validator {
  final String? message;
  const Email({this.message});
}

/// Validates that a number is at least [value].
class Min extends Validator {
  final num value;
  final String? message;
  const Min(this.value, {this.message});
}

/// Validates that a number is at most [value].
class Max extends Validator {
  final num value;
  final String? message;
  const Max(this.value, {this.message});
}

/// Validates that a string length is within [min] and [max].
class Length extends Validator {
  final int? min;
  final int? max;
  final String? message;
  const Length({this.min, this.max, this.message});
}

/// Validates that a string matches the given [pattern].
class Pattern extends Validator {
  final String pattern;
  final String? message;
  const Pattern(this.pattern, {this.message});
}

/// Validates that a string contains only numbers.
class IsNumeric extends Validator {
  final String? message;
  const IsNumeric({this.message});
}

/// Validates that a string is a valid date (ISO 8601).
class IsDate extends Validator {
  final String? message;
  const IsDate({this.message});
}

/// Validates that a string represents a boolean ("true", "false", "1", "0").
class IsBooleanString extends Validator {
  final String? message;
  const IsBooleanString({this.message});
}

/// Validates that a value is a string.
class IsString extends Validator {
  final String? message;
  const IsString({this.message});
}
