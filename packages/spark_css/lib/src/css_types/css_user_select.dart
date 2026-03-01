import 'css_value.dart';

/// CSS user-select property values.
sealed class CssUserSelect implements CssValue {
  const CssUserSelect._();

  static const CssUserSelect none = _CssUserSelectKeyword('none');
  static const CssUserSelect auto = _CssUserSelectKeyword('auto');
  static const CssUserSelect text = _CssUserSelectKeyword('text');
  static const CssUserSelect all = _CssUserSelectKeyword('all');
  static const CssUserSelect contain = _CssUserSelectKeyword('contain');

  /// CSS variable reference.
  factory CssUserSelect.variable(String varName) = _CssUserSelectVariable;

  /// Raw CSS value escape hatch.
  factory CssUserSelect.raw(String value) = _CssUserSelectRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssUserSelect.global(CssGlobal global) = _CssUserSelectGlobal;
}

final class _CssUserSelectKeyword extends CssUserSelect {
  final String keyword;
  const _CssUserSelectKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssUserSelectVariable extends CssUserSelect {
  final String varName;
  const _CssUserSelectVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssUserSelectRaw extends CssUserSelect {
  final String value;
  const _CssUserSelectRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssUserSelectGlobal extends CssUserSelect {
  final CssGlobal global;
  const _CssUserSelectGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
