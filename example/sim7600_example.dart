import 'package:libserialport/libserialport.dart';
import 'package:sim7600/sim7600.dart';
import 'dart:io';

void main() async {
  // Writer
  final serial = SimSerial();
  final port = serial.port;
  if (!port.isOpen) {
    if (!port.openReadWrite()) {
      print(SerialPort.lastError);
      exit(-1);
    }
  }
  // serial.writeMessage('AT&V');
  // Reader
  // final simReader = SimReader();
  // print(await simReader.read(signal: 'OK'));
  // Configuration
  SimStatus simStatus = await SimStatus.create();
  print(simStatus.cellNumber);
  print(simStatus.cellFunction.value);
  await simStatus.cellFunction.setMode(1);
  print(simStatus.cellFunction.value);
  exit(0);
}
