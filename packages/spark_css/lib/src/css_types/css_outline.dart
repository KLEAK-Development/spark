import 'css_border.dart';
import 'css_color.dart';
import 'css_length.dart';
import 'css_value.dart';

/// CSS outline shorthand property.
sealed class CssOutline implements CssValue {
  const CssOutline._();

  static const CssOutline none = _CssOutlineKeyword('none');

  /// Outline shorthand: [width] [style] [color].
  ///
  /// Note: The order of values in the shorthand does not matter in CSS,
  /// but we maintain a consistent order for the output string.
  factory CssOutline({
    CssLength? width,
    CssBorderStyle? style,
    CssColor? color,
  }) = _CssOutlineShorthand;

  /// CSS variable reference.
  factory CssOutline.variable(String varName) = _CssOutlineVariable;

  /// Raw CSS value escape hatch.
  factory CssOutline.raw(String value) = _CssOutlineRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssOutline.global(CssGlobal global) = _CssOutlineGlobal;
}

final class _CssOutlineKeyword extends CssOutline {
  final String keyword;
  const _CssOutlineKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssOutlineShorthand extends CssOutline {
  final CssLength? width;
  final CssBorderStyle? style;
  final CssColor? color;

  const _CssOutlineShorthand({this.width, this.style, this.color}) : super._();

  @override
  String toCss() {
    final parts = <String>[];
    if (width != null) parts.add(width!.toCss());
    if (style != null) parts.add(style!.toCss());
    if (color != null) parts.add(color!.toCss());
    return parts.isEmpty ? 'none' : parts.join(' ');
  }
}

final class _CssOutlineVariable extends CssOutline {
  final String varName;
  const _CssOutlineVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssOutlineRaw extends CssOutline {
  final String value;
  const _CssOutlineRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssOutlineGlobal extends CssOutline {
  final CssGlobal global;
  const _CssOutlineGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}

/// CSS outline-offset property.
sealed class CssOutlineOffset implements CssValue {
  const CssOutlineOffset._();

  /// Creates an outline offset with the given length.
  factory CssOutlineOffset(CssLength length) = _CssOutlineOffsetLength;

  /// CSS variable reference.
  factory CssOutlineOffset.variable(String varName) = _CssOutlineOffsetVariable;

  /// Raw CSS value escape hatch.
  factory CssOutlineOffset.raw(String value) = _CssOutlineOffsetRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssOutlineOffset.global(CssGlobal global) = _CssOutlineOffsetGlobal;
}

final class _CssOutlineOffsetLength extends CssOutlineOffset {
  final CssLength length;
  const _CssOutlineOffsetLength(this.length) : super._();

  @override
  String toCss() => length.toCss();
}

final class _CssOutlineOffsetVariable extends CssOutlineOffset {
  final String varName;
  const _CssOutlineOffsetVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssOutlineOffsetRaw extends CssOutlineOffset {
  final String value;
  const _CssOutlineOffsetRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssOutlineOffsetGlobal extends CssOutlineOffset {
  final CssGlobal global;
  const _CssOutlineOffsetGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
