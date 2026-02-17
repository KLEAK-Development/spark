import 'dart:async';
import 'package:spark_framework/spark.dart';

@Component(tag: GeolocationDemo.tag)
class GeolocationDemo {
  static const tag = 'geolocation-demo';

  int? _watchId;

  GeolocationDemo({this.status = 'Ready', this.coords = '', this.error = ''});

  @Attribute()
  String status = 'Ready';

  @Attribute()
  String coords = '';

  @Attribute()
  String error = '';

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

  Element render() {
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

  Future<void> _getCurrentPosition({bool highAccuracy = true}) async {
    status = highAccuracy
        ? 'Requesting position (High Accuracy)...'
        : 'Requesting position (Low Accuracy)...';
    error = '';

    try {
      final position = await window.navigator.geolocation.getPosition(
        PositionOptions(
          enableHighAccuracy: highAccuracy,
          timeout: 15000,
          maximumAge: 0,
        ),
      );
      status = 'Position retrieved';
      coords = _formatPosition(position);
    } catch (e) {
      if (e is GeolocationPositionError && highAccuracy && e.code == 2) {
        // Firefox sometimes fails with code 2 (POSITION_UNAVAILABLE) when
        // enableHighAccuracy is true on systems without a GPS.
        // Fallback to low accuracy in this case.
        return _getCurrentPosition(highAccuracy: false);
      }
      status = 'Error';
      if (e is GeolocationPositionError) {
        error = '[${e.code}] ${e.message}';
      } else {
        error = e.toString();
      }
    }
  }

  void _startWatch({bool highAccuracy = true}) {
    if (_watchId != null) return;

    status = highAccuracy
        ? 'Watching position (High Accuracy)...'
        : 'Watching position (Low Accuracy)...';
    error = '';

    final stream = window.navigator.geolocation.onPositionChanged(
      PositionOptions(enableHighAccuracy: highAccuracy),
    );

    // We still use _watchId internally to track if we're watching,
    // though the implementation now uses a Stream.
    _watchId = 1; // Dummy ID

    final subscription = stream.listen(
      (position) {
        status = 'Position updated';
        coords = _formatPosition(position);
      },
      onError: (e) {
        if (e is GeolocationPositionError && highAccuracy && e.code == 2) {
          _stopWatch();
          _startWatch(highAccuracy: false);
          return;
        }
        status = 'Watch Error';
        if (e is GeolocationPositionError) {
          error = '[${e.code}] ${e.message}';
        } else {
          error = e.toString();
        }
      },
    );

    // Store subscription in a way we can cancel it
    _subscription = subscription;
  }

  StreamSubscription? _subscription;

  void _stopWatch() {
    _subscription?.cancel();
    _subscription = null;
    _watchId = null;
    status = 'Watch stopped';
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
}
