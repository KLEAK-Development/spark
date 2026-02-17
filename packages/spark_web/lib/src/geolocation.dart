/// Geolocation API types matching the MDN Web API.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API
library;

// ---------------------------------------------------------------------------
// Callbacks
// ---------------------------------------------------------------------------

typedef PositionCallback = void Function(GeolocationPosition position);
typedef PositionErrorCallback = void Function(GeolocationPositionError error);

// ---------------------------------------------------------------------------
// GeolocationPosition
// ---------------------------------------------------------------------------

/// Represents the position of the concerned device at a given time.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/GeolocationPosition
abstract class GeolocationPosition {
  /// The coordinates defining the current location.
  GeolocationCoordinates get coords;

  /// The time at which the location was retrieved (milliseconds since epoch).
  int get timestamp;
}

// ---------------------------------------------------------------------------
// GeolocationCoordinates
// ---------------------------------------------------------------------------

/// Represents the position and altitude of the device on Earth, as well as the
/// accuracy with which these properties are calculated.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/GeolocationCoordinates
abstract class GeolocationCoordinates {
  /// The position's latitude in decimal degrees.
  double get latitude;

  /// The position's longitude in decimal degrees.
  double get longitude;

  /// The position's altitude in meters, relative to sea level.
  double? get altitude;

  /// The accuracy of the latitude and longitude properties, expressed in meters.
  double get accuracy;

  /// The accuracy of the altitude expressed in meters.
  double? get altitudeAccuracy;

  /// The direction in which the device is traveling, in degrees (0-360).
  ///
  /// This value is 0 if the device is stationary.
  double? get heading;

  /// The magnitude of the horizontal component of the device's velocity in m/s.
  double? get speed;
}

// ---------------------------------------------------------------------------
// GeolocationPositionError
// ---------------------------------------------------------------------------

/// Represents the reason of an error occurring when using the geolocating device.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/GeolocationPositionError
abstract class GeolocationPositionError {
  /// The error code.
  int get code;

  /// A human-readable error message.
  String get message;

  /// The acquisition of the geolocation information failed because
  /// the page didn't have the permission to do it.
  static const int PERMISSION_DENIED = 1;

  /// The acquisition of the geolocation failed because at least one
  /// internal source of position returned an internal error.
  static const int POSITION_UNAVAILABLE = 2;

  /// The time allowed to acquire the geolocation, defined by
  /// [PositionOptions.timeout], was reached before the information was obtained.
  static const int TIMEOUT = 3;
}

// ---------------------------------------------------------------------------
// PositionOptions
// ---------------------------------------------------------------------------

/// Options for methods [Geolocation.getCurrentPosition] and [Geolocation.watchPosition].
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/PositionOptions
class PositionOptions {
  /// A boolean value that indicates the application would like to receive the
  /// best possible results.
  ///
  /// If true and if the device is able to provide a more accurate position,
  /// it will do so. Note that this can result in slower response times or
  /// increased power consumption (with a GPS chip on a mobile device for example).
  /// On the other hand, if false, the device can take the liberty to save
  /// resources by responding more quickly and/or using less power.
  /// Default: false.
  final bool enableHighAccuracy;

  /// A positive long value representing the maximum length of time (in milliseconds)
  /// the device is allowed to take in order to return a position.
  ///
  /// The default value is Infinity, meaning that getCurrentPosition() won't return
  /// until the position is available.
  final int? timeout;

  /// A positive long value indicating the maximum age in milliseconds of a
  /// possible cached position that is acceptable to return.
  ///
  /// If set to 0, it means that the device cannot use a cached position and
  /// must attempt to retrieve the real current position. If set to Infinity
  /// the device must return a cached position regardless of its age.
  /// Default: 0.
  final int maximumAge;

  const PositionOptions({
    this.enableHighAccuracy = false,
    this.timeout,
    this.maximumAge = 0,
  });
}

// ---------------------------------------------------------------------------
// Geolocation
// ---------------------------------------------------------------------------

/// The Geolocation interface represents an object able to programmatically
/// obtain the position of the device.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Geolocation
abstract class Geolocation {
  /// usage: getCurrentPosition(success, error, options)
  void getCurrentPosition(
    PositionCallback successCallback, [
    PositionErrorCallback? errorCallback,
    PositionOptions? options,
  ]);

  /// usage: watchPosition(success, error, options)
  int watchPosition(
    PositionCallback successCallback, [
    PositionErrorCallback? errorCallback,
    PositionOptions? options,
  ]);

  /// usage: clearWatch(id)
  void clearWatch(int watchId);
}
