import 'dart:io';

import 'package:spark_cli/src/console/console_output.dart';
import 'package:spark_cli/src/utils/directory_utils.dart';
import 'package:test/test.dart';

// A simple mock for ConsoleOutput to verify interactions
class MockConsoleOutput extends ConsoleOutput {
  final List<String> logs = [];

  MockConsoleOutput() : super(useColors: false);

  @override
  void printGray(String message) {
    logs.add(message);
  }

  @override
  void printInfo(String message) {
    logs.add(message);
  }

  @override
  void printSuccess(String message) {
    logs.add(message);
  }

  @override
  void printError(String message) {
    logs.add(message);
  }

  @override
  void printWarning(String message) {
    logs.add(message);
  }
}

void main() {
  group('DirectoryUtils.cleanDirectory', () {
    late Directory tempDir;
    late MockConsoleOutput console;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('spark_cli_test_');
      console = MockConsoleOutput();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('deletes existing directory and logs message', () async {
      final targetDir = Directory('${tempDir.path}/to_clean');
      await targetDir.create();
      expect(await targetDir.exists(), isTrue);

      await DirectoryUtils.cleanDirectory(targetDir.path, console);

      expect(await targetDir.exists(), isFalse);
      expect(console.logs.length, equals(1));
      expect(console.logs.first, startsWith('Cleaning ${targetDir.path}'));
    });

    test('does nothing if directory does not exist', () async {
      final targetDir = Directory('${tempDir.path}/non_existent');
      expect(await targetDir.exists(), isFalse);

      await DirectoryUtils.cleanDirectory(targetDir.path, console);

      expect(await targetDir.exists(), isFalse);
      expect(console.logs, isEmpty);
    });

    test('recursively deletes content in directory', () async {
      final targetDir = Directory('${tempDir.path}/to_clean_deep');
      await targetDir.create();
      final subDir = Directory('${targetDir.path}/subdir');
      await subDir.create();
      final file = File('${targetDir.path}/file.txt');
      await file.writeAsString('content');
      final subFile = File('${subDir.path}/subfile.txt');
      await subFile.writeAsString('subcontent');

      expect(await targetDir.exists(), isTrue);
      expect(await subDir.exists(), isTrue);
      expect(await file.exists(), isTrue);
      expect(await subFile.exists(), isTrue);

      await DirectoryUtils.cleanDirectory(targetDir.path, console);

      expect(await targetDir.exists(), isFalse);
      // If the parent is gone, children should be gone too.
      expect(await subDir.exists(), isFalse);
      expect(await file.exists(), isFalse);
      expect(await subFile.exists(), isFalse);
    });

    test('uses custom message if provided', () async {
      final targetDir = Directory('${tempDir.path}/custom_msg');
      await targetDir.create();

      await DirectoryUtils.cleanDirectory(
        targetDir.path,
        console,
        message: 'Removing',
      );

      expect(await targetDir.exists(), isFalse);
      expect(console.logs.length, equals(1));
      expect(console.logs.first, startsWith('Removing ${targetDir.path}'));
    });
  });
}
