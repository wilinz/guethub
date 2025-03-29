import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:guethub/data/database/database.dart';
import 'package:guethub/data/get_storage.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/background_image.dart';
import 'package:guethub/data/repository/campus_network.dart';
import 'package:guethub/data/repository/network_detection.dart';
import 'package:guethub/device_info.dart';
import 'package:guethub/package_info.dart';
import 'package:guethub/path.dart';
import 'package:rust_module/src/rust/frb_generated.dart';
import 'package:guethub/ui/route.dart';
import 'package:guethub/ui/settings/settings_controller.dart';
import 'package:guethub/util/platform.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rust_module/rust_module.dart';
import 'data/device/tracking.dart';
import 'generated/locales.g.dart';
import 'map/amap.dart';
import 'ui/page/theme/theme_changer_controller.dart';
import 'package:guethub/logger.dart';

Future<void> main() async {
  //确保组件树初始化
  WidgetsFlutterBinding.ensureInitialized();
  final t1 = DateTime.now();
  await initDesktopWindow();

  await RustLib.init();
  await Future.wait([
    initDeviceInfo(),
    initGetStorage(),
    initFlutterUdid(),
    initFilePath(),
    initPackageInfo(),
    initAmap()
  ]);
  await () async {
    await initLoggerOnLaunch();
    await Future.wait([initAppDatabase()]);
    await AppNetwork.init();
  }();

  try {
    clearDiskCachedImages(duration: Duration(days: 7));
  } catch (e) {
    logger.e(e);
  }

  NetworkDetectionRepository.get().refresh();
  CampusNetworkRepository.get().refresh();
  BackgroundImageRepository.get().init();

  final t2 = DateTime.now();
  logger.d(
      "Init consuming: ${t2.millisecondsSinceEpoch - t1.millisecondsSinceEpoch}");

  runApp(const MyApp());
}

Future<void> initDesktopWindow() async {
  if (PlatformUtil.isDesktop()) {
    final screen = await getCurrentScreen();

    final sc = Platform.isMacOS ? 1.0 : (screen?.scaleFactor ?? 1);
    final padding = 32 / sc;
    final height =
        ((screen?.visibleFrame.height ?? 450) + padding * 2) - padding * 2;
    final size = Size(height * 1.5, height) / sc;

    // 必须加上这一行。
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(size: size);

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.setMinimizable(true);
      await windowManager.setAlignment(Alignment.center);
      await windowManager.setMaximizable(false);
      await windowManager.setResizable(true);
      final position = await windowManager.getPosition();
      await windowManager
          .setPosition(Offset(position.dx - padding, position.dy));
      // await windowManager.setTitleBarStyle(TitleBarStyle.normal,windowButtonVisibility: true);
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

showSnackBar(BuildContext context, String msg, int milliseconds) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      // action: SnackBarAction(label: '撤销', onPressed: Null),
      duration: Duration(milliseconds: milliseconds)));
}

class MyApp extends StatefulWidget with WindowListener {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final settings = Get.put(SettingsController(getStorage));
  final themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    return GetMaterialApp(
        title: LocaleKeys.app_name.tr,
        builder: FToastBuilder(),
        translationsKeys: AppTranslation.translations,
        defaultTransition: Transition.cupertino,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [
          settings.locale.value ?? Get.deviceLocale ?? Locale("zh", "CN"),
        ],
        // 转场动画
        // locale: Locale('en', 'US'),
        locale: settings.locale.value ?? Get.deviceLocale,
        fallbackLocale: Locale('zh', 'CN'),
        theme: themeController.getTheme(),
        darkTheme: themeController.getTheme(brightness: Brightness.dark),
        themeMode: themeController.themeMode.value,
        debugShowCheckedModeBanner: false,
        navigatorKey: AppRoute.navigatorKey,
        getPages: AppRoute.routes);
  }

  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  StreamSubscription<List<ConnectivityResult>>? subscription;

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
    subscription = Connectivity().onConnectivityChanged.listen((result) {
      NetworkDetectionRepository.get().refresh();
      CampusNetworkRepository.get().refresh();
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    subscription?.cancel();
    super.dispose();
  }
}

ScrollBehavior myScrollBehavior(BuildContext context) =>
    ScrollConfiguration.of(context).copyWith(
      dragDevices: PointerDeviceKind.values.toSet(),
    );
