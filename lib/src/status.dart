import 'package:libserialport/libserialport.dart';

import 'read.dart';

class SimStatus {
  late String cellNumber;
  late CellFunction cellFunction;
  final _simReader = SimReader();

  SimStatus._(this.cellNumber, this.cellFunction);

  static Future<SimStatus> create() async {
    StringBuffer buffer = StringBuffer();
    final simReader = SimReader();
    try {
      buffer.write(await getField('AT+CNUM', simReader));
      String number =
          getCellNumber(buffer) ?? 'Error retrieving number, buffer: $buffer';
      buffer.clear();

      buffer.write(await getField('AT+CFUN?', simReader));
      String function =
          getCellFunction(buffer) ??
          'Error reading device function, buffer: $buffer';
      final CellFunction cellFunction = CellFunction(function);
      buffer.clear();

      return SimStatus._(number, cellFunction);
    } catch (e) {
      throw SerialPortError('Error $e from ${SerialPort.lastError}');
    }
  }

  static Future<String> getField(String msg, SimReader simReader) async {
    return simReader.writeAndRead(msg: msg, signal: 'OK');
  }

  static String? getCellNumber(StringBuffer buffer) {
    List<String> response = buffer.toString().split('"');
    if (response.length >= 3) {
      return response[3].trim();
    }
    return null;
  }

  Future<void> updateCellFunction() async {
    cellFunction = CellFunction(
      getCellNumber(StringBuffer(await getField('AT+CFUN?', _simReader))) ?? '',
    );
  }

  static String? getCellFunction(StringBuffer buffer) {
    return buffer.toString().split(':').last.replaceAll('OK', '').trim();
  }
}

class CellFunction {
  final String value;
  const CellFunction(this.value);

  Future<void> setMode(int mode) async {
    /// 0 - Minimum Functionality
    /// 1 - Full Functionality, online mode
    /// 4 - Disable phone RX/TX RF
    /// 5 - Factory Test Mode
    /// 6 - Reset
    /// 7 - Offline Mode
    final simReader = SimReader();
    print('Setting mode $mode');
    final request = await simReader.writeAndRead(
      msg: 'AT+CFUN=$mode',
      signal: 'OK',
    );
    if (!request.contains('OK')) {
      print('Error setting mode: $request');
    }
    final SimStatus status = await SimStatus.create();
    status.updateCellFunction();
  }
}
