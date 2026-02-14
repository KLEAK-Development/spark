import 'css_value.dart';

/// CSS overflow property values.
sealed class CssOverflow implements CssValue {
  const CssOverflow._();

  static const CssOverflow visible = _CssOverflowKeyword('visible');
  static const CssOverflow hidden = _CssOverflowKeyword('hidden');
  static const CssOverflow scroll = _CssOverflowKeyword('scroll');
  static const CssOverflow auto = _CssOverflowKeyword('auto');
  static const CssOverflow clip = _CssOverflowKeyword('clip');

  /// CSS variable reference.
  factory CssOverflow.variable(String varName) = _CssOverflowVariable;

  /// Raw CSS value escape hatch.
  factory CssOverflow.raw(String value) = _CssOverflowRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssOverflow.global(CssGlobal global) = _CssOverflowGlobal;
}

final class _CssOverflowKeyword extends CssOverflow {
  final String keyword;
  const _CssOverflowKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssOverflowVariable extends CssOverflow {
  final String varName;
  const _CssOverflowVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssOverflowRaw extends CssOverflow {
  final String value;
  const _CssOverflowRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssOverflowGlobal extends CssOverflow {
  final CssGlobal global;
  const _CssOverflowGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
