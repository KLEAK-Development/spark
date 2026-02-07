import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../utils/naming_utils.dart';

class CreatePageCommand extends Command<void> {
  @override
  String get name => 'page';

  @override
  String get description => 'Create a new page.\n\n'
      'Usage: spark create page <name>\n'
      'Example: spark create page dashboard';

  @override
  Future<void> run() async {
    final args = argResults?.rest;
    if (args == null || args.isEmpty) {
      print('Please provide a page name.');
      print('Usage: spark create page <name>');
      return;
    }

    final input = args.first;
    final snakeName = toSnakeCase(input);
    final pascalName = toPascalCase(input);
    final kebabName = toKebabCase(input);

    final fileName = '${snakeName}_page.dart';
    final filePath = p.join('lib', 'pages', fileName);

    final file = File(filePath);
    if (file.existsSync()) {
      print('File $filePath already exists.');
      return;
    }

    await file.create(recursive: true);
    await file.writeAsString(_pageTemplate(pascalName, kebabName));

    print('Created page ${pascalName}Page at $filePath');
  }

  String _pageTemplate(String pascalName, String kebabName) => '''
import 'package:spark_framework/spark.dart';

@Page(path: '/$kebabName')
class ${pascalName}Page extends SparkPage<void> {
  @override
  Future<PageResponse<void>> loader(PageRequest request) async {
    return PageData(null);
  }

  @override
  Element render(void data, PageRequest request) {
    return div([
      h1('${pascalName}Page'),
    ]);
  }
}
''';
}
