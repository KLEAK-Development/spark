import 'css_length.dart';
import 'css_value.dart';

/// CSS scroll-margin property values.
sealed class CssScrollMargin implements CssValue {
  const CssScrollMargin._();

  /// Same value for all four sides.
  ///
  /// Example: `CssScrollMargin.all(CssLength.px(10))` → `10px`
  factory CssScrollMargin.all(CssLength value) = _CssScrollMarginAll;

  /// Symmetric scroll margin (vertical and horizontal).
  ///
  /// Example: `CssScrollMargin.symmetric(CssLength.px(10), CssLength.px(20))` → `10px 20px`
  factory CssScrollMargin.symmetric(CssLength vertical, CssLength horizontal) =
      _CssScrollMarginSymmetric;

  /// Individual sides.
  ///
  /// Example: `CssScrollMargin.only(top: CssLength.px(10), right: CssLength.px(20), bottom: CssLength.px(30), left: CssLength.px(40))` → `10px 20px 30px 40px`
  factory CssScrollMargin.only({
    CssLength? top,
    CssLength? right,
    CssLength? bottom,
    CssLength? left,
  }) = _CssScrollMarginOnly;

  /// CSS variable reference.
  factory CssScrollMargin.variable(String varName) = _CssScrollMarginVariable;

  /// Raw CSS value escape hatch.
  factory CssScrollMargin.raw(String value) = _CssScrollMarginRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssScrollMargin.global(CssGlobal global) = _CssScrollMarginGlobal;
}

final class _CssScrollMarginAll extends CssScrollMargin {
  final CssLength value;
  const _CssScrollMarginAll(this.value) : super._();

  @override
  String toCss() => value.toCss();
}

final class _CssScrollMarginSymmetric extends CssScrollMargin {
  final CssLength vertical;
  final CssLength horizontal;
  const _CssScrollMarginSymmetric(this.vertical, this.horizontal) : super._();

  @override
  String toCss() => '${vertical.toCss()} ${horizontal.toCss()}';
}

final class _CssScrollMarginOnly extends CssScrollMargin {
  final CssLength? top;
  final CssLength? right;
  final CssLength? bottom;
  final CssLength? left;
  const _CssScrollMarginOnly({this.top, this.right, this.bottom, this.left})
    : super._();

  @override
  String toCss() {
    final t = top ?? CssLength.zero;
    final r = right ?? CssLength.zero;
    final b = bottom ?? CssLength.zero;
    final l = left ?? CssLength.zero;
    return '${t.toCss()} ${r.toCss()} ${b.toCss()} ${l.toCss()}';
  }
}

final class _CssScrollMarginVariable extends CssScrollMargin {
  final String varName;
  const _CssScrollMarginVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssScrollMarginRaw extends CssScrollMargin {
  final String value;
  const _CssScrollMarginRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssScrollMarginGlobal extends CssScrollMargin {
  final CssGlobal global;
  const _CssScrollMarginGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
