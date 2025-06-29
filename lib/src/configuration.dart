import 'comm_imports.dart';

class SimConfiguration {
  final simReader = SimReader();
  late Future<String> rawConfig;
  SimConfiguration() {
    rawConfig = simReader.writeAndRead(msg: 'AT&V', signal: 'OK');
  }
}
