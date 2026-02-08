import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:stream_channel/stream_channel.dart';

import '../mcp/spark_mcp_server.dart';

/// Starts an MCP (Model Context Protocol) server over stdio.
///
/// Usage: `spark mcp`
///
/// The server communicates via JSON-RPC 2.0 over stdin/stdout.
class McpCommand extends Command<void> {
  @override
  String get name => 'mcp';

  @override
  String get description =>
      'Start the MCP (Model Context Protocol) server for IDE integration.';

  @override
  Future<void> run() async {
    final input = stdin.transform(utf8.decoder).transform(const LineSplitter());

    final outputController = StreamController<String>();
    outputController.stream.listen((line) => stdout.writeln(line));

    final channel = StreamChannel.withGuarantees(input, outputController.sink);

    final server = createSparkMcpServer(channel: channel);
    await server.run();
  }
}
