import 'dart:async';

import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:guethub/data/get_storage.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/util/platform.dart';
import 'package:kt_dart/kt.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

WebViewEnvironment? webViewEnvironment;

class WebViewArgs {
  final String url;

  WebViewArgs({required this.url});
}

class WebView extends StatefulWidget {
  final WebViewArgs args;

  const WebView({super.key, required this.args});

  @override
  State<WebView> createState() => WebViewState();
}

class WebViewState extends State<WebView> {
  bool isInit = false;
  DateTime? lastPressed; // for double back exit
  bool isMobileMode = false;

  final GetStorage storage = getStorage;

  @override
  void initState() {
    super.initState();
    init();
  }

  bool _isLargeScreen(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth >= 600; // 600 是一个常用的宽度阈值
  }

  init() async {
    final isLargeScreen = _isLargeScreen(Get.context!);
    // For Windows WebView2
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();

      if (availableVersion == null) {
        launchUrl(Uri.parse(
            "https://www.catalog.update.microsoft.com/Search.aspx?q=Microsoft%20Edge%20WebView2%20Runtime"));
      }
      final path = await getApplicationSupportDirectory();
      webViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(
              userDataFolder: join(path.path, 'webview')));
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
    }

    // Initialize isMobileMode using GetStorage.
    // If no value is stored yet, determine it by platform.
    bool? storedMobileMode = storage.read<bool>('isMobileMode');
    if (storedMobileMode == null) {
      // For example, you might decide that Android/iOS should be mobile mode by default
      storedMobileMode = !isLargeScreen;
      storage.write('isMobileMode', storedMobileMode);
    }

    isMobileMode = storedMobileMode;
    // Pass the stored value to the inner WebView widget via arguments or state management.
    // Here, we add it to WebViewArgs for simplicity.

    // Setup cookies as before
    CookieManager cookieManager = CookieManager.instance();

    final urls = [
      widget.args.url,
      "https://bkjwtest.guet.edu.cn",
      "https://bkjwtest.guet.edu.cn/student",
      "https://bkjwsrv.guet.edu.cn",
      "https://bkjw.guet.edu.cn",
      "https://wvpn.guet.edu.cn",
      "https://wvpn.guet.edu.cn/authserver",
      "https://cas.guet.edu.cn",
      "https://cas.guet.edu.cn/authserver",
      "https://v.guet.edu.cn",
      'https://classroom.guet.edu.cn',
      'https://yjapp.guet.edu.cn',
      'https://pcportal.guet.edu.cn'
    ];

    // await AppNetwork.get().bkjwTestDio.get(widget.args.url);

    for (final url in urls) {
      final cookies =
          await AppNetwork.get().cookieJar.loadForRequest(Uri.parse(url));

      for (final cookie in cookies) {
        await cookieManager.setCookie(
          url: WebUri(url),
          name: cookie.name,
          value: cookie.value,
          path: cookie.path ?? "",
          domain: cookie.domain,
          expiresDate: cookie.expires?.millisecondsSinceEpoch,
          maxAge: cookie.maxAge,
          isSecure: cookie.secure,
          isHttpOnly: cookie.httpOnly,
          sameSite: cookie.sameSite?.name.let(
              (sameSite) => HTTPCookieSameSitePolicy.fromNativeValue(sameSite)),
        );
      }
    }

    setState(() {
      isInit = true;
    });
  }

  // Future<bool> onWillPop() async {
  //   // Handle double back press to exit
  //   DateTime now = DateTime.now();
  //   if (lastPressed == null ||
  //       now.difference(lastPressed!) > const Duration(seconds: 2)) {
  //     lastPressed = now;
  //     ScaffoldMessenger.of(Get.context!).showSnackBar(
  //       const SnackBar(content: Text("再按一次退出")),
  //     );
  //     return false;
  //   }
  //   return true;
  // }

  @override
  Widget build(BuildContext context) {
    return isInit
        ? _WebView(
            args: widget.args, storage: storage, isMobileMode: isMobileMode)
        : Scaffold(
            appBar: AppBar(title: Text("加载中")),
            body: Center(child: CircularProgressIndicator()),
          );
  }
}

class _WebView extends StatefulWidget {
  final WebViewArgs args;
  final bool isMobileMode;
  final GetStorage storage;

  const _WebView(
      {super.key,
      required this.args,
      required this.storage,
      required this.isMobileMode});

  @override
  State<_WebView> createState() => _WebViewState();
}

class _WebViewState extends State<_WebView> {
  final GlobalKey webViewKey = GlobalKey();

  final androidDesktopModeUserAgent =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

  final iosDesktopModeUserAgent =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Version/17.0 Safari/537.36";

  // Android 移动模式 User-Agent
  final androidMobileModeUserAgent =
      "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36";

  // iOS 移动模式 User-Agent
  final iosMobileModeUserAgent =
      "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/537.36";

  String get desktopModeUserAgent =>
      GetPlatform.isIOS ? iosDesktopModeUserAgent : androidDesktopModeUserAgent;

  String get mobileModeUserAgent =>
      GetPlatform.isIOS ? iosMobileModeUserAgent : androidMobileModeUserAgent;

  // Use the passed in isMobileMode value from storage
  late bool isMobileMode = widget.isMobileMode;
  InAppWebViewController? webViewController;

  InAppWebViewSettings get settings => InAppWebViewSettings(
        isInspectable: kDebugMode,
        userAgent: isMobileMode ? mobileModeUserAgent : desktopModeUserAgent,
        mediaPlaybackRequiresUserGesture: false,
        javaScriptCanOpenWindowsAutomatically: true,
        allowsInlineMediaPlayback: true,
        iframeAllow: "camera; microphone",
        iframeAllowFullscreen: true,
        geolocationEnabled: true,
        initialScale: 2,
        // 默认缩放级别（0 表示不缩放）
        minimumZoomScale: -10,
        // 设置最小缩放比例
        maximumZoomScale: 10.0,
        // 可选，防止用户放大
        supportZoom: true,
        // 启用缩放支持
        useWideViewPort: true,
        // 适应屏幕宽度，必须
        loadWithOverviewMode: false, // 让内容适应 WebView
      );

  PullToRefreshController? pullToRefreshController;
  String url = "";
  String? title = null;
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // pullToRefreshController = kIsWeb ||
    //     ![TargetPlatform.iOS, TargetPlatform.android]
    //         .contains(defaultTargetPlatform)
    //     ? null
    //     : PullToRefreshController(
    //   settings: PullToRefreshSettings(
    //     color: Colors.blue,
    //   ),
    //   onRefresh: () async {
    //     if (defaultTargetPlatform == TargetPlatform.android) {
    //       webViewController?.reload();
    //     } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    //       webViewController?.loadUrl(
    //           urlRequest:
    //           URLRequest(url: await webViewController?.getUrl()));
    //     }
    //   },
    // );
  }

  /// Share the current URL
  Future<void> share(BuildContext context,
      {required String subject, required String text}) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      text,
      subject: subject,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  List<Widget> buildMobileActions1(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          webViewController?.goBack();
        },
      ),
      IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            webViewController?.goForward();
          })
    ];
  }

  /// Build actions for mobile: put some actions into an overflow menu.
  List<Widget> buildMobileActions(BuildContext context) {
    return [
      ...buildMobileActions1(context),
      PopupMenuButton<int>(
        onSelected: (value) {
          switch (value) {
            case 0:
              // Switch mode
              setState(() {
                isMobileMode = !isMobileMode;
                widget.storage.write('isMobileMode', isMobileMode);
                webViewController?.setSettings(
                    settings: settings
                      ..userAgent = isMobileMode
                          ? mobileModeUserAgent
                          : desktopModeUserAgent);
                webViewController?.reload();
              });
              break;
            case 1:
              // Refresh
              webViewController?.reload();
              break;
            case 2:
              // Share link
              share(context, subject: "", text: url);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
              value: 0, child: Text(isMobileMode ? "切换为桌面端网页" : "切换为移动端网页")),
          const PopupMenuItem(value: 1, child: Text("刷新")),
          const PopupMenuItem(value: 2, child: Text("分享链接")),
        ],
      )
    ];
  }

  /// Build actions for desktop: show actions as individual icons.
  List<Widget> buildDesktopActions(BuildContext context) {
    return [
      TextButton(
        onPressed: () {
          setState(() {
            isMobileMode = !isMobileMode;
            widget.storage.write('isMobileMode', isMobileMode);
            webViewController?.setSettings(
                settings: settings
                  ..userAgent = isMobileMode
                      ? mobileModeUserAgent
                      : desktopModeUserAgent);
            webViewController?.reload();
          });
        },
        child: Text(isMobileMode ? "切换为桌面端网页" : "切换为移动端网页"),
      ),
      ...buildMobileActions1(context),
      IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () {
          webViewController?.reload();
        },
      ),
      IconButton(
        icon: Icon(Icons.share),
        onPressed: () {
          share(context, subject: "", text: url);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title ?? "加载中"),
          actions: GetPlatform.isAndroid || GetPlatform.isIOS
              ? buildMobileActions(context)
              : buildDesktopActions(context),
          // If you want to add back/forward buttons for desktop, you can also include them here.
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  webViewEnvironment: webViewEnvironment,
                  initialUrlRequest: URLRequest(url: WebUri(widget.args.url)),
                  initialSettings: settings,
                  // pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onPermissionRequest: (controller, request) async {
                    if (request.resources.any((r) =>
                        r == PermissionResourceType.CAMERA_AND_MICROPHONE ||
                        r == PermissionResourceType.CAMERA ||
                        r == PermissionResourceType.MICROPHONE)) {
                      try {
                        var cameraStatus = await [Permission.camera, Permission.microphone].request();
                        if (cameraStatus.values.all((e) => e == PermissionStatus.granted)) {
                          print("camera and microphone granted");
                          return PermissionResponse(
                              action: PermissionResponseAction.GRANT,
                              resources: [
                                PermissionResourceType.CAMERA_AND_MICROPHONE,
                                PermissionResourceType.CAMERA,
                                PermissionResourceType.MICROPHONE,
                              ]);
                        }
                        print("camera and microphone deny");
                        return PermissionResponse(
                            action: PermissionResponseAction.DENY,
                            resources: [
                              PermissionResourceType.CAMERA_AND_MICROPHONE,
                              PermissionResourceType.CAMERA,
                              PermissionResourceType.MICROPHONE,
                            ]);
                      } catch (e) {
                        print("camera and microphone error: ${e}");
                        return PermissionResponse(
                            action: PermissionResponseAction.PROMPT,
                            resources: [
                              PermissionResourceType.CAMERA_AND_MICROPHONE,
                              PermissionResourceType.CAMERA,
                              PermissionResourceType.MICROPHONE,
                            ]);
                      }
                    }
                    return PermissionResponse(
                        action: PermissionResponseAction.GRANT,
                        resources: [
                          PermissionResourceType.CAMERA_AND_MICROPHONE,
                          PermissionResourceType.CAMERA,
                          PermissionResourceType.MICROPHONE,
                        ]);
                  },
                  onTitleChanged: (controller, title) {
                    if (title != null) {
                      setState(() {
                        this.title = title;
                      });
                    }
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    if (kDebugMode) {
                      print(consoleMessage);
                    }
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
        ]));
  }
}
