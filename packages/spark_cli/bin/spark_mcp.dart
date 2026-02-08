import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:stream_channel/stream_channel.dart';

import 'package:spark_cli/src/mcp/spark_mcp_server.dart';

void main() async {
  final input = stdin.transform(utf8.decoder).transform(const LineSplitter());

  final outputController = StreamController<String>();
  outputController.stream.listen((line) => stdout.writeln(line));

  final channel = StreamChannel.withGuarantees(input, outputController.sink);

  final server = createSparkMcpServer(channel: channel);
  await server.run();
}
