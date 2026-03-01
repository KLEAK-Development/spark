import 'css_value.dart';

/// CSS box-sizing property values.
sealed class CssBoxSizing implements CssValue {
  const CssBoxSizing._();

  static const CssBoxSizing contentBox = _CssBoxSizingKeyword('content-box');
  static const CssBoxSizing borderBox = _CssBoxSizingKeyword('border-box');

  /// CSS variable reference.
  factory CssBoxSizing.variable(String varName) = _CssBoxSizingVariable;

  /// Raw CSS value escape hatch.
  factory CssBoxSizing.raw(String value) = _CssBoxSizingRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBoxSizing.global(CssGlobal global) = _CssBoxSizingGlobal;
}

final class _CssBoxSizingKeyword extends CssBoxSizing {
  final String keyword;
  const _CssBoxSizingKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBoxSizingVariable extends CssBoxSizing {
  final String varName;
  const _CssBoxSizingVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBoxSizingRaw extends CssBoxSizing {
  final String value;
  const _CssBoxSizingRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBoxSizingGlobal extends CssBoxSizing {
  final CssGlobal global;
  const _CssBoxSizingGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
