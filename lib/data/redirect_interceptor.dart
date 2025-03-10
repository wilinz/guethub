import 'package:dio/dio.dart';
import 'package:guethub/data/network.dart';

typedef RedirectCallback = bool Function(
    Response response, ResponseInterceptorHandler handler);

class RedirectInterceptor extends Interceptor {
  final Dio _dio;
  RedirectCallback? _redirectCallback;
  static const String followRedirects = "followRedirects";
  static const String rawUri = "rawUri";
  static const String rawRequestOption = "rawRequestOption";
  static const String redirectCount = "redirectCount";

  RedirectInterceptor(this._dio, {RedirectCallback? onRedirect})
      : _redirectCallback = onRedirect;

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    final isFollowRedirects =
        response.requestOptions.extra[followRedirects] as bool? ?? true;
    if (!isFollowRedirects) {
      handler.next(response);
      return;
    }

    final rawUriValue = response.requestOptions.extra[rawUri] as Uri?;
    if (rawUriValue == null) {
      response.requestOptions.extra[rawUri] = response.requestOptions.uri;
    }
    final rawRequestOptionValue = response.requestOptions.extra[rawRequestOption];
    if (rawRequestOptionValue == null){
      response.requestOptions.extra[rawRequestOption] = response.requestOptions;
    }

    if (_isRedirect(response.statusCode ?? 0)) {
      try {
        final redirectCountValue =
            response.requestOptions.extra[redirectCount] ?? 0;
        if (redirectCountValue >= 10) {
          handler.next(response);
          return;
        }
        if (_redirectCallback != null &&
            !_redirectCallback!.call(response, handler)) {
          return;
        }
        final location = response.headers.value('location');
        if (location == null) throw Exception("Redirect location is null");
        final requestOptions = response.requestOptions;
        final rawUri = requestOptions.uri.toString();
        final newUri = Uri.parse(_parseHttpLocation(rawUri, location));
        response.requestOptions.extra[redirectCount] = redirectCountValue + 1;

        final option = Options(
          sendTimeout: requestOptions.sendTimeout,
          receiveTimeout: requestOptions.receiveTimeout,
          extra: requestOptions.extra
            ..[BaseUrlInterceptor.enableAutoVpnUrl] = false,
          // headers: requestOptions.headers
          //   ..removeWhere((key, value) {
          //     return key.toLowerCase() == "cookie" || key.toLowerCase() == 'content-length';
          //   }),
          responseType: requestOptions.responseType,
          validateStatus: requestOptions.validateStatus,
          receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
          followRedirects: requestOptions.followRedirects,
          maxRedirects: requestOptions.maxRedirects,
          persistentConnection: requestOptions.persistentConnection,
          requestEncoder: requestOptions.requestEncoder,
          responseDecoder: requestOptions.responseDecoder,
          listFormat: requestOptions.listFormat,
        );

        final redirectResponse = await _dio.getUri(
          newUri,
          options: option,
        );
        return handler.next(redirectResponse);
      } on DioException catch (e) {
        return handler.reject(e);
      }
    }
    return handler.next(response);
  }

  bool _isRedirect(int statusCode) {
    return statusCode == 301 ||
        statusCode == 302 ||
        statusCode == 303 ||
        statusCode == 307 ||
        statusCode == 308;
  }

  String _parseHttpLocation(final String rawUri, final String location) {
    var location1 = location;
    String uri;
    if (!location1.contains("://")) {
      final schemaEndIndex = rawUri.indexOf("://") + 3;
      var index = location1.startsWith("/")
          ? rawUri.indexOf("/", schemaEndIndex)
          : rawUri.substring(schemaEndIndex).lastIndexOf("/") + schemaEndIndex;
      if (index == -1) index = rawUri.length - 1;
      var baseUrl = rawUri.substring(0, index + 1);
      if (baseUrl.endsWith("/")) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      if (location1.startsWith("/")) {
        location1 = location1.substring(1);
      }
      uri = baseUrl + "/" + location1;
    } else {
      uri = location1;
    }
    return uri;
  }
}
