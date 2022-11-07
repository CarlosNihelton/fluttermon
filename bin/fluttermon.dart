import 'package:fluttermon/fluttermon.dart' as fluttermon;

Future<void> main(List<String> arguments) async {
  final mon = fluttermon.Monitor(arguments);
  await mon.start();
}
