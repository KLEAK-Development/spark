import 'dart:convert';
import 'dart:io';

import 'package:spark_cli/src/mcp/spark_mcp_server.dart';

void main() async {
  final inputStream = stdin
      .transform(utf8.decoder)
      .transform(const LineSplitter());

  final server = createSparkMcpServer(
    input: inputStream,
    output: stdout.writeln,
  );

  await server.run();
}
