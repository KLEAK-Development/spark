import 'css_length.dart';
import 'css_value.dart';

/// CSS spacing value for margin and padding properties.
///
/// Supports all CSS shorthand syntaxes:
/// - Single value: `CssSpacing.all(CssLength.px(10))` → `10px`
/// - Two values: `CssSpacing.symmetric(vertical, horizontal)` → `10px 20px`
/// - Three values: `CssSpacing.only(top, horizontal, bottom)` → `10px 20px 30px`
/// - Four values: `CssSpacing.trbl(top, right, bottom, left)` → `10px 20px 30px 40px`
sealed class CssSpacing implements CssValue {
  const CssSpacing._();

  /// Zero spacing.
  static const CssSpacing zero = _CssSpacingAll(CssLength.zero);

  /// Same value for all four sides.
  ///
  /// Example: `CssSpacing.all(CssLength.px(10))` → `10px`
  factory CssSpacing.all(CssLength value) = _CssSpacingAll;

  /// Symmetric spacing (vertical and horizontal).
  ///
  /// Example: `CssSpacing.symmetric(CssLength.px(10), CssLength.px(20))` → `10px 20px`
  factory CssSpacing.symmetric(CssLength vertical, CssLength horizontal) =
      _CssSpacingSymmetric;

  /// Three-value shorthand (top, horizontal, bottom).
  ///
  /// Example: `CssSpacing.only(top: CssLength.px(10), horizontal: CssLength.px(20), bottom: CssLength.px(30))` → `10px 20px 30px`
  factory CssSpacing.only({
    required CssLength top,
    required CssLength horizontal,
    required CssLength bottom,
  }) = _CssSpacingThree;

  /// Four-value shorthand (top, right, bottom, left).
  ///
  /// Example: `CssSpacing.trbl(top, right, bottom, left)` → `10px 20px 30px 40px`
  factory CssSpacing.trbl(
    CssLength top,
    CssLength right,
    CssLength bottom,
    CssLength left,
  ) = _CssSpacingFour;

  /// Create spacing from individual sides.
  ///
  /// Only non-null values are included. If all four are provided, uses TRBL syntax.
  /// This is a convenience factory for cases where you want named parameters.
  factory CssSpacing.sides({
    CssLength? top,
    CssLength? right,
    CssLength? bottom,
    CssLength? left,
  }) {
    // If all four are the same and provided
    if (top != null && right == null && bottom == null && left == null) {
      return _CssSpacingAll(top);
    }

    // Count non-null values
    final hasTop = top != null;
    final hasRight = right != null;
    final hasBottom = bottom != null;
    final hasLeft = left != null;

    if (hasTop && hasRight && hasBottom && hasLeft) {
      return _CssSpacingFour(top, right, bottom, left);
    }

    // For partial values, use raw with the values we have
    // This is a fallback - ideally users use the specific factories
    final parts = <String>[];
    if (hasTop) parts.add(top.toCss());
    if (hasRight) parts.add(right.toCss());
    if (hasBottom) parts.add(bottom.toCss());
    if (hasLeft) parts.add(left.toCss());

    if (parts.isEmpty) {
      return _CssSpacingAll(CssLength.zero);
    }

    return _CssSpacingRaw(parts.join(' '));
  }

  /// CSS variable reference.
  factory CssSpacing.variable(String varName) = _CssSpacingVariable;

  /// Raw CSS value escape hatch.
  factory CssSpacing.raw(String value) = _CssSpacingRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssSpacing.global(CssGlobal global) = _CssSpacingGlobal;

  /// Create from a single CssLength (convenience for migration).
  factory CssSpacing.length(CssLength value) = _CssSpacingAll;
}

final class _CssSpacingAll extends CssSpacing {
  final CssLength value;
  const _CssSpacingAll(this.value) : super._();

  @override
  String toCss() => value.toCss();
}

final class _CssSpacingSymmetric extends CssSpacing {
  final CssLength vertical;
  final CssLength horizontal;
  const _CssSpacingSymmetric(this.vertical, this.horizontal) : super._();

  @override
  String toCss() => '${vertical.toCss()} ${horizontal.toCss()}';
}

final class _CssSpacingThree extends CssSpacing {
  final CssLength top;
  final CssLength horizontal;
  final CssLength bottom;
  const _CssSpacingThree({
    required this.top,
    required this.horizontal,
    required this.bottom,
  }) : super._();

  @override
  String toCss() => '${top.toCss()} ${horizontal.toCss()} ${bottom.toCss()}';
}

final class _CssSpacingFour extends CssSpacing {
  final CssLength top;
  final CssLength right;
  final CssLength bottom;
  final CssLength left;
  const _CssSpacingFour(this.top, this.right, this.bottom, this.left)
    : super._();

  @override
  String toCss() =>
      '${top.toCss()} ${right.toCss()} ${bottom.toCss()} ${left.toCss()}';
}

final class _CssSpacingVariable extends CssSpacing {
  final String varName;
  const _CssSpacingVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssSpacingRaw extends CssSpacing {
  final String value;
  const _CssSpacingRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssSpacingGlobal extends CssSpacing {
  final CssGlobal global;
  const _CssSpacingGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
