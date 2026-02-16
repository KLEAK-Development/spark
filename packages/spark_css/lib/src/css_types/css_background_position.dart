import 'css_value.dart';

/// CSS background-position property values.
sealed class CssBackgroundPosition implements CssValue {
  const CssBackgroundPosition._();

  // Keyword values
  static const CssBackgroundPosition left = _CssBackgroundPositionKeyword(
    'left',
  );
  static const CssBackgroundPosition center = _CssBackgroundPositionKeyword(
    'center',
  );
  static const CssBackgroundPosition right = _CssBackgroundPositionKeyword(
    'right',
  );
  static const CssBackgroundPosition top = _CssBackgroundPositionKeyword('top');
  static const CssBackgroundPosition bottom = _CssBackgroundPositionKeyword(
    'bottom',
  );

  /// Creates a position from one to four values (keywords or lengths).
  ///
  /// Example:
  /// ```dart
  /// CssBackgroundPosition.parts([CssBackgroundPosition.left, CssLength.px(20)])
  /// // Output: left 20px
  /// ```
  factory CssBackgroundPosition.parts(List<CssValue> values) =
      _CssBackgroundPositionParts;

  /// Multiple background positions (comma-separated).
  ///
  /// Example:
  /// ```dart
  /// CssBackgroundPosition.multiple([
  ///   CssBackgroundPosition.parts([CssBackgroundPosition.left]),
  ///   CssBackgroundPosition.parts([CssBackgroundPosition.right]),
  /// ])
  /// // Output: left, right
  /// ```
  factory CssBackgroundPosition.multiple(
    List<CssBackgroundPosition> positions,
  ) = _CssBackgroundPositionMultiple;

  /// CSS variable reference.
  factory CssBackgroundPosition.variable(String varName) =
      _CssBackgroundPositionVariable;

  /// Raw CSS value escape hatch.
  factory CssBackgroundPosition.raw(String value) = _CssBackgroundPositionRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBackgroundPosition.global(CssGlobal global) =
      _CssBackgroundPositionGlobal;
}

final class _CssBackgroundPositionKeyword extends CssBackgroundPosition {
  final String keyword;
  const _CssBackgroundPositionKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBackgroundPositionParts extends CssBackgroundPosition {
  final List<CssValue> values;
  const _CssBackgroundPositionParts(this.values) : super._();

  @override
  String toCss() => values.map((v) => v.toCss()).join(' ');
}

final class _CssBackgroundPositionMultiple extends CssBackgroundPosition {
  final List<CssBackgroundPosition> positions;
  const _CssBackgroundPositionMultiple(this.positions) : super._();

  @override
  String toCss() => positions.map((p) => p.toCss()).join(', ');
}

final class _CssBackgroundPositionVariable extends CssBackgroundPosition {
  final String varName;
  const _CssBackgroundPositionVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBackgroundPositionRaw extends CssBackgroundPosition {
  final String value;
  const _CssBackgroundPositionRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBackgroundPositionGlobal extends CssBackgroundPosition {
  final CssGlobal global;
  const _CssBackgroundPositionGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
