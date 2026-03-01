import 'css_value.dart';

/// CSS pointer-events property values.
sealed class CssPointerEvents implements CssValue {
  const CssPointerEvents._();

  static const CssPointerEvents auto = _CssPointerEventsKeyword('auto');
  static const CssPointerEvents none = _CssPointerEventsKeyword('none');
  static const CssPointerEvents visiblePainted = _CssPointerEventsKeyword(
    'visiblePainted',
  );
  static const CssPointerEvents visibleFill = _CssPointerEventsKeyword(
    'visibleFill',
  );
  static const CssPointerEvents visibleStroke = _CssPointerEventsKeyword(
    'visibleStroke',
  );
  static const CssPointerEvents visible = _CssPointerEventsKeyword('visible');
  static const CssPointerEvents painted = _CssPointerEventsKeyword('painted');
  static const CssPointerEvents fill = _CssPointerEventsKeyword('fill');
  static const CssPointerEvents stroke = _CssPointerEventsKeyword('stroke');
  static const CssPointerEvents all = _CssPointerEventsKeyword('all');

  /// CSS variable reference.
  factory CssPointerEvents.variable(String varName) = _CssPointerEventsVariable;

  /// Raw CSS value escape hatch.
  factory CssPointerEvents.raw(String value) = _CssPointerEventsRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssPointerEvents.global(CssGlobal global) = _CssPointerEventsGlobal;
}

final class _CssPointerEventsKeyword extends CssPointerEvents {
  final String keyword;
  const _CssPointerEventsKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssPointerEventsVariable extends CssPointerEvents {
  final String varName;
  const _CssPointerEventsVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssPointerEventsRaw extends CssPointerEvents {
  final String value;
  const _CssPointerEventsRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssPointerEventsGlobal extends CssPointerEvents {
  final CssGlobal global;
  const _CssPointerEventsGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
