import 'package:spark_cli/src/errors/dev_error_type.dart';
import 'package:spark_cli/src/parsers/build_runner_parser.dart';
import 'package:test/test.dart';

void main() {
  late BuildRunnerParser parser;

  setUp(() {
    parser = BuildRunnerParser();
  });

  group('BuildRunnerParser', () {
    group('initial state', () {
      test('starts with empty errors', () {
        expect(parser.errors, isEmpty);
      });

      test('errors list is unmodifiable', () {
        expect(() => (parser.errors as List).add(null), throwsUnsupportedError);
      });
    });

    group('SEVERE pattern', () {
      test('parses [SEVERE] with file, line, column, and message', () {
        parser.parseLine(
          '[SEVERE] lib/main.dart:10:5: Type mismatch',
        );
        parser.finalize();

        expect(parser.errors, hasLength(1));
        final error = parser.errors.first;
        expect(error.type, DevErrorType.build);
        expect(error.message, 'Type mismatch');
        expect(error.filePath, 'lib/main.dart');
        expect(error.line, 10);
        expect(error.column, 5);
      });

      test('handles deeply nested file paths', () {
        parser.parseLine(
          '[SEVERE] lib/src/pages/admin/users_page.dart:42:12: Missing return',
        );
        parser.finalize();

        expect(parser.errors, hasLength(1));
        expect(parser.errors.first.filePath, 'lib/src/pages/admin/users_page.dart');
        expect(parser.errors.first.line, 42);
        expect(parser.errors.first.column, 12);
        expect(parser.errors.first.message, 'Missing return');
      });
    });

    group('ERROR pattern', () {
      test('parses [ERROR] builder on package', () {
        parser.parseLine(
          '[ERROR] spark_generator on package:my_app/pages/home_page.dart:',
        );
        parser.finalize();

        expect(parser.errors, hasLength(1));
        final error = parser.errors.first;
        expect(error.type, DevErrorType.build);
        expect(error.message, 'spark_generator failed');
        expect(error.filePath, 'my_app/pages/home_page.dart');
      });
    });

    group('dart error with location', () {
      test('parses error: Message (at path:line:column)', () {
        parser.parseLine(
          'error: Undefined name (at lib/main.dart:5:3)',
        );

        expect(parser.errors, hasLength(1));
        final error = parser.errors.first;
        expect(error.type, DevErrorType.build);
        expect(error.message, 'Undefined name');
        expect(error.filePath, 'lib/main.dart');
        expect(error.line, 5);
        expect(error.column, 3);
      });
    });

    group('simple error pattern', () {
      test('parses error: Message', () {
        parser.parseLine('error: Missing semicolon');

        expect(parser.errors, hasLength(1));
        expect(parser.errors.first.message, 'Missing semicolon');
        expect(parser.errors.first.filePath, isNull);
      });
    });

    group('code generation failure', () {
      test('parses Could not generate pattern', () {
        parser.parseLine("Could not generate `home_page.g.dart`");

        expect(parser.errors, hasLength(1));
        expect(
          parser.errors.first.message,
          'Code generation failed for home_page.g.dart',
        );
      });
    });

    group('multi-line errors', () {
      test('accumulates context lines after SEVERE', () {
        parser.parseLine(
          '[SEVERE] lib/main.dart:10:5: Type mismatch',
        );
        parser.parseLine('  Expected: String');
        parser.parseLine('  Got: int');
        parser.parseLine(''); // empty line ends the block

        expect(parser.errors, hasLength(1));
        final error = parser.errors.first;
        expect(error.message, 'Type mismatch');
        expect(error.context, 'Expected: String\nGot: int');
      });

      test('flushes buffer when [INFO] line appears', () {
        parser.parseLine(
          '[SEVERE] lib/main.dart:1:1: Error happened',
        );
        parser.parseLine('  detail line');
        parser.parseLine('[INFO] Build completed');

        expect(parser.errors, hasLength(1));
        expect(parser.errors.first.context, 'detail line');
      });

      test('flushes buffer when [FINE] line appears', () {
        parser.parseLine(
          '[SEVERE] lib/main.dart:1:1: Error',
        );
        parser.parseLine('[FINE] some fine output');

        expect(parser.errors, hasLength(1));
      });

      test('flushes buffer when Succeeded appears', () {
        parser.parseLine(
          '[SEVERE] lib/main.dart:1:1: Error',
        );
        parser.parseLine('Succeeded after 1.2s');

        expect(parser.errors, hasLength(1));
      });

      test('flushes buffer when Building... appears', () {
        parser.parseLine(
          '[SEVERE] lib/main.dart:1:1: Error',
        );
        parser.parseLine('Building...');

        expect(parser.errors, hasLength(1));
      });

      test('handles no context (single-line SEVERE)', () {
        parser.parseLine(
          '[SEVERE] lib/main.dart:1:1: Simple error',
        );
        parser.parseLine('');

        expect(parser.errors, hasLength(1));
        expect(parser.errors.first.context, isNull);
      });
    });

    group('sequential errors', () {
      test('consecutive SEVERE lines flush previous error', () {
        parser.parseLine(
          '[SEVERE] lib/a.dart:1:1: First error',
        );
        parser.parseLine(
          '[SEVERE] lib/b.dart:2:2: Second error',
        );
        parser.finalize();

        expect(parser.errors, hasLength(2));
        expect(parser.errors[0].message, 'First error');
        expect(parser.errors[0].filePath, 'lib/a.dart');
        expect(parser.errors[1].message, 'Second error');
        expect(parser.errors[1].filePath, 'lib/b.dart');
      });

      test('mixed error patterns', () {
        parser.parseLine(
          '[SEVERE] lib/a.dart:1:1: Severe error',
        );
        parser.parseLine('');
        parser.parseLine('error: Simple error');
        parser.parseLine("Could not generate `main.g.dart`");

        expect(parser.errors, hasLength(3));
        expect(parser.errors[0].message, 'Severe error');
        expect(parser.errors[1].message, 'Simple error');
        expect(parser.errors[2].message, 'Code generation failed for main.g.dart');
      });
    });

    group('clear', () {
      test('removes all collected errors', () {
        parser.parseLine('error: Some error');
        expect(parser.errors, hasLength(1));

        parser.clear();
        expect(parser.errors, isEmpty);
      });

      test('resets multi-line error state', () {
        parser.parseLine(
          '[SEVERE] lib/main.dart:1:1: Error',
        );
        // Don't finalize - simulate clearing mid-error-block
        parser.clear();

        // Subsequent unrelated line should NOT be treated as continuation
        parser.parseLine('just some log line');
        parser.finalize();
        expect(parser.errors, isEmpty);
      });
    });

    group('finalize', () {
      test('flushes remaining buffered error', () {
        parser.parseLine(
          '[SEVERE] lib/main.dart:1:1: Buffered error',
        );
        parser.parseLine('  context line');
        // No empty line to trigger flush

        // Before finalize: buffer not flushed yet because no end-of-block indicator
        // After finalize: should flush
        parser.finalize();

        expect(parser.errors, hasLength(1));
        expect(parser.errors.first.message, 'Buffered error');
        expect(parser.errors.first.context, 'context line');
      });

      test('is safe to call when no buffered errors', () {
        parser.finalize();
        expect(parser.errors, isEmpty);
      });

      test('is safe to call multiple times', () {
        parser.parseLine('error: Once');
        parser.finalize();
        parser.finalize();
        expect(parser.errors, hasLength(1));
      });
    });

    group('non-matching lines', () {
      test('ignores regular log output', () {
        parser.parseLine('[INFO] Generating build script...');
        parser.parseLine('[FINE] Reading cached asset graph...');
        parser.parseLine('Succeeded after 1.2s with 0 outputs');
        parser.finalize();

        expect(parser.errors, isEmpty);
      });

      test('ignores empty lines when not in error block', () {
        parser.parseLine('');
        parser.parseLine('');
        parser.finalize();

        expect(parser.errors, isEmpty);
      });
    });
  });
}
