import 'package:dio/dio.dart';

import '../network.dart';
import 'package:guethub/logger.dart';

class NetworkDetectionService {
  static Future<bool> isCampusNetwork(Dio dio) async {
    dio.options.validateStatus = (int? status) => status != null;
    try {
      final resp1 = await dio.get<String>("https://bkjwtest.guet.edu.cn/student/home",
          options: Options(
              sendTimeout: Duration(seconds: 5),
              receiveTimeout: Duration(seconds: 5)));
      return (resp1.statusCode ?? 400) < 300;
    } catch (e) {
      logger.e(e);
      return false;
    }
    // return resp.statusCode != 403;
  }
}
