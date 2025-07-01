import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:libserialport/libserialport.dart';

import 'write.dart';

class SimReader {
  /// Class for reading serial communications
  final SerialPortReader reader;
  final SimSerial simSerial;

  factory SimReader() {
    final simSerial = SimSerial();
    final reader = SerialPortReader(simSerial.port);
    return SimReader._internal(reader, simSerial);
  }

  SimReader._internal(this.reader, this.simSerial);
  String _decodeMsg(Uint8List data) {
    return utf8.decode(data, allowMalformed: true);
  }

  StreamSubscription listen() {
    /// Stream serial communication
    return reader.stream.listen((data) {
      print(_decodeMsg(data));
    });
  }

  Future<String> read({String signal = "\r\n"}) async {
    /// Returns serial communication when signal is found, defaults to carriage return if no value is given
    return await reader.stream
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
        simSerial.port.flush();
        simSerial.writeMessage('$msg\r\n');
        final buffer = StringBuffer();
        await for (var data in reader.stream.map(_decodeMsg).timeout(timeout)) {
          buffer.write(data);
          String content = buffer.toString();
          if (content.contains(signal)) {
            return content;
          }
        }
        print('Attempt $attempt: Signal "$signal" not found!');
      } catch (e) {
        print('Attempt $attempt error: $e');
        if (attempt == retries) return '';
        await Future.delayed(Duration(milliseconds: 500)); // retry
      } finally {
        reader.close();
      }
    }
    return '';
  }
}
