import 'dart:async';
import 'dart:typed_data';

class Test implements StreamConsumer<Uint8List> {
  final StreamSink<List<int>> _sink;

  Test(this._sink);

  @override
  Future addStream(Stream<Uint8List> stream) {
    return _sink.addStream(stream.map((event) {
      return List<int>.from(event);
    }));
  }

  @override
  Future close() {
    return _sink.close();
  }

}
