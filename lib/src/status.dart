import 'read.dart';

class SimStatus {
  late String cellNumber;
  late String cellFunction;

  SimStatus._(this.cellNumber, this.cellFunction);

  static Future<SimStatus> create() async {
    StringBuffer buffer = StringBuffer();
    final simReader = SimReader();

    buffer.write(await _initField('AT+CNUM', simReader));
    String number =
        _initCellNumber(buffer) ?? 'Error retrieving number, buffer: $buffer';
    buffer.clear();

    buffer.write(await _initField('AT+CFUN?', simReader));
    String function =
        _initCellFunction(buffer) ??
        'Error reading device function, buffer: $buffer';
    buffer.clear();

    return SimStatus._(number, function);
  }

  static Future<String> _initField(String msg, SimReader simReader) async {
    return simReader.writeAndRead(msg: msg, signal: 'OK');
  }

  static String? _initCellNumber(StringBuffer buffer) {
    return buffer.toString().split('"')[3].trim();
  }

  static String? _initCellFunction(StringBuffer buffer) {
    print(buffer.toString());
    return '';
  }
}
