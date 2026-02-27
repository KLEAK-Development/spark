import 'package:spark_framework/spark.dart';

import '../../components/notification_demo/notification_demo.dart';

@Page(path: '/notification')
class NotificationPage extends SparkPage<void> {
  @override
  Future<PageResponse<void>> loader(PageRequest request) async {
    return PageData(null);
  }

  @override
  Element render(void data, PageRequest request) {
    return div([
      h1('Notification API Test'),
      p([
        'This page demonstrates the ',
        strong(['spark_web Notification API']),
        '. Use the controls below to test permission handling, '
            'notification creation, and notification properties.',
      ]),
      NotificationDemo().render(),
    ]);
  }

  @override
  String title(void data, PageRequest request) => 'Notification API Test';

  @override
  List<Type> get components => [NotificationDemo];

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
