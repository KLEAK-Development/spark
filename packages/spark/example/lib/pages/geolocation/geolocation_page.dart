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
    'body': Style.typed(
      fontFamily: CssFontFamily.stack([
        CssFontFamily.systemUi,
        CssFontFamily.generic('-apple-system'),
        CssFontFamily.generic('BlinkMacSystemFont'),
        CssFontFamily.named('Segoe UI'),
        CssFontFamily.generic('Roboto'),
        CssFontFamily.sansSerif,
      ]),
      maxWidth: CssLength.px(800),
      margin: CssSpacing.symmetric(CssLength.zero, CssLength.auto),
      padding: CssSpacing.symmetric(CssLength.px(40), CssLength.px(20)),
      lineHeight: CssNumber(1.6),
      color: CssColor.hex('#333'),
    ),
    'h1': Style.typed(color: CssColor.hex('#2196f3')),
    'p': Style.typed(color: CssColor.hex('#666')),
  });
}
