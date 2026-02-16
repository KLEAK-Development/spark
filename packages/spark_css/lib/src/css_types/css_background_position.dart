import 'css_length.dart';
import 'css_value.dart';

/// CSS background-position property.
sealed class CssBackgroundPosition implements CssValue {
  const CssBackgroundPosition._();

  /// Center position (`center`).
  static const CssBackgroundPosition center = _CssBackgroundPositionKeyword(
    'center',
  );

  /// Top position (`top` - equivalent to `top center`).
  static const CssBackgroundPosition top = _CssBackgroundPositionKeyword('top');

  /// Bottom position (`bottom` - equivalent to `bottom center`).
  static const CssBackgroundPosition bottom = _CssBackgroundPositionKeyword(
    'bottom',
  );

  /// Left position (`left` - equivalent to `left center`).
  static const CssBackgroundPosition left = _CssBackgroundPositionKeyword(
    'left',
  );

  /// Right position (`right` - equivalent to `right center`).
  static const CssBackgroundPosition right = _CssBackgroundPositionKeyword(
    'right',
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

  /// Position defined by x and y coordinates.
  factory CssBackgroundPosition.xy(CssLength x, CssLength y) =
      _CssBackgroundPositionXY;

  /// Position defined by x coordinate (y defaults to center).
  factory CssBackgroundPosition.x(CssLength x) = _CssBackgroundPositionX;

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
