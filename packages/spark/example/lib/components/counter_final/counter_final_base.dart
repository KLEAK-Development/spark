import 'package:spark_framework/spark.dart';

import 'config.dart';

@Component(tag: CounterFinal.tag)
class CounterFinal {
  static const tag = 'counter-final';

  CounterFinal({
    this.value = 0,
    this.config = const CounterConfig(),
    this.label = 'Clicks',
    this.isUpdating = false,
  });

  @Attribute()
  int value;

  @Attribute()
  String label;

  @Attribute()
  bool isUpdating;

  @Attribute()
  CounterConfig config;

  Stylesheet get adoptedStyleSheets => css({
    ':host': .typed(
      display: .block,
      padding: .all(.px(16)),
      border: CssBorder(width: .px(1), style: .solid, color: .hex('#e0e0e0')),
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
    'button:disabled': .typed(
      opacity: CssNumber(0.6),
      cursor: .raw('not-allowed'),
    ),
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
      border: CssBorder(width: .px(1), style: .solid, color: .hex('#cccccc')),
      borderRadius: .px(4),
    ),
  });

  Element render() {
    return div([
      div(className: 'counter-display', [
        span(id: 'label', className: 'label', ['$label:']),
        span(id: 'val', className: 'value', [
          isUpdating ? 'Updating...' : value,
        ]),
      ]),
      div(className: 'buttons', [
        button(
          id: 'dec',
          className: 'decrement',
          attributes: {'disabled': isUpdating ? 'true' : null},
          ['−'],
          onClick: (_) async {
            isUpdating = true;
            if (config.secondsOfDelay > 0) {
              await Future.delayed(Duration(seconds: config.secondsOfDelay));
            }
            value -= config.step;
            isUpdating = false;
          },
        ),
        button(
          id: 'inc',
          className: 'increment',
          attributes: {'disabled': isUpdating ? 'true' : null},
          ['+'],
          onClick: (_) async {
            isUpdating = true;
            if (config.secondsOfDelay > 0) {
              await Future.delayed(Duration(seconds: config.secondsOfDelay));
            }
            value += config.step;
            isUpdating = false;
          },
        ),
      ]),
      div(className: 'step-controls', [
        span(['Step:']),
        input(
          attributes: {'type': 'number', 'value': config.step},
          className: 'step-input',
          onInput: (e) {
            final val = int.tryParse((e.target as HTMLInputElement).value) ?? 1;
            config = CounterConfig(
              step: val,
              secondsOfDelay: config.secondsOfDelay,
            );
          },
        ),
      ]),
      div(className: 'step-controls', [
        span(['Delay:']),
        input(
          attributes: {'type': 'number', 'value': config.secondsOfDelay},
          className: 'step-input',
          onInput: (e) {
            final val = int.tryParse((e.target as HTMLInputElement).value) ?? 1;
            config = CounterConfig(secondsOfDelay: val, step: config.step);
          },
        ),
      ]),
    ]);
  }
}
