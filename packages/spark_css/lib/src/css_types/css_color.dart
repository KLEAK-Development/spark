import 'css_value.dart';

/// CSS color value type.
sealed class CssColor implements CssValue {
  const CssColor._();

  // Named colors - common subset
  static const CssColor transparent = _CssNamedColor('transparent');
  static const CssColor currentColor = _CssNamedColor('currentColor');
  static const CssColor black = _CssNamedColor('black');
  static const CssColor white = _CssNamedColor('white');
  static const CssColor red = _CssNamedColor('red');
  static const CssColor green = _CssNamedColor('green');
  static const CssColor blue = _CssNamedColor('blue');
  static const CssColor yellow = _CssNamedColor('yellow');
  static const CssColor orange = _CssNamedColor('orange');
  static const CssColor purple = _CssNamedColor('purple');
  static const CssColor pink = _CssNamedColor('pink');
  static const CssColor gray = _CssNamedColor('gray');
  static const CssColor grey = _CssNamedColor('grey');
  static const CssColor cyan = _CssNamedColor('cyan');
  static const CssColor magenta = _CssNamedColor('magenta');

  /// Named CSS color.
  factory CssColor.named(String name) = _CssNamedColor;

  /// Hexadecimal color (#RGB, #RRGGBB, #RGBA, #RRGGBBAA).
  factory CssColor.hex(String hex) = _CssHexColor;

  /// RGB color (0-255 for each channel).
  factory CssColor.rgb(int r, int g, int b) = _CssRgbColor;

  /// RGBA color with alpha (0.0-1.0).
  factory CssColor.rgba(int r, int g, int b, double a) = _CssRgbaColor;

  /// HSL color (hue: 0-360, saturation: 0-100, lightness: 0-100).
  factory CssColor.hsl(int h, int s, int l) = _CssHslColor;

  /// HSLA color with alpha (0.0-1.0).
  factory CssColor.hsla(int h, int s, int l, double a) = _CssHslaColor;

  /// CSS variable reference.
  factory CssColor.variable(String varName) = _CssColorVariable;

  /// Raw CSS value escape hatch.
  factory CssColor.raw(String value) = _CssColorRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssColor.global(CssGlobal global) = _CssColorGlobal;
}

final class _CssNamedColor extends CssColor {
  final String name;
  const _CssNamedColor(this.name) : super._();

  @override
  String toCss() => name;
}

final class _CssHexColor extends CssColor {
  final String hex;
  _CssHexColor(String hex)
    : hex = hex.startsWith('#') ? hex : '#$hex',
      super._();

  @override
  String toCss() => hex;
}

final class _CssRgbColor extends CssColor {
  final int r, g, b;
  const _CssRgbColor(this.r, this.g, this.b) : super._();

  @override
  String toCss() => 'rgb($r, $g, $b)';
}

final class _CssRgbaColor extends CssColor {
  final int r, g, b;
  final double a;
  const _CssRgbaColor(this.r, this.g, this.b, this.a) : super._();

  @override
  String toCss() => 'rgba($r, $g, $b, $a)';
}

final class _CssHslColor extends CssColor {
  final int h, s, l;
  const _CssHslColor(this.h, this.s, this.l) : super._();

  @override
  String toCss() => 'hsl($h, $s%, $l%)';
}

final class _CssHslaColor extends CssColor {
  final int h, s, l;
  final double a;
  const _CssHslaColor(this.h, this.s, this.l, this.a) : super._();

  @override
  String toCss() => 'hsla($h, $s%, $l%, $a)';
}

final class _CssColorVariable extends CssColor {
  final String varName;
  const _CssColorVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssColorRaw extends CssColor {
  final String value;
  const _CssColorRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssColorGlobal extends CssColor {
  final CssGlobal global;
  const _CssColorGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
