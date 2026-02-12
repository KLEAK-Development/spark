/// Browser implementations of Canvas types wrapping `package:web`.
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../canvas.dart' as iface;
import '../dom.dart' as iface;
import 'dom.dart';

// ---------------------------------------------------------------------------
// CanvasRenderingContext2D
// ---------------------------------------------------------------------------

class BrowserCanvasRenderingContext2D implements iface.CanvasRenderingContext2D {
  final web.CanvasRenderingContext2D _native;
  BrowserCanvasRenderingContext2D(this._native);

  @override
  iface.HTMLCanvasElement get canvas =>
      BrowserHTMLCanvasElement(_native.canvas);

  // -- Rect methods ---------------------------------------------------------

  @override
  void fillRect(num x, num y, num width, num height) =>
      _native.fillRect(x, y, width, height);
  @override
  void strokeRect(num x, num y, num width, num height) =>
      _native.strokeRect(x, y, width, height);
  @override
  void clearRect(num x, num y, num width, num height) =>
      _native.clearRect(x, y, width, height);

  // -- Path methods ---------------------------------------------------------

  @override
  void beginPath() => _native.beginPath();
  @override
  void closePath() => _native.closePath();
  @override
  void moveTo(num x, num y) => _native.moveTo(x, y);
  @override
  void lineTo(num x, num y) => _native.lineTo(x, y);
  @override
  void arc(num x, num y, num radius, num startAngle, num endAngle,
          [bool counterclockwise = false]) =>
      _native.arc(x, y, radius, startAngle, endAngle, counterclockwise);
  @override
  void arcTo(num x1, num y1, num x2, num y2, num radius) =>
      _native.arcTo(x1, y1, x2, y2, radius);
  @override
  void bezierCurveTo(
          num cp1x, num cp1y, num cp2x, num cp2y, num x, num y) =>
      _native.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y);
  @override
  void quadraticCurveTo(num cpx, num cpy, num x, num y) =>
      _native.quadraticCurveTo(cpx, cpy, x, y);
  @override
  void rect(num x, num y, num width, num height) =>
      _native.rect(x, y, width, height);
  @override
  void ellipse(num x, num y, num radiusX, num radiusY, num rotation,
          num startAngle, num endAngle,
          [bool counterclockwise = false]) =>
      _native.ellipse(
          x, y, radiusX, radiusY, rotation, startAngle, endAngle,
          counterclockwise);
  @override
  void fill() => _native.fill();
  @override
  void stroke() => _native.stroke();
  @override
  void clip() => _native.clip();

  // -- Text methods ---------------------------------------------------------

  @override
  void fillText(String text, num x, num y, [num? maxWidth]) =>
      maxWidth != null
          ? _native.fillText(text, x, y, maxWidth)
          : _native.fillText(text, x, y);
  @override
  void strokeText(String text, num x, num y, [num? maxWidth]) =>
      maxWidth != null
          ? _native.strokeText(text, x, y, maxWidth)
          : _native.strokeText(text, x, y);
  @override
  iface.TextMetrics measureText(String text) =>
      BrowserTextMetrics(_native.measureText(text));

  // -- Style properties -----------------------------------------------------

  @override
  Object get fillStyle {
    final v = _native.fillStyle;
    if (v.isA<JSString>()) return (v as JSString).toDart;
    return v;
  }

  @override
  set fillStyle(Object value) =>
      _native.fillStyle = value is String ? value.toJS : value as JSAny;

  @override
  Object get strokeStyle {
    final v = _native.strokeStyle;
    if (v.isA<JSString>()) return (v as JSString).toDart;
    return v;
  }

  @override
  set strokeStyle(Object value) =>
      _native.strokeStyle = value is String ? value.toJS : value as JSAny;

  @override
  double get lineWidth => _native.lineWidth;
  @override
  set lineWidth(num value) => _native.lineWidth = value;
  @override
  String get lineCap => _native.lineCap;
  @override
  set lineCap(String value) => _native.lineCap = value;
  @override
  String get lineJoin => _native.lineJoin;
  @override
  set lineJoin(String value) => _native.lineJoin = value;
  @override
  double get miterLimit => _native.miterLimit;
  @override
  set miterLimit(num value) => _native.miterLimit = value;

  // -- Shadow properties ----------------------------------------------------

  @override
  double get shadowBlur => _native.shadowBlur;
  @override
  set shadowBlur(num value) => _native.shadowBlur = value;
  @override
  String get shadowColor => _native.shadowColor;
  @override
  set shadowColor(String value) => _native.shadowColor = value;
  @override
  double get shadowOffsetX => _native.shadowOffsetX;
  @override
  set shadowOffsetX(num value) => _native.shadowOffsetX = value;
  @override
  double get shadowOffsetY => _native.shadowOffsetY;
  @override
  set shadowOffsetY(num value) => _native.shadowOffsetY = value;

  // -- Text properties ------------------------------------------------------

  @override
  String get font => _native.font;
  @override
  set font(String value) => _native.font = value;
  @override
  String get textAlign => _native.textAlign;
  @override
  set textAlign(String value) => _native.textAlign = value;
  @override
  String get textBaseline => _native.textBaseline;
  @override
  set textBaseline(String value) => _native.textBaseline = value;

  // -- Compositing ----------------------------------------------------------

  @override
  double get globalAlpha => _native.globalAlpha;
  @override
  set globalAlpha(num value) => _native.globalAlpha = value;
  @override
  String get globalCompositeOperation => _native.globalCompositeOperation;
  @override
  set globalCompositeOperation(String value) =>
      _native.globalCompositeOperation = value;

  // -- State ----------------------------------------------------------------

  @override
  void save() => _native.save();
  @override
  void restore() => _native.restore();

  // -- Transforms -----------------------------------------------------------

  @override
  void scale(num x, num y) => _native.scale(x, y);
  @override
  void rotate(num angle) => _native.rotate(angle);
  @override
  void translate(num x, num y) => _native.translate(x, y);
  @override
  void setTransform(num a, num b, num c, num d, num e, num f) =>
      _native.setTransform(
          web.DOMMatrix2DInit(a: a, b: b, c: c, d: d, e: e, f: f));
  @override
  void resetTransform() => _native.resetTransform();

  // -- Image drawing --------------------------------------------------------

  @override
  void drawImage(iface.Element image, num dx, num dy) =>
      _native.drawImage(image.raw as web.CanvasImageSource, dx, dy);
  @override
  void drawImageScaled(
          iface.Element image, num dx, num dy, num dWidth, num dHeight) =>
      _native.drawImage(
          image.raw as web.CanvasImageSource, dx, dy, dWidth, dHeight);
  @override
  void drawImageScaledFromSource(
          iface.Element image,
          num sx,
          num sy,
          num sWidth,
          num sHeight,
          num dx,
          num dy,
          num dWidth,
          num dHeight) =>
      _native.drawImage(image.raw as web.CanvasImageSource, sx, sy, sWidth,
          sHeight, dx, dy, dWidth, dHeight);

  // -- Pixel manipulation ---------------------------------------------------

  @override
  iface.ImageData getImageData(int sx, int sy, int sw, int sh) =>
      BrowserImageData(_native.getImageData(sx, sy, sw, sh));
  @override
  iface.ImageData createImageData(int sw, int sh) =>
      BrowserImageData(_native.createImageData(sw.toJS, sh));
  @override
  void putImageData(iface.ImageData imagedata, int dx, int dy) =>
      _native.putImageData(
          (imagedata as BrowserImageData)._native, dx, dy);

  // -- Line dash ------------------------------------------------------------

  @override
  void setLineDash(List<num> segments) =>
      _native.setLineDash(segments.map((n) => n.toDouble().toJS).toList().toJS);
  @override
  List<num> getLineDash() =>
      _native.getLineDash().toDart.map((js) => js.toDartDouble).toList();
  @override
  double get lineDashOffset => _native.lineDashOffset;
  @override
  set lineDashOffset(num value) => _native.lineDashOffset = value;
}

// ---------------------------------------------------------------------------
// TextMetrics
// ---------------------------------------------------------------------------

class BrowserTextMetrics implements iface.TextMetrics {
  final web.TextMetrics _native;
  BrowserTextMetrics(this._native);

  @override
  double get width => _native.width;
  @override
  double get actualBoundingBoxLeft => _native.actualBoundingBoxLeft;
  @override
  double get actualBoundingBoxRight => _native.actualBoundingBoxRight;
  @override
  double get fontBoundingBoxAscent => _native.fontBoundingBoxAscent;
  @override
  double get fontBoundingBoxDescent => _native.fontBoundingBoxDescent;
  @override
  double get actualBoundingBoxAscent => _native.actualBoundingBoxAscent;
  @override
  double get actualBoundingBoxDescent => _native.actualBoundingBoxDescent;
}

// ---------------------------------------------------------------------------
// ImageData
// ---------------------------------------------------------------------------

class BrowserImageData implements iface.ImageData {
  final web.ImageData _native;
  BrowserImageData(this._native);

  @override
  int get width => _native.width;
  @override
  int get height => _native.height;
  @override
  List<int> get data => _native.data.toDart;
}
