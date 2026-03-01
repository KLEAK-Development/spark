import 'css_value.dart';

/// CSS list-style-type values.
sealed class CssListStyleType implements CssValue {
  const CssListStyleType._();

  static const CssListStyleType disc = _CssListStyleTypeKeyword('disc');
  static const CssListStyleType circle = _CssListStyleTypeKeyword('circle');
  static const CssListStyleType square = _CssListStyleTypeKeyword('square');
  static const CssListStyleType decimal = _CssListStyleTypeKeyword('decimal');
  static const CssListStyleType none = _CssListStyleTypeKeyword('none');
}

final class _CssListStyleTypeKeyword extends CssListStyleType {
  final String keyword;
  const _CssListStyleTypeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

/// CSS list-style-position values.
sealed class CssListStylePosition implements CssValue {
  const CssListStylePosition._();

  static const CssListStylePosition inside = _CssListStylePositionKeyword(
    'inside',
  );
  static const CssListStylePosition outside = _CssListStylePositionKeyword(
    'outside',
  );
}

final class _CssListStylePositionKeyword extends CssListStylePosition {
  final String keyword;
  const _CssListStylePositionKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

/// CSS list-style shorthand property values.
sealed class CssListStyle implements CssValue {
  const CssListStyle._();

  static const CssListStyle none = _CssListStyleKeyword('none');

  /// Shorthand with optional type, position, and image.
  factory CssListStyle({
    CssListStyleType? type,
    CssListStylePosition? position,
    String? image,
  }) = _CssListStyleShorthand;

  /// CSS variable reference.
  factory CssListStyle.variable(String varName) = _CssListStyleVariable;

  /// Raw CSS value escape hatch.
  factory CssListStyle.raw(String value) = _CssListStyleRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssListStyle.global(CssGlobal global) = _CssListStyleGlobal;
}

final class _CssListStyleKeyword extends CssListStyle {
  final String keyword;
  const _CssListStyleKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssListStyleShorthand extends CssListStyle {
  final CssListStyleType? type;
  final CssListStylePosition? position;
  final String? image;

  const _CssListStyleShorthand({this.type, this.position, this.image})
    : super._();

  @override
  String toCss() {
    final parts = <String>[
      ?type?.toCss(),
      ?position?.toCss(),
      ?image,
    ];
    return parts.join(' ');
  }
}

final class _CssListStyleVariable extends CssListStyle {
  final String varName;
  const _CssListStyleVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssListStyleRaw extends CssListStyle {
  final String value;
  const _CssListStyleRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssListStyleGlobal extends CssListStyle {
  final CssGlobal global;
  const _CssListStyleGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
