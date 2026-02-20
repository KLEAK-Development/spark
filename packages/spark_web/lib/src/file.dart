/// File API types matching the MDN Web API.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/File_API
library;

import 'dart:typed_data';

// ---------------------------------------------------------------------------
// Blob
// ---------------------------------------------------------------------------

/// A file-like object of immutable, raw data.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/Blob
abstract class Blob {
  int get size;
  String get type;

  Future<ByteBuffer> arrayBuffer();
  Blob slice([int? start, int? end, String? contentType]);
  Future<String> text();
  Stream<Uint8List> stream();

  /// The underlying platform object.
  dynamic get raw;
}

// ---------------------------------------------------------------------------
// File
// ---------------------------------------------------------------------------

/// A file from the user's system.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/File
abstract class File implements Blob {
  String get name;
  int get lastModified;
}

// ---------------------------------------------------------------------------
// FileList
// ---------------------------------------------------------------------------

/// A list of [File] objects (e.g., from an `<input type="file">`).
///
/// See: https://developer.mozilla.org/en-US/docs/Web/API/FileList
abstract class FileList {
  int get length;
  File? item(int index);
}
