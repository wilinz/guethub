import 'package:fl_amap/fl_amap.dart';
import 'package:flutter/foundation.dart';

class AmapConfig {
  static const String androidApiKeyDebug = "ac1fca1ed0b8eaaae7d0c2f35a3d61ce";
  static const String androidApiKeyRelease = "95db5679413272eb49c69417233d6405";
  static const String iosApiKey = "5b1935554cdba00e590a996492fb44d5";

  static String get androidApiKey => kDebugMode ? androidApiKeyDebug : androidApiKeyRelease;

// static AMapApiKey get aMapApiKey =>
//     AMapApiKey(androidKey: androidApiKey, iosKey: iosApiKey);
}

Future<void> initAmap() async {
  // AMapFlutterLocation.setApiKey(AmapConfig.androidApiKey, AmapConfig.iosApiKey);
  // AMapFlutterLocation.updatePrivacyShow(true, true);
  // AMapFlutterLocation.updatePrivacyAgree(true);
  final ok = await FlAMap().setAMapKey(
      iosKey: AmapConfig.iosApiKey,
      androidKey: AmapConfig.androidApiKey);

  if (ok) print('Init Amap successful');
}
