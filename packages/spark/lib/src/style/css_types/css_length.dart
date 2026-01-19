import 'css_value.dart';

/// CSS length/size value type.
sealed class CssLength implements CssValue {
  const CssLength._();

  // Special keywords
  static const CssLength auto = _CssLengthKeyword('auto');
  static const CssLength maxContent = _CssLengthKeyword('max-content');
  static const CssLength minContent = _CssLengthKeyword('min-content');
  static const CssLength fitContent = _CssLengthKeyword('fit-content');
  static const CssLength none = _CssLengthKeyword('none');

  /// Zero length (no unit needed).
  static const CssLength zero = _CssLengthNumeric(0, '');

  /// Pixel value.
  factory CssLength.px(num value) = _CssLengthPx;

  /// Em units (relative to element font size).
  factory CssLength.em(num value) = _CssLengthEm;

  /// Rem units (relative to root font size).
  factory CssLength.rem(num value) = _CssLengthRem;

  /// Percentage.
  factory CssLength.percent(num value) = _CssLengthPercent;

  /// Viewport width percentage.
  factory CssLength.vw(num value) = _CssLengthVw;

  /// Viewport height percentage.
  factory CssLength.vh(num value) = _CssLengthVh;

  /// Dynamic viewport width (accounts for browser UI).
  factory CssLength.dvw(num value) = _CssLengthDvw;

  /// Dynamic viewport height (accounts for browser UI).
  factory CssLength.dvh(num value) = _CssLengthDvh;

  /// Small viewport width.
  factory CssLength.svw(num value) = _CssLengthSvw;

  /// Small viewport height.
  factory CssLength.svh(num value) = _CssLengthSvh;

  /// Large viewport width.
  factory CssLength.lvw(num value) = _CssLengthLvw;

  /// Large viewport height.
  factory CssLength.lvh(num value) = _CssLengthLvh;

  /// Viewport minimum (smaller of vw or vh).
  factory CssLength.vmin(num value) = _CssLengthVmin;

  /// Viewport maximum (larger of vw or vh).
  factory CssLength.vmax(num value) = _CssLengthVmax;

  /// Character units (width of '0').
  factory CssLength.ch(num value) = _CssLengthCh;

  /// Ex units (x-height of font).
  factory CssLength.ex(num value) = _CssLengthEx;

  /// Line height units.
  factory CssLength.lh(num value) = _CssLengthLh;

  /// Root line height units.
  factory CssLength.rlh(num value) = _CssLengthRlh;

  /// CSS calc() function.
  factory CssLength.calc(String expression) = _CssLengthCalc;

  /// CSS min() function.
  factory CssLength.min(List<CssLength> values) = _CssLengthMin;

  /// CSS max() function.
  factory CssLength.max(List<CssLength> values) = _CssLengthMax;

  /// CSS clamp() function.
  factory CssLength.clamp(CssLength min, CssLength preferred, CssLength max) =
      _CssLengthClamp;

  /// fit-content() function with argument.
  factory CssLength.fitContentArg(CssLength value) = _CssLengthFitContentArg;

  /// CSS variable reference.
  factory CssLength.variable(String varName) = _CssLengthVariable;

  /// Raw CSS value escape hatch.
  factory CssLength.raw(String value) = _CssLengthRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssLength.global(CssGlobal global) = _CssLengthGlobal;
}

final class _CssLengthKeyword extends CssLength {
  final String keyword;
  const _CssLengthKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssLengthNumeric extends CssLength {
  final num value;
  final String unit;
  const _CssLengthNumeric(this.value, this.unit) : super._();

  @override
  String toCss() => value == 0 ? '0' : '$value$unit';
}

final class _CssLengthPx extends _CssLengthNumeric {
  const _CssLengthPx(num value) : super(value, 'px');
}

final class _CssLengthEm extends _CssLengthNumeric {
  const _CssLengthEm(num value) : super(value, 'em');
}

final class _CssLengthRem extends _CssLengthNumeric {
  const _CssLengthRem(num value) : super(value, 'rem');
}

final class _CssLengthPercent extends _CssLengthNumeric {
  const _CssLengthPercent(num value) : super(value, '%');
}

final class _CssLengthVw extends _CssLengthNumeric {
  const _CssLengthVw(num value) : super(value, 'vw');
}

final class _CssLengthVh extends _CssLengthNumeric {
  const _CssLengthVh(num value) : super(value, 'vh');
}

final class _CssLengthDvw extends _CssLengthNumeric {
  const _CssLengthDvw(num value) : super(value, 'dvw');
}

final class _CssLengthDvh extends _CssLengthNumeric {
  const _CssLengthDvh(num value) : super(value, 'dvh');
}

final class _CssLengthSvw extends _CssLengthNumeric {
  const _CssLengthSvw(num value) : super(value, 'svw');
}

final class _CssLengthSvh extends _CssLengthNumeric {
  const _CssLengthSvh(num value) : super(value, 'svh');
}

final class _CssLengthLvw extends _CssLengthNumeric {
  const _CssLengthLvw(num value) : super(value, 'lvw');
}

final class _CssLengthLvh extends _CssLengthNumeric {
  const _CssLengthLvh(num value) : super(value, 'lvh');
}

final class _CssLengthVmin extends _CssLengthNumeric {
  const _CssLengthVmin(num value) : super(value, 'vmin');
}

final class _CssLengthVmax extends _CssLengthNumeric {
  const _CssLengthVmax(num value) : super(value, 'vmax');
}

final class _CssLengthCh extends _CssLengthNumeric {
  const _CssLengthCh(num value) : super(value, 'ch');
}

final class _CssLengthEx extends _CssLengthNumeric {
  const _CssLengthEx(num value) : super(value, 'ex');
}

final class _CssLengthLh extends _CssLengthNumeric {
  const _CssLengthLh(num value) : super(value, 'lh');
}

final class _CssLengthRlh extends _CssLengthNumeric {
  const _CssLengthRlh(num value) : super(value, 'rlh');
}

final class _CssLengthCalc extends CssLength {
  final String expression;
  const _CssLengthCalc(this.expression) : super._();

  @override
  String toCss() => 'calc($expression)';
}

final class _CssLengthMin extends CssLength {
  final List<CssLength> values;
  const _CssLengthMin(this.values) : super._();

  @override
  String toCss() => 'min(${values.map((v) => v.toCss()).join(', ')})';
}

final class _CssLengthMax extends CssLength {
  final List<CssLength> values;
  const _CssLengthMax(this.values) : super._();

  @override
  String toCss() => 'max(${values.map((v) => v.toCss()).join(', ')})';
}

final class _CssLengthClamp extends CssLength {
  final CssLength min;
  final CssLength preferred;
  final CssLength max;
  const _CssLengthClamp(this.min, this.preferred, this.max) : super._();

  @override
  String toCss() =>
      'clamp(${min.toCss()}, ${preferred.toCss()}, ${max.toCss()})';
}

final class _CssLengthFitContentArg extends CssLength {
  final CssLength value;
  const _CssLengthFitContentArg(this.value) : super._();

  @override
  String toCss() => 'fit-content(${value.toCss()})';
}

final class _CssLengthVariable extends CssLength {
  final String varName;
  const _CssLengthVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssLengthRaw extends CssLength {
  final String value;
  const _CssLengthRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssLengthGlobal extends CssLength {
  final CssGlobal global;
  const _CssLengthGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
