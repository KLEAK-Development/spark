import 'dev_error_type.dart';

/// Represents a structured error from the dev environment.
class DevError {
  /// The type/category of this error.
  final DevErrorType type;

  /// Human-readable error message.
  final String message;

  /// Source file path (if applicable).
  final String? filePath;

  /// Line number in the source file (if applicable).
  final int? line;

  /// Column number in the source file (if applicable).
  final int? column;

  /// Additional context or raw output.
  final String? context;

  /// Timestamp when the error occurred.
  final DateTime timestamp;

  /// The underlying exception or error object (if any).
  final Object? error;

  /// Stack trace (if available).
  final StackTrace? stackTrace;

  const DevError({
    required this.type,
    required this.message,
    this.filePath,
    this.line,
    this.column,
    this.context,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  /// Creates a build error from parsed build_runner output.
  factory DevError.build({
    required String message,
    String? filePath,
    int? line,
    int? column,
    String? context,
  }) {
    return DevError(
      type: DevErrorType.build,
      message: message,
      filePath: filePath,
      line: line,
      column: column,
      context: context,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a server error (crash, exit, etc.).
  factory DevError.server({
    required String message,
    int? exitCode,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return DevError(
      type: DevErrorType.server,
      message: message,
      context: exitCode != null ? 'Exit code: $exitCode' : null,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Creates a hot reload error.
  factory DevError.hotReload({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return DevError(
      type: DevErrorType.hotReload,
      message: message,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Creates a VM service connection error.
  factory DevError.vmService({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return DevError(
      type: DevErrorType.vmService,
      message: message,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Creates a timeout error.
  factory DevError.timeout({required String message, Duration? duration}) {
    return DevError(
      type: DevErrorType.timeout,
      message: message,
      context: duration != null ? 'Timeout after ${duration.inSeconds}s' : null,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a live reload error.
  factory DevError.liveReload({
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return DevError(
      type: DevErrorType.liveReload,
      message: message,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Returns a formatted location string (e.g., "lib/main.dart:10:5").
  String? get location {
    final path = filePath;
    if (path == null) return null;
    final buffer = StringBuffer(path);
    if (line != null) {
      buffer.write(':$line');
      if (column != null) {
        buffer.write(':$column');
      }
    }
    return buffer.toString();
  }

  @override
  String toString() => '${type.label}: $message';
}
