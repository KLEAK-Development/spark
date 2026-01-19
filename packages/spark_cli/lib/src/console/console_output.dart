import 'dart:io';

/// ANSI console output utilities.
class ConsoleOutput {
  // ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _cyan = '\x1B[36m';
  static const String _gray = '\x1B[90m';

  /// Whether to use colors (auto-detect TTY).
  final bool useColors;

  ConsoleOutput({bool? useColors})
    : useColors = useColors ?? stdout.hasTerminal;

  void _print(String message) {
    // ignore: avoid_print
    print(message);
  }

  void printLine() => _print('');

  void printSuccess(String message) {
    _print(_colorize(message, _green));
  }

  void printError(String message) {
    _print(_colorize(message, _red));
  }

  void printWarning(String message) {
    _print(_colorize(message, _yellow));
  }

  void printInfo(String message) {
    _print(_colorize(message, _cyan));
  }

  void printGray(String message) {
    _print(_colorize(message, _gray));
  }

  /// Clears the console screen.
  void clear() {
    _print('\x1B[2J\x1B[0;0H');
  }

  String _colorize(String message, String color) {
    if (!useColors) return message;
    return '$color$message$_reset';
  }
}
