import 'dart:async';
import 'dart:convert';

import 'package:spark_cli/src/mcp/mcp_server.dart';
import 'package:test/test.dart';

void main() {
  group('McpServer', () {
    late List<Map<String, Object?>> responses;
    late StreamController<String> inputController;
    late McpServer server;

    setUp(() {
      responses = [];
      inputController = StreamController<String>();
      server = McpServer(
        name: 'test-server',
        version: '0.1.0',
        input: inputController.stream,
        output: (line) {
          responses.add(jsonDecode(line) as Map<String, Object?>);
        },
      );
    });

    tearDown(() {
      inputController.close();
    });

    group('initialize', () {
      test('responds with server info and capabilities', () async {
        await server.handleMessage({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'initialize',
          'params': {
            'protocolVersion': '2024-11-05',
            'capabilities': {},
            'clientInfo': {'name': 'test-client', 'version': '1.0.0'},
          },
        });

        expect(responses, hasLength(1));

        final result = responses.first['result'] as Map<String, Object?>;
        expect(result['protocolVersion'], '2024-11-05');
        expect(result['serverInfo'], {
          'name': 'test-server',
          'version': '0.1.0',
        });
        expect(result['capabilities'], containsPair('tools', isA<Map>()));
      });
    });

    group('ping', () {
      test('responds with empty result', () async {
        await server.handleMessage({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'ping',
        });

        expect(responses, hasLength(1));
        expect(responses.first['result'], isEmpty);
      });
    });

    group('notifications', () {
      test('does not respond to notifications (no id)', () async {
        await server.handleMessage({
          'jsonrpc': '2.0',
          'method': 'notifications/initialized',
        });

        expect(responses, isEmpty);
      });
    });

    group('tools/list', () {
      test('returns error when not initialized', () async {
        await server.handleMessage({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'tools/list',
        });

        expect(responses, hasLength(1));
        expect(responses.first['error'], isNotNull);

        final error = responses.first['error'] as Map<String, Object?>;
        expect(error['code'], -32002);
      });

      test('returns empty tools list when no tools registered', () async {
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
          'method': 'tools/list',
        });

        expect(responses, hasLength(1));

        final result = responses.first['result'] as Map<String, Object?>;
        expect(result['tools'], isEmpty);
      });

      test('returns registered tools', () async {
        server.addTool(
          McpTool(
            name: 'test_tool',
            description: 'A test tool',
            inputSchema: {
              'type': 'object',
              'properties': {
                'input': {'type': 'string'},
              },
            },
            handler: (_) async =>
                McpToolResult(content: [McpContent.text('ok')]),
          ),
        );

        // Initialize
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
          'method': 'tools/list',
        });

        final result = responses.first['result'] as Map<String, Object?>;
        final tools = result['tools'] as List;
        expect(tools, hasLength(1));
        expect((tools.first as Map)['name'], 'test_tool');
        expect((tools.first as Map)['description'], 'A test tool');
      });
    });

    group('tools/call', () {
      setUp(() {
        server.addTool(
          McpTool(
            name: 'echo',
            description: 'Echoes the input',
            inputSchema: {
              'type': 'object',
              'properties': {
                'message': {'type': 'string'},
              },
              'required': ['message'],
            },
            handler: (args) async {
              final message = args['message'] as String;
              return McpToolResult(
                content: [McpContent.text('Echo: $message')],
              );
            },
          ),
        );

        server.addTool(
          McpTool(
            name: 'fail',
            description: 'Always fails',
            inputSchema: {'type': 'object'},
            handler: (_) async => throw Exception('intentional failure'),
          ),
        );
      });

      test('returns error when not initialized', () async {
        await server.handleMessage({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'tools/call',
          'params': {
            'name': 'echo',
            'arguments': {'message': 'hi'},
          },
        });

        expect(responses.first['error'], isNotNull);
      });

      test('calls a tool and returns the result', () async {
        // Initialize
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
          'params': {
            'name': 'echo',
            'arguments': {'message': 'hello'},
          },
        });

        expect(responses, hasLength(1));

        final result = responses.first['result'] as Map<String, Object?>;
        final content = result['content'] as List;
        expect((content.first as Map)['text'], 'Echo: hello');
        expect(result['isError'], isNull);
      });

      test('returns error for unknown tool', () async {
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
          'params': {'name': 'nonexistent'},
        });

        final error = responses.first['error'] as Map<String, Object?>;
        expect(error['code'], -32602);
        expect(error['message'], contains('nonexistent'));
      });

      test('returns error when params are missing', () async {
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
        });

        final error = responses.first['error'] as Map<String, Object?>;
        expect(error['code'], -32602);
      });

      test('returns error when tool name is missing', () async {
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
          'params': {'arguments': {}},
        });

        final error = responses.first['error'] as Map<String, Object?>;
        expect(error['code'], -32602);
      });

      test('handles tool handler exceptions as error results', () async {
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
          'params': {'name': 'fail'},
        });

        final result = responses.first['result'] as Map<String, Object?>;
        expect(result['isError'], true);

        final content = result['content'] as List;
        expect((content.first as Map)['text'], contains('intentional failure'));
      });

      test('defaults to empty arguments when not provided', () async {
        server.addTool(
          McpTool(
            name: 'no_args',
            description: 'No arguments needed',
            inputSchema: {'type': 'object'},
            handler: (args) async => McpToolResult(
              content: [McpContent.text('args: ${args.length}')],
            ),
          ),
        );

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
          'params': {'name': 'no_args'},
        });

        final result = responses.first['result'] as Map<String, Object?>;
        final content = result['content'] as List;
        expect((content.first as Map)['text'], 'args: 0');
      });
    });

    group('unknown method', () {
      test('returns method not found error', () async {
        await server.handleMessage({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'unknown/method',
        });

        final error = responses.first['error'] as Map<String, Object?>;
        expect(error['code'], -32601);
        expect(error['message'], contains('unknown/method'));
      });
    });

    group('run (stream-based)', () {
      test('processes messages from input stream', () async {
        final runFuture = server.run();

        inputController.add(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'initialize',
            'params': {},
          }),
        );

        // Give the event loop a chance to process.
        await Future<void>.delayed(Duration(milliseconds: 50));

        expect(responses, hasLength(1));
        expect(responses.first['result'], isNotNull);

        await inputController.close();
        await runFuture;
      });

      test('skips empty lines', () async {
        final runFuture = server.run();

        inputController.add('');
        inputController.add('   ');
        inputController.add(
          jsonEncode({'jsonrpc': '2.0', 'id': 1, 'method': 'ping'}),
        );

        await Future<void>.delayed(Duration(milliseconds: 50));

        expect(responses, hasLength(1));

        await inputController.close();
        await runFuture;
      });

      test('returns parse error for invalid JSON', () async {
        final runFuture = server.run();

        inputController.add('not valid json');

        await Future<void>.delayed(Duration(milliseconds: 50));

        expect(responses, hasLength(1));

        final error = responses.first['error'] as Map<String, Object?>;
        expect(error['code'], -32700);

        await inputController.close();
        await runFuture;
      });
    });
  });

  group('McpToolResult', () {
    test('toJson includes isError only when true', () {
      final success = McpToolResult(content: [McpContent.text('ok')]);
      expect(success.toJson().containsKey('isError'), isFalse);

      final error = McpToolResult(
        content: [McpContent.text('fail')],
        isError: true,
      );
      expect(error.toJson()['isError'], true);
    });
  });

  group('McpContent', () {
    test('text constructor sets type to text', () {
      final content = McpContent.text('hello');
      expect(content.type, 'text');
      expect(content.text, 'hello');
    });

    test('toJson returns correct structure', () {
      final json = McpContent.text('hello').toJson();
      expect(json, {'type': 'text', 'text': 'hello'});
    });
  });

  group('McpTool', () {
    test('toJson returns correct structure', () {
      final tool = McpTool(
        name: 'my_tool',
        description: 'My tool description',
        inputSchema: {
          'type': 'object',
          'properties': {
            'name': {'type': 'string'},
          },
        },
        handler: (_) async => McpToolResult(content: []),
      );

      final json = tool.toJson();
      expect(json['name'], 'my_tool');
      expect(json['description'], 'My tool description');
      expect(json['inputSchema'], isA<Map>());
    });
  });
}
