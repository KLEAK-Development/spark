import 'css_flex.dart';
import 'css_justify_items.dart';
import 'css_value.dart';

/// CSS place-items shorthand property values.
sealed class CssPlaceItems implements CssValue {
  const CssPlaceItems._();

  /// Shorthand with align and optional justify.
  factory CssPlaceItems(CssAlignItems align, [CssJustifyItems? justify]) =
      _CssPlaceItemsShorthand;

  /// CSS variable reference.
  factory CssPlaceItems.variable(String varName) = _CssPlaceItemsVariable;

  /// Raw CSS value escape hatch.
  factory CssPlaceItems.raw(String value) = _CssPlaceItemsRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssPlaceItems.global(CssGlobal global) = _CssPlaceItemsGlobal;
}

final class _CssPlaceItemsShorthand extends CssPlaceItems {
  final CssAlignItems align;
  final CssJustifyItems? justify;
  const _CssPlaceItemsShorthand(this.align, [this.justify]) : super._();

  @override
  String toCss() {
    if (justify == null) return align.toCss();
    return '${align.toCss()} ${justify!.toCss()}';
  }
}

final class _CssPlaceItemsVariable extends CssPlaceItems {
  final String varName;
  const _CssPlaceItemsVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssPlaceItemsRaw extends CssPlaceItems {
  final String value;
  const _CssPlaceItemsRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssPlaceItemsGlobal extends CssPlaceItems {
  final CssGlobal global;
  const _CssPlaceItemsGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
