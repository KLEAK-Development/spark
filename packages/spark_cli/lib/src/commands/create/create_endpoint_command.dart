import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

import '../../utils/naming_utils.dart';

class CreateEndpointCommand extends Command<void> {
  @override
  String get name => 'endpoint';

  @override
  String get description => 'Create a new endpoint.\n\n'
      'Usage: spark create endpoint <name>\n'
      'Example: spark create endpoint dashboard';

  @override
  Future<void> run() async {
    final args = argResults?.rest;
    if (args == null || args.isEmpty) {
      print('Please provide an endpoint name.');
      print('Usage: spark create endpoint <name>');
      return;
    }

    final input = args.first;
    final snakeName = toSnakeCase(input);
    final pascalName = toPascalCase(input);
    final kebabName = toKebabCase(input);

    final fileName = '${snakeName}_endpoint.dart';
    final filePath = p.join('lib', 'endpoints', fileName);

    final file = File(filePath);
    if (file.existsSync()) {
      print('File $filePath already exists.');
      return;
    }

    await file.create(recursive: true);
    await file.writeAsString(_endpointTemplate(pascalName, kebabName));

    print('Created endpoint ${pascalName}Endpoint at $filePath');
  }

  String _endpointTemplate(String pascalName, String kebabName) => '''
import 'package:spark_framework/spark.dart';

@Endpoint(path: '/api/$kebabName', method: 'GET')
class ${pascalName}Endpoint extends SparkEndpoint {
  @override
  Future<String> handler(SparkRequest request) async {
    return '${pascalName}Endpoint';
  }
}
''';
}
