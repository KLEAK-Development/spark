import 'css_value.dart';
import 'css_color.dart';
import 'css_length.dart';
import 'css_gradient_direction.dart';
import 'css_radial_shape.dart';
import 'css_radial_size.dart';
import 'css_background_position.dart';

/// Represents a color stop in a gradient.
class CssGradientStop {
  /// The color at this stop.
  final CssColor color;

  /// The position of the stop along the gradient line.
  final CssLength? offset;

  /// Creates a new gradient color stop.
  const CssGradientStop(this.color, [this.offset]);

  /// Converts the stop to its CSS string representation.
  String toCss() {
    if (offset != null) {
      return '${color.toCss()} ${offset!.toCss()}';
    }
    return color.toCss();
  }
}

/// CSS background-image property values.
sealed class CssBackgroundImage implements CssValue {
  const CssBackgroundImage._();

  /// `none` keyword.
  static const CssBackgroundImage none = _CssBackgroundImageKeyword('none');

  /// URL image.
  factory CssBackgroundImage.url(String url) = _CssBackgroundImageUrl;

  /// Linear gradient.
  ///
  /// [direction] can be an angle (e.g. '45deg') or side/corner (e.g. 'to bottom right').
  factory CssBackgroundImage.linearGradient({
    CssGradientDirection? direction,
    required List<CssGradientStop> stops,
    bool repeating,
  }) = _CssBackgroundImageLinearGradient;

  /// Radial gradient.
  ///
  /// [shape] can be 'circle' or 'ellipse'.
  /// [size] can be 'closest-side', 'farthest-corner', etc. or a length.
  /// [position] is the center position (e.g. 'center', '50% 50%').
  factory CssBackgroundImage.radialGradient({
    CssRadialShape? shape,
    CssRadialSize? size,
    CssBackgroundPosition? position,
    required List<CssGradientStop> stops,
    bool repeating,
  }) = _CssBackgroundImageRadialGradient;

  /// Multiple background images.
  factory CssBackgroundImage.list(List<CssBackgroundImage> images) =
      _CssBackgroundImageList;

  /// Raw CSS value escape hatch.
  factory CssBackgroundImage.raw(String value) = _CssBackgroundImageRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBackgroundImage.global(CssGlobal global) =
      _CssBackgroundImageGlobal;
}

final class _CssBackgroundImageKeyword extends CssBackgroundImage {
  final String keyword;
  const _CssBackgroundImageKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBackgroundImageUrl extends CssBackgroundImage {
  final String url;
  const _CssBackgroundImageUrl(this.url) : super._();

  @override
  String toCss() => 'url($url)';
}

final class _CssBackgroundImageLinearGradient extends CssBackgroundImage {
  final CssGradientDirection? direction;
  final List<CssGradientStop> stops;
  final bool repeating;

  const _CssBackgroundImageLinearGradient({
    this.direction,
    required this.stops,
    this.repeating = false,
  }) : super._();

  @override
  String toCss() {
    final buffer = StringBuffer(
      repeating ? 'repeating-linear-gradient(' : 'linear-gradient(',
    );
    if (direction != null) {
      buffer.write('${direction!.toCss()}, ');
    }
    buffer.write(stops.map((s) => s.toCss()).join(', '));
    buffer.write(')');
    return buffer.toString();
  }
}

final class _CssBackgroundImageRadialGradient extends CssBackgroundImage {
  final CssRadialShape? shape;
  final CssRadialSize? size;
  final CssBackgroundPosition? position;
  final List<CssGradientStop> stops;
  final bool repeating;

  const _CssBackgroundImageRadialGradient({
    this.shape,
    this.size,
    this.position,
    required this.stops,
    this.repeating = false,
  }) : super._();

  @override
  String toCss() {
    final buffer = StringBuffer(
      repeating ? 'repeating-radial-gradient(' : 'radial-gradient(',
    );

    final hasShapeOrSize = shape != null || size != null;
    final hasPosition = position != null;

    if (hasShapeOrSize || hasPosition) {
      if (shape != null) {
        buffer.write(shape!.toCss());
        if (size != null) buffer.write(' ');
      }
      if (size != null) buffer.write(size!.toCss());

      if (hasPosition) {
        if (hasShapeOrSize) buffer.write(' ');
        buffer.write('at ${position!.toCss()}');
      }
      buffer.write(', ');
    }

    buffer.write(stops.map((s) => s.toCss()).join(', '));
    buffer.write(')');
    return buffer.toString();
  }
}

final class _CssBackgroundImageList extends CssBackgroundImage {
  final List<CssBackgroundImage> images;
  const _CssBackgroundImageList(this.images) : super._();

  @override
  String toCss() => images.map((i) => i.toCss()).join(', ');
}

final class _CssBackgroundImageRaw extends CssBackgroundImage {
  final String value;
  const _CssBackgroundImageRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBackgroundImageGlobal extends CssBackgroundImage {
  final CssGlobal global;
  const _CssBackgroundImageGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
