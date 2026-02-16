import 'css_color.dart';
import 'css_length.dart';
import 'css_value.dart';

/// CSS box-shadow value type.
sealed class CssBoxShadow implements CssValue {
  const CssBoxShadow._();

  /// No shadow.
  static const CssBoxShadow none = _CssBoxShadowKeyword('none');

  /// Creates a single box-shadow value.
  factory CssBoxShadow({
    required CssLength x,
    required CssLength y,
    CssLength? blur,
    CssLength? spread,
    CssColor? color,
    bool? inset,
  }) = _CssBoxShadowSingle;

  /// Creates a list of box-shadow values.
  factory CssBoxShadow.multiple(List<CssBoxShadow> shadows) =
      _CssBoxShadowMultiple;

  /// CSS variable reference.
  factory CssBoxShadow.variable(String varName) = _CssBoxShadowVariable;

  /// Raw CSS value escape hatch.
  factory CssBoxShadow.raw(String value) = _CssBoxShadowRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBoxShadow.global(CssGlobal global) = _CssBoxShadowGlobal;
}

final class _CssBoxShadowKeyword extends CssBoxShadow {
  final String keyword;
  const _CssBoxShadowKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBoxShadowSingle extends CssBoxShadow {
  final CssLength x;
  final CssLength y;
  final CssLength? blur;
  final CssLength? spread;
  final CssColor? color;
  final bool inset;

  const _CssBoxShadowSingle({
    required this.x,
    required this.y,
    this.blur,
    this.spread,
    this.color,
    bool? inset,
  }) : inset = inset ?? false,
       super._();

  @override
  String toCss() {
    final parts = <String>[];
    if (inset) parts.add('inset');
    parts.add(x.toCss());
    parts.add(y.toCss());
    if (blur != null) {
      parts.add(blur!.toCss());
    }
    if (spread != null) {
      if (blur == null) {
        parts.add('0'); // spread requires blur to be present
      }
      parts.add(spread!.toCss());
    }
    if (color != null) {
      parts.add(color!.toCss());
    }
    return parts.join(' ');
  }
}

final class _CssBoxShadowMultiple extends CssBoxShadow {
  final List<CssBoxShadow> shadows;
  const _CssBoxShadowMultiple(this.shadows) : super._();

  @override
  String toCss() => shadows.map((s) => s.toCss()).join(', ');
}

final class _CssBoxShadowVariable extends CssBoxShadow {
  final String varName;
  const _CssBoxShadowVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBoxShadowRaw extends CssBoxShadow {
  final String value;
  const _CssBoxShadowRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBoxShadowGlobal extends CssBoxShadow {
  final CssGlobal global;
  const _CssBoxShadowGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
