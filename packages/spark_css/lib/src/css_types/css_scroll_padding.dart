import 'css_length.dart';
import 'css_value.dart';

/// CSS scroll-padding property values.
sealed class CssScrollPadding implements CssValue {
  const CssScrollPadding._();

  /// Same value for all four sides.
  factory CssScrollPadding.all(CssLength value) = _CssScrollPaddingAll;

  /// Symmetric scroll padding (vertical and horizontal).
  factory CssScrollPadding.symmetric(CssLength vertical, CssLength horizontal) =
      _CssScrollPaddingSymmetric;

  /// Individual sides.
  factory CssScrollPadding.only({
    CssLength? top,
    CssLength? right,
    CssLength? bottom,
    CssLength? left,
  }) = _CssScrollPaddingOnly;

  /// CSS variable reference.
  factory CssScrollPadding.variable(String varName) = _CssScrollPaddingVariable;

  /// Raw CSS value escape hatch.
  factory CssScrollPadding.raw(String value) = _CssScrollPaddingRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssScrollPadding.global(CssGlobal global) = _CssScrollPaddingGlobal;
}

final class _CssScrollPaddingAll extends CssScrollPadding {
  final CssLength value;
  const _CssScrollPaddingAll(this.value) : super._();

  @override
  String toCss() => value.toCss();
}

final class _CssScrollPaddingSymmetric extends CssScrollPadding {
  final CssLength vertical;
  final CssLength horizontal;
  const _CssScrollPaddingSymmetric(this.vertical, this.horizontal) : super._();

  @override
  String toCss() => '${vertical.toCss()} ${horizontal.toCss()}';
}

final class _CssScrollPaddingOnly extends CssScrollPadding {
  final CssLength? top;
  final CssLength? right;
  final CssLength? bottom;
  final CssLength? left;
  const _CssScrollPaddingOnly({this.top, this.right, this.bottom, this.left})
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

final class _CssScrollPaddingVariable extends CssScrollPadding {
  final String varName;
  const _CssScrollPaddingVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssScrollPaddingRaw extends CssScrollPadding {
  final String value;
  const _CssScrollPaddingRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssScrollPaddingGlobal extends CssScrollPadding {
  final CssGlobal global;
  const _CssScrollPaddingGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
