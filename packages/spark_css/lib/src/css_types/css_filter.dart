import 'css_color.dart';
import 'css_length.dart';
import 'css_value.dart';

/// CSS filter function values.
sealed class CssFilter implements CssValue {
  const CssFilter._();

  static const CssFilter none = _CssFilterKeyword('none');

  /// Applies a Gaussian blur to the input image.
  factory CssFilter.blur(CssLength radius) = _CssFilterBlur;

  /// Applies a linear multiplier to the input image, making it appear more or less bright.
  /// `amount`: A number multiplier (0-1, or >1). 0 is black, 1 is unchanged.
  factory CssFilter.brightness(num amount) = _CssFilterBrightness;

  /// Same as [CssFilter.brightness] but takes a percentage (0-100, or >100).
  factory CssFilter.brightnessPercent(num amount) = _CssFilterBrightnessPercent;

  /// Adjusts the contrast of the input.
  /// `amount`: A number multiplier (0-1, or >1). 0 is gray, 1 is unchanged.
  factory CssFilter.contrast(num amount) = _CssFilterContrast;

  /// Same as [CssFilter.contrast] but takes a percentage (0-100, or >100).
  factory CssFilter.contrastPercent(num amount) = _CssFilterContrastPercent;

  /// Applies a drop shadow effect to the input image.
  factory CssFilter.dropShadow({
    required CssLength offsetX,
    required CssLength offsetY,
    CssLength? blurRadius,
    CssColor? color,
  }) = _CssFilterDropShadow;

  /// Converts the input image to grayscale.
  /// `amount`: A number multiplier (0-1). 1 is grayscale, 0 is unchanged.
  factory CssFilter.grayscale(num amount) = _CssFilterGrayscale;

  /// Same as [CssFilter.grayscale] but takes a percentage (0-100).
  factory CssFilter.grayscalePercent(num amount) = _CssFilterGrayscalePercent;

  /// Applies a hue rotation on the input image.
  ///
  /// TODO: Update to accept `CssAngle` once implemented.
  factory CssFilter.hueRotate(num angle) = _CssFilterHueRotate;

  /// Same as [CssFilter.hueRotate] but takes a unit string (e.g. '90deg', '0.5turn').
  factory CssFilter.hueRotateRaw(String angle) = _CssFilterHueRotateRaw;

  /// Inverts the samples in the input image.
  /// `amount`: A number multiplier (0-1). 1 is inverted, 0 is unchanged.
  factory CssFilter.invert(num amount) = _CssFilterInvert;

  /// Same as [CssFilter.invert] but takes a percentage (0-100).
  factory CssFilter.invertPercent(num amount) = _CssFilterInvertPercent;

  /// Applies transparency to the samples in the input image.
  /// `amount`: A number multiplier (0-1). 0 is transparent, 1 is unchanged.
  factory CssFilter.opacity(num amount) = _CssFilterOpacity;

  /// Same as [CssFilter.opacity] but takes a percentage (0-100).
  factory CssFilter.opacityPercent(num amount) = _CssFilterOpacityPercent;

  /// Saturates the input image.
  /// `amount`: A number multiplier (0-1, or >1). 0 is un-saturated, 1 is unchanged.
  factory CssFilter.saturate(num amount) = _CssFilterSaturate;

  /// Same as [CssFilter.saturate] but takes a percentage (0-100, or >100).
  factory CssFilter.saturatePercent(num amount) = _CssFilterSaturatePercent;

  /// Converts the input image to sepia.
  /// `amount`: A number multiplier (0-1). 1 is sepia, 0 is unchanged.
  factory CssFilter.sepia(num amount) = _CssFilterSepia;

  /// Same as [CssFilter.sepia] but takes a percentage (0-100).
  factory CssFilter.sepiaPercent(num amount) = _CssFilterSepiaPercent;

  /// Composes multiple filter functions.
  factory CssFilter.compose(List<CssFilter> filters) = _CssFilterCompose;

  /// CSS variable reference.
  factory CssFilter.variable(String varName) = _CssFilterVariable;

  /// Raw CSS value escape hatch.
  factory CssFilter.raw(String value) = _CssFilterRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssFilter.global(CssGlobal global) = _CssFilterGlobal;
}

final class _CssFilterKeyword extends CssFilter {
  final String keyword;
  const _CssFilterKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssFilterBlur extends CssFilter {
  final CssLength radius;
  const _CssFilterBlur(this.radius) : super._();

  @override
  String toCss() => 'blur(${radius.toCss()})';
}

final class _CssFilterBrightness extends CssFilter {
  final num amount;
  const _CssFilterBrightness(this.amount) : super._();

  @override
  String toCss() => 'brightness($amount)';
}

final class _CssFilterBrightnessPercent extends CssFilter {
  final num amount;
  const _CssFilterBrightnessPercent(this.amount) : super._();

  @override
  String toCss() => 'brightness($amount%)';
}

final class _CssFilterContrast extends CssFilter {
  final num amount;
  const _CssFilterContrast(this.amount) : super._();

  @override
  String toCss() => 'contrast($amount)';
}

final class _CssFilterContrastPercent extends CssFilter {
  final num amount;
  const _CssFilterContrastPercent(this.amount) : super._();

  @override
  String toCss() => 'contrast($amount%)';
}

final class _CssFilterDropShadow extends CssFilter {
  final CssLength offsetX;
  final CssLength offsetY;
  final CssLength? blurRadius;
  final CssColor? color;

  const _CssFilterDropShadow({
    required this.offsetX,
    required this.offsetY,
    this.blurRadius,
    this.color,
  }) : super._();

  @override
  String toCss() {
    final parts = [offsetX.toCss(), offsetY.toCss()];
    if (blurRadius != null) parts.add(blurRadius!.toCss());
    if (color != null) parts.add(color!.toCss());
    return 'drop-shadow(${parts.join(' ')})';
  }
}

final class _CssFilterGrayscale extends CssFilter {
  final num amount;
  const _CssFilterGrayscale(this.amount) : super._();

  @override
  String toCss() => 'grayscale($amount)';
}

final class _CssFilterGrayscalePercent extends CssFilter {
  final num amount;
  const _CssFilterGrayscalePercent(this.amount) : super._();

  @override
  String toCss() => 'grayscale($amount%)';
}

final class _CssFilterHueRotate extends CssFilter {
  final num angle;
  const _CssFilterHueRotate(this.angle) : super._();

  @override
  String toCss() => 'hue-rotate(${angle}deg)';
}

final class _CssFilterHueRotateRaw extends CssFilter {
  final String angle;
  const _CssFilterHueRotateRaw(this.angle) : super._();

  @override
  String toCss() => 'hue-rotate($angle)';
}

final class _CssFilterInvert extends CssFilter {
  final num amount;
  const _CssFilterInvert(this.amount) : super._();

  @override
  String toCss() => 'invert($amount)';
}

final class _CssFilterInvertPercent extends CssFilter {
  final num amount;
  const _CssFilterInvertPercent(this.amount) : super._();

  @override
  String toCss() => 'invert($amount%)';
}

final class _CssFilterOpacity extends CssFilter {
  final num amount;
  const _CssFilterOpacity(this.amount) : super._();

  @override
  String toCss() => 'opacity($amount)';
}

final class _CssFilterOpacityPercent extends CssFilter {
  final num amount;
  const _CssFilterOpacityPercent(this.amount) : super._();

  @override
  String toCss() => 'opacity($amount%)';
}

final class _CssFilterSaturate extends CssFilter {
  final num amount;
  const _CssFilterSaturate(this.amount) : super._();

  @override
  String toCss() => 'saturate($amount)';
}

final class _CssFilterSaturatePercent extends CssFilter {
  final num amount;
  const _CssFilterSaturatePercent(this.amount) : super._();

  @override
  String toCss() => 'saturate($amount%)';
}

final class _CssFilterSepia extends CssFilter {
  final num amount;
  const _CssFilterSepia(this.amount) : super._();

  @override
  String toCss() => 'sepia($amount)';
}

final class _CssFilterSepiaPercent extends CssFilter {
  final num amount;
  const _CssFilterSepiaPercent(this.amount) : super._();

  @override
  String toCss() => 'sepia($amount%)';
}

final class _CssFilterCompose extends CssFilter {
  final List<CssFilter> filters;
  const _CssFilterCompose(this.filters) : super._();

  @override
  String toCss() => filters.map((f) => f.toCss()).join(' ');
}

final class _CssFilterVariable extends CssFilter {
  final String varName;
  const _CssFilterVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssFilterRaw extends CssFilter {
  final String value;
  const _CssFilterRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssFilterGlobal extends CssFilter {
  final CssGlobal global;
  const _CssFilterGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
