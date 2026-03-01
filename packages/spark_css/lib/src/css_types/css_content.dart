import 'css_value.dart';

/// CSS content property values.
sealed class CssContent implements CssValue {
  const CssContent._();

  static const CssContent normal = _CssContentKeyword('normal');
  static const CssContent none = _CssContentKeyword('none');

  /// Arbitrary content value (e.g., `'"Hello"'`).
  factory CssContent.value(String value) = _CssContentValue;

  /// CSS variable reference.
  factory CssContent.variable(String varName) = _CssContentVariable;

  /// Raw CSS value escape hatch.
  factory CssContent.raw(String value) = _CssContentRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssContent.global(CssGlobal global) = _CssContentGlobal;
}

final class _CssContentKeyword extends CssContent {
  final String keyword;
  const _CssContentKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssContentValue extends CssContent {
  final String value;
  const _CssContentValue(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssContentVariable extends CssContent {
  final String varName;
  const _CssContentVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssContentRaw extends CssContent {
  final String value;
  const _CssContentRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssContentGlobal extends CssContent {
  final CssGlobal global;
  const _CssContentGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
