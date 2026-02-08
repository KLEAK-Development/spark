import 'dart:async';
import 'dart:convert';

import 'package:spark_cli/src/mcp/mcp_server.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:test/test.dart';

/// Creates an [McpServer] connected to in-memory streams for testing.
///
/// Returns the server and a list that accumulates decoded JSON responses.
({
  McpServer server,
  List<Map<String, Object?>> responses,
  StreamController<String> input,
})
_createTestServer({String name = 'test-server', String version = '0.1.0'}) {
  final responses = <Map<String, Object?>>[];
  final inputController = StreamController<String>();
  final outputController = StreamController<String>();

  outputController.stream.listen((line) {
    responses.add(jsonDecode(line) as Map<String, Object?>);
  });

  final channel = StreamChannel.withGuarantees(
    inputController.stream,
    outputController.sink,
  );

  final server = McpServer(name: name, version: version, channel: channel);

  return (server: server, responses: responses, input: inputController);
}

/// Sends a JSON-RPC request through the [input] controller and waits for
/// the response to appear in [responses].
Future<Map<String, Object?>> _sendRequest(
  StreamController<String> input,
  List<Map<String, Object?>> responses,
  Map<String, Object?> message,
) async {
  final countBefore = responses.length;
  input.add(jsonEncode(message));
  // Give the event loop time to process.
  await Future<void>.delayed(const Duration(milliseconds: 50));
  expect(
    responses.length,
    greaterThan(countBefore),
    reason: 'Expected a response for: ${message['method']}',
  );
  return responses.last;
}

void main() {
  group('McpServer', () {
    late List<Map<String, Object?>> responses;
    late StreamController<String> input;
    late McpServer server;

    setUp(() {
      final t = _createTestServer();
      server = t.server;
      responses = t.responses;
      input = t.input;

      // Start listening (non-blocking).
      server.run();
    });

    tearDown(() {
      input.close();
    });

    // -- helper to initialize before other requests --
    Future<void> initialize() async {
      await _sendRequest(input, responses, {
        'jsonrpc': '2.0',
        'id': 0,
        'method': 'initialize',
        'params': {},
      });
      responses.clear();
    }

    group('initialize', () {
      test('responds with server info and capabilities', () async {
        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'initialize',
          'params': {
            'protocolVersion': '2024-11-05',
            'capabilities': {},
            'clientInfo': {'name': 'test-client', 'version': '1.0.0'},
          },
        });

        final result = resp['result'] as Map<String, Object?>;
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
        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'ping',
        });

        expect(resp['result'], isEmpty);
      });
    });

    group('notifications', () {
      test('does not respond to notifications (no id)', () async {
        input.add(
          jsonEncode({'jsonrpc': '2.0', 'method': 'notifications/initialized'}),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(responses, isEmpty);
      });
    });

    group('tools/list', () {
      test('returns error when not initialized', () async {
        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'tools/list',
        });

        expect(resp['error'], isNotNull);
        final error = resp['error'] as Map<String, Object?>;
        expect(error['code'], -32002);
      });

      test('returns empty tools list when no tools registered', () async {
        await initialize();

        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 2,
          'method': 'tools/list',
        });

        final result = resp['result'] as Map<String, Object?>;
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

        await initialize();

        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 2,
          'method': 'tools/list',
        });

        final result = resp['result'] as Map<String, Object?>;
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
        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'tools/call',
          'params': {
            'name': 'echo',
            'arguments': {'message': 'hi'},
          },
        });

        expect(resp['error'], isNotNull);
      });

      test('calls a tool and returns the result', () async {
        await initialize();

        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 2,
          'method': 'tools/call',
          'params': {
            'name': 'echo',
            'arguments': {'message': 'hello'},
          },
        });

        final result = resp['result'] as Map<String, Object?>;
        final content = result['content'] as List;
        expect((content.first as Map)['text'], 'Echo: hello');
        expect(result['isError'], isNull);
      });

      test('returns error for unknown tool', () async {
        await initialize();

        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 2,
          'method': 'tools/call',
          'params': {'name': 'nonexistent'},
        });

        final error = resp['error'] as Map<String, Object?>;
        expect(error['code'], -32602);
        expect(error['message'], contains('nonexistent'));
      });

      test('returns error when tool name is missing', () async {
        await initialize();

        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 2,
          'method': 'tools/call',
          'params': {'arguments': {}},
        });

        final error = resp['error'] as Map<String, Object?>;
        expect(error['code'], -32602);
      });

      test('handles tool handler exceptions as error results', () async {
        await initialize();

        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 2,
          'method': 'tools/call',
          'params': {'name': 'fail'},
        });

        final result = resp['result'] as Map<String, Object?>;
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

        await initialize();

        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 2,
          'method': 'tools/call',
          'params': {'name': 'no_args'},
        });

        final result = resp['result'] as Map<String, Object?>;
        final content = result['content'] as List;
        expect((content.first as Map)['text'], 'args: 0');
      });
    });

    group('unknown method', () {
      test('returns method not found error', () async {
        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'unknown/method',
        });

        final error = resp['error'] as Map<String, Object?>;
        expect(error['code'], -32601);
      });
    });

    group('run (stream-based)', () {
      test('processes messages from input stream', () async {
        // server.run() was already called in setUp.
        final resp = await _sendRequest(input, responses, {
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'initialize',
          'params': {},
        });

        expect(resp['result'], isNotNull);
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
