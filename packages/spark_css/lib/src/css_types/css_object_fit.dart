import 'css_value.dart';

/// CSS object-fit property values.
sealed class CssObjectFit implements CssValue {
  const CssObjectFit._();

  static const CssObjectFit fill = _CssObjectFitKeyword('fill');
  static const CssObjectFit contain = _CssObjectFitKeyword('contain');
  static const CssObjectFit cover = _CssObjectFitKeyword('cover');
  static const CssObjectFit none = _CssObjectFitKeyword('none');
  static const CssObjectFit scaleDown = _CssObjectFitKeyword('scale-down');

  /// CSS variable reference.
  factory CssObjectFit.variable(String varName) = _CssObjectFitVariable;

  /// Raw CSS value escape hatch.
  factory CssObjectFit.raw(String value) = _CssObjectFitRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssObjectFit.global(CssGlobal global) = _CssObjectFitGlobal;
}

final class _CssObjectFitKeyword extends CssObjectFit {
  final String keyword;
  const _CssObjectFitKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssObjectFitVariable extends CssObjectFit {
  final String varName;
  const _CssObjectFitVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssObjectFitRaw extends CssObjectFit {
  final String value;
  const _CssObjectFitRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssObjectFitGlobal extends CssObjectFit {
  final CssGlobal global;
  const _CssObjectFitGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
