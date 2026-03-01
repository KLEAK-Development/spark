import 'css_value.dart';

/// CSS mix-blend-mode property values.
sealed class CssMixBlendMode implements CssValue {
  const CssMixBlendMode._();

  static const CssMixBlendMode normal = _CssMixBlendModeKeyword('normal');
  static const CssMixBlendMode multiply = _CssMixBlendModeKeyword('multiply');
  static const CssMixBlendMode screen = _CssMixBlendModeKeyword('screen');
  static const CssMixBlendMode overlay = _CssMixBlendModeKeyword('overlay');
  static const CssMixBlendMode darken = _CssMixBlendModeKeyword('darken');
  static const CssMixBlendMode lighten = _CssMixBlendModeKeyword('lighten');
  static const CssMixBlendMode colorDodge = _CssMixBlendModeKeyword(
    'color-dodge',
  );
  static const CssMixBlendMode colorBurn = _CssMixBlendModeKeyword(
    'color-burn',
  );
  static const CssMixBlendMode hardLight = _CssMixBlendModeKeyword(
    'hard-light',
  );
  static const CssMixBlendMode softLight = _CssMixBlendModeKeyword(
    'soft-light',
  );
  static const CssMixBlendMode difference = _CssMixBlendModeKeyword(
    'difference',
  );
  static const CssMixBlendMode exclusion = _CssMixBlendModeKeyword('exclusion');
  static const CssMixBlendMode hue = _CssMixBlendModeKeyword('hue');
  static const CssMixBlendMode saturation = _CssMixBlendModeKeyword(
    'saturation',
  );
  static const CssMixBlendMode color = _CssMixBlendModeKeyword('color');
  static const CssMixBlendMode luminosity = _CssMixBlendModeKeyword(
    'luminosity',
  );

  /// CSS variable reference.
  factory CssMixBlendMode.variable(String varName) = _CssMixBlendModeVariable;

  /// Raw CSS value escape hatch.
  factory CssMixBlendMode.raw(String value) = _CssMixBlendModeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssMixBlendMode.global(CssGlobal global) = _CssMixBlendModeGlobal;
}

final class _CssMixBlendModeKeyword extends CssMixBlendMode {
  final String keyword;
  const _CssMixBlendModeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssMixBlendModeVariable extends CssMixBlendMode {
  final String varName;
  const _CssMixBlendModeVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssMixBlendModeRaw extends CssMixBlendMode {
  final String value;
  const _CssMixBlendModeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssMixBlendModeGlobal extends CssMixBlendMode {
  final CssGlobal global;
  const _CssMixBlendModeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
