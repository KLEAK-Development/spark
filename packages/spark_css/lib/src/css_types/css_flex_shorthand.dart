import 'css_length.dart';
import 'css_value.dart';

/// CSS flex shorthand property values.
sealed class CssFlexShorthand implements CssValue {
  const CssFlexShorthand._();

  static const CssFlexShorthand auto = _CssFlexShorthandKeyword('auto');
  static const CssFlexShorthand initial = _CssFlexShorthandKeyword('initial');
  static const CssFlexShorthand none = _CssFlexShorthandKeyword('none');

  /// Creates a flex shorthand value.
  ///
  /// Supports the following combinations:
  /// - [grow]: flex-grow (number)
  /// - [basis]: flex-basis (length)
  /// - [grow] and [basis]: flex-grow flex-basis
  /// - [grow] and [shrink]: flex-grow flex-shrink
  /// - [grow], [shrink], and [basis]: flex-grow flex-shrink flex-basis
  ///
  /// If [shrink] is provided, [grow] must also be provided.
  factory CssFlexShorthand({num? grow, num? shrink, CssLength? basis}) {
    if (grow != null) {
      if (shrink != null) {
        if (basis != null) {
          return _CssFlexShorthandValues(grow, shrink, basis);
        }
        return _CssFlexShorthandValues(grow, shrink, null);
      }
      if (basis != null) {
        return _CssFlexShorthandValues(grow, null, basis);
      }
      return _CssFlexShorthandValues(grow, null, null);
    } else if (basis != null) {
      if (shrink != null) {
        throw ArgumentError('flex-shrink requires flex-grow to be specified.');
      }
      return _CssFlexShorthandValues(null, null, basis);
    } else if (shrink != null) {
      throw ArgumentError('flex-shrink requires flex-grow to be specified.');
    }

    throw ArgumentError('At least one of grow or basis must be provided.');
  }

  /// CSS variable reference.
  factory CssFlexShorthand.variable(String varName) = _CssFlexShorthandVariable;

  /// Raw CSS value escape hatch.
  factory CssFlexShorthand.raw(String value) = _CssFlexShorthandRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssFlexShorthand.global(CssGlobal global) = _CssFlexShorthandGlobal;
}

final class _CssFlexShorthandKeyword extends CssFlexShorthand {
  final String keyword;
  const _CssFlexShorthandKeyword(this.keyword) : super._();
  @override
  String toCss() => keyword;
}

final class _CssFlexShorthandValues extends CssFlexShorthand {
  final num? grow;
  final num? shrink;
  final CssLength? basis;

  const _CssFlexShorthandValues(this.grow, this.shrink, this.basis) : super._();

  @override
  String toCss() {
    final parts = <String>[];
    if (grow != null) parts.add(grow.toString());
    if (shrink != null) parts.add(shrink.toString());
    if (basis != null) parts.add(basis!.toCss());
    return parts.join(' ');
  }
}

final class _CssFlexShorthandVariable extends CssFlexShorthand {
  final String varName;
  const _CssFlexShorthandVariable(this.varName) : super._();
  @override
  String toCss() => 'var(--$varName)';
}

final class _CssFlexShorthandRaw extends CssFlexShorthand {
  final String value;
  const _CssFlexShorthandRaw(this.value) : super._();
  @override
  String toCss() => value;
}

final class _CssFlexShorthandGlobal extends CssFlexShorthand {
  final CssGlobal global;
  const _CssFlexShorthandGlobal(this.global) : super._();
  @override
  String toCss() => global.toCss();
}
