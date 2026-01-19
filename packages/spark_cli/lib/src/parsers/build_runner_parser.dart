import '../errors/dev_error.dart';

/// Parses build_runner output to extract structured errors.
class BuildRunnerParser {
  /// Buffer to accumulate multi-line error messages.
  final List<String> _errorBuffer = [];

  /// Collected errors from the current build.
  final List<DevError> _errors = [];

  /// Whether we're currently inside an error block.
  bool _inErrorBlock = false;

  /// Current error context.
  String? _currentFile;
  int? _currentLine;
  int? _currentColumn;

  /// All errors collected so far.
  List<DevError> get errors => List.unmodifiable(_errors);

  /// Clears all collected errors.
  void clear() {
    _errors.clear();
    _errorBuffer.clear();
    _inErrorBlock = false;
    _currentFile = null;
    _currentLine = null;
    _currentColumn = null;
  }

  /// Parses a line of build_runner output.
  ///
  /// Build runner error formats include:
  /// - `[SEVERE] path/to/file.dart:line:column: Error message`
  /// - `[ERROR] some_builder on package:path/file.dart:`
  /// - Multi-line error messages with context
  void parseLine(String line) {
    // Pattern: [SEVERE] path/to/file.dart:10:5: Error message
    final severeMatch = RegExp(
      r'\[SEVERE\]\s+(.+?):(\d+):(\d+):\s*(.+)',
    ).firstMatch(line);

    if (severeMatch != null) {
      _flushErrorBuffer();
      _currentFile = severeMatch.group(1);
      _currentLine = int.tryParse(severeMatch.group(2) ?? '');
      _currentColumn = int.tryParse(severeMatch.group(3) ?? '');
      _errorBuffer.add(severeMatch.group(4) ?? line);
      _inErrorBlock = true;
      return;
    }

    // Pattern: [ERROR] builder on package:path/file.dart:
    final errorMatch = RegExp(
      r'\[ERROR\]\s+(.+?)\s+on\s+package:(.+?):',
    ).firstMatch(line);

    if (errorMatch != null) {
      _flushErrorBuffer();
      _currentFile = errorMatch.group(2);
      _errorBuffer.add('${errorMatch.group(1)} failed');
      _inErrorBlock = true;
      return;
    }

    // Pattern: error: Message (at path/to/file.dart:line:column)
    final dartErrorMatch = RegExp(
      r'error:\s*(.+?)\s*\(at\s+(.+?):(\d+):(\d+)\)',
    ).firstMatch(line);

    if (dartErrorMatch != null) {
      _flushErrorBuffer();
      _errors.add(
        DevError.build(
          message: dartErrorMatch.group(1) ?? line,
          filePath: dartErrorMatch.group(2),
          line: int.tryParse(dartErrorMatch.group(3) ?? ''),
          column: int.tryParse(dartErrorMatch.group(4) ?? ''),
        ),
      );
      return;
    }

    // Simple error pattern: error: Message
    final simpleErrorMatch = RegExp(r'^error:\s*(.+)$').firstMatch(line);
    if (simpleErrorMatch != null) {
      _flushErrorBuffer();
      _errors.add(DevError.build(message: simpleErrorMatch.group(1) ?? line));
      return;
    }

    // Pattern: Could not generate `file.g.dart`
    final generateMatch = RegExp(
      r"Could not generate `(.+?)`",
    ).firstMatch(line);

    if (generateMatch != null) {
      _flushErrorBuffer();
      _errors.add(
        DevError.build(
          message: 'Code generation failed for ${generateMatch.group(1)}',
        ),
      );
      return;
    }

    // Check if this is continuation of a multi-line error
    if (_inErrorBlock) {
      // End of error block indicators
      if (line.isEmpty ||
          line.startsWith('[INFO]') ||
          line.startsWith('[FINE]') ||
          line.contains('Succeeded') ||
          line.contains('Building...')) {
        _flushErrorBuffer();
      } else {
        // Continue accumulating error context
        _errorBuffer.add(line.trim());
      }
    }
  }

  /// Flushes the error buffer, creating a DevError if there's content.
  void _flushErrorBuffer() {
    if (_errorBuffer.isNotEmpty) {
      final message = _errorBuffer.first;
      final context = _errorBuffer.length > 1
          ? _errorBuffer.skip(1).join('\n')
          : null;

      _errors.add(
        DevError.build(
          message: message,
          filePath: _currentFile,
          line: _currentLine,
          column: _currentColumn,
          context: context,
        ),
      );
    }

    _errorBuffer.clear();
    _inErrorBlock = false;
    _currentFile = null;
    _currentLine = null;
    _currentColumn = null;
  }

  /// Call when build completes to ensure any buffered error is captured.
  void finalize() {
    _flushErrorBuffer();
  }
}
