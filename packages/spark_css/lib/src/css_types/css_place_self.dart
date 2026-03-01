import 'css_flex.dart';
import 'css_justify_self.dart';
import 'css_value.dart';

/// CSS place-self shorthand property values.
sealed class CssPlaceSelf implements CssValue {
  const CssPlaceSelf._();

  /// Shorthand with align and optional justify.
  factory CssPlaceSelf(CssAlignSelf align, [CssJustifySelf? justify]) =
      _CssPlaceSelfShorthand;

  /// CSS variable reference.
  factory CssPlaceSelf.variable(String varName) = _CssPlaceSelfVariable;

  /// Raw CSS value escape hatch.
  factory CssPlaceSelf.raw(String value) = _CssPlaceSelfRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssPlaceSelf.global(CssGlobal global) = _CssPlaceSelfGlobal;
}

final class _CssPlaceSelfShorthand extends CssPlaceSelf {
  final CssAlignSelf align;
  final CssJustifySelf? justify;
  const _CssPlaceSelfShorthand(this.align, [this.justify]) : super._();

  @override
  String toCss() {
    if (justify == null) return align.toCss();
    return '${align.toCss()} ${justify!.toCss()}';
  }
}

final class _CssPlaceSelfVariable extends CssPlaceSelf {
  final String varName;
  const _CssPlaceSelfVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssPlaceSelfRaw extends CssPlaceSelf {
  final String value;
  const _CssPlaceSelfRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssPlaceSelfGlobal extends CssPlaceSelf {
  final CssGlobal global;
  const _CssPlaceSelfGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
