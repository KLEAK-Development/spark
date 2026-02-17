/// Server-side implementation of the Geolocation API.
///
/// No-op on the server — geolocation is a browser-only concept.
library;

import '../geolocation.dart' as iface;

// ---------------------------------------------------------------------------
// ServerGeolocation
// ---------------------------------------------------------------------------

class ServerGeolocation implements iface.Geolocation {
  @override
  void getCurrentPosition(
    iface.PositionCallback successCallback, [
    iface.PositionErrorCallback? errorCallback,
    iface.PositionOptions? options,
  ]) {
    // Immediately report that geolocation is unavailable on the server.
    if (errorCallback != null) {
      errorCallback(
        ServerGeolocationPositionError(
          iface.GeolocationPositionError.POSITION_UNAVAILABLE,
          'Geolocation is not supported on the server.',
        ),
      );
    }
  }

  @override
  int watchPosition(
    iface.PositionCallback successCallback, [
    iface.PositionErrorCallback? errorCallback,
    iface.PositionOptions? options,
  ]) {
    // Immediately report that geolocation is unavailable on the server.
    if (errorCallback != null) {
      errorCallback(
        ServerGeolocationPositionError(
          iface.GeolocationPositionError.POSITION_UNAVAILABLE,
          'Geolocation is not supported on the server.',
        ),
      );
    }
    return 0;
  }

  @override
  void clearWatch(int watchId) {
    // No-op
  }
}

// ---------------------------------------------------------------------------
// ServerGeolocationPosition
// ---------------------------------------------------------------------------

class ServerGeolocationPosition implements iface.GeolocationPosition {
  @override
  final iface.GeolocationCoordinates coords;

  @override
  final int timestamp;

  ServerGeolocationPosition({
    iface.GeolocationCoordinates? coords,
    int? timestamp,
  }) : coords = coords ?? ServerGeolocationCoordinates(),
       timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
}

// ---------------------------------------------------------------------------
// ServerGeolocationCoordinates
// ---------------------------------------------------------------------------

class ServerGeolocationCoordinates implements iface.GeolocationCoordinates {
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double? altitude;
  @override
  final double accuracy;
  @override
  final double? altitudeAccuracy;
  @override
  final double? heading;
  @override
  final double? speed;

  ServerGeolocationCoordinates({
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.altitude,
    this.accuracy = 0.0,
    this.altitudeAccuracy,
    this.heading,
    this.speed,
  });
}

// ---------------------------------------------------------------------------
// ServerGeolocationPositionError
// ---------------------------------------------------------------------------

class ServerGeolocationPositionError implements iface.GeolocationPositionError {
  @override
  final int code;
  @override
  final String message;

  ServerGeolocationPositionError(this.code, this.message);
}
