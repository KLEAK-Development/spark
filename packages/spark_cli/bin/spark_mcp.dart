import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:stream_channel/stream_channel.dart';

import 'package:spark_cli/src/mcp/spark_mcp_server.dart';

void main() async {
  // Capture a reference to the real stdout before overriding print().
  final realStdout = stdout;

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
        // Redirect all print() calls to stderr so they don't
        // corrupt the JSON-RPC protocol on stdout.
        stderr.writeln(line);
      },
    ),
  );
}
