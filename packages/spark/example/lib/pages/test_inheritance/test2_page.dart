import 'package:spark_framework/spark.dart';

import '../../components/counter_final/counter_final.dart';
import 'test_base.dart';

@Page(path: '/test2')
class Test2Page extends TestBasePage {
  @override
  Future<PageResponse<void>> loader(PageRequest request) async {
    return PageData(null);
  }

  @override
  Element render(void data, PageRequest request) {
    return div([h1('Hello World'), CounterFinal().render()]);
  }
}
