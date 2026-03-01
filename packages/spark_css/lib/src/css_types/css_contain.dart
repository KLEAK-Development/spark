import 'css_value.dart';

/// CSS contain property values.
sealed class CssContain implements CssValue {
  const CssContain._();

  static const CssContain none = _CssContainKeyword('none');
  static const CssContain strict = _CssContainKeyword('strict');
  static const CssContain content = _CssContainKeyword('content');
  static const CssContain size = _CssContainKeyword('size');
  static const CssContain layout = _CssContainKeyword('layout');
  static const CssContain style = _CssContainKeyword('style');
  static const CssContain paint = _CssContainKeyword('paint');

  /// Constructs a `contain` value from boolean flags.
  ///
  /// Active flags are joined with spaces in the order: size, layout, style,
  /// paint. Returns `none` if no flags are true.
  factory CssContain.flags({
    bool size,
    bool layout,
    bool style,
    bool paint,
  }) = _CssContainFlags;

  /// CSS variable reference.
  factory CssContain.variable(String varName) = _CssContainVariable;

  /// Raw CSS value escape hatch.
  factory CssContain.raw(String value) = _CssContainRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssContain.global(CssGlobal global) = _CssContainGlobal;
}

final class _CssContainKeyword extends CssContain {
  final String keyword;
  const _CssContainKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssContainFlags extends CssContain {
  final bool size;
  final bool layout;
  final bool style;
  final bool paint;

  const _CssContainFlags({
    this.size = false,
    this.layout = false,
    this.style = false,
    this.paint = false,
  }) : super._();

  @override
  String toCss() {
    final parts = <String>[];
    if (size) parts.add('size');
    if (layout) parts.add('layout');
    if (style) parts.add('style');
    if (paint) parts.add('paint');
    return parts.isEmpty ? 'none' : parts.join(' ');
  }
}

final class _CssContainVariable extends CssContain {
  final String varName;
  const _CssContainVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssContainRaw extends CssContain {
  final String value;
  const _CssContainRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssContainGlobal extends CssContain {
  final CssGlobal global;
  const _CssContainGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
