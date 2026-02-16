import 'css_value.dart';

/// CSS radial-gradient ending shape.
sealed class CssRadialShape implements CssValue {
  const CssRadialShape._();

  /// Circular shape (`circle`).
  static const CssRadialShape circle = _CssRadialShapeKeyword('circle');

  /// Elliptical shape (`ellipse`).
  static const CssRadialShape ellipse = _CssRadialShapeKeyword('ellipse');

  /// Raw CSS value escape hatch.
  factory CssRadialShape.raw(String value) = _CssRadialShapeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssRadialShape.global(CssGlobal global) = _CssRadialShapeGlobal;
}

final class _CssRadialShapeKeyword extends CssRadialShape {
  final String keyword;
  const _CssRadialShapeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssRadialShapeRaw extends CssRadialShape {
  final String value;
  const _CssRadialShapeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssRadialShapeGlobal extends CssRadialShape {
  final CssGlobal global;
  const _CssRadialShapeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
