import 'package:dio/dio.dart';

import 'login.dart';

class ChangKeService {
  static Future<String> getLoginCode(Dio dio, String username, String password,
      CaptchaHandler captchaHandler, bool isCampusNetwork) async {
    final url =
        "https://identity.guet.edu.cn/auth/realms/guet/protocol/openid-connect/auth";
    final params = {
      "scope": "openid",
      "response_type": "code",
      "redirect_uri": "https://mobile.guet.edu.cn/cas-callback?_h5=true",
      "client_id": "TronClassH5",
      "autologin": "true"
    };
    final resp = await dio.get(url, queryParameters: params);
    final redirectUrl = resp.requestOptions.uri;
    final redirectUrlString = redirectUrl.toString();

    Uri callbackUrl;
    if (redirectUrlString
        .contains("https://mobile.guet.edu.cn/cas-callback?_h5=true")) {
      callbackUrl = redirectUrl;
    } else {
      final serviceUrl = redirectUrl.queryParameters['service'];
      if (serviceUrl == null)
        throw Exception(
            "ChangKeService.getLoginServiceUrl: 'service' param is null!");

      final resp1 = await LoginService.loginCas(
          dio: dio,
          username: username,
          password: password,
          service: serviceUrl,
          serviceHomeUrl: "https://mobile.guet.edu.cn/",
          successVerify: (resp) async {
            final uri = resp.requestOptions.uri;
            final code = uri.queryParameters['code'];
            final ok = code != null;
            return ok;
          },
          isCampusNetwork: isCampusNetwork,
          captchaHandler: captchaHandler);
      callbackUrl = resp1.requestOptions.uri;
    }

    final code = callbackUrl.queryParameters["code"]!;
    return code;
  }

  static Future<String> getAccessToken(Dio dio, {required String code}) async {
    final url =
        "https://identity.guet.edu.cn/auth/realms/guet/protocol/openid-connect/token";
    final params = {
      "client_id": "TronClassH5",
      "redirect_uri": "https://mobile.guet.edu.cn/cas-callback?_h5=true",
      "code": code,
      "grant_type": "authorization_code",
      "scope": "openid"
    };
    final resp = await dio.post(url,
        data: params,
        options: Options(contentType: "application/x-www-form-urlencoded"));
    final accessToken = resp.data['access_token'];
    if (accessToken == null)
      throw Exception("ChangKeService.getAccessToken: 'access_token' is null!");
    return accessToken;
  }

  static Future<String> loginDesktopEndpoint(Dio dio,
      {required String accessToken}) async {
    final url = "https://courses.guet.edu.cn/api/login?login=access_token";
    final data = {"access_token": accessToken, "org_id": 1};
    final resp = await dio.post(url, data: data);
    final sessionId = resp.headers.value('x-session-id');
    if (sessionId == null)
      throw Exception(
          "ChangKeService.loginDesktopEndpoint: 'sessionId' is null!");
    return sessionId;
  }

  static Future<String> login(Dio dio,
      {required String username,
      required String password,
      required CaptchaHandler captchaHandler,
      required bool isCampusNetwork}) async {
    final code = await getLoginCode(
        dio, username, password, captchaHandler, isCampusNetwork);
    final token = await getAccessToken(dio, code: code);
    final sessionId = loginDesktopEndpoint(dio, accessToken: token);
    return sessionId;
  }

  static Future<Response<Map<String, dynamic>>> signQr(Dio dio,
      {required String rollcallId,
      required String data,
      required deviceId}) async {
    final url =
        "https://courses.guet.edu.cn/api/rollcall/${rollcallId}/answer_qr_rollcall";
    final body = {
      "data": data,
      "deviceId": deviceId,
    };
    final resp = await dio.put<Map<String, dynamic>>(url,
        data: body, options: Options(responseType: ResponseType.json));
    return resp;
  }
}
