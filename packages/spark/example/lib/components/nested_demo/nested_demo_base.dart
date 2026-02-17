import 'package:spark_framework/spark.dart';
import '../counter_final/counter_final.dart';

@Component(tag: NestedDemo.tag)
class NestedDemo {
  static const tag = 'nested-demo';

  NestedDemo({this.title = 'Nested Component Demo', this.showCounter = true});

  @Attribute()
  String title;

  @Attribute()
  bool showCounter;

  Stylesheet get adoptedStyleSheets => css({
    ':host': .typed(
      display: .block,
      padding: .all(.px(20)),
      margin: .symmetric(.px(16), .zero),
      border: CssBorder(width: .px(1), style: .solid, color: .hex('#2196f3')),
      borderRadius: .all(.px(12)),
      backgroundColor: .hex('#f0f7ff'),
    ),
    'h2': .typed(color: .hex('#1976d2'), marginTop: .zero),
    '.container': .typed(
      padding: .all(.px(16)),
      backgroundColor: .white,
      borderRadius: .all(.px(8)),
      boxShadow: .raw('0 2px 4px rgba(0,0,0,0.1)'),
    ),
    'button': .typed(
      padding: .symmetric(.px(8), .px(16)),
      marginBottom: .px(12),
      cursor: .pointer,
    ),
  });

  Element render() {
    return div([
      h2([title]),
      p([
        'This component demonstrates nesting. The counter below is a separate component managed inside this one.',
      ]),

      button(onClick: (_) => showCounter = !showCounter, [
        showCounter ? 'Remove Counter' : 'Add Counter',
      ]),

      if (showCounter) CounterFinal(value: 42, label: 'Inner Counter').render(),
    ]);
  }
}
