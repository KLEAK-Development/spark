import 'css_length.dart';
import 'css_value.dart';

/// CSS angle value.
sealed class CssAngle implements CssValue {
  const CssAngle._();

  /// Degrees.
  factory CssAngle.deg(num value) = _CssAngleDeg;

  /// Radians.
  factory CssAngle.rad(num value) = _CssAngleRad;

  /// Gradians.
  factory CssAngle.grad(num value) = _CssAngleGrad;

  /// Turns.
  factory CssAngle.turn(num value) = _CssAngleTurn;
}

final class _CssAngleDeg extends CssAngle {
  final num value;
  const _CssAngleDeg(this.value) : super._();
  @override
  String toCss() => '${value}deg';
}

final class _CssAngleRad extends CssAngle {
  final num value;
  const _CssAngleRad(this.value) : super._();
  @override
  String toCss() => '${value}rad';
}

final class _CssAngleGrad extends CssAngle {
  final num value;
  const _CssAngleGrad(this.value) : super._();
  @override
  String toCss() => '${value}grad';
}

final class _CssAngleTurn extends CssAngle {
  final num value;
  const _CssAngleTurn(this.value) : super._();
  @override
  String toCss() => '${value}turn';
}

/// CSS transform functions.
sealed class CssTransform implements CssValue {
  const CssTransform._();

  /// `none` keyword.
  static const CssTransform none = _CssTransformKeyword('none');

  /// `translateX` function.
  factory CssTransform.translateX(CssLength x) = _CssTransformTranslateX;

  /// `translateY` function.
  factory CssTransform.translateY(CssLength y) = _CssTransformTranslateY;

  /// `translate` function.
  factory CssTransform.translate(CssLength x, [CssLength? y]) =
      _CssTransformTranslate;

  /// `scaleX` function.
  factory CssTransform.scaleX(num s) = _CssTransformScaleX;

  /// `scaleY` function.
  factory CssTransform.scaleY(num s) = _CssTransformScaleY;

  /// `scale` function.
  factory CssTransform.scale(num x, [num? y]) = _CssTransformScale;

  /// `rotate` function.
  factory CssTransform.rotate(CssAngle angle) = _CssTransformRotate;

  /// `skewX` function.
  factory CssTransform.skewX(CssAngle angle) = _CssTransformSkewX;

  /// `skewY` function.
  factory CssTransform.skewY(CssAngle angle) = _CssTransformSkewY;

  /// `skew` function.
  factory CssTransform.skew(CssAngle x, [CssAngle? y]) = _CssTransformSkew;

  /// `matrix` function.
  factory CssTransform.matrix(num a, num b, num c, num d, num tx, num ty) =
      _CssTransformMatrix;

  /// Multiple transforms.
  factory CssTransform.list(List<CssTransform> transforms) = _CssTransformList;

  /// CSS variable reference.
  factory CssTransform.variable(String varName) = _CssTransformVariable;

  /// Raw CSS value escape hatch.
  factory CssTransform.raw(String value) = _CssTransformRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssTransform.global(CssGlobal global) = _CssTransformGlobal;
}

final class _CssTransformKeyword extends CssTransform {
  final String keyword;
  const _CssTransformKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssTransformTranslateX extends CssTransform {
  final CssLength x;
  const _CssTransformTranslateX(this.x) : super._();

  @override
  String toCss() => 'translateX(${x.toCss()})';
}

final class _CssTransformTranslateY extends CssTransform {
  final CssLength y;
  const _CssTransformTranslateY(this.y) : super._();

  @override
  String toCss() => 'translateY(${y.toCss()})';
}

final class _CssTransformTranslate extends CssTransform {
  final CssLength x;
  final CssLength? y;
  const _CssTransformTranslate(this.x, [this.y]) : super._();

  @override
  String toCss() {
    if (y != null) {
      return 'translate(${x.toCss()}, ${y!.toCss()})';
    }
    return 'translate(${x.toCss()})';
  }
}

final class _CssTransformScaleX extends CssTransform {
  final num s;
  const _CssTransformScaleX(this.s) : super._();

  @override
  String toCss() => 'scaleX($s)';
}

final class _CssTransformScaleY extends CssTransform {
  final num s;
  const _CssTransformScaleY(this.s) : super._();

  @override
  String toCss() => 'scaleY($s)';
}

final class _CssTransformScale extends CssTransform {
  final num x;
  final num? y;
  const _CssTransformScale(this.x, [this.y]) : super._();

  @override
  String toCss() {
    if (y != null) {
      return 'scale($x, $y)';
    }
    return 'scale($x)';
  }
}

final class _CssTransformRotate extends CssTransform {
  final CssAngle angle;
  const _CssTransformRotate(this.angle) : super._();

  @override
  String toCss() => 'rotate(${angle.toCss()})';
}

final class _CssTransformSkewX extends CssTransform {
  final CssAngle angle;
  const _CssTransformSkewX(this.angle) : super._();

  @override
  String toCss() => 'skewX(${angle.toCss()})';
}

final class _CssTransformSkewY extends CssTransform {
  final CssAngle angle;
  const _CssTransformSkewY(this.angle) : super._();

  @override
  String toCss() => 'skewY(${angle.toCss()})';
}

final class _CssTransformSkew extends CssTransform {
  final CssAngle x;
  final CssAngle? y;
  const _CssTransformSkew(this.x, [this.y]) : super._();

  @override
  String toCss() {
    if (y != null) {
      return 'skew(${x.toCss()}, ${y!.toCss()})';
    }
    return 'skew(${x.toCss()})';
  }
}

final class _CssTransformMatrix extends CssTransform {
  final num a, b, c, d, tx, ty;
  const _CssTransformMatrix(this.a, this.b, this.c, this.d, this.tx, this.ty)
    : super._();

  @override
  String toCss() => 'matrix($a, $b, $c, $d, $tx, $ty)';
}

final class _CssTransformList extends CssTransform {
  final List<CssTransform> transforms;
  const _CssTransformList(this.transforms) : super._();

  @override
  String toCss() => transforms.map((t) => t.toCss()).join(' ');
}

final class _CssTransformVariable extends CssTransform {
  final String varName;
  const _CssTransformVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTransformRaw extends CssTransform {
  final String value;
  const _CssTransformRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssTransformGlobal extends CssTransform {
  final CssGlobal global;
  const _CssTransformGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
