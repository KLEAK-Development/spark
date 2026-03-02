import 'css_color.dart';
import 'css_value.dart';

/// CSS caret-color property values.
sealed class CssCaretColor implements CssValue {
  const CssCaretColor._();

  static const CssCaretColor auto = _CssCaretColorKeyword('auto');

  /// Caret color from a CssColor value.
  factory CssCaretColor.color(CssColor color) = _CssCaretColorValue;

  /// CSS variable reference.
  factory CssCaretColor.variable(String varName) = _CssCaretColorVariable;

  /// Raw CSS value escape hatch.
  factory CssCaretColor.raw(String value) = _CssCaretColorRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssCaretColor.global(CssGlobal global) = _CssCaretColorGlobal;
}

final class _CssCaretColorKeyword extends CssCaretColor {
  final String keyword;
  const _CssCaretColorKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssCaretColorValue extends CssCaretColor {
  final CssColor color;
  const _CssCaretColorValue(this.color) : super._();

  @override
  String toCss() => color.toCss();
}

final class _CssCaretColorVariable extends CssCaretColor {
  final String varName;
  const _CssCaretColorVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssCaretColorRaw extends CssCaretColor {
  final String value;
  const _CssCaretColorRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssCaretColorGlobal extends CssCaretColor {
  final CssGlobal global;
  const _CssCaretColorGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
