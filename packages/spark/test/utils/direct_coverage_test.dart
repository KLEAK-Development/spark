import 'package:shelf/shelf.dart';
import 'package:spark_framework/src/utils/props_serializer.dart';
import 'package:spark_framework/src/page/page_request.dart';
import 'package:spark_framework/src/errors/errors.dart';
import 'package:spark_framework/src/server/render_page.dart';
import 'package:test/test.dart';

void main() {
  group('Direct Coverage', () {
    test('props_serializer line 46', () {
      expect(decodeProps(''), isEmpty);
    });

    test('page_request queryParam lines 120, 132, 134', () {
      final req = SparkRequest(
        shelfRequest: Request('GET', Uri.parse('http://localhost/?a=1&b=str')),
        pathParams: {},
      );
      // Line 120
      expect(req.queryParam('a'), '1');
      expect(req.queryParam('missing', 'fallback'), 'fallback');
      expect(req.queryParam('missing'), ''); 
      
      // Line 132, 134
      expect(req.queryParamInt('a'), 1);
      expect(req.queryParamInt('missing', 5), 5);
    });

    test('errors line 22', () {
      final err = ApiError(message: 'm', code: 'C');
      final json = err.toJson();
      expect(json['code'], 'C');
    });

    test('render_page line 140, 142', () {
      final html = renderPage(title: 'T', content: 'C', nonce: 'N');
      expect(html, contains('nonce="N"'));
    });
  });
}
