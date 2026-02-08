import 'dart:io';

import 'package:path/path.dart' as p;

import '../io/process_runner.dart';
import '../utils/naming_utils.dart';
import 'mcp_server.dart';

/// Creates and configures an MCP server with all Spark CLI tools registered.
McpServer createSparkMcpServer({
  required Stream<String> input,
  required McpOutputCallback output,
  ProcessRunner processRunner = const ProcessRunnerImpl(),
}) {
  final server = McpServer(
    name: 'spark-cli',
    version: '1.0.0-alpha.8',
    input: input,
    output: output,
  );

  server.addTool(_initTool(processRunner));
  server.addTool(_devTool(processRunner));
  server.addTool(_buildTool(processRunner));
  server.addTool(_createPageTool());
  server.addTool(_createEndpointTool());
  server.addTool(_createComponentTool());

  return server;
}

McpTool _initTool(ProcessRunner processRunner) {
  return McpTool(
    name: 'spark_init',
    description:
        'Initialize a new Spark project with all necessary scaffolding '
        'including pubspec.yaml, server entry point, example page, component, '
        'and endpoint.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'project_name': {
          'type': 'string',
          'description': 'The name of the project to create.',
        },
      },
      'required': ['project_name'],
    },
    handler: (args) async {
      final projectName = args['project_name'] as String?;
      if (projectName == null || projectName.isEmpty) {
        return McpToolResult(
          content: [McpContent.text('Error: project_name is required.')],
          isError: true,
        );
      }

      final projectDir = Directory(projectName);
      if (await projectDir.exists()) {
        return McpToolResult(
          content: [
            McpContent.text('Error: Directory $projectName already exists.'),
          ],
          isError: true,
        );
      }

      await projectDir.create(recursive: true);

      await _createFile(
        projectDir,
        'pubspec.yaml',
        _pubspecContent(projectName),
      );
      await _createFile(
        projectDir,
        'analysis_options.yaml',
        _analysisOptionsContent,
      );
      await _createFile(
        projectDir,
        'bin/server.dart',
        _serverContent(projectName),
      );
      await _createFile(
        projectDir,
        'lib/endpoints/endpoints.dart',
        _endpointsContent,
      );
      await _createFile(
        projectDir,
        'lib/components/counter.dart',
        _counterContent,
      );
      await _createFile(
        projectDir,
        'lib/components/counter_base.dart',
        _counterBaseContent,
      );
      await _createFile(
        projectDir,
        'lib/pages/home_page.dart',
        _homePageContent,
      );
      await _createFile(projectDir, '.gitignore', _gitignoreContent);

      return McpToolResult(
        content: [
          McpContent.text(
            'Project $projectName created successfully!\n'
            'Run the following commands to get started:\n'
            '  cd $projectName\n'
            '  dart pub get\n'
            '  spark dev',
          ),
        ],
      );
    },
  );
}

McpTool _devTool(ProcessRunner processRunner) {
  return McpTool(
    name: 'spark_dev',
    description:
        'Start the Spark development server with hot reload and live browser '
        'refresh. The server runs in the background.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'working_directory': {
          'type': 'string',
          'description':
              'The project directory to run the dev server in. '
              'Defaults to the current working directory.',
        },
      },
    },
    handler: (args) async {
      final workDir = args['working_directory'] as String? ?? '.';
      final dir = Directory(workDir);

      if (!await dir.exists()) {
        return McpToolResult(
          content: [
            McpContent.text('Error: Directory $workDir does not exist.'),
          ],
          isError: true,
        );
      }

      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (!await pubspec.exists()) {
        return McpToolResult(
          content: [
            McpContent.text(
              'Error: No pubspec.yaml found in $workDir. '
              'Is this a Dart project?',
            ),
          ],
          isError: true,
        );
      }

      try {
        final process = await processRunner.start('dart', [
          'run',
          'spark_cli:spark',
          'dev',
        ], workingDirectory: dir.path);

        // Don't await the process - it runs in the background.
        // Listen for early failures.
        final earlyOutput = StringBuffer();

        // Give the process a moment to start or fail immediately.
        final exitFuture = process.exitCode.then((code) => code);
        final timeout = Future.delayed(const Duration(seconds: 3), () => -1);
        final result = await Future.any([exitFuture, timeout]);

        if (result != -1) {
          // Process exited quickly - likely an error.
          return McpToolResult(
            content: [
              McpContent.text(
                'Dev server exited immediately with code $result.\n'
                '$earlyOutput',
              ),
            ],
            isError: true,
          );
        }

        return McpToolResult(
          content: [
            McpContent.text(
              'Dev server started in ${dir.path}.\n'
              'The server is running in the background with hot reload enabled.',
            ),
          ],
        );
      } catch (e) {
        return McpToolResult(
          content: [McpContent.text('Error starting dev server: $e')],
          isError: true,
        );
      }
    },
  );
}

McpTool _buildTool(ProcessRunner processRunner) {
  return McpTool(
    name: 'spark_build',
    description:
        'Build the Spark project for production. Runs code generation, '
        'compiles the server, compiles web assets, and copies static files.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'working_directory': {
          'type': 'string',
          'description':
              'The project directory to build. '
              'Defaults to the current working directory.',
        },
        'output': {
          'type': 'string',
          'description': 'Output directory path. Defaults to "build".',
        },
        'clean': {
          'type': 'boolean',
          'description':
              'Whether to clean the build directory before building. '
              'Defaults to true.',
        },
      },
    },
    handler: (args) async {
      final workDir = args['working_directory'] as String? ?? '.';
      final output = args['output'] as String? ?? 'build';
      final clean = args['clean'] as bool? ?? true;

      final dir = Directory(workDir);
      if (!await dir.exists()) {
        return McpToolResult(
          content: [
            McpContent.text('Error: Directory $workDir does not exist.'),
          ],
          isError: true,
        );
      }

      try {
        final cliArgs = <String>[
          'run',
          'spark_cli:spark',
          'build',
          '-o',
          output,
          if (!clean) '--no-clean',
        ];

        final result = await processRunner.run(
          'dart',
          cliArgs,
          workingDirectory: dir.path,
        );

        if (result.exitCode != 0) {
          return McpToolResult(
            content: [
              McpContent.text(
                'Build failed with exit code ${result.exitCode}.\n'
                '${result.stdout}\n${result.stderr}',
              ),
            ],
            isError: true,
          );
        }

        return McpToolResult(
          content: [
            McpContent.text('Build completed successfully.\n${result.stdout}'),
          ],
        );
      } catch (e) {
        return McpToolResult(
          content: [McpContent.text('Error running build: $e')],
          isError: true,
        );
      }
    },
  );
}

McpTool _createPageTool() {
  return McpTool(
    name: 'spark_create_page',
    description:
        'Create a new Spark page. Generates a page file in lib/pages/ '
        'with the appropriate template and route annotation.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'name': {
          'type': 'string',
          'description':
              'The page name. Accepts PascalCase, camelCase, or snake_case '
              '(e.g., "dashboard", "UserProfile", "user_settings").',
        },
        'working_directory': {
          'type': 'string',
          'description':
              'The project directory. Defaults to the current working directory.',
        },
      },
      'required': ['name'],
    },
    handler: (args) async {
      final name = args['name'] as String?;
      if (name == null || name.isEmpty) {
        return McpToolResult(
          content: [McpContent.text('Error: name is required.')],
          isError: true,
        );
      }

      final workDir = args['working_directory'] as String? ?? '.';
      final snakeName = toSnakeCase(name);
      final pascalName = toPascalCase(name);
      final kebabName = toKebabCase(name);

      final fileName = '${snakeName}_page.dart';
      final filePath = p.join(workDir, 'lib', 'pages', fileName);

      final file = File(filePath);
      if (file.existsSync()) {
        return McpToolResult(
          content: [McpContent.text('Error: File $filePath already exists.')],
          isError: true,
        );
      }

      await file.create(recursive: true);
      await file.writeAsString(_pageTemplate(pascalName, kebabName));

      return McpToolResult(
        content: [
          McpContent.text('Created page ${pascalName}Page at $filePath'),
        ],
      );
    },
  );
}

McpTool _createEndpointTool() {
  return McpTool(
    name: 'spark_create_endpoint',
    description:
        'Create a new Spark API endpoint. Generates an endpoint file in '
        'lib/endpoints/ with the appropriate template and route annotation.',
    inputSchema: {
      'type': 'object',
      'properties': {
        'name': {
          'type': 'string',
          'description':
              'The endpoint name. Accepts PascalCase, camelCase, or snake_case '
              '(e.g., "users", "UserProfile", "health_check").',
        },
        'working_directory': {
          'type': 'string',
          'description':
              'The project directory. Defaults to the current working directory.',
        },
      },
      'required': ['name'],
    },
    handler: (args) async {
      final name = args['name'] as String?;
      if (name == null || name.isEmpty) {
        return McpToolResult(
          content: [McpContent.text('Error: name is required.')],
          isError: true,
        );
      }

      final workDir = args['working_directory'] as String? ?? '.';
      final snakeName = toSnakeCase(name);
      final pascalName = toPascalCase(name);
      final kebabName = toKebabCase(name);

      final fileName = '${snakeName}_endpoint.dart';
      final filePath = p.join(workDir, 'lib', 'endpoints', fileName);

      final file = File(filePath);
      if (file.existsSync()) {
        return McpToolResult(
          content: [McpContent.text('Error: File $filePath already exists.')],
          isError: true,
        );
      }

      await file.create(recursive: true);
      await file.writeAsString(_endpointTemplate(pascalName, kebabName));

      return McpToolResult(
        content: [
          McpContent.text(
            'Created endpoint ${pascalName}Endpoint at $filePath',
          ),
        ],
      );
    },
  );
}

McpTool _createComponentTool() {
  return McpTool(
    name: 'spark_create_component',
    description:
        'Create a new Spark web component. Generates component files in '
        'lib/components/<name>/ with the export wrapper and base template. '
        'The name must produce a valid custom element tag (requires a hyphen), '
        'so use multi-word names like "my_counter" or "MyCounter".',
    inputSchema: {
      'type': 'object',
      'properties': {
        'name': {
          'type': 'string',
          'description':
              'The component name. Must be multi-word to produce a valid '
              'custom element tag with a hyphen '
              '(e.g., "my_counter", "MyCounter", "NavBar").',
        },
        'working_directory': {
          'type': 'string',
          'description':
              'The project directory. Defaults to the current working directory.',
        },
      },
      'required': ['name'],
    },
    handler: (args) async {
      final name = args['name'] as String?;
      if (name == null || name.isEmpty) {
        return McpToolResult(
          content: [McpContent.text('Error: name is required.')],
          isError: true,
        );
      }

      if (!isValidComponentName(name)) {
        return McpToolResult(
          content: [
            McpContent.text(
              'Error: Invalid component name: "$name".\n'
              'Web component tag names must contain a hyphen (-).\n'
              'A single word like "$name" cannot produce a valid tag.\n'
              'Use a multi-word name like "${name}_example" or '
              '"${name[0].toUpperCase()}${name.substring(1)}App".',
            ),
          ],
          isError: true,
        );
      }

      final workDir = args['working_directory'] as String? ?? '.';
      final snakeName = toSnakeCase(name);
      final pascalName = toPascalCase(name);
      final kebabName = toKebabCase(name);

      final componentDir = p.join(workDir, 'lib', 'components', snakeName);
      final exportFile = p.join(componentDir, '$snakeName.dart');
      final baseFile = p.join(componentDir, '${snakeName}_base.dart');

      final dir = Directory(componentDir);
      if (dir.existsSync()) {
        return McpToolResult(
          content: [
            McpContent.text('Error: Directory $componentDir already exists.'),
          ],
          isError: true,
        );
      }

      final export = File(exportFile);
      await export.create(recursive: true);
      await export.writeAsString(_exportTemplate(snakeName));

      final base = File(baseFile);
      await base.create(recursive: true);
      await base.writeAsString(_baseTemplate(pascalName, kebabName));

      return McpToolResult(
        content: [
          McpContent.text(
            'Created component $pascalName at:\n'
            '  $exportFile\n'
            '  $baseFile',
          ),
        ],
      );
    },
  );
}

// --- File creation helper ---

Future<void> _createFile(
  Directory projectDir,
  String path,
  String content,
) async {
  final file = File(p.join(projectDir.path, path));
  await file.create(recursive: true);
  await file.writeAsString(content);
}

// --- Templates (matching the existing CLI commands) ---

String _pubspecContent(String name) =>
    '''
name: $name
description: A new Spark project.
version: 0.0.1
publish_to: none

environment:
  sdk: ^3.10.0

dependencies:
  spark_framework: ^1.0.0-alpha.5
  shelf: ^1.4.1

dev_dependencies:
  build_runner: ^2.11.0
  build_web_compilers: ^4.4.7
  lints: ^6.0.0
  test: ^1.24.0
  spark_generator: ^1.0.0-alpha.11
''';

const _analysisOptionsContent = '''
include: package:lints/recommended.yaml
''';

String _serverContent(String projectName) => '''
import 'package:spark_framework/spark.dart';
import 'package:spark_framework/server.dart';
import 'package:\$projectName/spark_router.g.dart';

void main() async {
  final server = await createSparkServer(
    SparkServerConfig(
      port: 8080,
    ),
  );
  print('Server running at http://localhost:\${server.port}');
}
''';

const _endpointsContent = '''
import 'package:spark_framework/spark.dart';

@Endpoint(path: '/api/hello', method: 'GET')
class HealthEndpoint extends SparkEndpoint {
  @override
  Future<String> handler(SparkRequest request) async {
    return 'Hello from Spark!';
  }
}
''';

const _counterContent = '''
export 'counter_base.dart'
    if (dart.library.html) 'counter_base.impl.dart'
    if (dart.library.io) 'counter_base.impl.dart';
''';

const _counterBaseContent = '''
import 'package:spark_framework/spark.dart';


@Component(tag: Counter.tag)
class Counter {
  Counter({this.count = 0, this.label = 'Count'});

  static const tag = 'my-counter';

  String get tagName => tag;

  @Attribute()
  int count;

  @Attribute()
  String label;

  Element render() {
    return div([
      style([
        css({
          ':host': .typed(
            display: .inlineBlock,
            padding: .all(.px(16)),
            border: CssBorder(
              width: .px(1),
              style: .solid,
              color: .hex('#ccc'),
            ),
            borderRadius: .px(8),
            fontFamily: .raw('sans-serif'),
          ),
          'button': .typed(
            cursor: .pointer,
            padding: .symmetric(.px(4), .px(8)),
            margin: .symmetric(.px(4), .px(0)),
          ),
        }).toCss(),
      ]),
      span([label, ': ']),
      span(id: 'val', [count]),
      button(
        id: 'inc',
        onClick: (_) {
          count++;
        },
        ['+'],
      ),
      button(
        id: 'dec',
        onClick: (_) {
          count--;
        },
        ['-'],
      ),
    ]);
  }
}
''';

const _homePageContent = '''
import 'package:spark_framework/spark.dart';
import '../components/counter.dart';

class HomePageState {
  final String message;
  HomePageState(this.message);
}

@Page(path: '/')
class HomePage extends SparkPage<HomePageState> {
  @override
  Future<PageResponse<HomePageState>> loader(PageRequest request) async {
    return PageData(HomePageState('Welcome to Spark!'));
  }

  @override
  Element render(HomePageState state, PageRequest request) {
    return div(
      className: 'container',
      [
        h1(state.message),
        p('You have successfully created a new Spark project.'),
        Counter(count: 10, label: 'My Counter').render(),
      ],
    );
  }

  @override
  Stylesheet? get inlineStyles => css({
        '.container': .typed(
          fontFamily: .raw('system-ui, sans-serif'),
          textAlign: .center,
          padding: .all(.px(32)),
        ),
      });

  @override
  List<Type> get components => [
        Counter,
      ];
}
''';

const _gitignoreContent = '''
.dart_tool/
build/
.packages
.pub/
pubspec.lock
''';

String _pageTemplate(String pascalName, String kebabName) =>
    '''
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

String _endpointTemplate(String pascalName, String kebabName) =>
    '''
import 'package:spark_framework/spark.dart';

@Endpoint(path: '/api/$kebabName', method: 'GET')
class ${pascalName}Endpoint extends SparkEndpoint {
  @override
  Future<String> handler(SparkRequest request) async {
    return '${pascalName}Endpoint';
  }
}
''';

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
