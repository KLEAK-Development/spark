import 'css_value.dart';

/// CSS text-overflow property values.
sealed class CssTextOverflow implements CssValue {
  const CssTextOverflow._();

  static const CssTextOverflow clip = _CssTextOverflowKeyword('clip');
  static const CssTextOverflow ellipsis = _CssTextOverflowKeyword('ellipsis');

  /// Custom string value (outputs with quotes, e.g., `"…"`).
  factory CssTextOverflow.value(String value) = _CssTextOverflowValue;

  /// CSS variable reference.
  factory CssTextOverflow.variable(String varName) = _CssTextOverflowVariable;

  /// Raw CSS value escape hatch.
  factory CssTextOverflow.raw(String value) = _CssTextOverflowRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssTextOverflow.global(CssGlobal global) = _CssTextOverflowGlobal;
}

final class _CssTextOverflowKeyword extends CssTextOverflow {
  final String keyword;
  const _CssTextOverflowKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssTextOverflowValue extends CssTextOverflow {
  final String value;
  const _CssTextOverflowValue(this.value) : super._();

  @override
  String toCss() => '"$value"';
}

final class _CssTextOverflowVariable extends CssTextOverflow {
  final String varName;
  const _CssTextOverflowVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTextOverflowRaw extends CssTextOverflow {
  final String value;
  const _CssTextOverflowRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssTextOverflowGlobal extends CssTextOverflow {
  final CssGlobal global;
  const _CssTextOverflowGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
