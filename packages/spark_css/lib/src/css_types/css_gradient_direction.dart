import 'css_value.dart';
import 'css_angle.dart';

/// CSS linear-gradient direction.
sealed class CssGradientDirection implements CssValue {
  const CssGradientDirection._();

  /// Direction towards top (`to top`).
  static const CssGradientDirection toTop = _CssGradientDirectionKeyword(
    'to top',
  );

  /// Direction towards bottom (`to bottom`).
  static const CssGradientDirection toBottom = _CssGradientDirectionKeyword(
    'to bottom',
  );

  /// Direction towards left (`to left`).
  static const CssGradientDirection toLeft = _CssGradientDirectionKeyword(
    'to left',
  );

  /// Direction towards right (`to right`).
  static const CssGradientDirection toRight = _CssGradientDirectionKeyword(
    'to right',
  );

  /// Direction towards top left (`to top left`).
  static const CssGradientDirection toTopLeft = _CssGradientDirectionKeyword(
    'to top left',
  );

  /// Direction towards top right (`to top right`).
  static const CssGradientDirection toTopRight = _CssGradientDirectionKeyword(
    'to top right',
  );

  /// Direction towards bottom left (`to bottom left`).
  static const CssGradientDirection toBottomLeft = _CssGradientDirectionKeyword(
    'to bottom left',
  );

  /// Direction towards bottom right (`to bottom right`).
  static const CssGradientDirection toBottomRight =
      _CssGradientDirectionKeyword('to bottom right');

  /// Direction defined by an angle.
  factory CssGradientDirection.angle(CssAngle angle) =
      _CssGradientDirectionAngle;

  /// Raw CSS value escape hatch.
  factory CssGradientDirection.raw(String value) = _CssGradientDirectionRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssGradientDirection.global(CssGlobal global) =
      _CssGradientDirectionGlobal;
}

final class _CssGradientDirectionKeyword extends CssGradientDirection {
  final String keyword;
  const _CssGradientDirectionKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssGradientDirectionAngle extends CssGradientDirection {
  final CssAngle angle;
  const _CssGradientDirectionAngle(this.angle) : super._();

  @override
  String toCss() => angle.toCss();
}

final class _CssGradientDirectionRaw extends CssGradientDirection {
  final String value;
  const _CssGradientDirectionRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssGradientDirectionGlobal extends CssGradientDirection {
  final CssGlobal global;
  const _CssGradientDirectionGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
