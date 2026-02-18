@TestOn('browser')
import 'package:spark_web/spark_web.dart' as spark;
import 'package:test/test.dart';

void main() {
  group('Browser CSS', () {
    test('CSSStyleSheet replace', () async {
      final sheet = spark.createCSSStyleSheet();
      sheet.replaceSync('body { color: red; }');
      await sheet.replace('body { color: blue; }');
    });
  });
}
