import 'css_value.dart';

/// CSS background-origin property values.
sealed class CssBackgroundOrigin implements CssValue {
  const CssBackgroundOrigin._();

  /// The background extends to the outside edge of the border.
  static const CssBackgroundOrigin borderBox = _CssBackgroundOriginKeyword(
    'border-box',
  );

  /// The background extends to the outside edge of the padding.
  static const CssBackgroundOrigin paddingBox = _CssBackgroundOriginKeyword(
    'padding-box',
  );

  /// The background extends to the outside edge of the content.
  static const CssBackgroundOrigin contentBox = _CssBackgroundOriginKeyword(
    'content-box',
  );

  /// Multiple background-origin values for multiple background images.
  factory CssBackgroundOrigin.multiple(List<CssBackgroundOrigin> values) =
      _CssBackgroundOriginMultiple;

  /// CSS variable reference.
  factory CssBackgroundOrigin.variable(String varName) =
      _CssBackgroundOriginVariable;

  /// Raw CSS value escape hatch.
  factory CssBackgroundOrigin.raw(String value) = _CssBackgroundOriginRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBackgroundOrigin.global(CssGlobal global) =
      _CssBackgroundOriginGlobal;
}

final class _CssBackgroundOriginKeyword extends CssBackgroundOrigin {
  final String keyword;
  const _CssBackgroundOriginKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBackgroundOriginMultiple extends CssBackgroundOrigin {
  final List<CssBackgroundOrigin> values;
  const _CssBackgroundOriginMultiple(this.values) : super._();

  @override
  String toCss() => values.map((e) => e.toCss()).join(', ');
}

final class _CssBackgroundOriginVariable extends CssBackgroundOrigin {
  final String varName;
  const _CssBackgroundOriginVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBackgroundOriginRaw extends CssBackgroundOrigin {
  final String value;
  const _CssBackgroundOriginRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBackgroundOriginGlobal extends CssBackgroundOrigin {
  final CssGlobal global;
  const _CssBackgroundOriginGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
