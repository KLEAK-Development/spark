/// Browser implementation of the File API wrapping `package:web`.
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import '../file.dart' as iface;

class BrowserBlob implements iface.Blob {
  final web.Blob _nativeBlob;
  BrowserBlob(this._nativeBlob);

  @override
  dynamic get raw => _nativeBlob;

  @override
  int get size => _nativeBlob.size;
  @override
  String get type => _nativeBlob.type;

  @override
  Future<ByteBuffer> arrayBuffer() =>
      _nativeBlob.arrayBuffer().toDart.then((js) => js.toDart);

  @override
  iface.Blob slice([int? start, int? end, String? contentType]) {
    if (contentType != null) {
      return BrowserBlob(
        _nativeBlob.slice(start ?? 0, end ?? size, contentType),
      );
    }
    return BrowserBlob(_nativeBlob.slice(start ?? 0, end ?? size));
  }

  @override
  Future<String> text() => _nativeBlob.text().toDart.then((js) => js.toDart);

  @override
  Stream<Uint8List> stream() {
    final stream = _nativeBlob.stream();
    final reader = stream.getReader() as web.ReadableStreamDefaultReader;
    final controller = StreamController<Uint8List>();

    Future<void> read() async {
      try {
        while (true) {
          final result = await reader.read().toDart;
          if (result.done) {
            await controller.close();
            break;
          }
          final value = result.value;
          if (value != null) {
            controller.add((value as JSUint8Array).toDart);
          }
        }
      } catch (e) {
        controller.addError(e);
        await controller.close();
      }
    }

    read();
    return controller.stream;
  }
}

class BrowserFile extends BrowserBlob implements iface.File {
  final web.File _nativeFile;
  BrowserFile(this._nativeFile) : super(_nativeFile);

  @override
  String get name => _nativeFile.name;
  @override
  int get lastModified => _nativeFile.lastModified;
}

class BrowserFileList implements iface.FileList {
  final web.FileList _native;
  BrowserFileList(this._native);

  @override
  int get length => _native.length;

  @override
  iface.File? item(int index) {
    final f = _native.item(index);
    return f != null ? BrowserFile(f) : null;
  }
}
