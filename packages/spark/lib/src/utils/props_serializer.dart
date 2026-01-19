/// JSON props serialization utilities for passing complex data to components.
library;

import 'dart:convert';

/// Encodes a Map as a base64-encoded JSON string for use in HTML attributes.
///
/// This is useful for passing complex data structures to components
/// without worrying about HTML escaping issues.
///
/// ## Example
///
/// ```dart
/// // Server-side rendering
/// static String render({required User user}) {
///   return '''
///     <$tag data="${encodeProps({'name': user.name, 'id': user.id})}">
///       ...
///     </$tag>
///   ''';
/// }
///
/// // Client-side hydration
/// @override
/// void connectedCallback() {
///   final data = decodeProps(prop('data'));
///   final userName = data['name'] as String;
/// }
/// ```
String encodeProps(Map<String, dynamic> props) {
  final json = jsonEncode(props);
  return base64Encode(utf8.encode(json));
}

/// Decodes a base64-encoded JSON string back to a Map.
///
/// Returns an empty Map if the input is empty or invalid.
///
/// ## Example
///
/// ```dart
/// final props = decodeProps(prop('data'));
/// final name = props['name'] as String?;
/// ```
Map<String, dynamic> decodeProps(String encoded) {
  if (encoded.isEmpty) return {};

  try {
    final json = utf8.decode(base64Decode(encoded));
    final decoded = jsonDecode(json);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return {};
  } catch (e) {
    // Invalid base64 or JSON
    return {};
  }
}

/// Type-safe props helper for extracting values from decoded props.
///
/// ## Example
///
/// ```dart
/// final props = decodeProps(prop('data'));
/// final name = getPropsValue<String>(props, 'name', 'Unknown');
/// final count = getPropsValue<int>(props, 'count', 0);
/// ```
T getPropsValue<T>(Map<String, dynamic> props, String key, T defaultValue) {
  final value = props[key];
  if (value is T) return value;
  return defaultValue;
}

/// Extracts a String value from props.
String getPropsString(
  Map<String, dynamic> props,
  String key, [
  String defaultValue = '',
]) {
  return getPropsValue<String>(props, key, defaultValue);
}

/// Extracts an int value from props.
///
/// Handles both int and String representations.
int getPropsInt(
  Map<String, dynamic> props,
  String key, [
  int defaultValue = 0,
]) {
  final value = props[key];
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? defaultValue;
  if (value is double) return value.toInt();
  return defaultValue;
}

/// Extracts a double value from props.
///
/// Handles int, double, and String representations.
double getPropsDouble(
  Map<String, dynamic> props,
  String key, [
  double defaultValue = 0.0,
]) {
  final value = props[key];
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// Extracts a bool value from props.
///
/// Handles bool, int (0/1), and String ('true'/'false') representations.
bool getPropsBool(
  Map<String, dynamic> props,
  String key, [
  bool defaultValue = false,
]) {
  final value = props[key];
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  return defaultValue;
}

/// Extracts a List value from props.
///
/// Returns an empty list if the value is not a List.
List<T> getPropsList<T>(Map<String, dynamic> props, String key) {
  final value = props[key];
  if (value is List) {
    return value.whereType<T>().toList();
  }
  return [];
}

/// Extracts a nested Map value from props.
///
/// Returns an empty map if the value is not a Map.
Map<String, dynamic> getPropsMap(Map<String, dynamic> props, String key) {
  final value = props[key];
  if (value is Map<String, dynamic>) return value;
  return {};
}

/// A typed wrapper for component props that provides convenient accessors.
///
/// ## Example
///
/// ```dart
/// @override
/// void connectedCallback() {
///   final props = Props.decode(prop('data'));
///   final name = props.getString('name');
///   final count = props.getInt('count');
///   final items = props.getList<String>('items');
/// }
/// ```
class Props {
  /// The underlying decoded props map.
  final Map<String, dynamic> _data;

  /// Creates a Props instance from a decoded map.
  const Props(this._data);

  /// Creates a Props instance by decoding a base64-encoded JSON string.
  factory Props.decode(String encoded) {
    return Props(decodeProps(encoded));
  }

  /// Creates an empty Props instance.
  const Props.empty() : _data = const {};

  /// Returns the underlying map.
  Map<String, dynamic> get data => _data;

  /// Checks if the props contain a key.
  bool has(String key) => _data.containsKey(key);

  /// Gets a raw value by key.
  dynamic get(String key) => _data[key];

  /// Gets a String value.
  String getString(String key, [String defaultValue = '']) =>
      getPropsString(_data, key, defaultValue);

  /// Gets an int value.
  int getInt(String key, [int defaultValue = 0]) =>
      getPropsInt(_data, key, defaultValue);

  /// Gets a double value.
  double getDouble(String key, [double defaultValue = 0.0]) =>
      getPropsDouble(_data, key, defaultValue);

  /// Gets a bool value.
  bool getBool(String key, [bool defaultValue = false]) =>
      getPropsBool(_data, key, defaultValue);

  /// Gets a List value.
  List<T> getList<T>(String key) => getPropsList<T>(_data, key);

  /// Gets a nested Map value.
  Map<String, dynamic> getMap(String key) => getPropsMap(_data, key);

  /// Gets a nested Props value.
  Props getNested(String key) => Props(getMap(key));

  @override
  String toString() => 'Props($_data)';
}
