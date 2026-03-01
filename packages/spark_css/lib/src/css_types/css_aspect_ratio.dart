import 'css_value.dart';

/// CSS aspect-ratio property values.
sealed class CssAspectRatio implements CssValue {
  const CssAspectRatio._();

  static const CssAspectRatio auto = _CssAspectRatioKeyword('auto');

  /// Ratio value (e.g., `16 / 9`).
  factory CssAspectRatio.ratio(num width, num height) = _CssAspectRatioRatio;

  /// Single number value (e.g., `1` or `0.5`).
  factory CssAspectRatio.number(num value) = _CssAspectRatioNumber;

  /// CSS variable reference.
  factory CssAspectRatio.variable(String varName) = _CssAspectRatioVariable;

  /// Raw CSS value escape hatch.
  factory CssAspectRatio.raw(String value) = _CssAspectRatioRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAspectRatio.global(CssGlobal global) = _CssAspectRatioGlobal;
}

final class _CssAspectRatioKeyword extends CssAspectRatio {
  final String keyword;
  const _CssAspectRatioKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssAspectRatioRatio extends CssAspectRatio {
  final num width;
  final num height;
  const _CssAspectRatioRatio(this.width, this.height) : super._();

  @override
  String toCss() => '$width / $height';
}

final class _CssAspectRatioNumber extends CssAspectRatio {
  final num value;
  const _CssAspectRatioNumber(this.value) : super._();

  @override
  String toCss() => '$value';
}

final class _CssAspectRatioVariable extends CssAspectRatio {
  final String varName;
  const _CssAspectRatioVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAspectRatioRaw extends CssAspectRatio {
  final String value;
  const _CssAspectRatioRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssAspectRatioGlobal extends CssAspectRatio {
  final CssGlobal global;
  const _CssAspectRatioGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
