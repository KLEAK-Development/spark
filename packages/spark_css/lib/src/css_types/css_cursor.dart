import 'css_value.dart';

/// CSS cursor property values.
sealed class CssCursor implements CssValue {
  const CssCursor._();

  // General cursors
  static const CssCursor auto = _CssCursorKeyword('auto');
  static const CssCursor default_ = _CssCursorKeyword('default');
  static const CssCursor none = _CssCursorKeyword('none');

  // Link & status cursors
  static const CssCursor contextMenu = _CssCursorKeyword('context-menu');
  static const CssCursor help = _CssCursorKeyword('help');
  static const CssCursor pointer = _CssCursorKeyword('pointer');
  static const CssCursor progress = _CssCursorKeyword('progress');
  static const CssCursor wait = _CssCursorKeyword('wait');

  // Selection cursors
  static const CssCursor cell = _CssCursorKeyword('cell');
  static const CssCursor crosshair = _CssCursorKeyword('crosshair');
  static const CssCursor text = _CssCursorKeyword('text');
  static const CssCursor verticalText = _CssCursorKeyword('vertical-text');

  // Drag & drop cursors
  static const CssCursor alias = _CssCursorKeyword('alias');
  static const CssCursor copy = _CssCursorKeyword('copy');
  static const CssCursor move = _CssCursorKeyword('move');
  static const CssCursor noDrop = _CssCursorKeyword('no-drop');
  static const CssCursor notAllowed = _CssCursorKeyword('not-allowed');
  static const CssCursor grab = _CssCursorKeyword('grab');
  static const CssCursor grabbing = _CssCursorKeyword('grabbing');

  // Resize cursors
  static const CssCursor allScroll = _CssCursorKeyword('all-scroll');
  static const CssCursor colResize = _CssCursorKeyword('col-resize');
  static const CssCursor rowResize = _CssCursorKeyword('row-resize');
  static const CssCursor nResize = _CssCursorKeyword('n-resize');
  static const CssCursor eResize = _CssCursorKeyword('e-resize');
  static const CssCursor sResize = _CssCursorKeyword('s-resize');
  static const CssCursor wResize = _CssCursorKeyword('w-resize');
  static const CssCursor neResize = _CssCursorKeyword('ne-resize');
  static const CssCursor nwResize = _CssCursorKeyword('nw-resize');
  static const CssCursor seResize = _CssCursorKeyword('se-resize');
  static const CssCursor swResize = _CssCursorKeyword('sw-resize');
  static const CssCursor ewResize = _CssCursorKeyword('ew-resize');
  static const CssCursor nsResize = _CssCursorKeyword('ns-resize');
  static const CssCursor neswResize = _CssCursorKeyword('nesw-resize');
  static const CssCursor nwseResize = _CssCursorKeyword('nwse-resize');

  // Zoom cursors
  static const CssCursor zoomIn = _CssCursorKeyword('zoom-in');
  static const CssCursor zoomOut = _CssCursorKeyword('zoom-out');

  /// Custom cursor from URL.
  factory CssCursor.url(String url, {CssCursor? fallback}) = _CssCursorUrl;

  /// CSS variable reference.
  factory CssCursor.variable(String varName) = _CssCursorVariable;

  /// Raw CSS value escape hatch.
  factory CssCursor.raw(String value) = _CssCursorRaw;

  /// Global keyword (inherit, initial, unset, revert).
  factory CssCursor.global(CssGlobal global) = _CssCursorGlobal;
}

final class _CssCursorKeyword extends CssCursor {
  final String keyword;
  const _CssCursorKeyword(this.keyword) : super._();

  @override
  String toCss() => keyword;
}

final class _CssCursorUrl extends CssCursor {
  final String url;
  final CssCursor? fallback;
  const _CssCursorUrl(this.url, {this.fallback}) : super._();

  @override
  String toCss() {
    if (fallback != null) {
      return 'url($url), ${fallback!.toCss()}';
    }
    return 'url($url)';
  }
}

final class _CssCursorVariable extends CssCursor {
  final String varName;
  const _CssCursorVariable(this.varName) : super._();

  @override
  String toCss() => 'var(--$varName)';
}

final class _CssCursorRaw extends CssCursor {
  final String value;
  const _CssCursorRaw(this.value) : super._();

  @override
  String toCss() => value;
}

final class _CssCursorGlobal extends CssCursor {
  final CssGlobal global;
  const _CssCursorGlobal(this.global) : super._();

  @override
  String toCss() => global.toCss();
}
