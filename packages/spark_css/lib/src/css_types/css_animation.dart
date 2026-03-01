import 'css_transition.dart';
import 'css_value.dart';

/// CSS animation-direction values.
sealed class CssAnimationDirection implements CssValue {
  const CssAnimationDirection._();

  static const CssAnimationDirection normal = _CssAnimationDirectionKeyword(
    'normal',
  );
  static const CssAnimationDirection reverse = _CssAnimationDirectionKeyword(
    'reverse',
  );
  static const CssAnimationDirection alternate = _CssAnimationDirectionKeyword(
    'alternate',
  );
  static const CssAnimationDirection alternateReverse =
      _CssAnimationDirectionKeyword('alternate-reverse');

  /// CSS variable reference.
  factory CssAnimationDirection.variable(String varName) =
      _CssAnimationDirectionVariable;

  /// Raw CSS value escape hatch.
  factory CssAnimationDirection.raw(String value) = _CssAnimationDirectionRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAnimationDirection.global(CssGlobal global) =
      _CssAnimationDirectionGlobal;
}

final class _CssAnimationDirectionKeyword extends CssAnimationDirection {
  final String keyword;
  const _CssAnimationDirectionKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssAnimationDirectionVariable extends CssAnimationDirection {
  final String varName;
  const _CssAnimationDirectionVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAnimationDirectionRaw extends CssAnimationDirection {
  final String value;
  const _CssAnimationDirectionRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssAnimationDirectionGlobal extends CssAnimationDirection {
  final CssGlobal global;
  const _CssAnimationDirectionGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}

/// CSS animation-fill-mode values.
sealed class CssAnimationFillMode implements CssValue {
  const CssAnimationFillMode._();

  static const CssAnimationFillMode none = _CssAnimationFillModeKeyword('none');
  static const CssAnimationFillMode forwards = _CssAnimationFillModeKeyword(
    'forwards',
  );
  static const CssAnimationFillMode backwards = _CssAnimationFillModeKeyword(
    'backwards',
  );
  static const CssAnimationFillMode both = _CssAnimationFillModeKeyword('both');

  /// CSS variable reference.
  factory CssAnimationFillMode.variable(String varName) =
      _CssAnimationFillModeVariable;

  /// Raw CSS value escape hatch.
  factory CssAnimationFillMode.raw(String value) = _CssAnimationFillModeRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAnimationFillMode.global(CssGlobal global) =
      _CssAnimationFillModeGlobal;
}

final class _CssAnimationFillModeKeyword extends CssAnimationFillMode {
  final String keyword;
  const _CssAnimationFillModeKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssAnimationFillModeVariable extends CssAnimationFillMode {
  final String varName;
  const _CssAnimationFillModeVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAnimationFillModeRaw extends CssAnimationFillMode {
  final String value;
  const _CssAnimationFillModeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssAnimationFillModeGlobal extends CssAnimationFillMode {
  final CssGlobal global;
  const _CssAnimationFillModeGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}

/// CSS animation-play-state values.
sealed class CssAnimationPlayState implements CssValue {
  const CssAnimationPlayState._();

  static const CssAnimationPlayState running = _CssAnimationPlayStateKeyword(
    'running',
  );
  static const CssAnimationPlayState paused = _CssAnimationPlayStateKeyword(
    'paused',
  );

  /// CSS variable reference.
  factory CssAnimationPlayState.variable(String varName) =
      _CssAnimationPlayStateVariable;

  /// Raw CSS value escape hatch.
  factory CssAnimationPlayState.raw(String value) = _CssAnimationPlayStateRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAnimationPlayState.global(CssGlobal global) =
      _CssAnimationPlayStateGlobal;
}

final class _CssAnimationPlayStateKeyword extends CssAnimationPlayState {
  final String keyword;
  const _CssAnimationPlayStateKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssAnimationPlayStateVariable extends CssAnimationPlayState {
  final String varName;
  const _CssAnimationPlayStateVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAnimationPlayStateRaw extends CssAnimationPlayState {
  final String value;
  const _CssAnimationPlayStateRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssAnimationPlayStateGlobal extends CssAnimationPlayState {
  final CssGlobal global;
  const _CssAnimationPlayStateGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}

/// CSS animation-iteration-count values.
sealed class CssAnimationIterationCount implements CssValue {
  const CssAnimationIterationCount._();

  static const CssAnimationIterationCount infinite =
      _CssAnimationIterationCountKeyword('infinite');

  /// Numeric iteration count.
  factory CssAnimationIterationCount.count(num value) =
      _CssAnimationIterationCountNumber;

  /// CSS variable reference.
  factory CssAnimationIterationCount.variable(String varName) =
      _CssAnimationIterationCountVariable;

  /// Raw CSS value escape hatch.
  factory CssAnimationIterationCount.raw(String value) =
      _CssAnimationIterationCountRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAnimationIterationCount.global(CssGlobal global) =
      _CssAnimationIterationCountGlobal;
}

final class _CssAnimationIterationCountKeyword
    extends CssAnimationIterationCount {
  final String keyword;
  const _CssAnimationIterationCountKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssAnimationIterationCountNumber
    extends CssAnimationIterationCount {
  final num value;
  const _CssAnimationIterationCountNumber(this.value) : super._();

  @override
  String toCss() => '$value';
}

final class _CssAnimationIterationCountVariable
    extends CssAnimationIterationCount {
  final String varName;
  const _CssAnimationIterationCountVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAnimationIterationCountRaw extends CssAnimationIterationCount {
  final String value;
  const _CssAnimationIterationCountRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssAnimationIterationCountGlobal
    extends CssAnimationIterationCount {
  final CssGlobal global;
  const _CssAnimationIterationCountGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}

/// CSS animation shorthand value.
sealed class CssAnimation implements CssValue {
  const CssAnimation._();

  static const CssAnimation none = _CssAnimationKeyword('none');

  /// Single animation.
  factory CssAnimation({
    required String name,
    CssDuration? duration,
    CssTimingFunction? timingFunction,
    CssDuration? delay,
    CssAnimationIterationCount? iterationCount,
    CssAnimationDirection? direction,
    CssAnimationFillMode? fillMode,
    CssAnimationPlayState? playState,
  }) = _CssAnimationSingle;

  /// Multiple animations.
  factory CssAnimation.multiple(List<CssAnimation> animations) =
      _CssAnimationMultiple;

  /// CSS variable reference.
  factory CssAnimation.variable(String varName) = _CssAnimationVariable;

  /// Raw CSS value escape hatch.
  factory CssAnimation.raw(String value) = _CssAnimationRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssAnimation.global(CssGlobal global) = _CssAnimationGlobal;
}

final class _CssAnimationKeyword extends CssAnimation {
  final String keyword;
  const _CssAnimationKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssAnimationSingle extends CssAnimation {
  final String name;
  final CssDuration? duration;
  final CssTimingFunction? timingFunction;
  final CssDuration? delay;
  final CssAnimationIterationCount? iterationCount;
  final CssAnimationDirection? direction;
  final CssAnimationFillMode? fillMode;
  final CssAnimationPlayState? playState;

  const _CssAnimationSingle({
    required this.name,
    this.duration,
    this.timingFunction,
    this.delay,
    this.iterationCount,
    this.direction,
    this.fillMode,
    this.playState,
  }) : super._();

  @override
  String toCss() {
    final parts = [name];
    if (duration != null) parts.add(duration!.toCss());
    if (timingFunction != null) parts.add(timingFunction!.toCss());
    if (delay != null) parts.add(delay!.toCss());
    if (iterationCount != null) parts.add(iterationCount!.toCss());
    if (direction != null) parts.add(direction!.toCss());
    if (fillMode != null) parts.add(fillMode!.toCss());
    if (playState != null) parts.add(playState!.toCss());
    return parts.join(' ');
  }
}

final class _CssAnimationMultiple extends CssAnimation {
  final List<CssAnimation> animations;
  const _CssAnimationMultiple(this.animations) : super._();

  @override
  String toCss() => animations.map((a) => a.toCss()).join(', ');
}

final class _CssAnimationVariable extends CssAnimation {
  final String varName;
  const _CssAnimationVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssAnimationRaw extends CssAnimation {
  final String value;
  const _CssAnimationRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssAnimationGlobal extends CssAnimation {
  final CssGlobal global;
  const _CssAnimationGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
