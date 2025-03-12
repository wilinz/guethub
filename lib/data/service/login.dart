import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:guethub/common/encrypt/cas_new.dart';
import 'package:guethub/common/encrypt/webvpn.dart';
import 'package:guethub/common/encrypt/webvpn_new.dart';
import 'package:guethub/data/model/dynamic_code/dynamic_code.dart';
import 'package:guethub/data/model/dynamic_code/reauth.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/redirect_interceptor.dart';
import 'package:guethub/logger.dart';
import 'package:guethub/ui/util/toast.dart';
import 'package:guethub/util/ext.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:dio/dio.dart';

Map<String, String?> _parseLoginHtml(String html) {
  final doc = htmlParser.parse(html);
  final aesKey = doc.getElementById("pwdEncryptSalt")?.attributes["value"];
  final execution = doc.getElementById("execution")?.attributes["value"];
  return {"aesKey": aesKey, "execution": execution};
}

class LoginService {
  static Future<void> login(Dio dio, String username, String password,
      {required CaptchaHandler captchaHandler,
      bool isOnlyUseOldSystem = false,
      bool isOnlyUseNewSystem = false,
      bool isUpgradedUndergrad = false,
      bool isPostgraduate = false,
      required bool isCampusNetwork}) async {
    if (!isCampusNetwork) {
      // await loginCas(
      //     dio: dio,
      //     username: username,
      //     password: password,
      //     service: "https://v.guet.edu.cn/login?cas_login=true",
      //     serviceHomeUrl: "https://v.guet.edu.cn/",
      //     successVerify: (resp) {
      //       final uriStr = resp.requestOptions.uri.toString();
      //       final data = resp.data;
      //       final b2 = (uriStr.contains("/wengine-vpn-token-login") &&
      //           (resp.statusCode ?? 400) < 300);
      //       final b3 = data is String && data.contains("个人信息");
      //       return b2 || b3;
      //     },
      //     isCampusNetwork: isCampusNetwork,
      //     captchaHandler: captchaHandler);

      // try {
      //   await loginCas(
      //       dio: dio,
      //       username: username,
      //       password: password,
      //       service:
      //           "https://wvpn.guet.edu.cn/wengine-auth/login?cas_login=true",
      //       successVerify: (resp) {
      //         final html = resp.data as String;
      //         return html.contains("您已成功完成反代认证");
      //       },
      //       isCampusNetwork: isCampusNetwork,
      //       captchaHandler: captchaHandler);
      // } catch (e) {
      //   if (e is RequireLoginVerificationCodeException) rethrow;
      //   toast("跳过登录 https://wvpn.guet.edu.cn");
      //   print(e);
      // }
    }

    if (isUpgradedUndergrad) {
      await loginCas(
          dio: dio,
          username: username,
          password: password,
          service: "https://bkjwsrv.guet.edu.cn/",
          serviceHomeUrl: "https://bkjwsrv.guet.edu.cn/",
          successVerify: (resp) {
            final data = resp.data;
            final result = data is String && data.contains("用户类型：学生");
            return result;
          },
          isCampusNetwork: isCampusNetwork,
          captchaHandler: captchaHandler);
      return;
    }

    if (isPostgraduate) {
      //todo
      return;
    }

    if (isOnlyUseNewSystem) {
      await loginNewSystem(
          dio, username, password, captchaHandler, isCampusNetwork);
    } else if (isOnlyUseOldSystem) {
      await loginOldSystem(
          dio, username, password, captchaHandler, isCampusNetwork);
    } else {
      await loginNewSystem(
          dio, username, password, captchaHandler, isCampusNetwork);
      await loginOldSystem(
          dio, username, password, captchaHandler, isCampusNetwork);
    }
  }

  static Future<void> loginOldSystem(Dio dio, String username, String password,
      CaptchaHandler captchaHandler, bool isCampusNetwork) async {
    await loginCas(
        dio: dio,
        username: username,
        password: password,
        service: "https://bkjw.guet.edu.cn",
        serviceHomeUrl: "https://bkjw.guet.edu.cn/",
        successVerify: (resp) {
          final data = resp.data;
          final result = data is String && data.contains("用户类型：学生");
          return result;
        },
        isCampusNetwork: isCampusNetwork,
        captchaHandler: captchaHandler);
  }

  static Future<void> loginNewSystem(Dio dio, String username, String password,
      CaptchaHandler captchaHandler, bool isCampusNetwork) async {
    await loginCas(
        dio: dio,
        username: username,
        password: password,
        service: "https://bkjwtest.guet.edu.cn/student/sso/login",
        serviceHomeUrl: "https://bkjwtest.guet.edu.cn/student/home",
        successVerify: (resp) {
          final uri = resp.requestOptions.uri;
          return uri.toString().contains('/student/home');
        },
        isCampusNetwork: isCampusNetwork,
        captchaHandler: captchaHandler);
  }

  static Future<bool> loginWithWebVpn(String username, String password) async {
    // final resp = await (await AppNetwork.getDio()).get("https://v.guet.edu.cn");

    // var resp1 = await loginCas(
    //     dio: AppNetwork.get().dio2,
    //     username: username,
    //     password: password,
    //     service: "https://v.guet.edu.cn/login?cas_login=true",
    //     successVerify: (resp) {
    //       return true;
    //     },
    //     isCampusNetwork: false);

    // final resp3 = await loginNewSystem(username, false);
    // logger.d(resp3);

    return false;
  }

  static Future<Response> loginCas(
      {required Dio dio,
      required String username,
      required String password,
      required bool isCampusNetwork,
      required String service,
      required String serviceHomeUrl,
      required CaptchaHandler captchaHandler,
      required bool Function(Response response) successVerify,
      String? firstGetUrl,
      Map<String, dynamic>? firstGetQueryParameters}) async {
    // https://portal.guet.edu.cn/sui/
    // 根据是否处于校园网动态获取 uri
    final isNoUseWebVpn = isCampusNetwork;
    String getUri() => "authserver/login";

    // final serviceHomeResponse = await dio.get(
    //     /*  isCampusNetwork == true || serviceHomeUrl.contains("v.guet.edu.cn") ? serviceHomeUrl : getWebVPNUrl(serviceHomeUrl),*/
    //     serviceHomeUrl,
    //     options: Options(extra: {RedirectInterceptor.followRedirects: false}));

    // if (successVerify(serviceHomeResponse)) {
    //   return serviceHomeResponse;
    // }

    var uri = firstGetUrl ?? getUri();

    var resp = await dio.get(uri,
        queryParameters: firstGetQueryParameters ?? {'service': service},
        options:
            Options(extra: {GuetLoginInterceptor.allowCheckingLogin: false}));

    var reqUri = resp.requestOptions.uri;
    checkVerification(reqUri);
    if (successVerify(resp)) {
      return resp;
    }
    check401(resp);

    final parseLoginHtmlResult =
        await compute<String, Map<String, String?>>(_parseLoginHtml, resp.data);
    final aesKey = parseLoginHtmlResult["aesKey"];
    final execution = parseLoginHtmlResult["execution"];
    if (aesKey == null || execution == null) {
      logger.d(resp.requestOptions);
      logger.d(resp);
      throw LogonFailedException(
          'http request to ${resp.requestOptions.uri} failed: aesKey is null');
    }

    final captcha =
        await getCaptcha(dio, username, captchaHandler, isNoUseWebVpn);

    // 登录
    final uri1 = getUri();
    final resp1 = await dio.post(uri1,
        options: Options(
            contentType: AppNetwork.typeUrlEncode,
            responseType: ResponseType.plain,
            extra: {GuetLoginInterceptor.allowCheckingLogin: false}),
        queryParameters: {
          'service': service
        },
        data: {
          "username": username,
          "password": encryptPassword(password, utf8.encode(aesKey)),
          "rememberMe": true,
          "captcha": captcha,
          "_eventId": "submit",
          "cllt": "userNameLogin",
          "dllt": "generalLogin",
          "lt": "",
          "execution": execution
        });

    reqUri = resp1.requestOptions.uri;
    checkVerification(reqUri);
    final success = successVerify(resp1);
    if (success) {
      return resp;
    }
    check401(resp1);
    throw LogonFailedException('Login failed');
  }

  static Future<String> getCaptcha(Dio dio, String username,
      CaptchaHandler captchaHandler, bool isNoUseWebVpn) async {
    final checkNeedCaptchaResp = await dio.get(
        "authserver/checkNeedCaptcha.htl",
        queryParameters: {
          "username": username,
          "_": DateTime.timestamp().millisecondsSinceEpoch
        },
        options: Options(responseType: ResponseType.plain));
    final checkNeedCaptcha = jsonDecode(checkNeedCaptchaResp.data);

    logger.d("checkNeedCaptcha.data: ${checkNeedCaptcha}");
    if (checkNeedCaptcha['isNeed'] == true) {
      final image = await dio.get(
          "authserver/getCaptcha.htl?${DateTime.timestamp().millisecondsSinceEpoch}",
          options: Options(responseType: ResponseType.bytes));
      final captcha = await captchaHandler(image.data);
      return captcha;
    }
    return "";
  }

  static void check401(Response<dynamic> resp1) {
    if (resp1.statusCode == 401) {
      final html = resp1.data;
      final doc = htmlParser.parse(html);
      final errorTip = doc.querySelector("#showErrorTip")?.text;
      throw LogonFailedException(
          "状态码：${resp1.statusCode} " + (errorTip ?? 'Login failed'));
    }
  }

  static void checkVerification(Uri reqUri) {
    if (reqUri
        .toString()
        .contains('/authserver/reAuthCheck/reAuthLoginView.do')) {
      throw RequireLoginVerificationCodeException('Verification code required');
    }
  }

  /// {"res":"success","mobile":"123****4567","returnMessage":"动态口令已发送到手机","codeTime":120}
  static Future<DynamicCode> sendDynamicCode(
      {required Dio dio,
      required String username,
      required bool isCampusNetwork}) async {
    final resp = await dio.post(
        "authserver/dynamicCode/getDynamicCodeByReauth.do",
        data: {
          "userName": username,
          "authCodeTypeName": "reAuthDynamicCodeType"
        },
        options: Options(
            contentType: AppNetwork.typeUrlEncode,
            responseType: ResponseType.plain));
    return DynamicCode.fromJson(json.decode(resp.data));
  }

  ///{"msg":"动态码错误","code":"reAuth_failed"}
  static Future<ReAuth> reAuthCheck(
      {required Dio dio,
      required String code,
      required bool isCampusNetwork}) async {
    final resp = await dio.post("authserver/reAuthCheck/reAuthSubmit.do",
        data: {
          "service": "",
          "reAuthType": 3,
          "isMultifactor": true,
          "password": "",
          "dynamicCode": code,
          "uuid": "",
          "answer1": "",
          "answer2": "",
          "otpCode": "",
          "skipTmpReAuth": true,
        },
        options: Options(
            contentType: AppNetwork.typeUrlEncode,
            responseType: ResponseType.json));
    if (resp.statusCode != 200) {
      throw Exception("状态码：${resp.statusCode}");
    }
    return ReAuth.fromJson(resp.data);
  }
}

typedef CaptchaHandler = Future<String> Function(Uint8List image);

class LogonFailedException implements Exception {
  final String msg;

  LogonFailedException(this.msg);

  @override
  String toString() => msg;
}

class RequireLoginVerificationCodeException implements Exception {
  final String msg;

  RequireLoginVerificationCodeException(this.msg);

  @override
  String toString() => msg;
}
