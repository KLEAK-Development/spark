// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// ComponentGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_import

import 'package:spark_framework/spark.dart' hide query, queryAll;

/// Generated reactive implementation of [GeolocationDemo].
class GeolocationDemo extends SparkComponent {
  static const tag = 'geolocation-demo';

  late String _status;
  late String _coords;
  late String _error;
  int? _watchId;

  GeolocationDemo();

  String get status => _status;
  set status(String v) {
    if (_status != v) {
      _status = v;
      scheduleUpdate();
    }
  }

  String get coords => _coords;
  set coords(String v) {
    if (_coords != v) {
      _coords = v;
      scheduleUpdate();
    }
  }

  String get error => _error;
  set error(String v) {
    if (_error != v) {
      _error = v;
      scheduleUpdate();
    }
  }

  @override
  Element build() {
    return div([
      h2('Geolocation API Demo'),

      // Status Section
      div(className: 'section', [
        div(className: 'section-title', ['Status']),
        div([
          span(className: 'status-label', ['Current Status: ']),
          span(className: 'status-value', [status]),
        ]),
        if (error.isNotEmpty)
          div(className: 'error-message', ['Error: $error']),
      ]),

      // Controls
      div(className: 'section', [
        div(className: 'section-title', ['Controls']),
        div(className: 'button-row', [
          button(className: 'btn-primary', [
            'Get Current Position',
          ], onClick: (_) => _getCurrentPosition()),
          if (_watchId == null)
            button(className: 'btn-success', [
              'Start Watch',
            ], onClick: (_) => _startWatch())
          else
            button(className: 'btn-danger', [
              'Stop Watch',
            ], onClick: (_) => _stopWatch()),
        ]),
      ]),

      // Coordinates Display
      if (coords.isNotEmpty)
        div(className: 'section', [
          div(className: 'section-title', ['Position Data']),
          pre(className: 'code-block', [coords]),
        ]),
    ]);
  }

  void _getCurrentPosition() {
    status = 'Requesting position...';
    error = '';

    window.navigator.geolocation.getCurrentPosition(
      (position) {
        status = 'Position retrieved';
        coords = _formatPosition(position);
      },
      (e) {
        status = 'Error';
        error = '[${e.code}] ${e.message}';
      },
      PositionOptions(enableHighAccuracy: true, timeout: 5000, maximumAge: 0),
    );
  }

  void _startWatch() {
    if (_watchId != null) return;

    status = 'Watching position...';
    error = '';

    _watchId = window.navigator.geolocation.watchPosition(
      (position) {
        status = 'Position updated (Watch ID: $_watchId)';
        coords = _formatPosition(position);
      },
      (e) {
        status = 'Watch Error';
        error = '[${e.code}] ${e.message}';
      },
      PositionOptions(enableHighAccuracy: true),
    );
  }

  void _stopWatch() {
    if (_watchId != null) {
      window.navigator.geolocation.clearWatch(_watchId!);
      _watchId = null;
      status = 'Watch stopped';
    }
  }

  String _formatPosition(GeolocationPosition pos) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Timestamp: ${DateTime.fromMillisecondsSinceEpoch(pos.timestamp)}',
    );
    buffer.writeln('Latitude:  ${pos.coords.latitude}');
    buffer.writeln('Longitude: ${pos.coords.longitude}');
    buffer.writeln('Accuracy:  ${pos.coords.accuracy} meters');
    if (pos.coords.altitude != null) {
      buffer.writeln('Altitude:  ${pos.coords.altitude}');
    }
    if (pos.coords.heading != null) {
      buffer.writeln('Heading:   ${pos.coords.heading}');
    }
    if (pos.coords.speed != null) {
      buffer.writeln('Speed:     ${pos.coords.speed}');
    }
    return buffer.toString();
  }

  @override
  String get tagName => tag;

  @override
  List<String> get observedAttributes => const ['status', 'coords', 'error'];

  @override
  void syncAttributes() {
    setAttr('status', status);
    setAttr('coords', coords);
    setAttr('error', error);
  }

  @override
  Map<String, String> get dumpedAttributes => {
    'status': status,
    'coords': coords,
    'error': error,
  };

  @override
  void attributeChangedCallback(
    String name,
    String? oldValue,
    String? newValue,
  ) {
    switch (name) {
      case 'status':
        _status = newValue ?? '';
        break;
      case 'coords':
        _coords = newValue ?? '';
        break;
      case 'error':
        _error = newValue ?? '';
        break;
    }
    super.attributeChangedCallback(name, oldValue, newValue);
  }

  @override
  Stylesheet get adoptedStyleSheets => css({
    ':host': .typed(
      display: .block,
      padding: .all(.px(24)),
      border: CssBorder(width: .px(1), style: .solid, color: .hex('#e0e0e0')),
      borderRadius: .all(.px(12)),
      maxWidth: .px(600),
      fontFamily: .raw('system-ui, -apple-system, sans-serif'),
    ),
    'h2': .typed(
      margin: .zero,
      marginBottom: .px(16),
      fontSize: .px(20),
      color: .hex('#333333'),
    ),
    '.section': .typed(
      marginBottom: .px(16),
      padding: .all(.px(12)),
      backgroundColor: .hex('#f8f9fa'),
      borderRadius: .all(.px(8)),
    ),
    '.section-title': .typed(
      fontSize: .px(14),
      fontWeight: .bold,
      color: .hex('#555555'),
      marginBottom: .px(8),
    ),
    '.status-value': .typed(fontWeight: .bold, color: .hex('#2196f3')),
    '.error-message': .typed(
      marginTop: .px(8),
      color: .hex('#d32f2f'),
      fontWeight: .bold,
    ),
    '.button-row': .typed(
      display: .flex,
      gap: .px(8),
      marginTop: .px(8),
      flexWrap: .wrap,
    ),
    'button': .typed(
      padding: .symmetric(.px(8), .px(16)),
      fontSize: .px(14),
      border: .none,
      borderRadius: .all(.px(6)),
      cursor: .pointer,
      fontWeight: .bold,
      transition: .raw('background-color 0.2s, transform 0.1s'),
    ),
    'button:active': .typed(transform: CssTransform.scale(0.97)),
    '.btn-primary': .typed(backgroundColor: .hex('#2196f3'), color: .white),
    '.btn-primary:hover': .typed(backgroundColor: .hex('#1976d2')),
    '.btn-success': .typed(backgroundColor: .hex('#4caf50'), color: .white),
    '.btn-success:hover': .typed(backgroundColor: .hex('#388e3c')),
    '.btn-danger': .typed(backgroundColor: .hex('#f44336'), color: .white),
    '.btn-danger:hover': .typed(backgroundColor: .hex('#d32f2f')),
    '.code-block': .typed(
      backgroundColor: .hex('#2d2d2d'),
      color: .hex('#f8f8f2'),
      padding: .all(.px(12)),
      borderRadius: .all(.px(6)),
      fontFamily: .raw('monospace'),
      fontSize: .px(13),
      overflowX: .auto,
    ),
  });
}
