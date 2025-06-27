import 'package:libserialport/libserialport.dart';
import 'package:sim7600/sim7600.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  final serial = SimSerial();
  final port = serial.port;
  if (!port.isOpen) {
    if (!port.openReadWrite()) {
      print(SerialPort.lastError);
      exit(-1);
    }
  }
  Uint8List at = Uint8List.fromList(utf8.encode('AT\r\n'));
  port.write(at);
  final simReader = SimReader();
  simReader.reader.stream.listen((data) {
    print(utf8.decode(data));
  });
}
