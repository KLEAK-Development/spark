import 'css_value.dart';

/// CSS transition-timing-function values.
sealed class CssTimingFunction implements CssValue {
  const CssTimingFunction._();

  // Keyword values
  static const CssTimingFunction linear = _CssTimingFunctionKeyword('linear');
  static const CssTimingFunction ease = _CssTimingFunctionKeyword('ease');
  static const CssTimingFunction easeIn = _CssTimingFunctionKeyword('ease-in');
  static const CssTimingFunction easeOut = _CssTimingFunctionKeyword(
    'ease-out',
  );
  static const CssTimingFunction easeInOut = _CssTimingFunctionKeyword(
    'ease-in-out',
  );
  static const CssTimingFunction stepStart = _CssTimingFunctionKeyword(
    'step-start',
  );
  static const CssTimingFunction stepEnd = _CssTimingFunctionKeyword(
    'step-end',
  );

  /// Cubic bezier function.
  factory CssTimingFunction.cubicBezier(
    double x1,
    double y1,
    double x2,
    double y2,
  ) = _CssTimingFunctionCubicBezier;

  /// Steps function.
  factory CssTimingFunction.steps(int count, {String? jumpTerm}) =
      _CssTimingFunctionSteps;

  /// CSS variable reference.
  factory CssTimingFunction.variable(String varName) =
      _CssTimingFunctionVariable;

  /// Raw CSS value escape hatch.
  factory CssTimingFunction.raw(String value) = _CssTimingFunctionRaw;
}

final class _CssTimingFunctionKeyword extends CssTimingFunction {
  final String keyword;
  const _CssTimingFunctionKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssTimingFunctionCubicBezier extends CssTimingFunction {
  final double x1, y1, x2, y2;
  const _CssTimingFunctionCubicBezier(this.x1, this.y1, this.x2, this.y2)
    : super._();

  @override
  String toCss() => 'cubic-bezier($x1, $y1, $x2, $y2)';
}

final class _CssTimingFunctionSteps extends CssTimingFunction {
  final int count;
  final String? jumpTerm;
  const _CssTimingFunctionSteps(this.count, {this.jumpTerm}) : super._();

  @override
  String toCss() {
    if (jumpTerm != null) {
      return 'steps($count, $jumpTerm)';
    }
    return 'steps($count)';
  }
}

final class _CssTimingFunctionVariable extends CssTimingFunction {
  final String varName;
  const _CssTimingFunctionVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTimingFunctionRaw extends CssTimingFunction {
  final String value;
  const _CssTimingFunctionRaw(this.value) : super._();

  @override
  String toCss() => value;
}

/// CSS transition property names.
sealed class CssTransitionProperty implements CssValue {
  const CssTransitionProperty._();

  static const CssTransitionProperty all = _CssTransitionPropertyKeyword('all');
  static const CssTransitionProperty opacity = _CssTransitionPropertyKeyword(
    'opacity',
  );
  static const CssTransitionProperty transform = _CssTransitionPropertyKeyword(
    'transform',
  );
  static const CssTransitionProperty backgroundColor =
      _CssTransitionPropertyKeyword('background-color');
  static const CssTransitionProperty color = _CssTransitionPropertyKeyword(
    'color',
  );
  static const CssTransitionProperty width = _CssTransitionPropertyKeyword(
    'width',
  );
  static const CssTransitionProperty height = _CssTransitionPropertyKeyword(
    'height',
  );
  static const CssTransitionProperty margin = _CssTransitionPropertyKeyword(
    'margin',
  );
  static const CssTransitionProperty padding = _CssTransitionPropertyKeyword(
    'padding',
  );
  static const CssTransitionProperty border = _CssTransitionPropertyKeyword(
    'border',
  );
  static const CssTransitionProperty borderRadius =
      _CssTransitionPropertyKeyword('border-radius');
  static const CssTransitionProperty boxShadow = _CssTransitionPropertyKeyword(
    'box-shadow',
  );
  static const CssTransitionProperty top = _CssTransitionPropertyKeyword('top');
  static const CssTransitionProperty right = _CssTransitionPropertyKeyword(
    'right',
  );
  static const CssTransitionProperty bottom = _CssTransitionPropertyKeyword(
    'bottom',
  );
  static const CssTransitionProperty left = _CssTransitionPropertyKeyword(
    'left',
  );
  static const CssTransitionProperty visibility = _CssTransitionPropertyKeyword(
    'visibility',
  );
  static const CssTransitionProperty fontSize = _CssTransitionPropertyKeyword(
    'font-size',
  );
  static const CssTransitionProperty lineHeight = _CssTransitionPropertyKeyword(
    'line-height',
  );
  static const CssTransitionProperty letterSpacing =
      _CssTransitionPropertyKeyword('letter-spacing');
  static const CssTransitionProperty gap = _CssTransitionPropertyKeyword('gap');

  /// CSS variable reference.
  factory CssTransitionProperty.variable(String varName) =
      _CssTransitionPropertyVariable;

  /// Raw CSS value escape hatch.
  factory CssTransitionProperty.raw(String value) = _CssTransitionPropertyRaw;
}

final class _CssTransitionPropertyKeyword extends CssTransitionProperty {
  final String keyword;
  const _CssTransitionPropertyKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssTransitionPropertyVariable extends CssTransitionProperty {
  final String varName;
  const _CssTransitionPropertyVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTransitionPropertyRaw extends CssTransitionProperty {
  final String value;
  const _CssTransitionPropertyRaw(this.value) : super._();

  @override
  String toCss() => value;
}

/// CSS duration values.
sealed class CssDuration implements CssValue {
  const CssDuration._();

  /// Duration in milliseconds.
  factory CssDuration.ms(num milliseconds) = _CssDurationMs;

  /// Duration in seconds.
  factory CssDuration.s(num seconds) = _CssDurationS;

  /// CSS variable reference.
  factory CssDuration.variable(String varName) = _CssDurationVariable;

  /// Raw CSS value escape hatch.
  factory CssDuration.raw(String value) = _CssDurationRaw;
}

final class _CssDurationMs extends CssDuration {
  final num milliseconds;
  const _CssDurationMs(this.milliseconds) : super._();

  @override
  String toCss() => '${milliseconds}ms';
}

final class _CssDurationS extends CssDuration {
  final num seconds;
  const _CssDurationS(this.seconds) : super._();

  @override
  String toCss() => '${seconds}s';
}

final class _CssDurationVariable extends CssDuration {
  final String varName;
  const _CssDurationVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssDurationRaw extends CssDuration {
  final String value;
  const _CssDurationRaw(this.value) : super._();

  @override
  String toCss() => value;
}

/// CSS transition value.
sealed class CssTransition implements CssValue {
  const CssTransition._();

  static const CssTransition none = _CssTransitionKeyword('none');

  /// Single transition.
  factory CssTransition({
    required CssTransitionProperty property,
    required CssDuration duration,
    CssTimingFunction? timingFunction,
    CssDuration? delay,
  }) = _CssTransitionSingle;

  /// Shorthand for a simple transition.
  factory CssTransition.simple(
    CssTransitionProperty property,
    CssDuration duration, [
    CssTimingFunction? timingFunction,
  ]) => _CssTransitionSingle(
    property: property,
    duration: duration,
    timingFunction: timingFunction,
  );

  /// Multiple transitions.
  factory CssTransition.multiple(List<CssTransition> transitions) =
      _CssTransitionMultiple;

  /// CSS variable reference.
  factory CssTransition.variable(String varName) = _CssTransitionVariable;

  /// Raw CSS value escape hatch.
  factory CssTransition.raw(String value) = _CssTransitionRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssTransition.global(CssGlobal global) = _CssTransitionGlobal;
}

final class _CssTransitionKeyword extends CssTransition {
  final String keyword;
  const _CssTransitionKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssTransitionSingle extends CssTransition {
  final CssTransitionProperty property;
  final CssDuration duration;
  final CssTimingFunction? timingFunction;
  final CssDuration? delay;

  const _CssTransitionSingle({
    required this.property,
    required this.duration,
    this.timingFunction,
    this.delay,
  }) : super._();

  @override
  String toCss() {
    final parts = [property.toCss(), duration.toCss()];
    if (timingFunction != null) parts.add(timingFunction!.toCss());
    if (delay != null) parts.add(delay!.toCss());
    return parts.join(' ');
  }
}

final class _CssTransitionMultiple extends CssTransition {
  final List<CssTransition> transitions;
  const _CssTransitionMultiple(this.transitions) : super._();

  @override
  String toCss() => transitions.map((t) => t.toCss()).join(', ');
}

final class _CssTransitionVariable extends CssTransition {
  final String varName;
  const _CssTransitionVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssTransitionRaw extends CssTransition {
  final String value;
  const _CssTransitionRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssTransitionGlobal extends CssTransition {
  final CssGlobal global;
  const _CssTransitionGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
