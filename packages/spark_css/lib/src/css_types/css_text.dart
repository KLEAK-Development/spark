import 'css_value.dart';

/// CSS text-align property values.
sealed class CssTextAlign implements CssValue {
  const CssTextAlign._();

  static const CssTextAlign left = _CssTextAlignKeyword('left');
  static const CssTextAlign right = _CssTextAlignKeyword('right');
  static const CssTextAlign center = _CssTextAlignKeyword('center');
  static const CssTextAlign justify = _CssTextAlignKeyword('justify');
  static const CssTextAlign start = _CssTextAlignKeyword('start');
  static const CssTextAlign end = _CssTextAlignKeyword('end');
  static const CssTextAlign matchParent = _CssTextAlignKeyword('match-parent');
  static const CssTextAlign justifyAll = _CssTextAlignKeyword('justify-all');

  /// CSS variable reference.
  factory CssTextAlign.variable(String varName) = _CssTextAlignVariable;

  /// Raw CSS value escape hatch.
  factory CssTextAlign.raw(String value) = _CssTextAlignRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssTextAlign.global(CssGlobal global) = _CssTextAlignGlobal;
}

final class _CssTextAlignKeyword extends CssTextAlign {
  final String keyword;
  const _CssTextAlignKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssTextAlignVariable extends CssTextAlign {
  final String varName;
  const _CssTextAlignVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTextAlignRaw extends CssTextAlign {
  final String value;
  const _CssTextAlignRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssTextAlignGlobal extends CssTextAlign {
  final CssGlobal global;
  const _CssTextAlignGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS text-decoration property values.
sealed class CssTextDecoration implements CssValue {
  const CssTextDecoration._();

  static const CssTextDecoration none = _CssTextDecorationKeyword('none');
  static const CssTextDecoration underline = _CssTextDecorationKeyword(
    'underline',
  );
  static const CssTextDecoration overline = _CssTextDecorationKeyword(
    'overline',
  );
  static const CssTextDecoration lineThrough = _CssTextDecorationKeyword(
    'line-through',
  );

  /// CSS variable reference.
  factory CssTextDecoration.variable(String varName) =
      _CssTextDecorationVariable;

  /// Raw CSS value escape hatch.
  factory CssTextDecoration.raw(String value) = _CssTextDecorationRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssTextDecoration.global(CssGlobal global) = _CssTextDecorationGlobal;
}

final class _CssTextDecorationKeyword extends CssTextDecoration {
  final String keyword;
  const _CssTextDecorationKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssTextDecorationVariable extends CssTextDecoration {
  final String varName;
  const _CssTextDecorationVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTextDecorationRaw extends CssTextDecoration {
  final String value;
  const _CssTextDecorationRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssTextDecorationGlobal extends CssTextDecoration {
  final CssGlobal global;
  const _CssTextDecorationGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS text-transform property values.
sealed class CssTextTransform implements CssValue {
  const CssTextTransform._();

  static const CssTextTransform none = _CssTextTransformKeyword('none');
  static const CssTextTransform uppercase = _CssTextTransformKeyword(
    'uppercase',
  );
  static const CssTextTransform lowercase = _CssTextTransformKeyword(
    'lowercase',
  );
  static const CssTextTransform capitalize = _CssTextTransformKeyword(
    'capitalize',
  );
  static const CssTextTransform fullWidth = _CssTextTransformKeyword(
    'full-width',
  );
  static const CssTextTransform fullSizeKana = _CssTextTransformKeyword(
    'full-size-kana',
  );

  /// CSS variable reference.
  factory CssTextTransform.variable(String varName) = _CssTextTransformVariable;

  /// Raw CSS value escape hatch.
  factory CssTextTransform.raw(String value) = _CssTextTransformRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssTextTransform.global(CssGlobal global) = _CssTextTransformGlobal;
}

final class _CssTextTransformKeyword extends CssTextTransform {
  final String keyword;
  const _CssTextTransformKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssTextTransformVariable extends CssTextTransform {
  final String varName;
  const _CssTextTransformVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTextTransformRaw extends CssTextTransform {
  final String value;
  const _CssTextTransformRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssTextTransformGlobal extends CssTextTransform {
  final CssGlobal global;
  const _CssTextTransformGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS white-space property values.
sealed class CssWhiteSpace implements CssValue {
  const CssWhiteSpace._();

  static const CssWhiteSpace normal = _CssWhiteSpaceKeyword('normal');
  static const CssWhiteSpace nowrap = _CssWhiteSpaceKeyword('nowrap');
  static const CssWhiteSpace pre = _CssWhiteSpaceKeyword('pre');
  static const CssWhiteSpace preWrap = _CssWhiteSpaceKeyword('pre-wrap');
  static const CssWhiteSpace preLine = _CssWhiteSpaceKeyword('pre-line');
  static const CssWhiteSpace breakSpaces = _CssWhiteSpaceKeyword(
    'break-spaces',
  );

  /// CSS variable reference.
  factory CssWhiteSpace.variable(String varName) = _CssWhiteSpaceVariable;

  /// Raw CSS value escape hatch.
  factory CssWhiteSpace.raw(String value) = _CssWhiteSpaceRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssWhiteSpace.global(CssGlobal global) = _CssWhiteSpaceGlobal;
}

final class _CssWhiteSpaceKeyword extends CssWhiteSpace {
  final String keyword;
  const _CssWhiteSpaceKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssWhiteSpaceVariable extends CssWhiteSpace {
  final String varName;
  const _CssWhiteSpaceVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssWhiteSpaceRaw extends CssWhiteSpace {
  final String value;
  const _CssWhiteSpaceRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssWhiteSpaceGlobal extends CssWhiteSpace {
  final CssGlobal global;
  const _CssWhiteSpaceGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS word-break property values.
sealed class CssWordBreak implements CssValue {
  const CssWordBreak._();

  static const CssWordBreak normal = _CssWordBreakKeyword('normal');
  static const CssWordBreak breakAll = _CssWordBreakKeyword('break-all');
  static const CssWordBreak keepAll = _CssWordBreakKeyword('keep-all');
  static const CssWordBreak breakWord = _CssWordBreakKeyword('break-word');

  /// CSS variable reference.
  factory CssWordBreak.variable(String varName) = _CssWordBreakVariable;

  /// Raw CSS value escape hatch.
  factory CssWordBreak.raw(String value) = _CssWordBreakRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssWordBreak.global(CssGlobal global) = _CssWordBreakGlobal;
}

final class _CssWordBreakKeyword extends CssWordBreak {
  final String keyword;
  const _CssWordBreakKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssWordBreakVariable extends CssWordBreak {
  final String varName;
  const _CssWordBreakVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssWordBreakRaw extends CssWordBreak {
  final String value;
  const _CssWordBreakRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssWordBreakGlobal extends CssWordBreak {
  final CssGlobal global;
  const _CssWordBreakGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}
