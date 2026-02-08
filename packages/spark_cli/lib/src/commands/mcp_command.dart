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
/// All diagnostic output is redirected to stderr so that only valid
/// JSON-RPC messages appear on stdout.
class McpCommand extends Command<void> {
  @override
  String get name => 'mcp';

  @override
  String get description =>
      'Start the MCP (Model Context Protocol) server for IDE integration.';

  @override
  Future<void> run() async {
    // Redirect stdout to stderr so any stray print() calls from
    // dependencies or the Dart runtime don't corrupt the JSON-RPC
    // protocol on stdout.
    final realStdout = stdout;
    final stdoutOverride = stderr;

    await runZoned(
      () async {
        final input = stdin
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        final outputController = StreamController<String>();
        outputController.stream.listen((line) => realStdout.writeln(line));

        final channel = StreamChannel.withGuarantees(
          input,
          outputController.sink,
        );

        final server = createSparkMcpServer(channel: channel);
        await server.run();
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          // Redirect all print() calls to stderr.
          stdoutOverride.writeln(line);
        },
      ),
    );
  }
}
