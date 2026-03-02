import 'css_value.dart';

/// CSS overscroll-behavior property values.
sealed class CssOverscrollBehavior implements CssValue {
  const CssOverscrollBehavior._();

  static const CssOverscrollBehavior auto = _CssOverscrollBehaviorKeyword(
    'auto',
  );
  static const CssOverscrollBehavior contain = _CssOverscrollBehaviorKeyword(
    'contain',
  );
  static const CssOverscrollBehavior none = _CssOverscrollBehaviorKeyword(
    'none',
  );

  /// Two-value syntax for x and y axes.
  ///
  /// Example: `CssOverscrollBehavior.xy(CssOverscrollBehavior.contain, CssOverscrollBehavior.none)` → `contain none`
  factory CssOverscrollBehavior.xy(
    CssOverscrollBehavior x,
    CssOverscrollBehavior y,
  ) = _CssOverscrollBehaviorXY;

  /// CSS variable reference.
  factory CssOverscrollBehavior.variable(String varName) =
      _CssOverscrollBehaviorVariable;

  /// Raw CSS value escape hatch.
  factory CssOverscrollBehavior.raw(String value) = _CssOverscrollBehaviorRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssOverscrollBehavior.global(CssGlobal global) =
      _CssOverscrollBehaviorGlobal;
}

final class _CssOverscrollBehaviorKeyword extends CssOverscrollBehavior {
  final String keyword;
  const _CssOverscrollBehaviorKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssOverscrollBehaviorXY extends CssOverscrollBehavior {
  final CssOverscrollBehavior x;
  final CssOverscrollBehavior y;
  const _CssOverscrollBehaviorXY(this.x, this.y) : super._();

  @override
  String toCss() => '${x.toCss()} ${y.toCss()}';
}

final class _CssOverscrollBehaviorVariable extends CssOverscrollBehavior {
  final String varName;
  const _CssOverscrollBehaviorVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssOverscrollBehaviorRaw extends CssOverscrollBehavior {
  final String value;
  const _CssOverscrollBehaviorRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssOverscrollBehaviorGlobal extends CssOverscrollBehavior {
  final CssGlobal global;
  const _CssOverscrollBehaviorGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
