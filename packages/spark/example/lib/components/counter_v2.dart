import 'dart:convert';
import 'package:spark_framework/spark.dart';

part 'counter_v2.g.dart';

class CounterConfig {
  final int step;
  CounterConfig({this.step = 1});

  factory CounterConfig.fromJson(Map<String, dynamic> json) {
    return CounterConfig(step: json['step'] as int? ?? 1);
  }

  Map<String, dynamic> toJson() => {'step': step};
}

@Component(tag: CounterV2.tag)
class CounterV2 extends SparkComponent with _$CounterV2Sync {
  CounterV2({this.value = 0, this.label = 'Clicks', CounterConfig? config}) {
    if (config != null) this.config = config;
  }

  static const tag = 'interactive-counter';

  @override
  String get tagName => tag;

  @Attribute(observable: true)
  int value;

  String label;

  @Attribute(observable: true)
  CounterConfig config = CounterConfig();

  @override
  Element build() {
    return div([
      style([
        css({
          ':host': .typed(
            display: .block,
            padding: .all(.px(16)),
            border: CssBorder(
              width: .px(1),
              style: .solid,
              color: .hex('#e0e0e0'),
            ),
            borderRadius: .px(8),
            maxWidth: .px(200),
            fontFamily: .raw('system-ui, -apple-system, sans-serif'),
          ),
          '.counter-display': .typed(
            display: .flex,
            alignItems: .center,
            justifyContent: .spaceBetween,
            gap: .px(12),
          ),
          '.label': .typed(fontSize: .px(14), color: .hex('#666666')),
          '.value': .typed(
            fontSize: .px(24),
            fontWeight: .bold,
            color: .hex('#2196f3'),
            minWidth: .px(48),
            textAlign: .center,
          ),
          '.buttons': .typed(display: .flex, gap: .px(8)),
          'button': .typed(
            width: .px(36),
            height: .px(36),
            fontSize: .px(18),
            border: .none,
            borderRadius: .px(4),
            cursor: .pointer,
            transition: .raw('background-color 0.2s'),
          ),
          '.decrement': .typed(backgroundColor: .hex('#f44336'), color: .white),
          '.decrement:hover': .typed(backgroundColor: .hex('#d32f2f')),
          '.increment': .typed(backgroundColor: .hex('#4caf50'), color: .white),
          '.increment:hover': .typed(backgroundColor: .hex('#388e3c')),
          'button:active': .typed(transform: 'scale(0.95)'),
          '.step-controls': .typed(
            marginTop: .px(12),
            display: .flex,
            alignItems: .center,
            gap: .px(8),
            fontSize: .px(14),
            color: .hex('#666666'),
          ),
          '.step-input': .typed(
            width: .px(50),
            padding: .all(.px(4)),
            border: CssBorder(
              width: .px(1),
              style: .solid,
              color: .hex('#cccccc'),
            ),
            borderRadius: .px(4),
          ),
        }).toCss(),
      ]),
      div(className: 'counter-display', [
        span(id: 'label', className: 'label', ['$label:']),
        span(id: 'val', className: 'value', [value]),
      ]),
      div(className: 'buttons', [
        button(id: 'dec', className: 'decrement', [
          '−',
        ], onClick: (_) => value -= config.step),
        button(id: 'inc', className: 'increment', [
          '+',
        ], onClick: (_) => value += config.step),
      ]),
      div(className: 'step-controls', [
        span(['Step:']),
        input(
          attributes: {'type': 'number', 'value': config.step},
          className: 'step-input',
          onInput: (e) {
            final val = int.tryParse((e.target as HTMLInputElement).value) ?? 1;
            config = CounterConfig(step: val);
          },
        ),
      ]),
    ]);
  }
}
