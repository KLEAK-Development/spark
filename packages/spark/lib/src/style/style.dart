import 'css_types/css_types.dart';

const bool _minify = bool.fromEnvironment('dart.vm.product');

/// A common interface for CSS styles and stylesheets.
abstract class CssStyle {
  String toCss();
}

/// A map of CSS selectors to their styles.
class Stylesheet implements CssStyle {
  final Map<String, Style> rules;

  const Stylesheet(this.rules);

  /// Converts the stylesheet to a CSS string.
  @override
  String toCss() {
    final buffer = StringBuffer();
    final sortedKeys = rules.keys.toList()..sort();

    if (_minify) {
      for (final selector in sortedKeys) {
        final style = rules[selector]!;
        // Remove spaces around braces and colons
        buffer.write('$selector{${style.toCss()}}');
      }
    } else {
      for (final selector in sortedKeys) {
        final style = rules[selector]!;
        buffer.writeln('$selector {');
        buffer.write(style.toCss());
        buffer.writeln('}');
      }
    }
    return buffer.toString();
  }

  @override
  String toString() => toCss();
}

/// A typed representation of CSS styles.
///
/// Use [Style.typed] for a type-safe experience with [CssLength], [CssColor], etc.
/// Or use the default constructor for loose, string-based styles.
///
/// ## Example
///
/// ```dart
/// Style.typed(
///   display: CssDisplay.flex,
///   backgroundColor: CssColor.hex('333'),
///   padding: CssSpacing.all(CssLength.rem(1)),
/// )
/// ```
class Style implements CssStyle {
  final Map<String, String> _properties = {};
  final Stylesheet? stylesheet;

  /// Creates a style with raw string values.
  ///
  /// For type safety, prefer [Style.typed].
  Style({
    String? color,
    String? backgroundColor,
    String? background,
    String? fontSize,
    String? fontWeight,
    String? fontFamily,
    String? display,
    // ... (other properties are standard CSS)
    String? flexDirection,
    String? justifyContent,
    String? alignItems,
    String? margin,
    String? padding,
    String? width,
    String? height,
    String? maxWidth,
    String? maxHeight,
    String? border,
    String? borderBottom,
    String? borderRadius,
    String? position,
    String? top,
    String? bottom,
    String? left,
    String? right,
    String? zIndex,
    String? opacity,
    String? transition,
    String? cursor,
    String? textAlign,
    String? lineHeight,
    String? letterSpacing,
    String? textDecoration,
    String? textTransform,
    String? gap,
    String? gridTemplateColumns,
    String? fill,
    String? backdropFilter,
    String? marginTop,
    String? marginBottom,
    String? marginLeft,
    String? marginRight,
    String? paddingTop,
    String? paddingBottom,
    String? paddingLeft,
    String? paddingRight,
    String? borderTop,
    String? borderLeft,
    String? borderRight,
    String? flex,
    String? flexGrow,
    String? flexShrink,
    String? flexWrap,
    String? alignSelf,
    String? overflow,
    String? overflowX,
    String? overflowY,
    String? minHeight,
    String? minWidth,
    String? boxShadow,
    String? transform,
    String? borderColor,
    Stylesheet? css,
  }) : stylesheet = css {
    if (color != null) _properties['color'] = color;
    if (backgroundColor != null) {
      _properties['background-color'] = backgroundColor;
    }
    if (background != null) _properties['background'] = background;
    if (fontSize != null) _properties['font-size'] = fontSize;
    if (fontWeight != null) _properties['font-weight'] = fontWeight;
    if (fontFamily != null) _properties['font-family'] = fontFamily;
    if (display != null) _properties['display'] = display;
    if (flexDirection != null) _properties['flex-direction'] = flexDirection;
    if (justifyContent != null) _properties['justify-content'] = justifyContent;
    if (alignItems != null) _properties['align-items'] = alignItems;
    if (margin != null) _properties['margin'] = margin;
    if (padding != null) _properties['padding'] = padding;
    if (width != null) _properties['width'] = width;
    if (height != null) _properties['height'] = height;
    if (maxWidth != null) _properties['max-width'] = maxWidth;
    if (maxHeight != null) _properties['max-height'] = maxHeight;
    if (border != null) _properties['border'] = border;
    if (borderBottom != null) _properties['border-bottom'] = borderBottom;
    if (borderRadius != null) _properties['border-radius'] = borderRadius;
    if (position != null) _properties['position'] = position;
    if (top != null) _properties['top'] = top;
    if (bottom != null) _properties['bottom'] = bottom;
    if (left != null) _properties['left'] = left;
    if (right != null) _properties['right'] = right;
    if (zIndex != null) _properties['z-index'] = zIndex;
    if (opacity != null) _properties['opacity'] = opacity;
    if (transition != null) _properties['transition'] = transition;
    if (cursor != null) _properties['cursor'] = cursor;
    if (textAlign != null) _properties['text-align'] = textAlign;
    if (lineHeight != null) _properties['line-height'] = lineHeight;
    if (letterSpacing != null) _properties['letter-spacing'] = letterSpacing;
    if (textDecoration != null) _properties['text-decoration'] = textDecoration;
    if (textTransform != null) _properties['text-transform'] = textTransform;
    if (gap != null) _properties['gap'] = gap;
    if (gridTemplateColumns != null) {
      _properties['grid-template-columns'] = gridTemplateColumns;
    }
    if (fill != null) _properties['fill'] = fill;
    if (backdropFilter != null) _properties['backdrop-filter'] = backdropFilter;
    if (marginTop != null) _properties['margin-top'] = marginTop;
    if (marginBottom != null) _properties['margin-bottom'] = marginBottom;
    if (marginLeft != null) _properties['margin-left'] = marginLeft;
    if (marginRight != null) _properties['margin-right'] = marginRight;
    if (paddingTop != null) _properties['padding-top'] = paddingTop;
    if (paddingBottom != null) _properties['padding-bottom'] = paddingBottom;
    if (paddingLeft != null) _properties['padding-left'] = paddingLeft;
    if (paddingRight != null) _properties['padding-right'] = paddingRight;
    if (borderTop != null) _properties['border-top'] = borderTop;
    if (borderLeft != null) _properties['border-left'] = borderLeft;
    if (borderRight != null) _properties['border-right'] = borderRight;
    if (flex != null) _properties['flex'] = flex;
    if (flexGrow != null) _properties['flex-grow'] = flexGrow;
    if (flexShrink != null) _properties['flex-shrink'] = flexShrink;
    if (flexWrap != null) _properties['flex-wrap'] = flexWrap;
    if (alignSelf != null) _properties['align-self'] = alignSelf;
    if (overflow != null) _properties['overflow'] = overflow;
    if (overflowX != null) _properties['overflow-x'] = overflowX;
    if (overflowY != null) _properties['overflow-y'] = overflowY;
    if (minHeight != null) _properties['min-height'] = minHeight;
    if (minWidth != null) _properties['min-width'] = minWidth;
    if (boxShadow != null) _properties['box-shadow'] = boxShadow;
    if (transform != null) _properties['transform'] = transform;
    if (borderColor != null) _properties['border-color'] = borderColor;
  }

  /// Type-safe constructor with CSS value types.
  ///
  /// Example:
  /// ```dart
  /// Style.v2(
  ///   display: CssDisplay.flex,
  ///   flexDirection: CssFlexDirection.column,
  ///   justifyContent: CssJustifyContent.center,
  ///   alignItems: CssAlignItems.center,
  ///   gap: CssLength.rem(1),
  ///   // Single value padding
  ///   padding: CssSpacing.all(CssLength.px(16)),
  ///   // Or multi-value: vertical | horizontal
  ///   margin: CssSpacing.symmetric(CssLength.px(10), CssLength.px(20)),
  ///   // Or all four sides: top | right | bottom | left
  ///   // margin: CssSpacing.trbl(top, right, bottom, left),
  ///   backgroundColor: CssColor.hex('f5f5f5'),
  ///   color: CssColor.variable('text-primary'),
  ///   borderRadius: CssLength.px(8),
  /// )
  /// ```
  Style.typed({
    // Colors
    CssColor? color,
    CssColor? backgroundColor,
    CssColor? borderColor,
    CssColor? fill,
    // Layout
    CssDisplay? display,
    CssPosition? position,
    // Sizing
    CssLength? width,
    CssLength? height,
    CssLength? minWidth,
    CssLength? minHeight,
    CssLength? maxWidth,
    CssLength? maxHeight,
    // Spacing (CssSpacing supports multi-value shorthand: all, symmetric, trbl)
    CssSpacing? margin,
    CssLength? marginTop,
    CssLength? marginRight,
    CssLength? marginBottom,
    CssLength? marginLeft,
    CssSpacing? padding,
    CssLength? paddingTop,
    CssLength? paddingRight,
    CssLength? paddingBottom,
    CssLength? paddingLeft,
    // Position offsets
    CssLength? top,
    CssLength? right,
    CssLength? bottom,
    CssLength? left,
    // Flexbox
    CssFlexDirection? flexDirection,
    CssFlexWrap? flexWrap,
    CssJustifyContent? justifyContent,
    CssAlignItems? alignItems,
    CssAlignSelf? alignSelf,
    CssAlignContent? alignContent,
    CssNumber? flexGrow,
    CssNumber? flexShrink,
    CssLength? gap,
    // Typography
    CssLength? fontSize,
    CssFontWeight? fontWeight,
    CssFontFamily? fontFamily,
    CssFontStyle? fontStyle,
    CssTextAlign? textAlign,
    CssTextDecoration? textDecoration,
    CssTextTransform? textTransform,
    CssWhiteSpace? whiteSpace,
    CssWordBreak? wordBreak,
    CssNumber? lineHeight,
    CssLength? letterSpacing,
    // Borders
    CssBorder? border,
    CssBorder? borderTop,
    CssBorder? borderRight,
    CssBorder? borderBottom,
    CssBorder? borderLeft,
    CssLength? borderRadius,
    // Visual
    CssNumber? opacity,
    CssOverflow? overflow,
    CssOverflow? overflowX,
    CssOverflow? overflowY,
    CssZIndex? zIndex,
    CssCursor? cursor,
    // Effects
    CssTransition? transition,
    // Complex properties (keep as String for flexibility)
    String? transform,
    String? boxShadow,
    String? backdropFilter,
    String? background,
    String? flex,
    String? gridTemplateColumns,
    Stylesheet? css,
  }) : stylesheet = css {
    // Colors
    if (color != null) _properties['color'] = color.toCss();
    if (backgroundColor != null) {
      _properties['background-color'] = backgroundColor.toCss();
    }
    if (borderColor != null) _properties['border-color'] = borderColor.toCss();
    if (fill != null) _properties['fill'] = fill.toCss();

    // Layout
    if (display != null) _properties['display'] = display.toCss();
    if (position != null) _properties['position'] = position.toCss();

    // Sizing
    if (width != null) _properties['width'] = width.toCss();
    if (height != null) _properties['height'] = height.toCss();
    if (minWidth != null) _properties['min-width'] = minWidth.toCss();
    if (minHeight != null) _properties['min-height'] = minHeight.toCss();
    if (maxWidth != null) _properties['max-width'] = maxWidth.toCss();
    if (maxHeight != null) _properties['max-height'] = maxHeight.toCss();

    // Spacing
    if (margin != null) _properties['margin'] = margin.toCss();
    if (marginTop != null) _properties['margin-top'] = marginTop.toCss();
    if (marginRight != null) _properties['margin-right'] = marginRight.toCss();
    if (marginBottom != null) {
      _properties['margin-bottom'] = marginBottom.toCss();
    }
    if (marginLeft != null) _properties['margin-left'] = marginLeft.toCss();
    if (padding != null) _properties['padding'] = padding.toCss();
    if (paddingTop != null) _properties['padding-top'] = paddingTop.toCss();
    if (paddingRight != null) {
      _properties['padding-right'] = paddingRight.toCss();
    }
    if (paddingBottom != null) {
      _properties['padding-bottom'] = paddingBottom.toCss();
    }
    if (paddingLeft != null) _properties['padding-left'] = paddingLeft.toCss();

    // Position offsets
    if (top != null) _properties['top'] = top.toCss();
    if (right != null) _properties['right'] = right.toCss();
    if (bottom != null) _properties['bottom'] = bottom.toCss();
    if (left != null) _properties['left'] = left.toCss();

    // Flexbox
    if (flexDirection != null) {
      _properties['flex-direction'] = flexDirection.toCss();
    }
    if (flexWrap != null) _properties['flex-wrap'] = flexWrap.toCss();
    if (justifyContent != null) {
      _properties['justify-content'] = justifyContent.toCss();
    }
    if (alignItems != null) _properties['align-items'] = alignItems.toCss();
    if (alignSelf != null) _properties['align-self'] = alignSelf.toCss();
    if (alignContent != null) {
      _properties['align-content'] = alignContent.toCss();
    }
    if (flexGrow != null) _properties['flex-grow'] = flexGrow.toCss();
    if (flexShrink != null) _properties['flex-shrink'] = flexShrink.toCss();
    if (gap != null) _properties['gap'] = gap.toCss();

    // Typography
    if (fontSize != null) _properties['font-size'] = fontSize.toCss();
    if (fontWeight != null) _properties['font-weight'] = fontWeight.toCss();
    if (fontFamily != null) _properties['font-family'] = fontFamily.toCss();
    if (fontStyle != null) _properties['font-style'] = fontStyle.toCss();
    if (textAlign != null) _properties['text-align'] = textAlign.toCss();
    if (textDecoration != null) {
      _properties['text-decoration'] = textDecoration.toCss();
    }
    if (textTransform != null) {
      _properties['text-transform'] = textTransform.toCss();
    }
    if (whiteSpace != null) _properties['white-space'] = whiteSpace.toCss();
    if (wordBreak != null) _properties['word-break'] = wordBreak.toCss();
    if (lineHeight != null) _properties['line-height'] = lineHeight.toCss();
    if (letterSpacing != null) {
      _properties['letter-spacing'] = letterSpacing.toCss();
    }

    // Borders
    if (border != null) _properties['border'] = border.toCss();
    if (borderTop != null) _properties['border-top'] = borderTop.toCss();
    if (borderRight != null) _properties['border-right'] = borderRight.toCss();
    if (borderBottom != null) {
      _properties['border-bottom'] = borderBottom.toCss();
    }
    if (borderLeft != null) _properties['border-left'] = borderLeft.toCss();
    if (borderRadius != null) {
      _properties['border-radius'] = borderRadius.toCss();
    }

    // Visual
    if (opacity != null) _properties['opacity'] = opacity.toCss();
    if (overflow != null) _properties['overflow'] = overflow.toCss();
    if (overflowX != null) _properties['overflow-x'] = overflowX.toCss();
    if (overflowY != null) _properties['overflow-y'] = overflowY.toCss();
    if (zIndex != null) _properties['z-index'] = zIndex.toCss();
    if (cursor != null) _properties['cursor'] = cursor.toCss();

    // Effects
    if (transition != null) _properties['transition'] = transition.toCss();

    // Complex properties (string-based)
    if (transform != null) _properties['transform'] = transform;
    if (boxShadow != null) _properties['box-shadow'] = boxShadow;
    if (backdropFilter != null) _properties['backdrop-filter'] = backdropFilter;
    if (background != null) _properties['background'] = background;
    if (flex != null) _properties['flex'] = flex;
    if (gridTemplateColumns != null) {
      _properties['grid-template-columns'] = gridTemplateColumns;
    }
  }

  /// Adds a custom property not covered by the named arguments.
  void add(String property, String value) {
    _properties[property] = value;
  }

  /// Converts the style to a CSS string.
  @override
  String toCss() {
    final buffer = StringBuffer();
    final sortedKeys = _properties.keys.toList()..sort();

    if (_minify) {
      for (final property in sortedKeys) {
        // No indentation, no spaces after colon/semicolon
        buffer.write('$property:${_properties[property]};');
      }
      if (stylesheet != null) {
        buffer.write(stylesheet!.toCss());
      }
    } else {
      for (final property in sortedKeys) {
        buffer.writeln('  $property: ${_properties[property]};');
      }
      if (stylesheet != null) {
        buffer.write(stylesheet!.toCss());
      }
    }
    return buffer.toString();
  }

  @override
  String toString() => toCss();
}

/// Helper to create a stylesheet from a map of rules.
Stylesheet css(Map<String, Style> rules) => Stylesheet(rules);
