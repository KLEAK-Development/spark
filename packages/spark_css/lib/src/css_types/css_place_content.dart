import 'css_flex.dart';
import 'css_value.dart';

/// CSS place-content shorthand property values.
sealed class CssPlaceContent implements CssValue {
  const CssPlaceContent._();

  /// Shorthand with align and optional justify.
  factory CssPlaceContent(CssAlignContent align, [CssJustifyContent? justify]) =
      _CssPlaceContentShorthand;

  /// CSS variable reference.
  factory CssPlaceContent.variable(String varName) = _CssPlaceContentVariable;

  /// Raw CSS value escape hatch.
  factory CssPlaceContent.raw(String value) = _CssPlaceContentRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssPlaceContent.global(CssGlobal global) = _CssPlaceContentGlobal;
}

final class _CssPlaceContentShorthand extends CssPlaceContent {
  final CssAlignContent align;
  final CssJustifyContent? justify;
  const _CssPlaceContentShorthand(this.align, [this.justify]) : super._();

  @override
  String toCss() {
    if (justify == null) return align.toCss();
    return '${align.toCss()} ${justify!.toCss()}';
  }
}

final class _CssPlaceContentVariable extends CssPlaceContent {
  final String varName;
  const _CssPlaceContentVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssPlaceContentRaw extends CssPlaceContent {
  final String value;
  const _CssPlaceContentRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssPlaceContentGlobal extends CssPlaceContent {
  final CssGlobal global;
  const _CssPlaceContentGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
