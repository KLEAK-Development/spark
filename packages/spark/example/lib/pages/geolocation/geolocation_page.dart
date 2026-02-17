import 'package:spark_framework/spark.dart';

import '../../components/geolocation_demo/geolocation_demo.dart';

@Page(path: '/geolocation')
class GeolocationPage extends SparkPage<void> {
  @override
  Future<PageResponse<void>> loader(PageRequest request) async {
    return PageData(null);
  }

  @override
  Element render(void data, PageRequest request) {
    return div([
      h1('Geolocation API Test'),
      p([
        'This page demonstrates the ',
        strong(['spark_web Geolocation API']),
        '. Use the controls below to retrieve or watch your current position.',
      ]),
      GeolocationDemo().render(),
    ]);
  }

  @override
  String title(void data, PageRequest request) => 'Geolocation API Test';

  @override
  List<Type> get components => [GeolocationDemo];

  @override
  Stylesheet? get inlineStyles => css({
    'body': Style(
      fontFamily:
          'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
      maxWidth: '800px',
      margin: '0 auto',
      padding: '40px 20px',
      lineHeight: '1.6',
      color: '#333',
    ),
    'h1': Style(color: '#2196f3'),
    'p': Style(color: '#666'),
  });
}
