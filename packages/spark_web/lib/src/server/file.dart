/// Server-side implementation of the File API.
library;

import 'dart:typed_data';
import '../file.dart' as iface;

class ServerBlob implements iface.Blob {
  @override
  int get size => 0;
  @override
  String get type => '';

  @override
  Future<ByteBuffer> arrayBuffer() async => Uint8List(0).buffer;

  @override
  iface.Blob slice([int? start, int? end, String? contentType]) => ServerBlob();

  @override
  Future<String> text() async => '';

  @override
  Stream<Uint8List> stream() => const Stream.empty();

  @override
  dynamic get raw => null;
}

class ServerFile extends ServerBlob implements iface.File {
  @override
  String get name => '';
  @override
  int get lastModified => 0;
}

class ServerFileList implements iface.FileList {
  @override
  int get length => 0;
  @override
  iface.File? item(int index) => null;
}
