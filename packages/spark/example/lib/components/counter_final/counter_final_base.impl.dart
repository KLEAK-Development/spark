// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// ComponentGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_import

import 'package:spark_framework/spark.dart' hide query, queryAll;
import 'config.dart';
import 'dart:convert';

/// Generated reactive implementation of [CounterFinal].
class CounterFinal extends SparkComponent {
  static const tag = 'counter-final';

  late num _value;
  late String _label;
  late bool _isUpdating;
  late CounterConfig _config;

  CounterFinal({
    num value = 0,
    CounterConfig config = const CounterConfig(),
    String label = 'Clicks',
    bool isUpdating = false,
  }) {
    _value = value;
    _config = config;
    _label = label;
    _isUpdating = isUpdating;
  }

  num get value => _value;
  set value(num v) {
    if (_value != v) {
      _value = v;
      scheduleUpdate();
    }
  }

  String get label => _label;
  set label(String v) {
    if (_label != v) {
      _label = v;
      scheduleUpdate();
    }
  }

  bool get isUpdating => _isUpdating;
  set isUpdating(bool v) {
    if (_isUpdating != v) {
      _isUpdating = v;
      scheduleUpdate();
    }
  }

  CounterConfig get config => _config;
  set config(CounterConfig v) {
    if (_config != v) {
      _config = v;
      scheduleUpdate();
    }
  }

  @override
  Element build() {
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
              await Future.delayed(
                Duration(seconds: config.secondsOfDelay.toInt()),
              );
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
              await Future.delayed(
                Duration(seconds: config.secondsOfDelay.toInt()),
              );
            }
            value += config.step;
            isUpdating = false;
          },
        ),
      ]),
      div(className: 'step-controls', [
        span(['Step:']),
        input<int>(
          type: 'number',
          value: config.step.toInt(),
          className: 'step-input',
          onInput: (e) {
            final target = e.target as HTMLInputElement;
            config = CounterConfig(
              step: int.tryParse(target.value) ?? 1,
              secondsOfDelay: config.secondsOfDelay,
            );
          },
        ),
      ]),
      div(className: 'step-controls', [
        span(['Delay:']),
        input<num>(
          type: 'number',
          value: config.secondsOfDelay,
          className: 'step-input',
          onInput: (e) {
            final target = e.target as HTMLInputElement;
            config = CounterConfig(
              step: config.step,
              secondsOfDelay: num.tryParse(target.value) ?? 0,
            );
          },
        ),
      ]),
    ]);
  }

  @override
  String get tagName => tag;

  @override
  List<String> get observedAttributes => const [
    'value',
    'label',
    'isupdating',
    'config',
  ];

  @override
  void syncAttributes() {
    setAttr('value', value.toString());
    setAttr('label', label);
    setAttr('isupdating', isUpdating.toString());
    setAttr('config', jsonEncode(config.toJson()));
  }

  @override
  Map<String, String> get dumpedAttributes => {
    'value': value.toString(),
    'label': label,
    'isupdating': isUpdating.toString(),
    'config': jsonEncode(config.toJson()),
  };

  @override
  void attributeChangedCallback(
    String name,
    String? oldValue,
    String? newValue,
  ) {
    switch (name) {
      case 'value':
        _value = num.tryParse(newValue ?? '') ?? 0;
        break;
      case 'label':
        _label = newValue ?? '';
        break;
      case 'isupdating':
        _isUpdating = newValue != null && newValue != 'false';
        break;
      case 'config':
        if (newValue != null) {
          try {
            _config = CounterConfig.fromJson(jsonDecode(newValue));
          } catch (_) {}
        }
        break;
    }
    super.attributeChangedCallback(name, oldValue, newValue);
  }

  @override
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
}
