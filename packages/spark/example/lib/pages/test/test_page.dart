import 'package:spark_framework/spark.dart';

import '../../components/counter_final/counter_final.dart';

@Page(path: '/test')
class TestPage extends SparkPage<void> {
  @override
  List<Type> get components => [CounterFinal];

  @override
  Future<PageResponse<void>> loader(PageRequest request) async {
    return PageData(null);
  }

  @override
  Element render(void data, PageRequest request) {
    return div([h1('Hello World'), CounterFinal().render()]);
  }
}
