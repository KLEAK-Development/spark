import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:spark_css/spark_css.dart';

class StyleBenchmark extends BenchmarkBase {
  StyleBenchmark() : super('Style.toCss');

  late Stylesheet _stylesheet;

  @override
  void setup() {
    // Create a moderately complex stylesheet
    final rules = <String, Style>{};
    for (var i = 0; i < 1000; i++) {
      rules['.item-$i'] = Style(
        color: 'red',
        backgroundColor: 'blue',
        margin: '10px',
        padding: '20px',
        display: 'flex',
        fontSize: '${i}px',
        width: '100%',
        height: '50px',
        borderRadius: '5px',
        border: '1px solid black',
      );
    }
    _stylesheet = css(rules);
  }

  @override
  void run() {
    _stylesheet.toCss();
  }
}

void main() {
  StyleBenchmark().report();
}
