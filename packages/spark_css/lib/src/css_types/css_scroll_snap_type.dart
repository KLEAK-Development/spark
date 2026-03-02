import 'css_value.dart';

/// CSS scroll-snap-type property values.
sealed class CssScrollSnapType implements CssValue {
  const CssScrollSnapType._();

  static const CssScrollSnapType none = _CssScrollSnapTypeKeyword('none');

  /// Scroll snap type with axis and optional strictness.
  ///
  /// [axis] must be one of: `x`, `y`, `block`, `inline`, `both`.
  /// [strictness] is optional: `mandatory` or `proximity`.
  ///
  /// Example: `CssScrollSnapType.axis('x', 'mandatory')` → `x mandatory`
  factory CssScrollSnapType.axis(String axis, [String? strictness]) =
      _CssScrollSnapTypeAxis;

  /// CSS variable reference.
  factory CssScrollSnapType.variable(String varName) =
      _CssScrollSnapTypeVariable;

  /// Raw CSS value escape hatch.
  factory CssScrollSnapType.raw(String value) = _CssScrollSnapTypeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssScrollSnapType.global(CssGlobal global) = _CssScrollSnapTypeGlobal;
}

final class _CssScrollSnapTypeKeyword extends CssScrollSnapType {
  final String keyword;
  const _CssScrollSnapTypeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssScrollSnapTypeAxis extends CssScrollSnapType {
  final String axis;
  final String? strictness;
  const _CssScrollSnapTypeAxis(this.axis, [this.strictness]) : super._();

  @override
  String toCss() => strictness != null ? '$axis $strictness' : axis;
}

final class _CssScrollSnapTypeVariable extends CssScrollSnapType {
  final String varName;
  const _CssScrollSnapTypeVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssScrollSnapTypeRaw extends CssScrollSnapType {
  final String value;
  const _CssScrollSnapTypeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssScrollSnapTypeGlobal extends CssScrollSnapType {
  final CssGlobal global;
  const _CssScrollSnapTypeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
