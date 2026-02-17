/// Browser implementation of the Geolocation API wrapping `package:web`.
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

import '../geolocation.dart' as iface;

// ---------------------------------------------------------------------------
// BrowserGeolocation
// ---------------------------------------------------------------------------

class BrowserGeolocation implements iface.Geolocation {
  final web.Geolocation _native;

  BrowserGeolocation(this._native);

  @override
  void getCurrentPosition(
    iface.PositionCallback successCallback, [
    iface.PositionErrorCallback? errorCallback,
    iface.PositionOptions? options,
  ]) {
    final nativeOptions = _createNativeOptions(options);

    if (nativeOptions != null) {
      _native.getCurrentPosition(
        ((web.GeolocationPosition pos) => successCallback(
          BrowserGeolocationPosition(pos),
        )).toJS,
        errorCallback == null
            ? null
            : ((web.GeolocationPositionError err) => errorCallback(
                BrowserGeolocationPositionError(err),
              )).toJS,
        nativeOptions,
      );
    } else {
      _native.getCurrentPosition(
        ((web.GeolocationPosition pos) => successCallback(
          BrowserGeolocationPosition(pos),
        )).toJS,
        errorCallback == null
            ? null
            : ((web.GeolocationPositionError err) => errorCallback(
                BrowserGeolocationPositionError(err),
              )).toJS,
      );
    }
  }

  @override
  int watchPosition(
    iface.PositionCallback successCallback, [
    iface.PositionErrorCallback? errorCallback,
    iface.PositionOptions? options,
  ]) {
    final nativeOptions = _createNativeOptions(options);

    if (nativeOptions != null) {
      return _native.watchPosition(
        ((web.GeolocationPosition pos) => successCallback(
          BrowserGeolocationPosition(pos),
        )).toJS,
        errorCallback == null
            ? null
            : ((web.GeolocationPositionError err) => errorCallback(
                BrowserGeolocationPositionError(err),
              )).toJS,
        nativeOptions,
      );
    } else {
      return _native.watchPosition(
        ((web.GeolocationPosition pos) => successCallback(
          BrowserGeolocationPosition(pos),
        )).toJS,
        errorCallback == null
            ? null
            : ((web.GeolocationPositionError err) => errorCallback(
                BrowserGeolocationPositionError(err),
              )).toJS,
      );
    }
  }

  @override
  void clearWatch(int watchId) => _native.clearWatch(watchId);

  static web.PositionOptions? _createNativeOptions(
    iface.PositionOptions? options,
  ) {
    if (options == null) return null;

    final webOptions = web.PositionOptions(
      enableHighAccuracy: options.enableHighAccuracy,
      maximumAge: options.maximumAge,
    );

    if (options.timeout != null) {
      webOptions.timeout = options.timeout!;
    }

    return webOptions;
  }
}

// ---------------------------------------------------------------------------
// BrowserGeolocationPosition
// ---------------------------------------------------------------------------

class BrowserGeolocationPosition implements iface.GeolocationPosition {
  final web.GeolocationPosition _native;

  BrowserGeolocationPosition(this._native);

  @override
  iface.GeolocationCoordinates get coords =>
      BrowserGeolocationCoordinates(_native.coords);

  @override
  int get timestamp => _native.timestamp;
}

// ---------------------------------------------------------------------------
// BrowserGeolocationCoordinates
// ---------------------------------------------------------------------------

class BrowserGeolocationCoordinates implements iface.GeolocationCoordinates {
  final web.GeolocationCoordinates _native;

  BrowserGeolocationCoordinates(this._native);

  @override
  double get latitude => _native.latitude;

  @override
  double get longitude => _native.longitude;

  @override
  double? get altitude => _native.altitude;

  @override
  double get accuracy => _native.accuracy;

  @override
  double? get altitudeAccuracy => _native.altitudeAccuracy;

  @override
  double? get heading => _native.heading;

  @override
  double? get speed => _native.speed;
}

// ---------------------------------------------------------------------------
// BrowserGeolocationPositionError
// ---------------------------------------------------------------------------

class BrowserGeolocationPositionError
    implements iface.GeolocationPositionError {
  final web.GeolocationPositionError _native;

  BrowserGeolocationPositionError(this._native);

  @override
  int get code => _native.code;

  @override
  String get message => _native.message;
}
