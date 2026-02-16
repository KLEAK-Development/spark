import 'css_color.dart';
import 'css_length.dart';
import 'css_value.dart';

/// CSS text-shadow value type.
sealed class CssTextShadow implements CssValue {
  const CssTextShadow._();

  /// No text shadow.
  static const CssTextShadow none = _CssTextShadowKeyword('none');

  /// Creates a single text shadow.
  factory CssTextShadow({
    required CssLength x,
    required CssLength y,
    CssLength? blur,
    CssColor? color,
  }) = _CssTextShadowSingle;

  /// Creates multiple text shadows.
  factory CssTextShadow.multiple(List<CssTextShadow> shadows) =
      _CssTextShadowMultiple;

  /// CSS variable reference.
  factory CssTextShadow.variable(String varName) = _CssTextShadowVariable;

  /// Raw CSS value escape hatch.
  factory CssTextShadow.raw(String value) = _CssTextShadowRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssTextShadow.global(CssGlobal global) = _CssTextShadowGlobal;
}

final class _CssTextShadowKeyword extends CssTextShadow {
  final String keyword;
  const _CssTextShadowKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssTextShadowSingle extends CssTextShadow {
  final CssLength x;
  final CssLength y;
  final CssLength? blur;
  final CssColor? color;

  const _CssTextShadowSingle({
    required this.x,
    required this.y,
    this.blur,
    this.color,
  }) : super._();

  @override
  String toCss() {
    final parts = [x.toCss(), y.toCss()];
    if (blur != null) parts.add(blur!.toCss());
    if (color != null) parts.add(color!.toCss());
    return parts.join(' ');
  }
}

final class _CssTextShadowMultiple extends CssTextShadow {
  final List<CssTextShadow> shadows;
  const _CssTextShadowMultiple(this.shadows) : super._();

  @override
  String toCss() => shadows.map((s) => s.toCss()).join(', ');
}

final class _CssTextShadowVariable extends CssTextShadow {
  final String varName;
  const _CssTextShadowVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTextShadowRaw extends CssTextShadow {
  final String value;
  const _CssTextShadowRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssTextShadowGlobal extends CssTextShadow {
  final CssGlobal global;
  const _CssTextShadowGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
