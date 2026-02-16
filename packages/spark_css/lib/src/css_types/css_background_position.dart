import 'css_length.dart';
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

  /// Top left position (`top left`).
  static const CssBackgroundPosition topLeft = _CssBackgroundPositionKeyword(
    'top left',
  );

  /// Top right position (`top right`).
  static const CssBackgroundPosition topRight = _CssBackgroundPositionKeyword(
    'top right',
  );

  /// Bottom left position (`bottom left`).
  static const CssBackgroundPosition bottomLeft = _CssBackgroundPositionKeyword(
    'bottom left',
  );

  /// Bottom right position (`bottom right`).
  static const CssBackgroundPosition bottomRight =
      _CssBackgroundPositionKeyword('bottom right');

  /// Creates a position from x and y coordinates.
  factory CssBackgroundPosition.xy(CssLength x, CssLength y) =
      _CssBackgroundPositionXY;

  /// Creates a position from x coordinate (y defaults to center).
  factory CssBackgroundPosition.x(CssLength x) = _CssBackgroundPositionX;

  /// Creates a position from y coordinate (x defaults to center).
  factory CssBackgroundPosition.y(CssLength y) = _CssBackgroundPositionY;

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

final class _CssBackgroundPositionXY extends CssBackgroundPosition {
  final CssLength x;
  final CssLength y;
  const _CssBackgroundPositionXY(this.x, this.y) : super._();

  @override
  String toCss() => '${x.toCss()} ${y.toCss()}';
}

final class _CssBackgroundPositionX extends CssBackgroundPosition {
  final CssLength x;
  const _CssBackgroundPositionX(this.x) : super._();

  @override
  String toCss() => x.toCss();
}

final class _CssBackgroundPositionY extends CssBackgroundPosition {
  final CssLength y;
  const _CssBackgroundPositionY(this.y) : super._();

  @override
  String toCss() => 'center ${y.toCss()}';
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
