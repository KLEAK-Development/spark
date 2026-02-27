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
      rules['.item-$i'] = Style.typed(
        color: CssColor.red,
        backgroundColor: CssColor.blue,
        margin: CssSpacing.all(CssLength.px(10)),
        padding: CssSpacing.all(CssLength.px(20)),
        display: CssDisplay.flex,
        fontSize: CssLength.px(i),
        width: CssLength.percent(100),
        height: CssLength.px(50),
        borderRadius: CssBorderRadius.all(CssLength.px(5)),
        border: CssBorder(
          width: CssLength.px(1),
          style: CssBorderStyle.solid,
          color: CssColor.black,
        ),
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
