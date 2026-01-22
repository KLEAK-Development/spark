class CounterConfig {
  final num step;
  final num secondsOfDelay;

  const CounterConfig({this.step = 1, this.secondsOfDelay = 0});

  Map<String, dynamic> toJson() => {
    'step': step,
    'secondsOfDelay': secondsOfDelay,
  };

  factory CounterConfig.fromJson(Map<String, dynamic> json) => CounterConfig(
    step: json['step'] as int? ?? 1,
    secondsOfDelay: json['secondsOfDelay'] as int? ?? 0,
  );
}
