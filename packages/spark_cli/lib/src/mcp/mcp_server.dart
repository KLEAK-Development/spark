import 'package:json_rpc_2/json_rpc_2.dart' as json_rpc;
import 'package:stream_channel/stream_channel.dart';

/// A tool definition for the MCP server.
class McpTool {
  final String name;
  final String description;
  final Map<String, Object?> inputSchema;
  final Future<McpToolResult> Function(Map<String, Object?> arguments) handler;

  McpTool({
    required this.name,
    required this.description,
    required this.inputSchema,
    required this.handler,
  });

  Map<String, Object?> toJson() => {
    'name': name,
    'description': description,
    'inputSchema': inputSchema,
  };
}

/// The result of executing an MCP tool.
class McpToolResult {
  final List<McpContent> content;
  final bool isError;

  McpToolResult({required this.content, this.isError = false});

  Map<String, Object?> toJson() => {
    'content': content.map((c) => c.toJson()).toList(),
    if (isError) 'isError': true,
  };
}

/// A content block within an MCP tool result.
class McpContent {
  final String type;
  final String text;

  McpContent({required this.type, required this.text});

  McpContent.text(this.text) : type = 'text';

  Map<String, Object?> toJson() => {'type': type, 'text': text};
}

/// MCP protocol server backed by [json_rpc.Server].
///
/// Implements the Model Context Protocol (MCP) on top of JSON-RPC 2.0
/// for exposing tools to LLM clients.
class McpServer {
  final String name;
  final String version;
  final List<McpTool> _tools = [];
  final json_rpc.Server _rpc;

  bool _initialized = false;

  /// Creates an MCP server that communicates over [channel].
  McpServer({
    required this.name,
    required this.version,
    required StreamChannel<String> channel,
  }) : _rpc = json_rpc.Server(channel) {
    _registerMethods();
  }

  void _registerMethods() {
    _rpc.registerMethod('initialize', (_) {
      _initialized = true;
      return {
        'protocolVersion': '2024-11-05',
        'capabilities': {
          'tools': {'listChanged': false},
        },
        'serverInfo': {'name': name, 'version': version},
      };
    });

    _rpc.registerMethod('notifications/initialized', (_) {
      // Client acknowledged initialization – nothing to do.
    });

    _rpc.registerMethod('ping', (_) => <String, Object?>{});

    _rpc.registerMethod('tools/list', (_) {
      _requireInitialized();
      return {'tools': _tools.map((t) => t.toJson()).toList()};
    });

    _rpc.registerMethod('tools/call', (json_rpc.Parameters params) async {
      _requireInitialized();

      final paramsMap = params.value as Map<String, Object?>;

      final toolName = paramsMap['name'] as String?;
      if (toolName == null) {
        throw json_rpc.RpcException.invalidParams('Missing tool name');
      }

      final tool = _tools.where((t) => t.name == toolName).firstOrNull;
      if (tool == null) {
        throw json_rpc.RpcException.invalidParams('Unknown tool: $toolName');
      }

      final arguments =
          (paramsMap['arguments'] as Map<String, Object?>?) ??
          <String, Object?>{};

      try {
        final result = await tool.handler(arguments);
        return result.toJson();
      } catch (e) {
        return McpToolResult(
          content: [McpContent.text('Error: $e')],
          isError: true,
        ).toJson();
      }
    });
  }

  void _requireInitialized() {
    if (!_initialized) {
      throw json_rpc.RpcException(-32002, 'Server not initialized');
    }
  }

  /// Registers a tool with the MCP server.
  void addTool(McpTool tool) {
    _tools.add(tool);
  }

  /// Returns the list of registered tools.
  List<McpTool> get tools => List.unmodifiable(_tools);

  /// Starts listening for JSON-RPC messages on the channel.
  Future<void> run() => _rpc.listen();
}
