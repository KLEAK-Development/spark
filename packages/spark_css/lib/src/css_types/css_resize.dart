import 'css_value.dart';

/// CSS resize property values.
sealed class CssResize implements CssValue {
  const CssResize._();

  static const CssResize none = _CssResizeKeyword('none');
  static const CssResize both = _CssResizeKeyword('both');
  static const CssResize horizontal = _CssResizeKeyword('horizontal');
  static const CssResize vertical = _CssResizeKeyword('vertical');
  static const CssResize block = _CssResizeKeyword('block');
  static const CssResize inline = _CssResizeKeyword('inline');

  /// CSS variable reference.
  factory CssResize.variable(String varName) = _CssResizeVariable;

  /// Raw CSS value escape hatch.
  factory CssResize.raw(String value) = _CssResizeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssResize.global(CssGlobal global) = _CssResizeGlobal;
}

final class _CssResizeKeyword extends CssResize {
  final String keyword;
  const _CssResizeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssResizeVariable extends CssResize {
  final String varName;
  const _CssResizeVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssResizeRaw extends CssResize {
  final String value;
  const _CssResizeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssResizeGlobal extends CssResize {
  final CssGlobal global;
  const _CssResizeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
