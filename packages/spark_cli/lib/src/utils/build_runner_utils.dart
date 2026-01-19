import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../console/console_output.dart';
import '../io/process_runner.dart';
import '../parsers/build_runner_parser.dart';

/// Utilities for running build_runner.
class BuildRunnerUtils {
  final ProcessRunner _processRunner;
  final BuildRunnerParser _parser;
  final ConsoleOutput _console;
  final Directory _workingDirectory;

  BuildRunnerUtils({
    ProcessRunner processRunner = const ProcessRunnerImpl(),
    BuildRunnerParser? parser,
    ConsoleOutput? console,
    Directory? workingDirectory,
  }) : _processRunner = processRunner,
       _parser = parser ?? BuildRunnerParser(),
       _console = console ?? ConsoleOutput(),
       _workingDirectory = workingDirectory ?? Directory.current;

  BuildRunnerParser get parser => _parser;

  /// Runs `dart run build_runner build`.
  ///
  /// returns true if successful, false otherwise.
  Future<bool> runBuild({
    bool verbose = false,
    List<String> extraArgs = const [],
  }) async {
    _console.printInfo('Running code generation...');
    _parser.clear();

    final args = [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
      ...extraArgs,
    ];

    final process = await _processRunner.start(
      'dart',
      args,
      workingDirectory: _workingDirectory.path,
    );
    final exitCode = await _pipeProcessOutput(process, verbose: verbose);

    _parser.finalize();

    if (exitCode != 0) {
      _console.printError('Code generation failed.');
      return false;
    }

    _console.printSuccess('Code generation complete.');
    return true;
  }

  /// Runs `dart run build_runner watch`.
  ///
  /// Returns the started Process.
  Future<Process> startWatch({
    bool verbose = false,
    List<String> extraArgs = const [],
    void Function(String)? onLog,
  }) async {
    _console.printInfo('Starting build_runner...');

    final args = [
      'run',
      'build_runner',
      'watch',
      '--delete-conflicting-outputs',
      ...extraArgs,
    ];

    final process = await _processRunner.start(
      'dart',
      args,
      workingDirectory: _workingDirectory.path,
    );

    // We don't wait for exit here, but we do hook up listeners
    _pipeStream(process.stdout, verbose: verbose, onLog: onLog);
    _pipeStream(process.stderr, verbose: verbose, onLog: onLog);

    return process;
  }

  /// Pipes process output to parser and console.
  Future<int> _pipeProcessOutput(
    Process process, {
    bool verbose = false,
  }) async {
    final futures = <Future>[];
    futures.add(_pipeStream(process.stdout, verbose: verbose));
    futures.add(_pipeStream(process.stderr, verbose: verbose));

    await Future.wait(futures);
    return process.exitCode;
  }

  Future<void> _pipeStream(
    Stream<List<int>> stream, {
    bool verbose = false,
    void Function(String)? onLog,
  }) {
    final completer = Completer<void>();
    stream.transform(utf8.decoder).transform(const LineSplitter()).listen((
      line,
    ) {
      _parser.parseLine(line);
      if (verbose) {
        _console.printGray('  $line');
      }
      if (onLog != null) {
        onLog(line);
      }
    }, onDone: completer.complete);
    return completer.future;
  }
}
