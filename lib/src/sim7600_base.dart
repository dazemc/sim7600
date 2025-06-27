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

  Uint8List _convertMsg(String msg) {
    return Uint8List.fromList(utf8.encode('$msg\r\n'));
  }

  void writeMessage(String msg) {
    port.write(_convertMsg(msg));
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

  void listen() {
    reader.stream.listen((data) {
      print(utf8.decode(data, allowMalformed: true));
    });
  }
}
