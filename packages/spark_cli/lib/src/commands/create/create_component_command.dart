import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../utils/naming_utils.dart';

class CreateComponentCommand extends Command<void> {
  @override
  String get name => 'component';

  @override
  String get description =>
      'Create a new web component.\n\n'
      'Usage: spark create component <name>\n'
      'Example: spark create component my_counter\n\n'
      'The name must produce a valid custom element tag (requires a hyphen).\n'
      'Use PascalCase (MyCounter) or snake_case (my_counter) with at least two words.';

  @override
  Future<void> run() async {
    final args = argResults?.rest;
    if (args == null || args.isEmpty) {
      print('Please provide a component name.');
      print('Usage: spark create component <name>');
      return;
    }

    final input = args.first;

    if (!isValidComponentName(input)) {
      print(
        'Invalid component name: "$input".\n'
        'Web component tag names must contain a hyphen (-).\n'
        'A single word like "$input" cannot produce a valid tag.\n'
        'Use a multi-word name like "${input}_example" or "${input[0].toUpperCase()}${input.substring(1)}App".',
      );
      return;
    }

    final snakeName = toSnakeCase(input);
    final pascalName = toPascalCase(input);
    final kebabName = toKebabCase(input);

    final componentDir = p.join('lib', 'components', snakeName);
    final exportFile = p.join(componentDir, '$snakeName.dart');
    final baseFile = p.join(componentDir, '${snakeName}_base.dart');

    final dir = Directory(componentDir);
    if (dir.existsSync()) {
      print('Directory $componentDir already exists.');
      return;
    }

    final export = File(exportFile);
    await export.create(recursive: true);
    await export.writeAsString(_exportTemplate(snakeName));

    final base = File(baseFile);
    await base.create(recursive: true);
    await base.writeAsString(_baseTemplate(pascalName, kebabName));

    print('Created component $pascalName at:');
    print('  $exportFile');
    print('  $baseFile');
  }

  String _exportTemplate(String snakeName) =>
      '''
export '${snakeName}_base.dart'
    if (dart.library.html) '${snakeName}_base.impl.dart'
    if (dart.library.io) '${snakeName}_base.impl.dart';
''';

  String _baseTemplate(String pascalName, String kebabName) =>
      '''
import 'package:spark_framework/spark.dart';

@Component(tag: $pascalName.tag)
class $pascalName {
  $pascalName();

  static const tag = '$kebabName';

  String get tagName => tag;

  Element render() {
    return div([
      h1('$pascalName'),
    ]);
  }
}
''';
}
