import 'package:test/test.dart';
import 'package:spark_framework/src/page/spark_page.dart';
import 'package:spark_framework/src/page/page_request.dart';
import 'package:spark_framework/src/page/page_response.dart';
import 'package:spark_framework/src/html/node.dart';
import 'package:shelf/shelf.dart';

// Concrete implementation for testing defaults
class TestPage extends SparkPage<String> {
  @override
  Future<PageResponse<String>> loader(PageRequest request) async {
    return PageData('loaded');
  }

  @override
  VNode render(String data, PageRequest request) {
    return Text(data);
  }
}

// Implementation overriding defaults
class CustomPage extends SparkPage<void> {
  @override
  Future<PageResponse<void>> loader(PageRequest request) async =>
      PageData(null);

  @override
  VNode render(void data, PageRequest request) => Text('');

  @override
  String title(void data, PageRequest request) => 'Custom Title';

  @override
  List<String> get stylesheets => ['style.css'];

  @override
  List<String> get additionalScripts => ['script.js'];

  @override
  List<Middleware> get middleware => [logRequests()];

  @override
  String get lang => 'es';
}

void main() {
  group('SparkPage Abstraction', () {
    test('defaults are correct', () {
      final page = TestPage();
      final request = PageRequest(
        shelfRequest: Request('GET', Uri.parse('http://localhost/')),
        pathParams: {},
      );

      expect(page.title('data', request), equals('Spark App'));
      expect(page.components, isEmpty);
      expect(page.headContent, isNull);
      expect(page.inlineStyles, isNull);
      expect(page.stylesheets, isEmpty);
      expect(page.additionalScripts, isEmpty);
      expect(page.middleware, isEmpty);
      expect(page.lang, equals('en'));
    });

    test('overrides work correctly', () {
      final page = CustomPage();
      final request = PageRequest(
        shelfRequest: Request('GET', Uri.parse('http://localhost/')),
        pathParams: {},
      );

      expect(page.title(null, request), equals('Custom Title'));
      expect(page.stylesheets, contains('style.css'));
      expect(page.additionalScripts, contains('script.js'));
      expect(page.middleware, isNotEmpty);
      expect(page.lang, equals('es'));
    });
  });
}
