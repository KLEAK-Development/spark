import 'css_value.dart';

/// CSS isolation property values.
sealed class CssIsolation implements CssValue {
  const CssIsolation._();

  static const CssIsolation auto = _CssIsolationKeyword('auto');
  static const CssIsolation isolate = _CssIsolationKeyword('isolate');

  /// CSS variable reference.
  factory CssIsolation.variable(String varName) = _CssIsolationVariable;

  /// Raw CSS value escape hatch.
  factory CssIsolation.raw(String value) = _CssIsolationRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssIsolation.global(CssGlobal global) = _CssIsolationGlobal;
}

final class _CssIsolationKeyword extends CssIsolation {
  final String keyword;
  const _CssIsolationKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssIsolationVariable extends CssIsolation {
  final String varName;
  const _CssIsolationVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssIsolationRaw extends CssIsolation {
  final String value;
  const _CssIsolationRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssIsolationGlobal extends CssIsolation {
  final CssGlobal global;
  const _CssIsolationGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
