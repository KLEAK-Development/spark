import 'css_value.dart';

/// CSS background-blend-mode property values.
sealed class CssBackgroundBlendMode implements CssValue {
  const CssBackgroundBlendMode._();

  static const CssBackgroundBlendMode normal = _CssBackgroundBlendModeKeyword(
    'normal',
  );
  static const CssBackgroundBlendMode multiply = _CssBackgroundBlendModeKeyword(
    'multiply',
  );
  static const CssBackgroundBlendMode screen = _CssBackgroundBlendModeKeyword(
    'screen',
  );
  static const CssBackgroundBlendMode overlay = _CssBackgroundBlendModeKeyword(
    'overlay',
  );
  static const CssBackgroundBlendMode darken = _CssBackgroundBlendModeKeyword(
    'darken',
  );
  static const CssBackgroundBlendMode lighten = _CssBackgroundBlendModeKeyword(
    'lighten',
  );
  static const CssBackgroundBlendMode colorDodge =
      _CssBackgroundBlendModeKeyword('color-dodge');
  static const CssBackgroundBlendMode colorBurn =
      _CssBackgroundBlendModeKeyword('color-burn');
  static const CssBackgroundBlendMode hardLight =
      _CssBackgroundBlendModeKeyword('hard-light');
  static const CssBackgroundBlendMode softLight =
      _CssBackgroundBlendModeKeyword('soft-light');
  static const CssBackgroundBlendMode difference =
      _CssBackgroundBlendModeKeyword('difference');
  static const CssBackgroundBlendMode exclusion =
      _CssBackgroundBlendModeKeyword('exclusion');
  static const CssBackgroundBlendMode hue = _CssBackgroundBlendModeKeyword(
    'hue',
  );
  static const CssBackgroundBlendMode saturation =
      _CssBackgroundBlendModeKeyword('saturation');
  static const CssBackgroundBlendMode color = _CssBackgroundBlendModeKeyword(
    'color',
  );
  static const CssBackgroundBlendMode luminosity =
      _CssBackgroundBlendModeKeyword('luminosity');

  /// CSS variable reference.
  factory CssBackgroundBlendMode.variable(String varName) =
      _CssBackgroundBlendModeVariable;

  /// Raw CSS value escape hatch.
  factory CssBackgroundBlendMode.raw(String value) = _CssBackgroundBlendModeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBackgroundBlendMode.global(CssGlobal global) =
      _CssBackgroundBlendModeGlobal;
}

final class _CssBackgroundBlendModeKeyword extends CssBackgroundBlendMode {
  final String keyword;
  const _CssBackgroundBlendModeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBackgroundBlendModeVariable extends CssBackgroundBlendMode {
  final String varName;
  const _CssBackgroundBlendModeVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBackgroundBlendModeRaw extends CssBackgroundBlendMode {
  final String value;
  const _CssBackgroundBlendModeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBackgroundBlendModeGlobal extends CssBackgroundBlendMode {
  final CssGlobal global;
  const _CssBackgroundBlendModeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
