import 'css_value.dart';

/// CSS position property values.
sealed class CssPosition implements CssValue {
  const CssPosition._();

  static const CssPosition static_ = _CssPositionKeyword('static');
  static const CssPosition relative = _CssPositionKeyword('relative');
  static const CssPosition absolute = _CssPositionKeyword('absolute');
  static const CssPosition fixed = _CssPositionKeyword('fixed');
  static const CssPosition sticky = _CssPositionKeyword('sticky');

  /// CSS variable reference.
  factory CssPosition.variable(String varName) = _CssPositionVariable;

  /// Raw CSS value escape hatch.
  factory CssPosition.raw(String value) = _CssPositionRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssPosition.global(CssGlobal global) = _CssPositionGlobal;
}

final class _CssPositionKeyword extends CssPosition {
  final String keyword;
  const _CssPositionKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssPositionVariable extends CssPosition {
  final String varName;
  const _CssPositionVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssPositionRaw extends CssPosition {
  final String value;
  const _CssPositionRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssPositionGlobal extends CssPosition {
  final CssGlobal global;
  const _CssPositionGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
