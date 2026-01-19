import 'css_color.dart';
import 'css_length.dart';
import 'css_value.dart';

/// CSS border-style values.
sealed class CssBorderStyle implements CssValue {
  const CssBorderStyle._();

  static const CssBorderStyle none = _CssBorderStyleKeyword('none');
  static const CssBorderStyle hidden = _CssBorderStyleKeyword('hidden');
  static const CssBorderStyle solid = _CssBorderStyleKeyword('solid');
  static const CssBorderStyle dashed = _CssBorderStyleKeyword('dashed');
  static const CssBorderStyle dotted = _CssBorderStyleKeyword('dotted');
  static const CssBorderStyle double_ = _CssBorderStyleKeyword('double');
  static const CssBorderStyle groove = _CssBorderStyleKeyword('groove');
  static const CssBorderStyle ridge = _CssBorderStyleKeyword('ridge');
  static const CssBorderStyle inset = _CssBorderStyleKeyword('inset');
  static const CssBorderStyle outset = _CssBorderStyleKeyword('outset');

  /// CSS variable reference.
  factory CssBorderStyle.variable(String varName) = _CssBorderStyleVariable;

  /// Raw CSS value escape hatch.
  factory CssBorderStyle.raw(String value) = _CssBorderStyleRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBorderStyle.global(CssGlobal global) = _CssBorderStyleGlobal;
}

final class _CssBorderStyleKeyword extends CssBorderStyle {
  final String keyword;
  const _CssBorderStyleKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBorderStyleVariable extends CssBorderStyle {
  final String varName;
  const _CssBorderStyleVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBorderStyleRaw extends CssBorderStyle {
  final String value;
  const _CssBorderStyleRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBorderStyleGlobal extends CssBorderStyle {
  final CssGlobal global;
  const _CssBorderStyleGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}

/// CSS border shorthand value.
sealed class CssBorder implements CssValue {
  const CssBorder._();

  static const CssBorder none = _CssBorderKeyword('none');

  /// Full border shorthand: width style color.
  factory CssBorder({
    required CssLength width,
    required CssBorderStyle style,
    CssColor? color,
  }) = _CssBorderShorthand;

  /// Border with just width and style.
  factory CssBorder.widthStyle(CssLength width, CssBorderStyle style) =>
      _CssBorderShorthand(width: width, style: style);

  /// CSS variable reference.
  factory CssBorder.variable(String varName) = _CssBorderVariable;

  /// Raw CSS value escape hatch.
  factory CssBorder.raw(String value) = _CssBorderRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBorder.global(CssGlobal global) = _CssBorderGlobal;
}

final class _CssBorderKeyword extends CssBorder {
  final String keyword;
  const _CssBorderKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBorderShorthand extends CssBorder {
  final CssLength width;
  final CssBorderStyle style;
  final CssColor? color;

  const _CssBorderShorthand({
    required this.width,
    required this.style,
    this.color,
  }) : super._();

  @override
  String toCss() {
    final parts = [width.toCss(), style.toCss()];
    if (color != null) parts.add(color!.toCss());
    return parts.join(' ');
  }
}

final class _CssBorderVariable extends CssBorder {
  final String varName;
  const _CssBorderVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBorderRaw extends CssBorder {
  final String value;
  const _CssBorderRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBorderGlobal extends CssBorder {
  final CssGlobal global;
  const _CssBorderGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
