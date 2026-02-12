/// Canvas rendering context types matching the MDN Web API.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
library;

import 'dom.dart';

// ---------------------------------------------------------------------------
// RenderingContext (base type for all canvas contexts)
// ---------------------------------------------------------------------------

/// Base type for canvas rendering contexts.
///
/// Returned by [HTMLCanvasElement.getContext]. Cast to the specific context
/// type (e.g., [CanvasRenderingContext2D]) based on the context ID you
/// requested.
///
/// ```dart
/// final ctx = canvas.getContext('2d') as CanvasRenderingContext2D;
/// ctx.fillRect(0, 0, 100, 100);
/// ```
abstract class RenderingContext {
  /// The canvas element this context draws on.
  HTMLCanvasElement get canvas;
}

// ---------------------------------------------------------------------------
// CanvasRenderingContext2D
// ---------------------------------------------------------------------------

/// Provides 2D rendering methods for the `<canvas>` element.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D
abstract class CanvasRenderingContext2D implements RenderingContext {
  // -- Rect methods ---------------------------------------------------------

  /// Draws a filled rectangle.
  void fillRect(num x, num y, num width, num height);

  /// Draws a rectangle outline.
  void strokeRect(num x, num y, num width, num height);

  /// Clears a rectangular area, making it fully transparent.
  void clearRect(num x, num y, num width, num height);

  // -- Path methods ---------------------------------------------------------

  /// Starts a new path.
  void beginPath();

  /// Closes the current sub-path.
  void closePath();

  /// Moves the starting point of a new sub-path.
  void moveTo(num x, num y);

  /// Connects the last point to the given point with a straight line.
  void lineTo(num x, num y);

  /// Adds a circular arc to the current path.
  void arc(num x, num y, num radius, num startAngle, num endAngle,
      [bool counterclockwise = false]);

  /// Adds an arc between two tangent lines.
  void arcTo(num x1, num y1, num x2, num y2, num radius);

  /// Adds a cubic Bézier curve.
  void bezierCurveTo(num cp1x, num cp1y, num cp2x, num cp2y, num x, num y);

  /// Adds a quadratic Bézier curve.
  void quadraticCurveTo(num cpx, num cpy, num x, num y);

  /// Adds a rectangle to the current path.
  void rect(num x, num y, num width, num height);

  /// Adds an elliptical arc to the current path.
  void ellipse(num x, num y, num radiusX, num radiusY, num rotation,
      num startAngle, num endAngle,
      [bool counterclockwise = false]);

  /// Fills the current path.
  void fill();

  /// Strokes (outlines) the current path.
  void stroke();

  /// Clips the current path, making it the clipping region.
  void clip();

  // -- Text methods ---------------------------------------------------------

  /// Draws filled text.
  void fillText(String text, num x, num y, [num? maxWidth]);

  /// Draws text outlines.
  void strokeText(String text, num x, num y, [num? maxWidth]);

  /// Returns metrics for the given text string.
  TextMetrics measureText(String text);

  // -- Style properties -----------------------------------------------------

  /// Current fill style (CSS color string, CanvasGradient, or CanvasPattern).
  Object get fillStyle;
  set fillStyle(Object value);

  /// Current stroke style (CSS color string, CanvasGradient, or CanvasPattern).
  Object get strokeStyle;
  set strokeStyle(Object value);

  /// Width of lines. Default: `1.0`.
  double get lineWidth;
  set lineWidth(num value);

  /// Shape of line ends: `'butt'`, `'round'`, or `'square'`.
  String get lineCap;
  set lineCap(String value);

  /// Shape of line joins: `'round'`, `'bevel'`, or `'miter'`.
  String get lineJoin;
  set lineJoin(String value);

  /// Miter limit ratio.
  double get miterLimit;
  set miterLimit(num value);

  // -- Shadow properties ----------------------------------------------------

  /// Blur amount for shadows.
  double get shadowBlur;
  set shadowBlur(num value);

  /// Color of shadows (CSS color string).
  String get shadowColor;
  set shadowColor(String value);

  /// Horizontal offset for shadows.
  double get shadowOffsetX;
  set shadowOffsetX(num value);

  /// Vertical offset for shadows.
  double get shadowOffsetY;
  set shadowOffsetY(num value);

  // -- Text properties ------------------------------------------------------

  /// CSS font string for text methods (e.g., `'16px sans-serif'`).
  String get font;
  set font(String value);

  /// Text alignment: `'start'`, `'end'`, `'left'`, `'right'`, `'center'`.
  String get textAlign;
  set textAlign(String value);

  /// Text baseline: `'top'`, `'hanging'`, `'middle'`, `'alphabetic'`,
  /// `'ideographic'`, `'bottom'`.
  String get textBaseline;
  set textBaseline(String value);

  // -- Compositing ----------------------------------------------------------

  /// Global alpha (transparency), from 0.0 to 1.0.
  double get globalAlpha;
  set globalAlpha(num value);

  /// Compositing operation (e.g., `'source-over'`, `'multiply'`).
  String get globalCompositeOperation;
  set globalCompositeOperation(String value);

  // -- State ----------------------------------------------------------------

  /// Saves the current drawing state to a stack.
  void save();

  /// Restores the most recently saved drawing state.
  void restore();

  // -- Transforms -----------------------------------------------------------

  /// Scales the canvas units.
  void scale(num x, num y);

  /// Rotates the canvas.
  void rotate(num angle);

  /// Translates the canvas origin.
  void translate(num x, num y);

  /// Resets the current transform and then applies the given matrix.
  void setTransform(num a, num b, num c, num d, num e, num f);

  /// Resets the current transform to the identity matrix.
  void resetTransform();

  // -- Image drawing --------------------------------------------------------

  /// Draws an image onto the canvas.
  ///
  /// The [image] must be an [HTMLImageElement], [HTMLCanvasElement],
  /// [HTMLVideoElement], or similar source.
  void drawImage(Element image, num dx, num dy);

  /// Draws an image scaled to the given dimensions.
  void drawImageScaled(
      Element image, num dx, num dy, num dWidth, num dHeight);

  /// Draws a portion of an image onto a portion of the canvas.
  void drawImageScaledFromSource(Element image, num sx, num sy, num sWidth,
      num sHeight, num dx, num dy, num dWidth, num dHeight);

  // -- Pixel manipulation ---------------------------------------------------

  /// Returns an [ImageData] object representing pixel data for a rectangle.
  ImageData getImageData(int sx, int sy, int sw, int sh);

  /// Creates a new blank [ImageData] with the given dimensions.
  ImageData createImageData(int sw, int sh);

  /// Paints pixel data from an [ImageData] object onto the canvas.
  void putImageData(ImageData imagedata, int dx, int dy);

  // -- Line dash ------------------------------------------------------------

  /// Sets the current line dash pattern.
  void setLineDash(List<num> segments);

  /// Returns the current line dash pattern.
  List<num> getLineDash();

  /// Line dash offset. Default: `0.0`.
  double get lineDashOffset;
  set lineDashOffset(num value);
}

// ---------------------------------------------------------------------------
// TextMetrics
// ---------------------------------------------------------------------------

/// Measurement of a text string.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/TextMetrics
abstract class TextMetrics {
  double get width;
  double get actualBoundingBoxLeft;
  double get actualBoundingBoxRight;
  double get fontBoundingBoxAscent;
  double get fontBoundingBoxDescent;
  double get actualBoundingBoxAscent;
  double get actualBoundingBoxDescent;
}

// ---------------------------------------------------------------------------
// ImageData
// ---------------------------------------------------------------------------

/// Represents pixel data for a rectangular area of a canvas.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/ImageData
abstract class ImageData {
  /// Width of the image data in pixels.
  int get width;

  /// Height of the image data in pixels.
  int get height;

  /// A one-dimensional array of RGBA pixel values (0–255).
  List<int> get data;
}
