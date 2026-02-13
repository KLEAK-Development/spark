import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;

class InitCommand extends Command<void> {
  @override
  String get name => 'init';

  @override
  String get description => 'Initialize a new Spark project.';

  @override
  Future<void> run() async {
    final args = argResults?.rest;
    if (args == null || args.isEmpty) {
      print('Please provide a project name.');
      return;
    }

    final projectName = args.first;
    final projectDir = Directory(projectName);

    if (await projectDir.exists()) {
      print('Directory $projectName already exists.');
      return;
    }

    print('Creating project $projectName...');
    await projectDir.create(recursive: true);

    await _createFile(projectDir, 'pubspec.yaml', _pubspecContent(projectName));
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
    await _createFile(projectDir, 'lib/pages/home_page.dart', _homePageContent);
    await _createFile(projectDir, '.gitignore', _gitignoreContent);

    print('Project $projectName created successfully!');
    print('Run the following commands to get started:');
    print('  cd $projectName');
    print('  dart pub get');
    print('  spark dev');
  }

  Future<void> _createFile(
    Directory projectDir,
    String path,
    String content,
  ) async {
    final file = File(p.join(projectDir.path, path));
    await file.create(recursive: true);
    await file.writeAsString(content);
  }

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

  final _analysisOptionsContent = '''
include: package:lints/recommended.yaml
''';

  String _serverContent(String projectName) =>
      '''
import 'package:spark_framework/spark.dart';
import 'package:spark_framework/server.dart';
import 'package:$projectName/spark_router.g.dart';

void main() async {
  final server = await createSparkServer(
    SparkServerConfig(
      port: 8080,
    ),
  );
  print('Server running at http://localhost:\${server.port}');
}
''';

  final _endpointsContent = '''
import 'package:spark_framework/spark.dart';

@Endpoint(path: '/api/hello', method: 'GET')
class HealthEndpoint extends SparkEndpoint {
  @override
  Future<String> handler(SparkRequest request) async {
    return 'Hello from Spark!';
  }
}
''';

  final _counterContent = '''
export 'counter_base.dart'
    if (dart.library.html) 'counter_base.impl.dart'
    if (dart.library.io) 'counter_base.impl.dart';
''';

  final _counterBaseContent = '''
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

  Stylesheet get adoptedStyleSheets => css({
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
  });


  Element render() {
    return div([
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

  final _homePageContent = '''
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

  final _gitignoreContent = '''
.dart_tool/
build/
.packages
.pub/
pubspec.lock
''';
}
