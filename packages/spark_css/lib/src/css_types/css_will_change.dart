import 'css_value.dart';

/// CSS will-change property values.
sealed class CssWillChange implements CssValue {
  const CssWillChange._();

  static const CssWillChange auto = _CssWillChangeKeyword('auto');
  static const CssWillChange scrollPosition = _CssWillChangeKeyword(
    'scroll-position',
  );
  static const CssWillChange contents = _CssWillChangeKeyword('contents');

  /// Hints that the listed CSS property names will change.
  ///
  /// Example: `CssWillChange.properties(['transform', 'opacity'])`
  /// produces `will-change: transform, opacity`.
  factory CssWillChange.properties(List<String> properties) =
      _CssWillChangeProperties;

  /// CSS variable reference.
  factory CssWillChange.variable(String varName) = _CssWillChangeVariable;

  /// Raw CSS value escape hatch.
  factory CssWillChange.raw(String value) = _CssWillChangeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssWillChange.global(CssGlobal global) = _CssWillChangeGlobal;
}

final class _CssWillChangeKeyword extends CssWillChange {
  final String keyword;
  const _CssWillChangeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssWillChangeProperties extends CssWillChange {
  final List<String> properties;
  const _CssWillChangeProperties(this.properties) : super._();

  @override
  String toCss() => properties.join(', ');
}

final class _CssWillChangeVariable extends CssWillChange {
  final String varName;
  const _CssWillChangeVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssWillChangeRaw extends CssWillChange {
  final String value;
  const _CssWillChangeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssWillChangeGlobal extends CssWillChange {
  final CssGlobal global;
  const _CssWillChangeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
