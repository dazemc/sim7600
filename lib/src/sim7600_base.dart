import 'package:libserialport/libserialport.dart';

const String comName = '/dev/ttyUSB2';

class SimSerial {
  final SerialPort port;
  static final SimSerial _instance = SimSerial._internal();
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
}
