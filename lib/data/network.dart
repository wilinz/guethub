import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:dio_retry_plus/dio_retry_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:get/get_core/src/get_main.dart';
import 'package:guethub/common/encrypt/webvpn.dart';
import 'package:guethub/common/encrypt/webvpn_new.dart';
import 'package:guethub/data/device/tracking.dart';
import 'package:guethub/data/get_storage.dart';
import 'package:guethub/data/redirect_interceptor.dart';
import 'package:guethub/data/repository/login.dart';
import 'package:guethub/data/repository/network_detection.dart';
import 'package:guethub/data/repository/user.dart';
import 'package:guethub/data/service/course_select.dart';
import 'package:guethub/data/service/experiment.dart';
import 'package:guethub/data/service/login.dart';
import 'package:guethub/data/service/teaching_evaluation.dart';
import 'package:guethub/logger.dart';
import 'package:guethub/package_info.dart';
import 'package:guethub/path.dart';
import 'package:guethub/ui/login/captcha_dialog.dart';
import 'package:guethub/ui/login/verification_code_dialog.dart';
import 'package:guethub/ui/util/toast.dart';
import 'package:guethub/util/ext.dart';
import 'package:kt_dart/kt.dart';
import 'package:path/path.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socks5_proxy/socks_client.dart';

import 'util/user_agent.dart';

extension DioExt on Dio {
  Dio setFollowRedirects(bool followRedirects) {
    options.followRedirects = followRedirects;
    if (followRedirects) {
      options.validateStatus =
          (int? status) => status != null && status >= 200 && status < 300;
    } else {
      options.validateStatus =
          (int? status) => status != null && status >= 200 && status < 400;
    }
    return this;
  }
}

class AppNetwork {
  static const String appBaseUrl = "https://app.guethub.net/";
  static const bool isDev = false;
  static const String devAppBaseUrl = "http://172.16.0.104:10036/";
  static const String devAppImageBaseUrl = "http://172.16.0.104:19000";

  static String get appOSSBaseUrl =>
      isDev ? devAppImageBaseUrl : "https://s3.guethub.net";
  static const String baseUrl = "https://bkjw.guet.edu.cn/";
  static const String webVpnUrl = "https://v.guet.edu.cn/";
  static const String webVpnHost = "v.guet.edu.cn";
  static const String typeUrlEncode = "application/x-www-form-urlencoded";

  static String? _userAgent = null;

  static String get userAgent => (_userAgent ??= getRandomUserAgent());

  // static VpnCookieInterceptor vpnCookieInterceptor(CookieJar cookieJar) =>
  //     VpnCookieInterceptor(cookieJar: cookieJar, urls: [
  //       'https://bkjw.guet.edu.cn',
  //       'https://bkjwtest.guet.edu.cn',
  //       'https://bkjwsrv.guet.edu.cn',
  //       'https://classroom.guet.edu.cn',
  //       'https://yjapp.guet.edu.cn',
  //       'https://pcportal.guet.edu.cn',
  //       'https://www.guet.edu.cn', // 图书馆
  //       'http://202.193.70.166:8020', // 数据库导航
  //     ]);

  static CookieJar getAppCookieJar() {
    CookieJar cookieJar;
    if (!kIsWeb) {
      cookieJar = PersistCookieJar(
          storage: FileStorage(
              join(applicationSupportDirectory.path, "cookies", "app/")));
    } else {
      cookieJar = CookieJar();
    }
    return cookieJar;
  }

  static CookieJar getCookieJar({required String username}) {
    CookieJar cookieJar;
    if (!kIsWeb) {
      cookieJar = PersistCookieJar(
          storage: FileStorage(join(
              applicationSupportDirectory.path, "cookies", username + "/")));
    } else {
      cookieJar = CookieJar();
    }
    return cookieJar;
  }

  static setupCasDio(Dio dio, CookieJar cookieJar) {
    final interceptorsDio = () async => AppNetwork.get().casDio;
    final url = "https://cas.guet.edu.cn/";
    dio.options = BaseOptions(
        baseUrl: url,
        headers: {"User-Agent": userAgent},
        followRedirects: false,
        validateStatus: (int? status) => status != null,
        connectTimeout: Duration(minutes: 1),
        receiveTimeout: Duration(minutes: 5),
        sendTimeout: Duration(minutes: 5));
    dio.interceptors.addAll([
      BaseUrlInterceptor(),
      CookieManager(cookieJar),
      RedirectInterceptor(interceptorsDio),
      RefererInterceptor(),
      DioExceptionInterceptor(),
      RetryInterceptor(
          dio: dio,
          logPrint: (msg) {
            logger.i(msg);
          },
          toNoInternetPageNavigator: () async {},
          retries: 3,
          retryDelays: [Duration(milliseconds: 100)])
    ]);
    // _proxy(dio);
    // setupGuetProxy(dio);
    setDioLogger(dio);
    return dio;
  }

  static Dio setupBkjwDio(Dio dio, CookieJar cookieJar) {
    final interceptorsDio = () async => AppNetwork.get().bkjwDio;
    dio.options = BaseOptions(
        baseUrl: baseUrl,
        headers: {"User-Agent": userAgent},
        followRedirects: false,
        validateStatus: (int? status) => status != null,
        connectTimeout: Duration(minutes: 1),
        receiveTimeout: Duration(minutes: 5),
        sendTimeout: Duration(minutes: 5));
    dio.interceptors.addAll([
      BaseUrlInterceptor(),
      // AppNetwork.vpnCookieInterceptor(cookieJar),
      CookieManager(cookieJar),
      GuetLoginInterceptor(interceptorsDio),
      RedirectInterceptor(interceptorsDio),
      BaseUrlInterceptor(),
      RefererInterceptor(),
      DioExceptionInterceptor(),
      RetryInterceptor(
          dio: dio,
          logPrint: (msg) {
            logger.i(msg);
          },
          toNoInternetPageNavigator: () async {},
          retries: 3,
          retryDelays: [Duration(milliseconds: 100)])
    ]);
    // _proxy(dio);
    // setupGuetProxy(dio);
    setDioLogger(dio);
    return dio;
  }

  static setupBkjwTestDio(Dio dio, CookieJar cookieJar) {
    final interceptorsDio = () async => AppNetwork.get().bkjwTestDio;
    final url = "https://bkjwtest.guet.edu.cn/";
    dio.options = BaseOptions(
        baseUrl: url,
        headers: {"User-Agent": userAgent},
        followRedirects: false,
        validateStatus: (int? status) => status != null,
        connectTimeout: Duration(minutes: 1),
        receiveTimeout: Duration(minutes: 5),
        sendTimeout: Duration(minutes: 5));
    dio.interceptors.addAll([
      BaseUrlInterceptor(),
      CookieManager(cookieJar),
      TeachingEvaluationAuthInterceptor(dio),
      CourseSelectAuthInterceptor(interceptorsDio),
      GuetLoginInterceptor(interceptorsDio),
      RedirectInterceptor(interceptorsDio),
      RefererInterceptor(),
      ExperimentSystemAuthInterceptor(interceptorsDio),
      DioExceptionInterceptor(),
      RetryInterceptor(
          dio: dio,
          logPrint: (msg) {
            logger.i(msg);
          },
          toNoInternetPageNavigator: () async {},
          retries: 3,
          retryDelays: [Duration(milliseconds: 100)])
    ]);
    // _proxy(dio);
    // setupGuetProxy(dio);
    setDioLogger(dio);
    return dio;
  }

  static setupNoProxyDio(Dio dio, CookieJar cookieJar) {
    dio.options = BaseOptions(
      headers: {"User-Agent": userAgent, "Referer": url},
      followRedirects: false,
      validateStatus: (int? status) => status != null,
    );
    dio.interceptors.addAll([
      CookieManager(cookieJar),
      JsonpInterceptor(),
      RedirectInterceptor(() async => dio)
    ]);
    // _proxy(dio);
    setDioLogger(dio);
    return dio;
  }

  static String getPlatformInfo() {
    if (Platform.isAndroid) {
      return 'Android ${Platform.operatingSystemVersion}';
    } else if (Platform.isIOS) {
      return 'iOS ${Platform.operatingSystemVersion}';
    } else if (Platform.isLinux) {
      return 'Linux ${Platform.operatingSystemVersion}';
    } else if (Platform.isMacOS) {
      return 'macOS ${Platform.operatingSystemVersion}';
    } else if (Platform.isWindows) {
      return 'Windows ${Platform.operatingSystemVersion}';
    } else {
      return 'Unknown Platform';
    }
  }

  static setupAppDio(Dio dio, CookieJar cookieJar) {
    // 定义包含平台信息的User-Agent
    String userAgent =
        "${packageInfo.appName}/${packageInfo.version}+${packageInfo.buildNumber} | ${packageInfo.packageName} | ${packageInfo.installerStore} | (${getPlatformInfo()})";
    dio.options = BaseOptions(
      baseUrl: isDev ? devAppBaseUrl : appBaseUrl,
      headers: {"User-Agent": Uri.encodeFull(userAgent), "udid": udid},
      followRedirects: false,
      validateStatus: (int? status) => status != null,
    );
    dio.interceptors.addAll(
        [CookieManager(cookieJar), RedirectInterceptor(() async => dio)]);
    // _proxy(dio);
    setDioLogger(dio);
    return dio;
  }

  static void setupGuetProxy(Dio dio) {
    // (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    //   logger.d("on create http client");
    //   final client = HttpClient();
    //   SocksTCPClient.assignToHttpClient(client, [
    //     ProxySettings('www.wilinz.com', 10888,
    //         username: utf8.decode(base64Decode('cm9vdA==')),
    //         password: utf8.decode(
    //             base64Decode('NDRjODA4NTUwN2EwNDIwNDk2MmE4NTUxMDc2MDNhNmI='))),
    //   ]);
    //   return client;
    // };
  }

  static Dio setupGuetProxy1(Dio dio) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      logger.d("on create http client");
      final client = HttpClient();
      SocksTCPClient.assignToHttpClient(client, [
        ProxySettings('www.wilinz.com', 10888,
            username: utf8.decode(base64Decode('cm9vdA==')),
            password: utf8.decode(
                base64Decode('NDRjODA4NTUwN2EwNDIwNDk2MmE4NTUxMDc2MDNhNmI='))),
      ]);
      return client;
    };
    return dio;
  }

  static final loggedDioList = <Dio>[];

  static void setDioLogger(Dio dio) {
    dio.interceptors.add(dioLogger);
    loggedDioList.add(dio);
  }

  static void _proxy(Dio dio) {
    if (!kReleaseMode &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.findProxy = (uri) {
          // 这里设置代理地址和端口号
          return "PROXY 127.0.0.1:18888";
        };
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      };
    }
  }

  // static Future<String> get baseUrlAutoAdapt async {
  //   final isCampusNetwork =
  //       await NetworkDetectionRepository.get().isCampusNetwork;
  //   if (isCampusNetwork == true) return baseUrl;
  //   return Uri.parse(baseUrl).toWebVpnUrl().toString();
  // }

  late Dio _bkjwDio;
  late Dio _bkjwDioProxy;

  late Dio _bkjwTestDio;
  late Dio _bkjwTestDioProxy;

  late Dio _casDio;
  late Dio _casDioProxy;

  Future<Dio> get bkjwDio async {
    final isCampusNetwork =
        await NetworkDetectionRepository.get().isCampusNetwork;
    return isCampusNetwork == true ? _bkjwDio : _bkjwDioProxy;
  }

  Future<Dio> get bkjwTestDio async {
    final isCampusNetwork =
        await NetworkDetectionRepository.get().isCampusNetwork;
    return isCampusNetwork == true ? _bkjwTestDio : _bkjwTestDioProxy;
  }

  Future<Dio> get casDio async {
    final isCampusNetwork =
        await NetworkDetectionRepository.get().isCampusNetwork;
    return isCampusNetwork == true ? _casDio : _casDioProxy;
  }

  late Dio noProxyDio;
  late Dio appDio;

  AppNetwork._create();

  static Map<String, AppNetwork> _instances = {};

  static String currentUsername = "default";

  static Future<void> init() async {
    final user = await UserRepository.get().getActiveUser();
    if (user != null) {
      AppNetwork.get(username: user.username);
      onPrettyDioLoggerChangeEvent.listen((logger) {
        loggedDioList.forEach((dio) {
          dio.interceptors.removeWhere((it) => it is PrettyDioLogger);
          dio.interceptors.add(logger);
        });
      });
    }
  }

  factory AppNetwork.get({String? username}) {
    return getInstance(username: username);
  }

  late CookieJar cookieJar;

  static AppNetwork getInstance({bool isTest = false, String? username}) {
    if (username == null) {
      username = currentUsername;
    } else {
      currentUsername = username;
    }

    logger.d("Appnetwork username: ${username}");

    if (_instances[username] == null) {
      final instance = AppNetwork._create();
      instance.cookieJar =
          !isTest ? getCookieJar(username: username) : CookieJar();

      // _instance._dio = setupDio(Dio(), _instance.cookieJar);
      // _instance._dio.setFollowRedirects(true);
      //
      // _instance._dio1 = setupDio(Dio(), _instance.cookieJar);
      // _instance._dio1.setFollowRedirects(false);

      Dio newDio() => Dio();
      // ..httpClientAdapter = Http2Adapter(
      //   ConnectionManager(idleTimeout: Duration(seconds: 10)),
      //   fallbackAdapter: HttpClientAdapter(),
      // );
      instance._casDio = setupCasDio(newDio(), instance.cookieJar);
      instance._casDioProxy = setupGuetProxy1(
          instance._casDio.clone(httpClientAdapter: HttpClientAdapter()));

      instance._bkjwTestDio = setupBkjwTestDio(newDio(), instance.cookieJar);
      instance._bkjwTestDioProxy = setupGuetProxy1(
          instance._bkjwTestDio.clone(httpClientAdapter: HttpClientAdapter()));

      instance.noProxyDio = setupNoProxyDio(newDio(), instance.cookieJar);
      instance.appDio =
          setupAppDio(newDio(), !isTest ? getAppCookieJar() : CookieJar());

      final dio2 = newDio();
      instance._bkjwDio = setupBkjwDio(dio2, instance.cookieJar);
      instance._bkjwDioProxy = setupGuetProxy1(
          instance._bkjwDio.clone(httpClientAdapter: HttpClientAdapter()));
      _instances[username] = instance;
    }
    return _instances[username]!;
  }
}

class VpnCookieInterceptor extends Interceptor {
  final CookieJar cookieJar;
  final List<String> urls;

  VpnCookieInterceptor({required this.cookieJar, required this.urls});

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (response.requestOptions.uri.host == 'wvpn.guet.edu.cn' &&
        response.headers.map.containsKey('set-cookie')) {
      try {
        await _saveCookies(response);
        handler.next(response);
      } catch (e, s) {
        final err = DioException(
          requestOptions: response.requestOptions,
          error: e,
          stackTrace: s,
        );
        handler.reject(err, true);
      }
      return;
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      if (err.response!.requestOptions.uri.host == 'wvpn.guet.edu.cn' &&
          err.response!.headers.map.containsKey('set-cookie')) {
        _saveCookies(err.response!).then((_) => handler.next(err)).catchError(
          (dynamic e, StackTrace s) {
            final error = DioException(
              requestOptions: err.response!.requestOptions,
              error: e,
              stackTrace: s,
            );
            handler.next(error);
          },
        );
      }
    } else {
      handler.next(err);
    }
  }

  final _setCookieReg = RegExp('(?<=)(,)(?=[^;]+?=)');

  Future<void> _saveCookies(Response response) async {
    final setCookies = response.headers[HttpHeaders.setCookieHeader];
    if (setCookies == null || setCookies.isEmpty) {
      return;
    }
    final List<Cookie> cookies = setCookies
        .map((str) => str.split(_setCookieReg))
        .expand((cookie) => cookie)
        .where((cookie) => cookie.isNotEmpty)
        .map((str) => Cookie.fromSetCookieValue(str))
        .toList();

    if (urls.isNotEmpty) {
      await Future.wait(
        urls.map(
          (location) => cookieJar.saveFromResponse(
            // Resolves the location based on the current Uri.
            Uri.parse(location),
            cookies,
          ),
        ),
      );
    }
  }
}

class UnauthorizedException implements Exception {
  final String msg;

  UnauthorizedException(this.msg);

  @override
  String toString() => msg;
}

class GuetLoginInterceptor extends Interceptor {
  static const String allowCheckingLogin = "allowCheckingLogin";

  final Future<Dio> Function() dio;

  // ..httpClientAdapter = Http2Adapter(
  //   ConnectionManager(idleTimeout: Duration(seconds: 10)),
  //   fallbackAdapter: HttpClientAdapter(),
  // );

  static Completer<void>? _loginCompleter;

  GuetLoginInterceptor(this.dio);

  final bkjw404Host = [
    "https://bkjwsrv.guet.edu.cn",
    "https://bkjw.guet.edu.cn",
    WebVPN.encryptHost('bkjwsrv.guet.edu.cn'),
    WebVPN.encryptHost('bkjw.guet.edu.cn')
  ];

  bool _isBkjw404(Response response) =>
      bkjw404Host
          .any((it) => response.requestOptions.uri.toString().contains(it)) &&
      response.statusCode == 404 &&
      response.headers.value("content-type") == "text/html";

  Future<bool> _isWvpn403(Response response) async {
    final isCampusNetwork =
        await NetworkDetectionRepository.get().isCampusNetwork;
    return response.statusCode == 403 && isCampusNetwork != true;
  }

  bool _isRedirectToLogin(Response response) {
    final isRedirect = _isRedirect(response.statusCode ?? 0);
    final location = response.headers.value("location");
    final isRedirectToLogin = location?.let(
            (it) => RegExp("/login|/Login").hasMatch(Uri.parse(it).path)) ??
        false;
    return isRedirect && isRedirectToLogin;
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    final isAllowCheckingLogins =
        response.requestOptions.extra[allowCheckingLogin] as bool? ?? true;

    bool isRequiredLoginAgain = isAllowCheckingLogins &&
        (_isBkjw404(response) ||
            await _isWvpn403(response) ||
            _isRedirectToLogin(response));

    if (!isRequiredLoginAgain) {
      handler.next(response);
      return;
    }

    var user = await UserRepository.get().getActiveUser();
    if (user == null) {
      handler.next(response);
      return;
    }

    var username = user.username;
    var password = user.password;

    if (_loginCompleter == null) {
      _loginCompleter = Completer();
    } else {
      await _loginCompleter!.future;
      await Future.delayed(Duration(milliseconds: 300));
      await reFetch(response, handler);
      return;
    }
    logger.d("请求内容登录失效：" + response.requestOptions.uri.toString());
    toast("登录过期，正在尝试自动登录");

    try {
      await _login(username, password,
          isOnlyUseOldSystem: user.isOnlyUseOldSystem,
          isOnlyUseNewSystem: user.isOnlyUseNewSystem(),
          isUpgradedUndergrad: user.isUpgradedUndergrad,
          isPostgraduate: user.isPostgraduate);
      await Future.delayed(Duration(milliseconds: 300)); // 过快会导致 cookie 同步不上
      await reFetch(response, handler);
      _loginCompleter!.complete();
      _loginCompleter = null;
    } catch (e, st) {
      logger.e(e);
      if (e is DioException) {
        logger.d("e is DioException");
        handler.reject(e);
      } else {
        handler.reject(DioException(
            requestOptions: response.requestOptions, error: e, stackTrace: st));
      }
      _loginCompleter!.completeError(e);
      _loginCompleter = null;
      rethrow;
    }
  }

  Future<void> reFetch(
      Response<dynamic> response, ResponseInterceptorHandler handler) async {
    logger.d("正在重新请求");
    final rawRequestOptionValue = (response.requestOptions
            .extra[RedirectInterceptor.rawRequestOption] as RequestOptions?) ??
        response.requestOptions;

    logger.d("请求内容：" + rawRequestOptionValue.toString());
    final requestOptions = rawRequestOptionValue;

    final uri = requestOptions.uri;
    logger.d("重新请求：$uri");

    final newHeader = requestOptions.headers
      ..removeWhere((key, value) => key.toLowerCase() == "cookie");
    logger.d("新请求头: $newHeader");
    final newExtra = requestOptions.extra..[allowCheckingLogin] = false;
    final newResp = await (await dio())
        .fetch(requestOptions.copyWith(headers: newHeader, extra: newExtra));
    logger.d("新响应");
    handler.next(newResp);
    return;
  }

  bool _isRedirect(int statusCode) {
    return statusCode == 301 ||
        statusCode == 302 ||
        statusCode == 303 ||
        statusCode == 307 ||
        statusCode == 308;
  }

  Future<void> _login(
    String username,
    String password, {
    bool isOnlyUseOldSystem = false,
    bool isOnlyUseNewSystem = false,
    bool isUpgradedUndergrad = false,
    bool isPostgraduate = false,
  }) async {
    try {
      await LoginRepository.get().loginAcademicAffairsSystem(username, password,
          isOnlyUseOldSystem: isOnlyUseOldSystem,
          isUpgradedUndergrad: isUpgradedUndergrad,
          isPostgraduate: isPostgraduate, captchaHandler: (image) async {
        // Show a dialog for captcha handling
        final buildContent = Get.context;
        if (buildContent == null) throw Exception("应用不处于前台，无法输入图形验证码");
        final result = await showDialog(
          context: buildContent,
          barrierDismissible: false,
          builder: (context) => CaptchaDialog(image: image),
        );
        return result;
      });
      toastSuccess(message: "登录成功");
    } catch (e) {
      if (e is RequireLoginVerificationCodeException) {
        final buildContent = Get.context;
        if (buildContent == null) throw Exception("应用不处于前台，无法输入短信验证码");
        final result = await showDialog(
          context: buildContent,
          barrierDismissible: false,
          builder: (context) => VerificationCodeDialog(username: username),
        );
        if (result == true) {
          _login(
            username,
            password,
            isOnlyUseOldSystem: isOnlyUseOldSystem,
            isOnlyUseNewSystem: isOnlyUseNewSystem,
            isUpgradedUndergrad: isUpgradedUndergrad,
            isPostgraduate: isPostgraduate,
          );
          return;
        }
      } else {
        rethrow;
      }
    }
  }
}

class BaseUrlInterceptor extends Interceptor {
  static const String enableAutoVpnUrl = "enableAutoVpnUrl";

  final hosts = [
    "bkjwsrv.guet.edu.cn",
    "bkjw.guet.edu.cn",
    // "utsc.guet.edu.cn",
    "bkjwtest.guet.edu.cn",
    "cas.guet.edu.cn"
  ];

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    var newOptions = options;
    final enableAutoVpnUrlValue =
        options.extra[enableAutoVpnUrl] as bool? ?? true;

    // if (hosts.contains(newOptions.uri.host)) {
    if (newOptions.uri.host == "bkjw.guet.edu.cn") {
      final user = await UserRepository.get().getActiveUser();
      if (user?.isUpgradedUndergrad == true) {
        final uri = newOptions.uri.replace(host: "bkjwsrv.guet.edu.cn");
        newOptions = newOptions.copyWith(baseUrl: uri.getBaseUrl());
      }
    }
    // if (enableAutoVpnUrlValue && !options.uri.path.startsWith("/http")) {
    //   final isCampusNetwork =
    //       await NetworkDetectionRepository.get().isCampusNetwork;
    //   final uri = newOptions.uri;
    //
    //   if (isCampusNetwork != true &&
    //       uri.host != AppNetwork.webVpnHost) {
    //     final vpnUrl = Uri.parse(getWebVPNUrl(uri.toString()));
    //     logger.d(vpnUrl);
    //     logger.d(uri);
    //     newOptions = newOptions.copyWith(
    //         baseUrl: vpnUrl.getBaseUrl(), path: vpnUrl.path);
    //   }
    // }
    // }
    handler.next(newOptions);
  }
}

class DioExceptionInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 检查是否是 HandshakeException 错误
    if (err.error is HandshakeException) {
      // 创建一个新的 DioError 并设置 type 为 connectionError
      final newError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: DioExceptionType.connectionError,
        error: 'Connection terminated during handshake',
      );
      // 调用 handler.next 传递新的错误
      handler.next(newError);
    } else {
      // 否则，调用 handler.next 传递原始错误
      handler.next(err);
    }
  }
}

class RefererInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Referer'] = options.uri.toString();
    handler.next(options);
  }
}

class ExperimentSystemAuthInterceptor extends Interceptor {
  final Future<Dio> Function() dio;

  ExperimentSystemAuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final urlPath = options.uri.path;
    if (!urlPath.contains("/guet-lab-system") ||
        urlPath.contains(
            "/guet-lab-system/api/authentication/getAccessTokenByEduToken")) {
      handler.next(options);
      return;
    }

    var user = await UserRepository.get().getActiveUser();
    if (user == null) {
      handler.next(options);
      return;
    }

    var token = user.experimentSystemToken;

    renewToken() async {
      token = await ExperimentService.getToken(await dio());
      if (token == null) {
        handler.next(options);
        return;
      }
      UserRepository.get().updateUser(user..experimentSystemToken = token);
    }

    try {
      final jwt = JWT.decode(token!);
      final exp = DateTime.fromMillisecondsSinceEpoch(
          (jwt.payload['exp'] as int) * 1000);
      if (exp.isBefore(DateTime.now())) {
        await renewToken();
      }
    } catch (e) {
      await renewToken();
      print(e);
    }
    options.headers['x-access-token'] = token;
    handler.next(options);
  }
}

class CourseSelectAuthInterceptor extends Interceptor {
  final Future<Dio> Function() dio;

  CourseSelectAuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final urlPath = options.uri.path;
    if (!urlPath.contains("/course-selection-api")) {
      handler.next(options);
      return;
    }

    var user = await UserRepository.get().getActiveUser();
    if (user == null) {
      handler.next(options);
      return;
    }

    var token = user.courseSelectToken;

    renewToken() async {
      token = await CourseSelectService.getToken(await dio());
      if (token == null) {
        handler.next(options);
        return;
      }
      UserRepository.get().updateUser(user..courseSelectToken = token);
    }

    if (token == null) {
      await renewToken();
    } else {
      final jwt = JWT.decode(token!);
      final exp = DateTime.fromMillisecondsSinceEpoch(
          (jwt.payload['exp'] as int) * 1000);
      if (exp.isBefore(DateTime.now())) {
        await renewToken();
      }
    }
    options.headers['authorization'] = token;
    handler.next(options);
  }
}

class TeachingEvaluationAuthInterceptor extends Interceptor {
  final Dio dio;

  TeachingEvaluationAuthInterceptor(this.dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final urlPath = options.uri.path;
    if (!urlPath.contains("eams5-evaluation-service") ||
        urlPath.contains(
            "student/for-std/extra-system/student-summation-forstudent/index")) {
      handler.next(options);
      return;
    }

    var user = await UserRepository.get().getActiveUser();
    if (user == null) {
      handler.next(options);
      return;
    }

    var token = user.teachingEvaluationToken;
    if (token == null) {
      token = await TeachingEvaluationService.getToken(dio);
      UserRepository.get().updateUser(user..teachingEvaluationToken = token);
    } else {
      final jwt = JWT.decode(token);
      final exp = DateTime.fromMillisecondsSinceEpoch(
          (jwt.payload['exp'] as int) * 1000);
      if (exp.isBefore(DateTime.now())) {
        token = await TeachingEvaluationService.getToken(dio);
        UserRepository.get().updateUser(user..teachingEvaluationToken = token);
      }
    }
    options.headers['authorization'] = token;
    handler.next(options);
  }
}

/// options: Options(extra: {JsonpInterceptor.UseJsonpParser: true})
class JsonpInterceptor extends Interceptor {
  static const String UseJsonpParser = "use_jsonp_parser";

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final useJsonpParser = options.extra[UseJsonpParser] as bool? ?? false;
    if (useJsonpParser) {
      options.responseType = ResponseType.plain;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final useJsonpParser =
        response.requestOptions.extra[UseJsonpParser] as bool? ?? false;
    if (useJsonpParser) {
      response.data = json.decode(_removeJsonpWrapper(response.data));
    }
    handler.next(response);
  }

  String _removeJsonpWrapper(String jsonp) {
    int functionStart = jsonp.indexOf('(') + 1;
    int functionEnd = jsonp.lastIndexOf(')');
    String jsonString = jsonp.substring(functionStart, functionEnd);
    return jsonString;
  }
}
