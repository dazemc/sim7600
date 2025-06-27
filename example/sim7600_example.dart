import 'package:libserialport/libserialport.dart';
import 'package:sim7600/sim7600.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  // Writer
  final serial = SimSerial();
  final port = serial.port;
  if (!port.isOpen) {
    if (!port.openReadWrite()) {
      print(SerialPort.lastError);
      exit(-1);
    }
  }
  serial.writeMessage('AT&V');
  // Reader
  final simReader = SimReader();
  simReader.listen();
}
