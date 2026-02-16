import 'css_value.dart';

/// CSS background-clip property values.
sealed class CssBackgroundClip implements CssValue {
  const CssBackgroundClip._();

  /// The background extends to the outside edge of the border.
  static const CssBackgroundClip borderBox = _CssBackgroundClipKeyword(
    'border-box',
  );

  /// The background extends to the outside edge of the padding.
  static const CssBackgroundClip paddingBox = _CssBackgroundClipKeyword(
    'padding-box',
  );

  /// The background extends to the outside edge of the content.
  static const CssBackgroundClip contentBox = _CssBackgroundClipKeyword(
    'content-box',
  );

  /// The background is clipped to the foreground text.
  static const CssBackgroundClip text = _CssBackgroundClipKeyword('text');

  /// Multiple background-clip values for multiple background images.
  factory CssBackgroundClip.multiple(List<CssBackgroundClip> values) =
      _CssBackgroundClipMultiple;

  /// CSS variable reference.
  factory CssBackgroundClip.variable(String varName) =
      _CssBackgroundClipVariable;

  /// Raw CSS value escape hatch.
  factory CssBackgroundClip.raw(String value) = _CssBackgroundClipRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBackgroundClip.global(CssGlobal global) = _CssBackgroundClipGlobal;
}

final class _CssBackgroundClipKeyword extends CssBackgroundClip {
  final String keyword;
  const _CssBackgroundClipKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBackgroundClipMultiple extends CssBackgroundClip {
  final List<CssBackgroundClip> values;
  const _CssBackgroundClipMultiple(this.values) : super._();

  @override
  String toCss() => values.map((e) => e.toCss()).join(', ');
}

final class _CssBackgroundClipVariable extends CssBackgroundClip {
  final String varName;
  const _CssBackgroundClipVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBackgroundClipRaw extends CssBackgroundClip {
  final String value;
  const _CssBackgroundClipRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBackgroundClipGlobal extends CssBackgroundClip {
  final CssGlobal global;
  const _CssBackgroundClipGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
