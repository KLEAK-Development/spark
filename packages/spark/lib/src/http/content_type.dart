/// Standardized content types supported by Spark.
///
/// This enum simplifies handling of common MIME types in HTTP requests and responses.
enum ContentType {
  /// JSON (application/json)
  json,

  /// Form URL Encoded (application/x-www-form-urlencoded)
  formUrlEncoded,

  /// Multipart Form Data (multipart/form-data)
  multipart,

  /// Plain Text (text/*)
  text,

  /// Binary Data (application/octet-stream)
  binary,

  /// Unknown or unsupported content type
  unknown;

  /// parses the [ContentType] from a MIME type string.
  ///
  /// Returns [ContentType.unknown] if the mime type is null or not recognized.
  static ContentType from(String? mimeType) {
    if (mimeType == null) return unknown;

    final lower = mimeType.toLowerCase();
    // Handle parameters (e.g. application/json; charset=utf-8) by taking only the first part
    final baseType = lower.split(';').first.trim();

    if (baseType == 'application/json') return json;
    if (baseType == 'application/x-www-form-urlencoded') {
      return formUrlEncoded;
    }
    if (baseType == 'multipart/form-data') return multipart;
    if (baseType.startsWith('text/')) return text;
    if (baseType == 'application/octet-stream') return binary;

    return unknown;
  }
}
