import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../console/console_output.dart';
import '../io/process_runner.dart';
import '../utils/build_runner_utils.dart';
import '../utils/directory_utils.dart';

/// Builds the Spark project for production with optimized output.
class BuildCommand extends Command<void> {
  @override
  String get name => 'build';

  @override
  String get description => 'Build the Spark project for production.';

  final ConsoleOutput _console = ConsoleOutput();
  late final BuildRunnerUtils _buildUtils;
  final ProcessRunner _processRunner;
  final Directory _workingDirectory;

  BuildCommand({
    ProcessRunner processRunner = const ProcessRunnerImpl(),
    Directory? workingDirectory,
  }) : _processRunner = processRunner,
       _workingDirectory = workingDirectory ?? Directory.current {
    _buildUtils = BuildRunnerUtils(
      processRunner: processRunner,
      console: _console,
      workingDirectory: _workingDirectory,
    );
    argParser.addFlag(
      'clean',
      defaultsTo: true,
      help: 'Clean build directory before building.',
    );
    argParser.addFlag('verbose', abbr: 'v', help: 'Show verbose build output.');
    argParser.addOption(
      'output',
      abbr: 'o',
      defaultsTo: 'build',
      help: 'Output directory path.',
    );
  }

  @override
  Future<void> run() async {
    final stopwatch = Stopwatch()..start();
    final outputDir = p.join(
      _workingDirectory.path,
      argResults!['output'] as String,
    );
    final clean = argResults!['clean'] as bool;
    final verbose = argResults!['verbose'] as bool;

    _console.printInfo('Building Spark project for production...');
    _console.printLine();

    try {
      // Phase 1: Clean build directory
      if (clean) {
        await DirectoryUtils.cleanDirectory(outputDir, _console);
      }

      // Phase 2: Run build_runner for code generation
      if (!await _buildUtils.runBuild(verbose: verbose)) {
        _printErrors();
        exit(1);
      }

      // Phase 3: Compile server executable
      if (!await _compileServer(outputDir)) {
        exit(1);
      }

      // Phase 4: Compile web entry points
      if (!await _compileWebEntryPoints(outputDir, verbose)) {
        exit(1);
      }

      // Phase 5: Copy static assets
      await _copyStaticAssets(outputDir);

      // Phase 6: Clean up development artifacts
      await _cleanupArtifacts(outputDir);

      // Success
      stopwatch.stop();
      _printBuildSummary(outputDir, stopwatch.elapsed);
    } catch (e, st) {
      _console.printError('Build failed: $e');
      if (verbose) {
        _console.printGray(st.toString());
      }
      exit(1);
    }
  }

  /// Phase 3: Compile the server executable.
  Future<bool> _compileServer(String outputDir) async {
    _console.printInfo('Compiling server...');

    // Ensure output directory exists
    final dir = Directory(outputDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    // Use 'dart build cli' for bin/server.dart
    final tempBuildDir = p.join(outputDir, 'server_build');

    if (!await _runServerCompilation(tempBuildDir)) {
      return false;
    }

    if (!await _processServerBundle(outputDir, tempBuildDir)) {
      return false;
    }

    // Cleanup temporary build directory
    await DirectoryUtils.cleanDirectory(
      tempBuildDir,
      _console,
      message: 'Cleaning temp',
    );

    _console.printSuccess('Server compiled.');
    return true;
  }

  Future<bool> _runServerCompilation(String tempBuildDir) async {
    final binaryName = Platform.isWindows ? 'server.exe' : 'server';
    final outputBinPath = p.join(tempBuildDir, 'bundle', 'bin', binaryName);

    final outputDir = Directory(p.dirname(outputBinPath));
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final process = await _processRunner.run('dart', [
      'build',
      'cli',
      '--target=bin/server.dart',
      '--output=$tempBuildDir',
    ], workingDirectory: _workingDirectory.path);

    if (process.exitCode != 0) {
      _console.printError('Server compilation failed:');
      _console.printGray(process.stderr.toString());
      return false;
    }
    return true;
  }

  Future<bool> _processServerBundle(
    String outputDir,
    String tempBuildDir,
  ) async {
    // The output is in <tempBuildDir>/bundle/bin/<executable>
    final binaryName = Platform.isWindows ? 'server.exe' : 'server';
    final generatedBinary = File(
      p.join(tempBuildDir, 'bundle', 'bin', binaryName),
    );

    if (!await generatedBinary.exists()) {
      _console.printError(
        'Server compilation succeeded but binary not found at ${generatedBinary.path}.',
      );
      return false;
    }

    // Create bin directory for server binary
    final binDir = Directory(p.join(outputDir, 'bin'));
    if (!await binDir.exists()) {
      await binDir.create(recursive: true);
    }
    final targetPath = p.join(outputDir, 'bin', binaryName);

    // Copy generated binary to final location
    await generatedBinary.copy(targetPath);

    // Copy native libraries from bundle/lib/ if they exist
    await _copyNativeLibraries(outputDir, tempBuildDir);

    return true;
  }

  Future<void> _copyNativeLibraries(
    String outputDir,
    String tempBuildDir,
  ) async {
    final bundleLibDir = Directory(p.join(tempBuildDir, 'bundle', 'lib'));
    if (await bundleLibDir.exists()) {
      final targetLibDir = Directory(p.join(outputDir, 'lib'));
      await targetLibDir.create(recursive: true);
      await for (final entity in bundleLibDir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = p.relative(entity.path, from: bundleLibDir.path);
          final targetPath = p.join(targetLibDir.path, relativePath);
          await Directory(p.dirname(targetPath)).create(recursive: true);
          await entity.copy(targetPath);
        }
      }
      _console.printGray('  Copied native libraries.');
    }
  }

  /// Phase 4: Compile web entry points with dart2js.
  Future<bool> _compileWebEntryPoints(String outputDir, bool verbose) async {
    final webDir = Directory(p.join(_workingDirectory.path, 'web'));
    if (!await webDir.exists()) {
      _console.printWarning(
        'No web/ directory found, skipping web compilation.',
      );
      return true;
    }

    _console.printInfo('Compiling web assets...');

    // Find all .dart files in web/ directory
    final entries = await webDir
        .list(recursive: true)
        .where((e) => e is File && e.path.endsWith('.dart'))
        .cast<File>()
        .toList();

    if (entries.isEmpty) {
      _console.printWarning('No Dart files in web/, skipping web compilation.');
      return true;
    }

    // Create output web directory
    final webOutputDir = Directory('$outputDir/web');
    if (!await webOutputDir.exists()) {
      await webOutputDir.create(recursive: true);
    }

    for (final entry in entries) {
      final relativePath = p.relative(entry.path, from: webDir.path);
      final relativePathWithoutExt = p.withoutExtension(relativePath);
      final outputPath = p.join(
        outputDir,
        'web',
        '$relativePathWithoutExt.dart.js',
      );

      // Ensure output directory exists
      final outputDirFile = File(outputPath);
      if (!await outputDirFile.parent.exists()) {
        await outputDirFile.parent.create(recursive: true);
      }

      _console.printGray('  Compiling $relativePath...');

      final process = await _processRunner.run('dart', [
        'compile',
        'js',
        '-O2', // Production optimizations
        '-o',
        outputPath,
        entry.path,
      ], workingDirectory: _workingDirectory.path);

      if (process.exitCode != 0) {
        _console.printError('Failed to compile ${entry.path}:');
        _console.printGray(process.stderr.toString());
        return false;
      }

      if (verbose) {
        final size = await File(outputPath).length();
        _console.printGray('    Output: ${_formatSize(size)}');
      }
    }

    _console.printSuccess(
      'Web assets compiled (${entries.length} file${entries.length == 1 ? '' : 's'}).',
    );
    return true;
  }

  /// Phase 5: Copy static assets from web/.
  Future<void> _copyStaticAssets(String outputDir) async {
    final webDir = Directory(p.join(_workingDirectory.path, 'web'));
    if (!await webDir.exists()) {
      return;
    }

    _console.printInfo('Copying static assets...');

    final targetDir = Directory('$outputDir/web');
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    var count = 0;
    await for (final entity in webDir.list(recursive: true)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: webDir.path);

        // Skip Dart files (handled by compilation)
        if (relativePath.endsWith('.dart')) continue;

        // Skip hidden files and directories (start with .)
        if (p.split(relativePath).any((part) => part.startsWith('.'))) continue;

        final targetPath = p.join(targetDir.path, relativePath);

        await Directory(p.dirname(targetPath)).create(recursive: true);
        await entity.copy(targetPath);
        count++;
      }
    }

    _console.printSuccess('Copied $count asset${count == 1 ? '' : 's'}.');
  }

  /// Phase 6: Clean up development artifacts.
  Future<void> _cleanupArtifacts(String outputDir) async {
    _console.printGray('Cleaning up development artifacts...');

    // Files and directories to remove
    final toRemove = [
      '$outputDir/packages',
      '$outputDir/.build.manifest',
      '$outputDir/pubspec.yaml',
      '$outputDir/.dart_tool',
    ];

    for (final path in toRemove) {
      final type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: true);
      } else if (type == FileSystemEntityType.file) {
        await File(path).delete();
      } else if (type == FileSystemEntityType.link) {
        await Link(path).delete();
      }
    }

    // Remove symlink in web/packages if it exists
    final webPackagesLink = Link('$outputDir/web/packages');
    if (await webPackagesLink.exists()) {
      await webPackagesLink.delete();
    }
  }

  /// Print collected build errors.
  void _printErrors() {
    final errors = _buildUtils.parser.errors;
    if (errors.isEmpty) return;

    _console.printLine();
    _console.printError('Build errors:');
    for (final error in errors) {
      _console.printError('  ${error.message}');
      if (error.filePath != null) {
        _console.printGray(
          '    at ${error.filePath}:${error.line ?? '?'}:${error.column ?? '?'}',
        );
      }
    }
  }

  /// Print the build summary.
  void _printBuildSummary(String outputDir, Duration elapsed) async {
    _console.printLine();
    _console.printSuccess('Build complete!');
    _console.printLine();
    _console.printInfo('Output: $outputDir/');

    // List output files
    final dir = Directory(outputDir);
    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final relativePath = p.relative(entity.path, from: outputDir);
          final size = await entity.length();
          _console.printGray('  $relativePath (${_formatSize(size)})');
        }
      }
    }

    _console.printLine();
    _console.printGray('Completed in ${elapsed.inSeconds}s');
  }

  /// Format file size in human-readable form.
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
