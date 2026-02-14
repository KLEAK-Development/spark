import 'css_value.dart';

/// CSS flex-direction property values.
sealed class CssFlexDirection implements CssValue {
  const CssFlexDirection._();

  static const CssFlexDirection row = _CssFlexDirectionKeyword('row');
  static const CssFlexDirection rowReverse = _CssFlexDirectionKeyword(
    'row-reverse',
  );
  static const CssFlexDirection column = _CssFlexDirectionKeyword('column');
  static const CssFlexDirection columnReverse = _CssFlexDirectionKeyword(
    'column-reverse',
  );

  /// CSS variable reference.
  factory CssFlexDirection.variable(String varName) = _CssFlexDirectionVariable;

  /// Raw CSS value escape hatch.
  factory CssFlexDirection.raw(String value) = _CssFlexDirectionRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssFlexDirection.global(CssGlobal global) = _CssFlexDirectionGlobal;
}

final class _CssFlexDirectionKeyword extends CssFlexDirection {
  final String keyword;
  const _CssFlexDirectionKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssFlexDirectionVariable extends CssFlexDirection {
  final String varName;
  const _CssFlexDirectionVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssFlexDirectionRaw extends CssFlexDirection {
  final String value;
  const _CssFlexDirectionRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssFlexDirectionGlobal extends CssFlexDirection {
  final CssGlobal global;
  const _CssFlexDirectionGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS flex-wrap property values.
sealed class CssFlexWrap implements CssValue {
  const CssFlexWrap._();

  static const CssFlexWrap nowrap = _CssFlexWrapKeyword('nowrap');
  static const CssFlexWrap wrap = _CssFlexWrapKeyword('wrap');
  static const CssFlexWrap wrapReverse = _CssFlexWrapKeyword('wrap-reverse');

  /// CSS variable reference.
  factory CssFlexWrap.variable(String varName) = _CssFlexWrapVariable;

  /// Raw CSS value escape hatch.
  factory CssFlexWrap.raw(String value) = _CssFlexWrapRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssFlexWrap.global(CssGlobal global) = _CssFlexWrapGlobal;
}

final class _CssFlexWrapKeyword extends CssFlexWrap {
  final String keyword;
  const _CssFlexWrapKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssFlexWrapVariable extends CssFlexWrap {
  final String varName;
  const _CssFlexWrapVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssFlexWrapRaw extends CssFlexWrap {
  final String value;
  const _CssFlexWrapRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssFlexWrapGlobal extends CssFlexWrap {
  final CssGlobal global;
  const _CssFlexWrapGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS justify-content property values.
sealed class CssJustifyContent implements CssValue {
  const CssJustifyContent._();

  static const CssJustifyContent normal = _CssJustifyContentKeyword('normal');
  static const CssJustifyContent flexStart = _CssJustifyContentKeyword(
    'flex-start',
  );
  static const CssJustifyContent flexEnd = _CssJustifyContentKeyword(
    'flex-end',
  );
  static const CssJustifyContent center = _CssJustifyContentKeyword('center');
  static const CssJustifyContent spaceBetween = _CssJustifyContentKeyword(
    'space-between',
  );
  static const CssJustifyContent spaceAround = _CssJustifyContentKeyword(
    'space-around',
  );
  static const CssJustifyContent spaceEvenly = _CssJustifyContentKeyword(
    'space-evenly',
  );
  static const CssJustifyContent start = _CssJustifyContentKeyword('start');
  static const CssJustifyContent end = _CssJustifyContentKeyword('end');
  static const CssJustifyContent left = _CssJustifyContentKeyword('left');
  static const CssJustifyContent right = _CssJustifyContentKeyword('right');
  static const CssJustifyContent stretch = _CssJustifyContentKeyword('stretch');

  /// CSS variable reference.
  factory CssJustifyContent.variable(String varName) =
      _CssJustifyContentVariable;

  /// Raw CSS value escape hatch.
  factory CssJustifyContent.raw(String value) = _CssJustifyContentRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssJustifyContent.global(CssGlobal global) = _CssJustifyContentGlobal;
}

final class _CssJustifyContentKeyword extends CssJustifyContent {
  final String keyword;
  const _CssJustifyContentKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssJustifyContentVariable extends CssJustifyContent {
  final String varName;
  const _CssJustifyContentVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssJustifyContentRaw extends CssJustifyContent {
  final String value;
  const _CssJustifyContentRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssJustifyContentGlobal extends CssJustifyContent {
  final CssGlobal global;
  const _CssJustifyContentGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS align-items property values.
sealed class CssAlignItems implements CssValue {
  const CssAlignItems._();

  static const CssAlignItems normal = _CssAlignItemsKeyword('normal');
  static const CssAlignItems flexStart = _CssAlignItemsKeyword('flex-start');
  static const CssAlignItems flexEnd = _CssAlignItemsKeyword('flex-end');
  static const CssAlignItems center = _CssAlignItemsKeyword('center');
  static const CssAlignItems baseline = _CssAlignItemsKeyword('baseline');
  static const CssAlignItems stretch = _CssAlignItemsKeyword('stretch');
  static const CssAlignItems start = _CssAlignItemsKeyword('start');
  static const CssAlignItems end = _CssAlignItemsKeyword('end');
  static const CssAlignItems selfStart = _CssAlignItemsKeyword('self-start');
  static const CssAlignItems selfEnd = _CssAlignItemsKeyword('self-end');

  /// CSS variable reference.
  factory CssAlignItems.variable(String varName) = _CssAlignItemsVariable;

  /// Raw CSS value escape hatch.
  factory CssAlignItems.raw(String value) = _CssAlignItemsRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAlignItems.global(CssGlobal global) = _CssAlignItemsGlobal;
}

final class _CssAlignItemsKeyword extends CssAlignItems {
  final String keyword;
  const _CssAlignItemsKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssAlignItemsVariable extends CssAlignItems {
  final String varName;
  const _CssAlignItemsVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAlignItemsRaw extends CssAlignItems {
  final String value;
  const _CssAlignItemsRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssAlignItemsGlobal extends CssAlignItems {
  final CssGlobal global;
  const _CssAlignItemsGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS align-self property values.
sealed class CssAlignSelf implements CssValue {
  const CssAlignSelf._();

  static const CssAlignSelf auto = _CssAlignSelfKeyword('auto');
  static const CssAlignSelf normal = _CssAlignSelfKeyword('normal');
  static const CssAlignSelf flexStart = _CssAlignSelfKeyword('flex-start');
  static const CssAlignSelf flexEnd = _CssAlignSelfKeyword('flex-end');
  static const CssAlignSelf center = _CssAlignSelfKeyword('center');
  static const CssAlignSelf baseline = _CssAlignSelfKeyword('baseline');
  static const CssAlignSelf stretch = _CssAlignSelfKeyword('stretch');
  static const CssAlignSelf start = _CssAlignSelfKeyword('start');
  static const CssAlignSelf end = _CssAlignSelfKeyword('end');
  static const CssAlignSelf selfStart = _CssAlignSelfKeyword('self-start');
  static const CssAlignSelf selfEnd = _CssAlignSelfKeyword('self-end');

  /// CSS variable reference.
  factory CssAlignSelf.variable(String varName) = _CssAlignSelfVariable;

  /// Raw CSS value escape hatch.
  factory CssAlignSelf.raw(String value) = _CssAlignSelfRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAlignSelf.global(CssGlobal global) = _CssAlignSelfGlobal;
}

final class _CssAlignSelfKeyword extends CssAlignSelf {
  final String keyword;
  const _CssAlignSelfKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssAlignSelfVariable extends CssAlignSelf {
  final String varName;
  const _CssAlignSelfVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAlignSelfRaw extends CssAlignSelf {
  final String value;
  const _CssAlignSelfRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssAlignSelfGlobal extends CssAlignSelf {
  final CssGlobal global;
  const _CssAlignSelfGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}

/// CSS align-content property values.
sealed class CssAlignContent implements CssValue {
  const CssAlignContent._();

  static const CssAlignContent normal = _CssAlignContentKeyword('normal');
  static const CssAlignContent flexStart = _CssAlignContentKeyword(
    'flex-start',
  );
  static const CssAlignContent flexEnd = _CssAlignContentKeyword('flex-end');
  static const CssAlignContent center = _CssAlignContentKeyword('center');
  static const CssAlignContent spaceBetween = _CssAlignContentKeyword(
    'space-between',
  );
  static const CssAlignContent spaceAround = _CssAlignContentKeyword(
    'space-around',
  );
  static const CssAlignContent spaceEvenly = _CssAlignContentKeyword(
    'space-evenly',
  );
  static const CssAlignContent stretch = _CssAlignContentKeyword('stretch');
  static const CssAlignContent start = _CssAlignContentKeyword('start');
  static const CssAlignContent end = _CssAlignContentKeyword('end');
  static const CssAlignContent baseline = _CssAlignContentKeyword('baseline');

  /// CSS variable reference.
  factory CssAlignContent.variable(String varName) = _CssAlignContentVariable;

  /// Raw CSS value escape hatch.
  factory CssAlignContent.raw(String value) = _CssAlignContentRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAlignContent.global(CssGlobal global) = _CssAlignContentGlobal;
}

final class _CssAlignContentKeyword extends CssAlignContent {
  final String keyword;
  const _CssAlignContentKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssAlignContentVariable extends CssAlignContent {
  final String varName;
  const _CssAlignContentVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAlignContentRaw extends CssAlignContent {
  final String value;
  const _CssAlignContentRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssAlignContentGlobal extends CssAlignContent {
  final CssGlobal global;
  const _CssAlignContentGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}
