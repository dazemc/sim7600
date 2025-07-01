import 'read.dart';

class SimConfiguration {
  late String cellNumber;

  SimConfiguration._(this.cellNumber);

  static Future<SimConfiguration> create() async {
    StringBuffer buffer = StringBuffer();
    final simReader = SimReader();

    buffer.write(await _initField('AT+CNUM', simReader));
    String number = _initCellNumber(buffer) ?? 'Error retrieving number';
    buffer.clear();

    return SimConfiguration._(number);
  }

  static Future<String> _initField(String msg, SimReader simReader) async {
    return simReader.writeAndRead(msg: msg, signal: 'OK');
  }

  static String? _initCellNumber(StringBuffer response) {
    return response.toString().split('"')[3].trim();
  }
}
