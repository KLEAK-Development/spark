@TestOn('vm')
library;

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:spark_framework/src/server/static_handler.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('static_handler_xss_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Request request(String path) {
    return Request('GET', Uri.parse('http://localhost/$path'));
  }

  test('escapes special characters in directory listing', () async {
    final subDirName = 'special&chars';
    final fileName = 'file&name.txt';

    final subDir = Directory('${tempDir.path}/$subDirName');
    await subDir.create();

    final file = File('${subDir.path}/$fileName');
    await file.writeAsString('content');

    final handler = createStaticHandler(
      tempDir.path,
      config: StaticHandlerConfig(path: tempDir.path, listDirectories: true),
    );

    // Request with unencoded '&' as it is valid in path segments
    final response = await handler(request('special&chars'));

    expect(
      response.statusCode,
      200,
      reason: 'Should find directory "special&chars"',
    );
    final body = await response.readAsString();

    // Verify title contains escaped path
    expect(
      body,
      contains('Index of /special&amp;chars'),
      reason: 'Title should be escaped',
    );

    // Verify header contains escaped path
    expect(
      body,
      contains('<h1>Index of /special&amp;chars</h1>'),
      reason: 'Header should be escaped',
    );

    // Verify file list contains escaped filename
    // <a href="...">file&amp;name.txt</a>
    expect(
      body,
      contains('>file&amp;name.txt</a>'),
      reason: 'File name in list should be escaped',
    );
  });
}
