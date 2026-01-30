import 'package:spark_framework/spark.dart';

import '../../components/counter_final/counter_final.dart';

abstract class TestBasePage extends SparkPage<void> {
  @override
  List<Type> get components => [CounterFinal];
}
