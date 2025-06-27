import 'dart:async';
import 'dart:io';

import 'package:libserialport/libserialport.dart';
import 'dart:convert';
import 'dart:typed_data';

const String comName = '/dev/ttyUSB2';

class SimSerial {
  static final SimSerial _instance = SimSerial._internal();
  final SerialPort port;

  factory SimSerial() => _instance;

  SimSerial._internal() : port = SerialPort(comName) {
    if (!port.openReadWrite()) {
      throw SerialPortError('Failed to open $comName: ${SerialPort.lastError}');
    }
    final SerialPortConfig config = SerialPortConfig();
    config.baudRate = 115200;
    config.bits = 8;
    config.parity = SerialPortParity.none;
    config.stopBits = 1;
    port.config = config;
    port.flush();
  }

  Uint8List _encodeMsg(String msg) {
    return Uint8List.fromList(utf8.encode('$msg\r\n'));
  }

  void writeMessage(String msg) {
    if (!port.isOpen) {
      throw SerialPortError(
        'Could not send message: $msg\nPort is not open ${SerialPort.lastError}',
      );
    }
    port.write(_encodeMsg(msg));
  }
}

class SimReader {
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

  void listen() {
    reader.stream.listen((data) {
      print(_decodeMsg(data));
    });
  }

  void read() {
    reader.stream.listen((data) {
      final String msg = _decodeMsg(data).trim();
      print(msg);
      if (msg.contains('OK')) {
        reader.close();
      }
    });
  }
}
