import 'css_length.dart';
import 'css_value.dart';

/// CSS radial-gradient size.
sealed class CssRadialSize implements CssValue {
  const CssRadialSize._();

  /// Keyword `closest-side`.
  static const CssRadialSize closestSide = _CssRadialSizeKeyword(
    'closest-side',
  );

  /// Keyword `closest-corner`.
  static const CssRadialSize closestCorner = _CssRadialSizeKeyword(
    'closest-corner',
  );

  /// Keyword `farthest-side`.
  static const CssRadialSize farthestSide = _CssRadialSizeKeyword(
    'farthest-side',
  );

  /// Keyword `farthest-corner`.
  static const CssRadialSize farthestCorner = _CssRadialSizeKeyword(
    'farthest-corner',
  );

  /// Size defined by a single length (for circle).
  factory CssRadialSize.size(CssLength value) = _CssRadialSizeSingle;

  /// Size defined by two lengths (for ellipse).
  factory CssRadialSize.size2(CssLength horizontal, CssLength vertical) =
      _CssRadialSizeDouble;

  /// Raw CSS value escape hatch.
  factory CssRadialSize.raw(String value) = _CssRadialSizeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssRadialSize.global(CssGlobal global) = _CssRadialSizeGlobal;
}

final class _CssRadialSizeKeyword extends CssRadialSize {
  final String keyword;
  const _CssRadialSizeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssRadialSizeSingle extends CssRadialSize {
  final CssLength value;
  const _CssRadialSizeSingle(this.value) : super._();

  @override
  String toCss() => value.toCss();
}

final class _CssRadialSizeDouble extends CssRadialSize {
  final CssLength horizontal;
  final CssLength vertical;
  const _CssRadialSizeDouble(this.horizontal, this.vertical) : super._();

  @override
  String toCss() => '${horizontal.toCss()} ${vertical.toCss()}';
}

final class _CssRadialSizeRaw extends CssRadialSize {
  final String value;
  const _CssRadialSizeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssRadialSizeGlobal extends CssRadialSize {
  final CssGlobal global;
  const _CssRadialSizeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
