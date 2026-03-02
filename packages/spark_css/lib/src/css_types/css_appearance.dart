import 'css_value.dart';

/// CSS appearance property values.
sealed class CssAppearance implements CssValue {
  const CssAppearance._();

  static const CssAppearance none = _CssAppearanceKeyword('none');
  static const CssAppearance auto = _CssAppearanceKeyword('auto');
  static const CssAppearance menulistButton = _CssAppearanceKeyword(
    'menulist-button',
  );
  static const CssAppearance textfield = _CssAppearanceKeyword('textfield');

  /// CSS variable reference.
  factory CssAppearance.variable(String varName) = _CssAppearanceVariable;

  /// Raw CSS value escape hatch.
  factory CssAppearance.raw(String value) = _CssAppearanceRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAppearance.global(CssGlobal global) = _CssAppearanceGlobal;
}

final class _CssAppearanceKeyword extends CssAppearance {
  final String keyword;
  const _CssAppearanceKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssAppearanceVariable extends CssAppearance {
  final String varName;
  const _CssAppearanceVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAppearanceRaw extends CssAppearance {
  final String value;
  const _CssAppearanceRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssAppearanceGlobal extends CssAppearance {
  final CssGlobal global;
  const _CssAppearanceGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
