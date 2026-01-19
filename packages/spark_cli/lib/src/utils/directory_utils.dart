import 'dart:io';
import '../console/console_output.dart';

/// Utilities for directory operations.
class DirectoryUtils {
  /// Cleans the directory at [path] if it exists.
  static Future<void> cleanDirectory(
    String path,
    ConsoleOutput console, {
    String message = 'Cleaning',
  }) async {
    final dir = Directory(path);
    if (await dir.exists()) {
      console.printGray('$message $path/...');
      await dir.delete(recursive: true);
      // Ensure the directory is fully removed before proceeding
      // (sometimes file system operations can be async/racy on some OSs)
    }
  }
}
