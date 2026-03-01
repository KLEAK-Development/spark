import 'css_value.dart';

/// CSS border-collapse property values.
sealed class CssBorderCollapse implements CssValue {
  const CssBorderCollapse._();

  static const CssBorderCollapse separate = _CssBorderCollapseKeyword(
    'separate',
  );
  static const CssBorderCollapse collapse = _CssBorderCollapseKeyword(
    'collapse',
  );

  /// CSS variable reference.
  factory CssBorderCollapse.variable(String varName) =
      _CssBorderCollapseVariable;

  /// Raw CSS value escape hatch.
  factory CssBorderCollapse.raw(String value) = _CssBorderCollapseRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBorderCollapse.global(CssGlobal global) = _CssBorderCollapseGlobal;
}

final class _CssBorderCollapseKeyword extends CssBorderCollapse {
  final String keyword;
  const _CssBorderCollapseKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBorderCollapseVariable extends CssBorderCollapse {
  final String varName;
  const _CssBorderCollapseVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBorderCollapseRaw extends CssBorderCollapse {
  final String value;
  const _CssBorderCollapseRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBorderCollapseGlobal extends CssBorderCollapse {
  final CssGlobal global;
  const _CssBorderCollapseGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
