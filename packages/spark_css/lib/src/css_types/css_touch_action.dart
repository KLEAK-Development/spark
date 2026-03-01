import 'css_value.dart';

/// CSS touch-action property values.
sealed class CssTouchAction implements CssValue {
  const CssTouchAction._();

  static const CssTouchAction auto = _CssTouchActionKeyword('auto');
  static const CssTouchAction none = _CssTouchActionKeyword('none');
  static const CssTouchAction manipulation = _CssTouchActionKeyword(
    'manipulation',
  );
  static const CssTouchAction panX = _CssTouchActionKeyword('pan-x');
  static const CssTouchAction panLeft = _CssTouchActionKeyword('pan-left');
  static const CssTouchAction panRight = _CssTouchActionKeyword('pan-right');
  static const CssTouchAction panY = _CssTouchActionKeyword('pan-y');
  static const CssTouchAction panUp = _CssTouchActionKeyword('pan-up');
  static const CssTouchAction panDown = _CssTouchActionKeyword('pan-down');
  static const CssTouchAction pinchZoom = _CssTouchActionKeyword('pinch-zoom');

  /// Combines multiple touch-action values.
  ///
  /// Example: `CssTouchAction.combine([CssTouchAction.panX, CssTouchAction.pinchZoom])`
  /// produces `pan-x pinch-zoom`.
  factory CssTouchAction.combine(List<CssTouchAction> values) =
      _CssTouchActionCombined;

  /// CSS variable reference.
  factory CssTouchAction.variable(String varName) = _CssTouchActionVariable;

  /// Raw CSS value escape hatch.
  factory CssTouchAction.raw(String value) = _CssTouchActionRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssTouchAction.global(CssGlobal global) = _CssTouchActionGlobal;
}

final class _CssTouchActionKeyword extends CssTouchAction {
  final String keyword;
  const _CssTouchActionKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssTouchActionCombined extends CssTouchAction {
  final List<CssTouchAction> values;
  const _CssTouchActionCombined(this.values) : super._();

  @override
  String toCss() => values.map((v) => v.toCss()).join(' ');
}

final class _CssTouchActionVariable extends CssTouchAction {
  final String varName;
  const _CssTouchActionVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTouchActionRaw extends CssTouchAction {
  final String value;
  const _CssTouchActionRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssTouchActionGlobal extends CssTouchAction {
  final CssGlobal global;
  const _CssTouchActionGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
