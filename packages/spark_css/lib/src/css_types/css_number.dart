import 'css_value.dart';

/// CSS numeric value (unitless).
/// Used for z-index, opacity, line-height, flex-grow, flex-shrink, etc.
sealed class CssNumber implements CssValue {
  const CssNumber._();

  /// Create from number value.
  factory CssNumber(num value) = _CssNumberValue;

  /// CSS variable reference.
  factory CssNumber.variable(String varName) = _CssNumberVariable;

  /// Raw CSS value escape hatch.
  factory CssNumber.raw(String value) = _CssNumberRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssNumber.global(CssGlobal global) = _CssNumberGlobal;
}

final class _CssNumberValue extends CssNumber {
  final num value;
  const _CssNumberValue(this.value) : super._();

  @override
  String toCss() => value.toString();
}

final class _CssNumberVariable extends CssNumber {
  final String varName;
  const _CssNumberVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssNumberRaw extends CssNumber {
  final String value;
  const _CssNumberRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssNumberGlobal extends CssNumber {
  final CssGlobal global;
  const _CssNumberGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}

/// CSS z-index value (accepts auto and integers).
sealed class CssZIndex implements CssValue {
  const CssZIndex._();

  static const CssZIndex auto = _CssZIndexKeyword('auto');

  /// Create from integer value.
  factory CssZIndex(int value) = _CssZIndexValue;

  /// CSS variable reference.
  factory CssZIndex.variable(String varName) = _CssZIndexVariable;

  /// Raw CSS value escape hatch.
  factory CssZIndex.raw(String value) = _CssZIndexRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssZIndex.global(CssGlobal global) = _CssZIndexGlobal;
}

final class _CssZIndexKeyword extends CssZIndex {
  final String keyword;
  const _CssZIndexKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssZIndexValue extends CssZIndex {
  final int value;
  const _CssZIndexValue(this.value) : super._();

  @override
  String toCss() => value.toString();
}

final class _CssZIndexVariable extends CssZIndex {
  final String varName;
  const _CssZIndexVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssZIndexRaw extends CssZIndex {
  final String value;
  const _CssZIndexRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssZIndexGlobal extends CssZIndex {
  final CssGlobal global;
  const _CssZIndexGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
