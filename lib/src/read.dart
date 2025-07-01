import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
import 'package:libserialport/libserialport.dart';

import 'write.dart';

class SimReader {
  /// Class for reading serial communications
  final SerialPortReader reader;

  factory SimReader() {
    final simSerial = SimSerial();
    final reader = SerialPortReader(simSerial.port);
    return SimReader._internal(reader);
  }

  SimReader._internal(this.reader);
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
    /// Looks for the sent message and the return signal in the serial stream and returns as a string.
    required String msg,
    String signal = '\r\n',
  }) async {
    final simSerial = SimSerial();
    simSerial.writeMessage(msg);
    String buffer = '';
    return await reader.stream
        .map((data) => _decodeMsg(data))
        .takeWhile((response) {
          buffer += response;
          return !buffer.contains(signal);
        })
        .last
        .timeout(Duration(seconds: 3), onTimeout: () => 'device timeout')
        .then((_) => buffer.isEmpty ? '' : buffer);
  }
}
