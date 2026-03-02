import 'css_length.dart';
import 'css_value.dart';

/// CSS tab-size property values.
sealed class CssTabSize implements CssValue {
  const CssTabSize._();

  /// Tab size as a number (number of spaces).
  factory CssTabSize.number(int value) = _CssTabSizeNumber;

  /// Tab size as a length.
  factory CssTabSize.length(CssLength value) = _CssTabSizeLength;

  /// CSS variable reference.
  factory CssTabSize.variable(String varName) = _CssTabSizeVariable;

  /// Raw CSS value escape hatch.
  factory CssTabSize.raw(String value) = _CssTabSizeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssTabSize.global(CssGlobal global) = _CssTabSizeGlobal;
}

final class _CssTabSizeNumber extends CssTabSize {
  final int value;
  const _CssTabSizeNumber(this.value) : super._();

  @override
  String toCss() => '$value';
}

final class _CssTabSizeLength extends CssTabSize {
  final CssLength value;
  const _CssTabSizeLength(this.value) : super._();

  @override
  String toCss() => value.toCss();
}

final class _CssTabSizeVariable extends CssTabSize {
  final String varName;
  const _CssTabSizeVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTabSizeRaw extends CssTabSize {
  final String value;
  const _CssTabSizeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssTabSizeGlobal extends CssTabSize {
  final CssGlobal global;
  const _CssTabSizeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
