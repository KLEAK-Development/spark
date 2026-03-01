import 'css_value.dart';

/// CSS hyphens property values.
sealed class CssHyphens implements CssValue {
  const CssHyphens._();

  static const CssHyphens none = _CssHyphensKeyword('none');
  static const CssHyphens manual = _CssHyphensKeyword('manual');
  static const CssHyphens auto = _CssHyphensKeyword('auto');

  /// CSS variable reference.
  factory CssHyphens.variable(String varName) = _CssHyphensVariable;

  /// Raw CSS value escape hatch.
  factory CssHyphens.raw(String value) = _CssHyphensRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssHyphens.global(CssGlobal global) = _CssHyphensGlobal;
}

final class _CssHyphensKeyword extends CssHyphens {
  final String keyword;
  const _CssHyphensKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssHyphensVariable extends CssHyphens {
  final String varName;
  const _CssHyphensVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssHyphensRaw extends CssHyphens {
  final String value;
  const _CssHyphensRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssHyphensGlobal extends CssHyphens {
  final CssGlobal global;
  const _CssHyphensGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
