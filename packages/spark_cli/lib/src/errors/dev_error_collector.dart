import '../console/console_output.dart';
import 'dev_error.dart';
import 'dev_error_type.dart';

/// Collects and formats development errors for display.
class DevErrorCollector {
  final List<DevError> _errors = [];
  final ConsoleOutput _console;

  DevErrorCollector({ConsoleOutput? console})
    : _console = console ?? ConsoleOutput();

  /// All collected errors.
  List<DevError> get errors => List.unmodifiable(_errors);

  /// Whether any errors have been collected.
  bool get hasErrors => _errors.isNotEmpty;

  /// Number of errors collected.
  int get errorCount => _errors.length;

  /// Adds an error to the collection.
  void add(DevError error) {
    _errors.add(error);
  }

  /// Adds multiple errors to the collection.
  void addAll(Iterable<DevError> errors) {
    _errors.addAll(errors);
  }

  /// Clears all collected errors.
  void clear() {
    _errors.clear();
  }

  /// Clears errors of a specific type.
  void clearType(DevErrorType type) {
    _errors.removeWhere((e) => e.type == type);
  }

  /// Returns errors grouped by type.
  Map<DevErrorType, List<DevError>> get errorsByType {
    final grouped = <DevErrorType, List<DevError>>{};
    for (final error in _errors) {
      grouped.putIfAbsent(error.type, () => []).add(error);
    }
    return grouped;
  }

  /// Prints a formatted error summary to the console.
  void printSummary({bool clearAfter = false}) {
    if (!hasErrors) return;

    final grouped = errorsByType;

    _console.printLine();
    _console.printError(
      '═══════════════════════════════════════════════════════',
    );
    _console.printError('  ERROR SUMMARY: $errorCount error(s)');
    _console.printError(
      '═══════════════════════════════════════════════════════',
    );

    for (final type in DevErrorType.values) {
      final errorsOfType = grouped[type];
      if (errorsOfType == null || errorsOfType.isEmpty) continue;

      _console.printLine();
      _console.printWarning(
        '┌─ ${type.label.toUpperCase()} (${errorsOfType.length})',
      );

      for (final error in errorsOfType) {
        _printError(error);
      }
    }

    _console.printLine();
    _console.printError(
      '═══════════════════════════════════════════════════════',
    );

    if (clearAfter) {
      clear();
    }
  }

  void _printError(DevError error) {
    final location = error.location;

    if (location != null) {
      _console.printError('│  ┌ $location');
      _console.printError('│  └ ${error.message}');
    } else {
      _console.printError('│  • ${error.message}');
    }

    if (error.context != null) {
      _console.printGray('│    ${error.context}');
    }
  }
}
