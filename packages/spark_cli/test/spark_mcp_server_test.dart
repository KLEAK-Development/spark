import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spark_cli/src/mcp/mcp_server.dart';
import 'package:spark_cli/src/mcp/spark_mcp_server.dart';
import 'package:test/test.dart';

void main() {
  group('createSparkMcpServer', () {
    late List<Map<String, Object?>> responses;
    late StreamController<String> inputController;
    late McpServer server;

    setUp(() {
      responses = [];
      inputController = StreamController<String>();
      server = createSparkMcpServer(
        input: inputController.stream,
        output: (line) {
          responses.add(jsonDecode(line) as Map<String, Object?>);
        },
      );
    });

    tearDown(() {
      inputController.close();
    });

    test('registers all six tools', () {
      expect(server.tools, hasLength(6));

      final names = server.tools.map((t) => t.name).toSet();
      expect(
        names,
        containsAll([
          'spark_init',
          'spark_dev',
          'spark_build',
          'spark_create_page',
          'spark_create_endpoint',
          'spark_create_component',
        ]),
      );
    });

    test('server name and version are set', () async {
      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {},
      });

      final result = responses.first['result'] as Map<String, Object?>;
      final serverInfo = result['serverInfo'] as Map<String, Object?>;
      expect(serverInfo['name'], 'spark-cli');
      expect(serverInfo['version'], '1.0.0-alpha.8');
    });
  });

  group('spark_init tool', () {
    late Directory tempDir;
    late Directory originalCwd;
    late McpServer server;
    late List<Map<String, Object?>> responses;

    setUp(() {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('spark_mcp_test_');
      Directory.current = tempDir;

      responses = [];
      server = createSparkMcpServer(
        input: const Stream.empty(),
        output: (line) {
          responses.add(jsonDecode(line) as Map<String, Object?>);
        },
      );
    });

    tearDown(() {
      Directory.current = originalCwd;
      tempDir.deleteSync(recursive: true);
    });

    Future<Map<String, Object?>> callTool(
      String name,
      Map<String, Object?> arguments,
    ) async {
      // Initialize first
      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {},
      });
      responses.clear();

      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {'name': name, 'arguments': arguments},
      });

      return responses.first['result'] as Map<String, Object?>;
    }

    test('creates a new project with all files', () async {
      final result = await callTool('spark_init', {'project_name': 'my_app'});

      expect(result['isError'], isNull);

      final content = result['content'] as List;
      final text = (content.first as Map)['text'] as String;
      expect(text, contains('my_app created successfully'));

      // Verify project files exist
      final projectDir = p.join(tempDir.path, 'my_app');
      expect(Directory(projectDir).existsSync(), isTrue);
      expect(File(p.join(projectDir, 'pubspec.yaml')).existsSync(), isTrue);
      expect(
        File(p.join(projectDir, 'bin', 'server.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(projectDir, 'lib', 'pages', 'home_page.dart')).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(projectDir, 'lib', 'endpoints', 'endpoints.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(projectDir, 'lib', 'components', 'counter.dart'),
        ).existsSync(),
        isTrue,
      );
      expect(File(p.join(projectDir, '.gitignore')).existsSync(), isTrue);
    });

    test('returns error for empty project name', () async {
      final result = await callTool('spark_init', {'project_name': ''});

      expect(result['isError'], true);
    });

    test('returns error when directory already exists', () async {
      Directory(p.join(tempDir.path, 'existing')).createSync();

      final result = await callTool('spark_init', {'project_name': 'existing'});

      expect(result['isError'], true);
      final text = ((result['content'] as List).first as Map)['text'] as String;
      expect(text, contains('already exists'));
    });

    test('generated pubspec contains project name', () async {
      await callTool('spark_init', {'project_name': 'test_proj'});

      final pubspec = File(p.join(tempDir.path, 'test_proj', 'pubspec.yaml'));
      final content = pubspec.readAsStringSync();
      expect(content, contains('name: test_proj'));
      expect(content, contains('spark_framework'));
    });
  });

  group('spark_create_page tool', () {
    late Directory tempDir;
    late Directory originalCwd;
    late McpServer server;
    late List<Map<String, Object?>> responses;

    setUp(() {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('spark_mcp_test_');
      Directory.current = tempDir;

      responses = [];
      server = createSparkMcpServer(
        input: const Stream.empty(),
        output: (line) {
          responses.add(jsonDecode(line) as Map<String, Object?>);
        },
      );
    });

    tearDown(() {
      Directory.current = originalCwd;
      tempDir.deleteSync(recursive: true);
    });

    Future<Map<String, Object?>> callTool(
      String name,
      Map<String, Object?> arguments,
    ) async {
      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {},
      });
      responses.clear();

      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {'name': name, 'arguments': arguments},
      });

      return responses.first['result'] as Map<String, Object?>;
    }

    test('creates a page with correct content', () async {
      final result = await callTool('spark_create_page', {'name': 'dashboard'});

      expect(result['isError'], isNull);

      final filePath = p.join(
        tempDir.path,
        'lib',
        'pages',
        'dashboard_page.dart',
      );
      expect(File(filePath).existsSync(), isTrue);

      final content = File(filePath).readAsStringSync();
      expect(content, contains("class DashboardPage extends SparkPage<void>"));
      expect(content, contains("@Page(path: '/dashboard')"));
    });

    test('creates a page from PascalCase input', () async {
      final result = await callTool('spark_create_page', {
        'name': 'UserProfile',
      });

      expect(result['isError'], isNull);

      final filePath = p.join(
        tempDir.path,
        'lib',
        'pages',
        'user_profile_page.dart',
      );
      expect(File(filePath).existsSync(), isTrue);

      final content = File(filePath).readAsStringSync();
      expect(
        content,
        contains("class UserProfilePage extends SparkPage<void>"),
      );
      expect(content, contains("@Page(path: '/user-profile')"));
    });

    test('supports working_directory argument', () async {
      final subDir = Directory(p.join(tempDir.path, 'subproject'));
      subDir.createSync();

      final result = await callTool('spark_create_page', {
        'name': 'home',
        'working_directory': subDir.path,
      });

      expect(result['isError'], isNull);

      final filePath = p.join(subDir.path, 'lib', 'pages', 'home_page.dart');
      expect(File(filePath).existsSync(), isTrue);
    });

    test('returns error when file already exists', () async {
      final dir = Directory(p.join(tempDir.path, 'lib', 'pages'));
      dir.createSync(recursive: true);
      File(
        p.join(dir.path, 'dashboard_page.dart'),
      ).writeAsStringSync('existing');

      final result = await callTool('spark_create_page', {'name': 'dashboard'});

      expect(result['isError'], true);
    });

    test('returns error for empty name', () async {
      final result = await callTool('spark_create_page', {'name': ''});
      expect(result['isError'], true);
    });
  });

  group('spark_create_endpoint tool', () {
    late Directory tempDir;
    late Directory originalCwd;
    late McpServer server;
    late List<Map<String, Object?>> responses;

    setUp(() {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('spark_mcp_test_');
      Directory.current = tempDir;

      responses = [];
      server = createSparkMcpServer(
        input: const Stream.empty(),
        output: (line) {
          responses.add(jsonDecode(line) as Map<String, Object?>);
        },
      );
    });

    tearDown(() {
      Directory.current = originalCwd;
      tempDir.deleteSync(recursive: true);
    });

    Future<Map<String, Object?>> callTool(
      String name,
      Map<String, Object?> arguments,
    ) async {
      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {},
      });
      responses.clear();

      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {'name': name, 'arguments': arguments},
      });

      return responses.first['result'] as Map<String, Object?>;
    }

    test('creates an endpoint with correct content', () async {
      final result = await callTool('spark_create_endpoint', {'name': 'users'});

      expect(result['isError'], isNull);

      final filePath = p.join(
        tempDir.path,
        'lib',
        'endpoints',
        'users_endpoint.dart',
      );
      expect(File(filePath).existsSync(), isTrue);

      final content = File(filePath).readAsStringSync();
      expect(content, contains("class UsersEndpoint extends SparkEndpoint"));
      expect(content, contains("@Endpoint(path: '/api/users', method: 'GET')"));
    });

    test('creates an endpoint from PascalCase input', () async {
      final result = await callTool('spark_create_endpoint', {
        'name': 'HealthCheck',
      });

      expect(result['isError'], isNull);

      final filePath = p.join(
        tempDir.path,
        'lib',
        'endpoints',
        'health_check_endpoint.dart',
      );
      expect(File(filePath).existsSync(), isTrue);

      final content = File(filePath).readAsStringSync();
      expect(
        content,
        contains("class HealthCheckEndpoint extends SparkEndpoint"),
      );
      expect(
        content,
        contains("@Endpoint(path: '/api/health-check', method: 'GET')"),
      );
    });

    test('returns error when file already exists', () async {
      final dir = Directory(p.join(tempDir.path, 'lib', 'endpoints'));
      dir.createSync(recursive: true);
      File(
        p.join(dir.path, 'users_endpoint.dart'),
      ).writeAsStringSync('existing');

      final result = await callTool('spark_create_endpoint', {'name': 'users'});

      expect(result['isError'], true);
    });

    test('returns error for empty name', () async {
      final result = await callTool('spark_create_endpoint', {'name': ''});
      expect(result['isError'], true);
    });
  });

  group('spark_create_component tool', () {
    late Directory tempDir;
    late Directory originalCwd;
    late McpServer server;
    late List<Map<String, Object?>> responses;

    setUp(() {
      originalCwd = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('spark_mcp_test_');
      Directory.current = tempDir;

      responses = [];
      server = createSparkMcpServer(
        input: const Stream.empty(),
        output: (line) {
          responses.add(jsonDecode(line) as Map<String, Object?>);
        },
      );
    });

    tearDown(() {
      Directory.current = originalCwd;
      tempDir.deleteSync(recursive: true);
    });

    Future<Map<String, Object?>> callTool(
      String name,
      Map<String, Object?> arguments,
    ) async {
      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {},
      });
      responses.clear();

      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {'name': name, 'arguments': arguments},
      });

      return responses.first['result'] as Map<String, Object?>;
    }

    test('creates a component with export and base files', () async {
      final result = await callTool('spark_create_component', {
        'name': 'my_counter',
      });

      expect(result['isError'], isNull);

      final exportFile = p.join(
        tempDir.path,
        'lib',
        'components',
        'my_counter',
        'my_counter.dart',
      );
      final baseFile = p.join(
        tempDir.path,
        'lib',
        'components',
        'my_counter',
        'my_counter_base.dart',
      );

      expect(File(exportFile).existsSync(), isTrue);
      expect(File(baseFile).existsSync(), isTrue);

      final exportContent = File(exportFile).readAsStringSync();
      expect(exportContent, contains("export 'my_counter_base.dart'"));

      final baseContent = File(baseFile).readAsStringSync();
      expect(baseContent, contains('class MyCounter'));
      expect(baseContent, contains("static const tag = 'my-counter'"));
    });

    test('creates a component from PascalCase input', () async {
      final result = await callTool('spark_create_component', {
        'name': 'NavBar',
      });

      expect(result['isError'], isNull);

      final baseFile = p.join(
        tempDir.path,
        'lib',
        'components',
        'nav_bar',
        'nav_bar_base.dart',
      );
      expect(File(baseFile).existsSync(), isTrue);

      final content = File(baseFile).readAsStringSync();
      expect(content, contains('class NavBar'));
      expect(content, contains("static const tag = 'nav-bar'"));
    });

    test('returns error for single-word name (invalid tag)', () async {
      final result = await callTool('spark_create_component', {
        'name': 'counter',
      });

      expect(result['isError'], true);

      final text = ((result['content'] as List).first as Map)['text'] as String;
      expect(text, contains('Invalid component name'));
    });

    test('returns error when directory already exists', () async {
      Directory(
        p.join(tempDir.path, 'lib', 'components', 'my_counter'),
      ).createSync(recursive: true);

      final result = await callTool('spark_create_component', {
        'name': 'my_counter',
      });

      expect(result['isError'], true);
    });

    test('returns error for empty name', () async {
      final result = await callTool('spark_create_component', {'name': ''});
      expect(result['isError'], true);
    });

    test('supports working_directory argument', () async {
      final subDir = Directory(p.join(tempDir.path, 'subproject'));
      subDir.createSync();

      final result = await callTool('spark_create_component', {
        'name': 'my_widget',
        'working_directory': subDir.path,
      });

      expect(result['isError'], isNull);

      final baseFile = p.join(
        subDir.path,
        'lib',
        'components',
        'my_widget',
        'my_widget_base.dart',
      );
      expect(File(baseFile).existsSync(), isTrue);
    });
  });

  group('spark_dev tool', () {
    late McpServer server;
    late List<Map<String, Object?>> responses;

    setUp(() {
      responses = [];
      server = createSparkMcpServer(
        input: const Stream.empty(),
        output: (line) {
          responses.add(jsonDecode(line) as Map<String, Object?>);
        },
      );
    });

    Future<Map<String, Object?>> callTool(
      String name,
      Map<String, Object?> arguments,
    ) async {
      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {},
      });
      responses.clear();

      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {'name': name, 'arguments': arguments},
      });

      return responses.first['result'] as Map<String, Object?>;
    }

    test('returns error for nonexistent directory', () async {
      final result = await callTool('spark_dev', {
        'working_directory': '/nonexistent/path',
      });

      expect(result['isError'], true);

      final text = ((result['content'] as List).first as Map)['text'] as String;
      expect(text, contains('does not exist'));
    });

    test('returns error when no pubspec.yaml exists', () async {
      final tempDir = Directory.systemTemp.createTempSync('spark_mcp_dev_');
      try {
        final result = await callTool('spark_dev', {
          'working_directory': tempDir.path,
        });

        expect(result['isError'], true);

        final text =
            ((result['content'] as List).first as Map)['text'] as String;
        expect(text, contains('pubspec.yaml'));
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });

  group('spark_build tool', () {
    late McpServer server;
    late List<Map<String, Object?>> responses;

    setUp(() {
      responses = [];
      server = createSparkMcpServer(
        input: const Stream.empty(),
        output: (line) {
          responses.add(jsonDecode(line) as Map<String, Object?>);
        },
      );
    });

    Future<Map<String, Object?>> callTool(
      String name,
      Map<String, Object?> arguments,
    ) async {
      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'initialize',
        'params': {},
      });
      responses.clear();

      await server.handleMessage({
        'jsonrpc': '2.0',
        'id': 2,
        'method': 'tools/call',
        'params': {'name': name, 'arguments': arguments},
      });

      return responses.first['result'] as Map<String, Object?>;
    }

    test('returns error for nonexistent directory', () async {
      final result = await callTool('spark_build', {
        'working_directory': '/nonexistent/path',
      });

      expect(result['isError'], true);

      final text = ((result['content'] as List).first as Map)['text'] as String;
      expect(text, contains('does not exist'));
    });
  });
}
