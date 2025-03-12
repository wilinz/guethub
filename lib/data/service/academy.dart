
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:guethub/data/model/academy/academy_response.dart';
import 'package:guethub/data/network.dart';

class AcademyService{
  static Future<List<Academy>> get(Dio dio) async {
    final resp = await dio.get(
        "Comm/GetDepart");
    final respData = AcademyResponse.fromJson(resp.data);
    return respData.data;
  }
}