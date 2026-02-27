import 'css_value.dart';
import 'css_color.dart';
import 'css_background_image.dart';
import 'css_background_position.dart';
import 'css_background_size.dart';
import 'css_background_repeat.dart';
import 'css_background_attachment.dart';
import 'css_background_origin.dart';
import 'css_background_clip.dart';

/// CSS `background` shorthand property values.
sealed class CssBackground implements CssValue {
  const CssBackground._();

  /// The `none` keyword.
  static const CssBackground none = _CssBackgroundKeyword('none');

  /// Simple color background.
  factory CssBackground.color(CssColor color) = _CssBackgroundColor;

  /// Full background shorthand with optional components.
  ///
  /// Assembles the shorthand per CSS spec:
  /// `<bg-image> <position> / <size> <repeat> <attachment> <origin> <clip> <color>`
  ///
  /// The `position / size` slash syntax is used when both are provided.
  factory CssBackground.shorthand({
    CssBackgroundImage? image,
    CssBackgroundPosition? position,
    CssBackgroundSize? size,
    CssBackgroundRepeat? repeat,
    CssBackgroundAttachment? attachment,
    CssBackgroundOrigin? origin,
    CssBackgroundClip? clip,
    CssColor? color,
  }) = _CssBackgroundShorthand;

  /// Multiple background layers (comma-separated).
  factory CssBackground.layers(List<CssBackground> layers) =
      _CssBackgroundLayers;

  /// CSS variable reference.
  factory CssBackground.variable(String varName) = _CssBackgroundVariable;

  /// Raw CSS value escape hatch.
  factory CssBackground.raw(String value) = _CssBackgroundRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssBackground.global(CssGlobal global) = _CssBackgroundGlobal;
}

final class _CssBackgroundKeyword extends CssBackground {
  final String keyword;
  const _CssBackgroundKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssBackgroundColor extends CssBackground {
  final CssColor color;
  const _CssBackgroundColor(this.color) : super._();

  @override
  String toCss() => color.toCss();
}

final class _CssBackgroundShorthand extends CssBackground {
  final CssBackgroundImage? image;
  final CssBackgroundPosition? position;
  final CssBackgroundSize? size;
  final CssBackgroundRepeat? repeat;
  final CssBackgroundAttachment? attachment;
  final CssBackgroundOrigin? origin;
  final CssBackgroundClip? clip;
  final CssColor? color;

  const _CssBackgroundShorthand({
    this.image,
    this.position,
    this.size,
    this.repeat,
    this.attachment,
    this.origin,
    this.clip,
    this.color,
  }) : super._();

  @override
  String toCss() {
    final parts = <String>[];

    if (image != null) parts.add(image!.toCss());

    if (position != null && size != null) {
      parts.add('${position!.toCss()} / ${size!.toCss()}');
    } else if (position != null) {
      parts.add(position!.toCss());
    } else if (size != null) {
      parts.add(size!.toCss());
    }

    if (repeat != null) parts.add(repeat!.toCss());
    if (attachment != null) parts.add(attachment!.toCss());
    if (origin != null) parts.add(origin!.toCss());
    if (clip != null) parts.add(clip!.toCss());
    if (color != null) parts.add(color!.toCss());

    return parts.join(' ');
  }
}

final class _CssBackgroundLayers extends CssBackground {
  final List<CssBackground> layers;
  const _CssBackgroundLayers(this.layers) : super._();

  @override
  String toCss() => layers.map((l) => l.toCss()).join(', ');
}

final class _CssBackgroundVariable extends CssBackground {
  final String varName;
  const _CssBackgroundVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssBackgroundRaw extends CssBackground {
  final String value;
  const _CssBackgroundRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssBackgroundGlobal extends CssBackground {
  final CssGlobal global;
  const _CssBackgroundGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
