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

  /// CSS variable reference.
  factory CssAngle.variable(String varName) = _CssAngleVariable;

  /// Raw CSS value escape hatch.
  factory CssAngle.raw(String value) = _CssAngleRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAngle.global(CssGlobal global) = _CssAngleGlobal;
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

final class _CssAngleVariable extends CssAngle {
  final String varName;
  const _CssAngleVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAngleRaw extends CssAngle {
  final String value;
  const _CssAngleRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssAngleGlobal extends CssAngle {
  final CssGlobal global;
  const _CssAngleGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}
