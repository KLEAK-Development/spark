import 'package:spark_framework/spark.dart';

@Page(path: '/no-component')
class NoComponentPage extends SparkPage<void> {
  @override
  Future<PageResponse<void>> loader(PageRequest request) async {
    return PageData(null);
  }

  @override
  Element render(void data, PageRequest request) {
    return div([h1('Hello World')]);
  }
}
