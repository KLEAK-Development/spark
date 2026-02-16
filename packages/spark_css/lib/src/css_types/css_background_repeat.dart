import 'css_value.dart';

/// CSS background-repeat property values.
sealed class CssBackgroundRepeat implements CssValue {
  const CssBackgroundRepeat._();

  // Keyword values
  static const CssBackgroundRepeat repeat = _CssBackgroundRepeatKeyword(
    'repeat',
  );
  static const CssBackgroundRepeat repeatX = _CssBackgroundRepeatKeyword(
    'repeat-x',
  );
  static const CssBackgroundRepeat repeatY = _CssBackgroundRepeatKeyword(
    'repeat-y',
  );
  static const CssBackgroundRepeat space = _CssBackgroundRepeatKeyword('space');
  static const CssBackgroundRepeat round = _CssBackgroundRepeatKeyword('round');
  static const CssBackgroundRepeat noRepeat = _CssBackgroundRepeatKeyword(
    'no-repeat',
  );

  /// Creates a two-value syntax background-repeat (e.g. `repeat space`).
  factory CssBackgroundRepeat.xy(CssBackgroundRepeat x, CssBackgroundRepeat y) =
      _CssBackgroundRepeatTwoValue;

  /// Creates a comma-separated list of background-repeat values for multiple background images.
  factory CssBackgroundRepeat.multiple(List<CssBackgroundRepeat> repeats) =
      _CssBackgroundRepeatMultiple;

  /// CSS variable reference.
  factory CssBackgroundRepeat.variable(String varName) =
      _CssBackgroundRepeatVariable;

  /// Raw CSS value escape hatch.
  factory CssBackgroundRepeat.raw(String value) = _CssBackgroundRepeatRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBackgroundRepeat.global(CssGlobal global) =
      _CssBackgroundRepeatGlobal;
}

final class _CssBackgroundRepeatKeyword extends CssBackgroundRepeat {
  final String keyword;
  const _CssBackgroundRepeatKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBackgroundRepeatTwoValue extends CssBackgroundRepeat {
  final CssBackgroundRepeat x;
  final CssBackgroundRepeat y;
  const _CssBackgroundRepeatTwoValue(this.x, this.y) : super._();

  @override
  String toCss() => '${x.toCss()} ${y.toCss()}';
}

final class _CssBackgroundRepeatMultiple extends CssBackgroundRepeat {
  final List<CssBackgroundRepeat> repeats;
  const _CssBackgroundRepeatMultiple(this.repeats) : super._();

  @override
  String toCss() => repeats.map((r) => r.toCss()).join(', ');
}

final class _CssBackgroundRepeatVariable extends CssBackgroundRepeat {
  final String varName;
  const _CssBackgroundRepeatVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBackgroundRepeatRaw extends CssBackgroundRepeat {
  final String value;
  const _CssBackgroundRepeatRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBackgroundRepeatGlobal extends CssBackgroundRepeat {
  final CssGlobal global;
  const _CssBackgroundRepeatGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
