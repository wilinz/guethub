import 'dart:convert';

import 'package:guethub/data/model/majors/majors_response.dart';
import 'package:guethub/data/network.dart';

class MajorsService {
  static Future<List<Major>> get() async {
    final sort = [
      {"property": "dptno", "direction": "ASC"},
      {"property": "spno", "direction": "ASC"}
    ];
    final resp = await AppNetwork.get().bkjwDio
        .get("Comm/GetSpno", queryParameters: {"sort": jsonEncode(sort)});
    final respData = MajorsResponse.fromJson(resp.data);
    return respData.data;
  }
}
