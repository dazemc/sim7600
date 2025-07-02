import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:libserialport/libserialport.dart';

import 'write.dart';

class SimReader {
  /// Class for reading serial communications
  static final SimReader _instance = SimReader._internal();
  final SerialPortReader reader;
  final SimSerial simSerial;
  final Stream<Uint8List> _broadcastStream;
  StreamSubscription? _subscription;

  factory SimReader() => _instance;

  SimReader._internal()
    : simSerial = SimSerial(),
      reader = SerialPortReader(SimSerial().port),
      _broadcastStream =
          SerialPortReader(SimSerial().port).stream.asBroadcastStream();

  String _decodeMsg(Uint8List data) {
    return utf8.decode(data, allowMalformed: true);
  }

  StreamSubscription listen() {
    /// Stream serial communication
    _subscription?.cancel();
    _subscription = _broadcastStream.listen(
      (data) {
        print(_decodeMsg(data));
      },
      onError: (e) => print('Stream error: $e'),
      onDone: () {
        print('Stream done.');
      },
    );
    return _subscription!;
  }

  Future<String> read({String signal = "\r\n"}) async {
    /// Returns serial communication when signal is found, defaults to carriage return if no value is given
    return await _broadcastStream
        .map((data) => _decodeMsg(data))
        .firstWhere((msg) => msg.contains(signal), orElse: () => '');
  }

  Future<String> writeAndRead({
    required String msg,
    String signal = '\r\n',
    Duration timeout = const Duration(seconds: 5),
    int retries = 3,
  }) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        simSerial.writeMessage('$msg\r\n');
        final buffer = StringBuffer();
        await for (var data in _broadcastStream
            .map(_decodeMsg)
            .timeout(timeout)) {
          buffer.write(data);
          String content = buffer.toString();
          if (content.contains(signal)) {
            return content;
          } else if (content.toLowerCase().contains('error')) {
            throw SerialPortError('Error sending $msg ${SerialPort.lastError}');
          }
        }
        print('Attempt $attempt: Signal "$signal" not found!');
      } catch (e) {
        print('Attempt $attempt error: $e');
        if (attempt == retries) return '';
        await Future.delayed(Duration(milliseconds: 500)); // retry
      }
    }
    return '';
  }
}
