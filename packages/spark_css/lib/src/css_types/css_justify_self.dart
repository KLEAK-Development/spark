import 'css_value.dart';

/// CSS justify-self property values.
sealed class CssJustifySelf implements CssValue {
  const CssJustifySelf._();

  static const CssJustifySelf auto = _CssJustifySelfKeyword('auto');
  static const CssJustifySelf normal = _CssJustifySelfKeyword('normal');
  static const CssJustifySelf stretch = _CssJustifySelfKeyword('stretch');
  static const CssJustifySelf start = _CssJustifySelfKeyword('start');
  static const CssJustifySelf end = _CssJustifySelfKeyword('end');
  static const CssJustifySelf center = _CssJustifySelfKeyword('center');
  static const CssJustifySelf left = _CssJustifySelfKeyword('left');
  static const CssJustifySelf right = _CssJustifySelfKeyword('right');
  static const CssJustifySelf baseline = _CssJustifySelfKeyword('baseline');
  static const CssJustifySelf firstBaseline = _CssJustifySelfKeyword(
    'first baseline',
  );
  static const CssJustifySelf lastBaseline = _CssJustifySelfKeyword(
    'last baseline',
  );
  static const CssJustifySelf selfStart = _CssJustifySelfKeyword('self-start');
  static const CssJustifySelf selfEnd = _CssJustifySelfKeyword('self-end');

  /// CSS variable reference.
  factory CssJustifySelf.variable(String varName) = _CssJustifySelfVariable;

  /// Raw CSS value escape hatch.
  factory CssJustifySelf.raw(String value) = _CssJustifySelfRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssJustifySelf.global(CssGlobal global) = _CssJustifySelfGlobal;
}

final class _CssJustifySelfKeyword extends CssJustifySelf {
  final String keyword;
  const _CssJustifySelfKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssJustifySelfVariable extends CssJustifySelf {
  final String varName;
  const _CssJustifySelfVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssJustifySelfRaw extends CssJustifySelf {
  final String value;
  const _CssJustifySelfRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssJustifySelfGlobal extends CssJustifySelf {
  final CssGlobal global;
  const _CssJustifySelfGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
