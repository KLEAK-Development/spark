import 'css_value.dart';

/// CSS scroll-snap-align property values.
sealed class CssScrollSnapAlign implements CssValue {
  const CssScrollSnapAlign._();

  static const CssScrollSnapAlign none = _CssScrollSnapAlignKeyword('none');
  static const CssScrollSnapAlign start = _CssScrollSnapAlignKeyword('start');
  static const CssScrollSnapAlign end = _CssScrollSnapAlignKeyword('end');
  static const CssScrollSnapAlign center = _CssScrollSnapAlignKeyword('center');

  /// Two-value syntax: inline alignment and block alignment.
  ///
  /// Example: `CssScrollSnapAlign.pair('start', 'end')` → `start end`
  factory CssScrollSnapAlign.pair(String align, String blockAlign) =
      _CssScrollSnapAlignPair;

  /// CSS variable reference.
  factory CssScrollSnapAlign.variable(String varName) =
      _CssScrollSnapAlignVariable;

  /// Raw CSS value escape hatch.
  factory CssScrollSnapAlign.raw(String value) = _CssScrollSnapAlignRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssScrollSnapAlign.global(CssGlobal global) =
      _CssScrollSnapAlignGlobal;
}

final class _CssScrollSnapAlignKeyword extends CssScrollSnapAlign {
  final String keyword;
  const _CssScrollSnapAlignKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssScrollSnapAlignPair extends CssScrollSnapAlign {
  final String align;
  final String blockAlign;
  const _CssScrollSnapAlignPair(this.align, this.blockAlign) : super._();

  @override
  String toCss() => '$align $blockAlign';
}

final class _CssScrollSnapAlignVariable extends CssScrollSnapAlign {
  final String varName;
  const _CssScrollSnapAlignVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssScrollSnapAlignRaw extends CssScrollSnapAlign {
  final String value;
  const _CssScrollSnapAlignRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssScrollSnapAlignGlobal extends CssScrollSnapAlign {
  final CssGlobal global;
  const _CssScrollSnapAlignGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
