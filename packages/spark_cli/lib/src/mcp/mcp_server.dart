import 'dart:convert';

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

/// Callback for sending a JSON-RPC message line.
typedef McpOutputCallback = void Function(String line);

/// MCP protocol server that communicates over a stream-based transport.
///
/// Implements the Model Context Protocol (MCP) JSON-RPC 2.0 interface
/// for exposing tools to LLM clients.
class McpServer {
  final String name;
  final String version;
  final List<McpTool> _tools = [];
  final McpOutputCallback _output;
  final Stream<String> _input;

  bool _initialized = false;

  McpServer({
    required this.name,
    required this.version,
    required Stream<String> input,
    required McpOutputCallback output,
  }) : _input = input,
       _output = output;

  /// Registers a tool with the MCP server.
  void addTool(McpTool tool) {
    _tools.add(tool);
  }

  /// Returns the list of registered tools.
  List<McpTool> get tools => List.unmodifiable(_tools);

  /// Starts listening for JSON-RPC messages on the input stream.
  Future<void> run() async {
    await for (final line in _input) {
      if (line.trim().isEmpty) continue;

      try {
        final message = jsonDecode(line) as Map<String, Object?>;
        await _handleMessage(message);
      } on FormatException {
        _sendError(null, -32700, 'Parse error');
      }
    }
  }

  /// Handles a single JSON-RPC message.
  ///
  /// Exposed for testing so callers can send messages directly
  /// without going through the input stream.
  Future<void> handleMessage(Map<String, Object?> message) =>
      _handleMessage(message);

  Future<void> _handleMessage(Map<String, Object?> message) async {
    final method = message['method'] as String?;
    final id = message['id'];

    // Notifications have no id
    if (id == null) {
      // Handle notifications silently
      return;
    }

    switch (method) {
      case 'initialize':
        _handleInitialize(id);
      case 'tools/list':
        _handleToolsList(id);
      case 'tools/call':
        await _handleToolsCall(id, message['params'] as Map<String, Object?>?);
      case 'ping':
        _sendResult(id, {});
      default:
        _sendError(id, -32601, 'Method not found: $method');
    }
  }

  void _handleInitialize(Object id) {
    _initialized = true;
    _sendResult(id, {
      'protocolVersion': '2024-11-05',
      'capabilities': {
        'tools': {'listChanged': false},
      },
      'serverInfo': {'name': name, 'version': version},
    });
  }

  void _handleToolsList(Object id) {
    if (!_initialized) {
      _sendError(id, -32002, 'Server not initialized');
      return;
    }

    _sendResult(id, {'tools': _tools.map((t) => t.toJson()).toList()});
  }

  Future<void> _handleToolsCall(Object id, Map<String, Object?>? params) async {
    if (!_initialized) {
      _sendError(id, -32002, 'Server not initialized');
      return;
    }

    if (params == null) {
      _sendError(id, -32602, 'Missing params');
      return;
    }

    final toolName = params['name'] as String?;
    if (toolName == null) {
      _sendError(id, -32602, 'Missing tool name');
      return;
    }

    final tool = _tools.where((t) => t.name == toolName).firstOrNull;
    if (tool == null) {
      _sendError(id, -32602, 'Unknown tool: $toolName');
      return;
    }

    final arguments =
        (params['arguments'] as Map<String, Object?>?) ?? <String, Object?>{};

    try {
      final result = await tool.handler(arguments);
      _sendResult(id, result.toJson());
    } catch (e) {
      _sendResult(
        id,
        McpToolResult(
          content: [McpContent.text('Error: $e')],
          isError: true,
        ).toJson(),
      );
    }
  }

  void _sendResult(Object? id, Map<String, Object?> result) {
    _send({'jsonrpc': '2.0', 'id': id, 'result': result});
  }

  void _sendError(Object? id, int code, String message) {
    _send({
      'jsonrpc': '2.0',
      'id': id,
      'error': {'code': code, 'message': message},
    });
  }

  void _send(Map<String, Object?> message) {
    _output(jsonEncode(message));
  }
}
