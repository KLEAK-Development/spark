import 'css_length.dart';
import 'css_value.dart';

/// CSS border-radius value.
///
/// Supports all CSS shorthand syntaxes:
/// - Single value: `CssBorderRadius.all(CssLength.px(10))` → `10px`
/// - Two values: `CssBorderRadius.symmetric(topLeftBottomRight, topRightBottomLeft)` → `10px 20px`
/// - Three values: `CssBorderRadius.only(topLeft: ..., topRightBottomLeft: ..., bottomRight: ...)` → `10px 20px 30px`
/// - Four values: `CssBorderRadius.trbl(topLeft, topRight, bottomRight, bottomLeft)` → `10px 20px 30px 40px`
sealed class CssBorderRadius implements CssValue {
  const CssBorderRadius._();

  /// Zero radius.
  static const CssBorderRadius zero = _CssBorderRadiusAll(CssLength.zero);

  /// Same value for all four corners.
  factory CssBorderRadius.all(CssLength radius) = _CssBorderRadiusAll;

  /// Symmetric radius.
  ///
  /// The first value applies to top-left and bottom-right.
  /// The second value applies to top-right and bottom-left.
  factory CssBorderRadius.symmetric(
    CssLength topLeftBottomRight,
    CssLength topRightBottomLeft,
  ) = _CssBorderRadiusSymmetric;

  /// Three-value shorthand.
  ///
  /// - [topLeft]: Top-left corner.
  /// - [topRightBottomLeft]: Top-right and bottom-left corners.
  /// - [bottomRight]: Bottom-right corner.
  factory CssBorderRadius.only({
    required CssLength topLeft,
    required CssLength topRightBottomLeft,
    required CssLength bottomRight,
  }) = _CssBorderRadiusThree;

  /// Four-value shorthand (top-left, top-right, bottom-right, bottom-left).
  factory CssBorderRadius.trbl(
    CssLength topLeft,
    CssLength topRight,
    CssLength bottomRight,
    CssLength bottomLeft,
  ) = _CssBorderRadiusFour;

  /// CSS variable reference.
  factory CssBorderRadius.variable(String varName) = _CssBorderRadiusVariable;

  /// Raw CSS value escape hatch.
  factory CssBorderRadius.raw(String value) = _CssBorderRadiusRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBorderRadius.global(CssGlobal global) = _CssBorderRadiusGlobal;
}

final class _CssBorderRadiusAll extends CssBorderRadius {
  final CssLength value;
  const _CssBorderRadiusAll(this.value) : super._();

  @override
  String toCss() => value.toCss();
}

final class _CssBorderRadiusSymmetric extends CssBorderRadius {
  final CssLength topLeftBottomRight;
  final CssLength topRightBottomLeft;
  const _CssBorderRadiusSymmetric(
    this.topLeftBottomRight,
    this.topRightBottomLeft,
  ) : super._();

  @override
  String toCss() =>
      '${topLeftBottomRight.toCss()} ${topRightBottomLeft.toCss()}';
}

final class _CssBorderRadiusThree extends CssBorderRadius {
  final CssLength topLeft;
  final CssLength topRightBottomLeft;
  final CssLength bottomRight;
  const _CssBorderRadiusThree({
    required this.topLeft,
    required this.topRightBottomLeft,
    required this.bottomRight,
  }) : super._();

  @override
  String toCss() =>
      '${topLeft.toCss()} ${topRightBottomLeft.toCss()} ${bottomRight.toCss()}';
}

final class _CssBorderRadiusFour extends CssBorderRadius {
  final CssLength topLeft;
  final CssLength topRight;
  final CssLength bottomRight;
  final CssLength bottomLeft;
  const _CssBorderRadiusFour(
    this.topLeft,
    this.topRight,
    this.bottomRight,
    this.bottomLeft,
  ) : super._();

  @override
  String toCss() =>
      '${topLeft.toCss()} ${topRight.toCss()} ${bottomRight.toCss()} ${bottomLeft.toCss()}';
}

final class _CssBorderRadiusVariable extends CssBorderRadius {
  final String varName;
  const _CssBorderRadiusVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBorderRadiusRaw extends CssBorderRadius {
  final String value;
  const _CssBorderRadiusRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBorderRadiusGlobal extends CssBorderRadius {
  final CssGlobal global;
  const _CssBorderRadiusGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
