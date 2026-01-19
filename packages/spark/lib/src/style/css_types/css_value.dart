/// Base interface for all CSS value types.
/// All CSS types implement this interface to provide CSS string output.
abstract interface class CssValue {
  /// Converts this value to its CSS string representation.
  String toCss();
}

/// Global CSS keywords applicable to any property.
sealed class CssGlobal implements CssValue {
  const CssGlobal._();

  /// The `inherit` keyword - inherits value from parent.
  static const CssGlobal inherit = _CssGlobalKeyword._('inherit');

  /// The `initial` keyword - uses property's initial value.
  static const CssGlobal initial = _CssGlobalKeyword._('initial');

  /// The `unset` keyword - resets to inherited or initial value.
  static const CssGlobal unset = _CssGlobalKeyword._('unset');

  /// The `revert` keyword - reverts to user agent stylesheet value.
  static const CssGlobal revert = _CssGlobalKeyword._('revert');

  /// The `revert-layer` keyword - reverts to previous cascade layer.
  static const CssGlobal revertLayer = _CssGlobalKeyword._('revert-layer');
}

final class _CssGlobalKeyword extends CssGlobal {
  final String keyword;
  const _CssGlobalKeyword._(this.keyword) : super._();

  @override
  String toCss() => keyword;
}
