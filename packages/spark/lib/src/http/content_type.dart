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

    if (lower.contains('application/json')) return json;
    if (lower.contains('application/x-www-form-urlencoded')) {
      return formUrlEncoded;
    }
    if (lower.contains('multipart/form-data')) return multipart;
    if (lower.contains('text/')) return text;
    if (lower.contains('application/octet-stream')) return binary;

    return unknown;
  }
}
