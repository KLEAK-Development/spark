import 'css_length.dart';
import 'css_value.dart';

/// CSS background-size property values.
sealed class CssBackgroundSize implements CssValue {
  const CssBackgroundSize._();

  /// Scales the image as large as possible without stretching the image.
  /// If the container is larger than the image, this will result in image tiling, unless the background-repeat property is set to no-repeat.
  static const CssBackgroundSize cover = _CssBackgroundSizeKeyword('cover');

  /// Scales the image to the largest size such that both its width and its height can fit inside the content area.
  static const CssBackgroundSize contain = _CssBackgroundSizeKeyword('contain');

  /// The `auto` keyword which scales the background image in the corresponding direction such that its intrinsic proportion is maintained.
  static const CssBackgroundSize auto = _CssBackgroundSizeKeyword('auto');

  /// Creates a background size with width and optional height.
  /// If height is omitted, it defaults to auto.
  factory CssBackgroundSize.size(CssLength width, [CssLength? height]) =
      _CssBackgroundSizeDimensions;

  /// Creates a background size with multiple values (comma-separated).
  factory CssBackgroundSize.multiple(List<CssBackgroundSize> sizes) =
      _CssBackgroundSizeMultiple;

  /// CSS variable reference.
  factory CssBackgroundSize.variable(String varName) = _CssBackgroundSizeVariable;

  /// Raw CSS value escape hatch.
  factory CssBackgroundSize.raw(String value) = _CssBackgroundSizeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBackgroundSize.global(CssGlobal global) = _CssBackgroundSizeGlobal;
}

final class _CssBackgroundSizeKeyword extends CssBackgroundSize {
  final String keyword;
  const _CssBackgroundSizeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBackgroundSizeDimensions extends CssBackgroundSize {
  final CssLength width;
  final CssLength? height;
  const _CssBackgroundSizeDimensions(this.width, [this.height]) : super._();

  @override
  String toCss() {
    if (height != null) {
      return '${width.toCss()} ${height!.toCss()}';
    }
    return width.toCss();
  }
}

final class _CssBackgroundSizeMultiple extends CssBackgroundSize {
  final List<CssBackgroundSize> sizes;
  const _CssBackgroundSizeMultiple(this.sizes) : super._();

  @override
  String toCss() => sizes.map((s) => s.toCss()).join(', ');
}

final class _CssBackgroundSizeVariable extends CssBackgroundSize {
  final String varName;
  const _CssBackgroundSizeVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBackgroundSizeRaw extends CssBackgroundSize {
  final String value;
  const _CssBackgroundSizeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBackgroundSizeGlobal extends CssBackgroundSize {
  final CssGlobal global;
  const _CssBackgroundSizeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
