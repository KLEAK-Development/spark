// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// ComponentGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_import

import 'package:spark_framework/spark.dart' hide query, queryAll;
import '../counter_final/counter_final.dart';

/// Generated reactive implementation of [NestedDemo].
class NestedDemo extends SparkComponent {
  static const tag = 'nested-demo';

  late String _title;
  late bool _showCounter;

  NestedDemo({
    String title = 'Nested Component Demo',
    bool showCounter = true,
  }) {
    _title = title;
    _showCounter = showCounter;
  }

  String get title => _title;
  set title(String v) {
    if (_title != v) {
      _title = v;
      scheduleUpdate();
    }
  }

  bool get showCounter => _showCounter;
  set showCounter(bool v) {
    if (_showCounter != v) {
      _showCounter = v;
      scheduleUpdate();
    }
  }

  @override
  Element build() {
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

  @override
  String get tagName => tag;

  @override
  List<String> get observedAttributes => const ['title', 'showcounter'];

  @override
  void syncAttributes() {
    setAttr('title', title);
    setAttr('showcounter', showCounter.toString());
  }

  @override
  Map<String, String> get dumpedAttributes => {
    'title': title,
    'showcounter': showCounter.toString(),
  };

  @override
  void attributeChangedCallback(
    String name,
    String? oldValue,
    String? newValue,
  ) {
    switch (name) {
      case 'title':
        _title = newValue ?? '';
        break;
      case 'showcounter':
        _showCounter = newValue != null && newValue != 'false';
        break;
    }
    super.attributeChangedCallback(name, oldValue, newValue);
  }

  @override
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
}
