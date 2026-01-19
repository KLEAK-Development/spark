// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_v2.dart';

// **************************************************************************
// ComponentGenerator
// **************************************************************************

mixin _$CounterV2Sync on SparkComponent {
  @override
  List<String> get observedAttributes => const ['value', 'config'];
  @override
  void syncAttributes() {
    setAttr('value', (this as CounterV2).value.toString());
    setAttr('config', jsonEncode((this as CounterV2).config.toJson()));
  }

  @override
  Map<String, String> get dumpedAttributes => {
    'value': (this as CounterV2).value.toString(),
    'config': jsonEncode((this as CounterV2).config.toJson()),
  };
  @override
  void attributeChangedCallback(
    String name,
    String? oldValue,
    String? newValue,
  ) {
    switch (name) {
      case 'value':
        (this as CounterV2).value = int.tryParse(newValue ?? '') ?? 0;
        break;
      case 'config':
        if (newValue != null) {
          try {
            (this as CounterV2).config = CounterConfig.fromJson(
              jsonDecode(newValue),
            );
          } catch (_) {}
        }
        break;
    }
    super.attributeChangedCallback(name, oldValue, newValue);
  }
}
