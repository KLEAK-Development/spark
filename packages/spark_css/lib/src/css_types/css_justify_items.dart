import 'css_value.dart';

/// CSS justify-items property values.
sealed class CssJustifyItems implements CssValue {
  const CssJustifyItems._();

  static const CssJustifyItems normal = _CssJustifyItemsKeyword('normal');
  static const CssJustifyItems stretch = _CssJustifyItemsKeyword('stretch');
  static const CssJustifyItems start = _CssJustifyItemsKeyword('start');
  static const CssJustifyItems end = _CssJustifyItemsKeyword('end');
  static const CssJustifyItems center = _CssJustifyItemsKeyword('center');
  static const CssJustifyItems left = _CssJustifyItemsKeyword('left');
  static const CssJustifyItems right = _CssJustifyItemsKeyword('right');
  static const CssJustifyItems baseline = _CssJustifyItemsKeyword('baseline');
  static const CssJustifyItems firstBaseline = _CssJustifyItemsKeyword(
    'first baseline',
  );
  static const CssJustifyItems lastBaseline = _CssJustifyItemsKeyword(
    'last baseline',
  );

  /// CSS variable reference.
  factory CssJustifyItems.variable(String varName) = _CssJustifyItemsVariable;

  /// Raw CSS value escape hatch.
  factory CssJustifyItems.raw(String value) = _CssJustifyItemsRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssJustifyItems.global(CssGlobal global) = _CssJustifyItemsGlobal;
}

final class _CssJustifyItemsKeyword extends CssJustifyItems {
  final String keyword;
  const _CssJustifyItemsKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssJustifyItemsVariable extends CssJustifyItems {
  final String varName;
  const _CssJustifyItemsVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssJustifyItemsRaw extends CssJustifyItems {
  final String value;
  const _CssJustifyItemsRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssJustifyItemsGlobal extends CssJustifyItems {
  final CssGlobal global;
  const _CssJustifyItemsGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
