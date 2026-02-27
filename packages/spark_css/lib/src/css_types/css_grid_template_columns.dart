import 'css_value.dart';
import 'css_length.dart';

/// Individual track size for CSS grid track definitions.
sealed class CssTrackSize implements CssValue {
  const CssTrackSize._();

  /// Fractional unit (e.g., `1fr`).
  factory CssTrackSize.fr(num value) = _CssTrackSizeFr;

  /// Length-based track size (delegates to CssLength).
  factory CssTrackSize.length(CssLength length) = _CssTrackSizeLength;

  /// The `minmax()` function (e.g., `minmax(200px, 1fr)`).
  factory CssTrackSize.minmax(CssTrackSize min, CssTrackSize max) =
      _CssTrackSizeMinmax;

  /// The `fit-content()` function (e.g., `fit-content(300px)`).
  factory CssTrackSize.fitContent(CssLength length) = _CssTrackSizeFitContent;

  /// Raw CSS value escape hatch.
  factory CssTrackSize.raw(String value) = _CssTrackSizeRaw;
}

final class _CssTrackSizeFr extends CssTrackSize {
  final num value;
  const _CssTrackSizeFr(this.value) : super._();

  @override
  String toCss() => '${value}fr';
}

final class _CssTrackSizeLength extends CssTrackSize {
  final CssLength length;
  const _CssTrackSizeLength(this.length) : super._();

  @override
  String toCss() => length.toCss();
}

final class _CssTrackSizeMinmax extends CssTrackSize {
  final CssTrackSize min;
  final CssTrackSize max;
  const _CssTrackSizeMinmax(this.min, this.max) : super._();

  @override
  String toCss() => 'minmax(${min.toCss()}, ${max.toCss()})';
}

final class _CssTrackSizeFitContent extends CssTrackSize {
  final CssLength length;
  const _CssTrackSizeFitContent(this.length) : super._();

  @override
  String toCss() => 'fit-content(${length.toCss()})';
}

final class _CssTrackSizeRaw extends CssTrackSize {
  final String value;
  const _CssTrackSizeRaw(this.value) : super._();

  @override
  String toCss() => value;
}

/// CSS `grid-template-columns` property values.
sealed class CssGridTemplateColumns implements CssValue {
  const CssGridTemplateColumns._();

  /// The `none` keyword.
  static const CssGridTemplateColumns none = _CssGridTemplateColumnsKeyword(
    'none',
  );

  /// The `subgrid` keyword.
  static const CssGridTemplateColumns subgrid = _CssGridTemplateColumnsKeyword(
    'subgrid',
  );

  /// Explicit track list (e.g., `1fr 2fr 100px`).
  factory CssGridTemplateColumns.tracks(List<CssTrackSize> tracks) =
      _CssGridTemplateColumnsTracks;

  /// The `repeat()` function with a fixed count (e.g., `repeat(3, 1fr)`).
  factory CssGridTemplateColumns.repeat(int count, List<CssTrackSize> tracks) =
      _CssGridTemplateColumnsRepeat;

  /// The `repeat(auto-fill, ...)` function.
  factory CssGridTemplateColumns.autoFill(List<CssTrackSize> tracks) =
      _CssGridTemplateColumnsAutoFill;

  /// The `repeat(auto-fit, ...)` function.
  factory CssGridTemplateColumns.autoFit(List<CssTrackSize> tracks) =
      _CssGridTemplateColumnsAutoFit;

  /// CSS variable reference.
  factory CssGridTemplateColumns.variable(String varName) =
      _CssGridTemplateColumnsVariable;

  /// Raw CSS value escape hatch.
  factory CssGridTemplateColumns.raw(String value) = _CssGridTemplateColumnsRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssGridTemplateColumns.global(CssGlobal global) =
      _CssGridTemplateColumnsGlobal;
}

final class _CssGridTemplateColumnsKeyword extends CssGridTemplateColumns {
  final String keyword;
  const _CssGridTemplateColumnsKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssGridTemplateColumnsTracks extends CssGridTemplateColumns {
  final List<CssTrackSize> tracks;
  const _CssGridTemplateColumnsTracks(this.tracks) : super._();

  @override
  String toCss() => tracks.map((t) => t.toCss()).join(' ');
}

final class _CssGridTemplateColumnsRepeat extends CssGridTemplateColumns {
  final int count;
  final List<CssTrackSize> tracks;
  const _CssGridTemplateColumnsRepeat(this.count, this.tracks) : super._();

  @override
  String toCss() => 'repeat($count, ${tracks.map((t) => t.toCss()).join(' ')})';
}

final class _CssGridTemplateColumnsAutoFill extends CssGridTemplateColumns {
  final List<CssTrackSize> tracks;
  const _CssGridTemplateColumnsAutoFill(this.tracks) : super._();

  @override
  String toCss() =>
      'repeat(auto-fill, ${tracks.map((t) => t.toCss()).join(' ')})';
}

final class _CssGridTemplateColumnsAutoFit extends CssGridTemplateColumns {
  final List<CssTrackSize> tracks;
  const _CssGridTemplateColumnsAutoFit(this.tracks) : super._();

  @override
  String toCss() =>
      'repeat(auto-fit, ${tracks.map((t) => t.toCss()).join(' ')})';
}

final class _CssGridTemplateColumnsVariable extends CssGridTemplateColumns {
  final String varName;
  const _CssGridTemplateColumnsVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssGridTemplateColumnsRaw extends CssGridTemplateColumns {
  final String value;
  const _CssGridTemplateColumnsRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssGridTemplateColumnsGlobal extends CssGridTemplateColumns {
  final CssGlobal global;
  const _CssGridTemplateColumnsGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
