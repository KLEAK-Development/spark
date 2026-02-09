import 'dart:io';
import 'package:spark_framework/server.dart';

void main() async {
  final tempDir = Directory.systemTemp.createTempSync('benchmark_');
  print('Setting up benchmark directory at ${tempDir.path} with 5000 files...');

  const numFiles = 5000;
  // Create files in batches to be faster? Or just sequentially.
  // Sequential might be slow but it's setup time, not benchmark time.
  for (var i = 0; i < numFiles; i++) {
    File('${tempDir.path}/file_$i.txt').createSync();
  }
  print('Setup complete.');

  final handler = createStaticHandler(
    tempDir.path,
    config: StaticHandlerConfig(path: tempDir.path, listDirectories: true),
  );

  // Warmup run
  print('Warming up...');
  await handler(Request('GET', Uri.parse('http://localhost/')));

  // Benchmark run
  print('Running benchmark...');
  final stopwatch = Stopwatch()..start();
  // Perform multiple iterations to get average
  const iterations = 10;
  for (var i = 0; i < iterations; i++) {
    final response = await handler(
      Request('GET', Uri.parse('http://localhost/')),
    );
    if (response.statusCode != 200) {
      print('Error: ${response.statusCode}');
      exit(1);
    }
    // Read the body to ensure it's fully processed if lazy
    await response.readAsString();
  }
  stopwatch.stop();

  print(
    'Total time for $iterations iterations: ${stopwatch.elapsedMilliseconds}ms',
  );
  print(
    'Average time per request: ${stopwatch.elapsedMilliseconds / iterations}ms',
  );

  // Clean up
  if (tempDir.existsSync()) {
    tempDir.deleteSync(recursive: true);
  }
}
