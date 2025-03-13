import 'package:flutter_udid/flutter_udid.dart';

late String udid;

// d9e7a046ab07be8b421d9585bd95e09426e290dd5de12efbca21887f6a5c21d5
Future<void> initFlutterUdid() async {
    udid = await FlutterUdid.consistentUdid;
    print("Device UDID is: ${udid}");
}