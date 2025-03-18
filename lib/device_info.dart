import 'package:device_info_plus/device_info_plus.dart';

late BaseDeviceInfo deviceInfo;

Future<void> initDeviceInfo() async {
  deviceInfo = await DeviceInfoPlugin().deviceInfo;
}
