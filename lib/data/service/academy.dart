
import 'dart:convert';

import 'package:guethub/data/model/academy/academy_response.dart';
import 'package:guethub/data/network.dart';

class AcademyService{
  static Future<List<Academy>> get() async {
    final resp = await AppNetwork.get().bkjwDio.get(
        "Comm/GetDepart");
    final respData = AcademyResponse.fromJson(resp.data);
    return respData.data;
  }
}