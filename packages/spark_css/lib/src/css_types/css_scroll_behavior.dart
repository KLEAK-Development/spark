import 'css_value.dart';

/// CSS scroll-behavior property values.
sealed class CssScrollBehavior implements CssValue {
  const CssScrollBehavior._();

  static const CssScrollBehavior auto = _CssScrollBehaviorKeyword('auto');
  static const CssScrollBehavior smooth = _CssScrollBehaviorKeyword('smooth');

  /// CSS variable reference.
  factory CssScrollBehavior.variable(String varName) =
      _CssScrollBehaviorVariable;

  /// Raw CSS value escape hatch.
  factory CssScrollBehavior.raw(String value) = _CssScrollBehaviorRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssScrollBehavior.global(CssGlobal global) = _CssScrollBehaviorGlobal;
}

final class _CssScrollBehaviorKeyword extends CssScrollBehavior {
  final String keyword;
  const _CssScrollBehaviorKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssScrollBehaviorVariable extends CssScrollBehavior {
  final String varName;
  const _CssScrollBehaviorVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssScrollBehaviorRaw extends CssScrollBehavior {
  final String value;
  const _CssScrollBehaviorRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssScrollBehaviorGlobal extends CssScrollBehavior {
  final CssGlobal global;
  const _CssScrollBehaviorGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
