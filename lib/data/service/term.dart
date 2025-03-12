import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:guethub/data/model/current_semesters/current_semesters.dart';
import 'package:guethub/data/model/semester_response/semester_response.dart';
import 'package:guethub/data/model/semesters/semesters.dart';
import 'package:guethub/data/model/term/term.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/logger.dart';
import 'package:json5/json5.dart';
import 'package:html/parser.dart' as htmlParser;

String unescapingJsonStr(String jsonStr) {
  return jsonDecode('{"text": "${jsonStr}"}')['text'];
}

List<dynamic>? extractSemesters(String jsCode) {
  RegExp semestersRegExp = RegExp(
      r'(var|let|const)\s+semesters\s*=\s*JSON.parse\(([\s\S]*?)\);',
      multiLine: true);
  RegExpMatch? semestersMatch = semestersRegExp.firstMatch(jsCode);

  if (semestersMatch != null) {
    String semestersJson = semestersMatch.group(2)!.trim();
    semestersJson = semestersJson.substring(1, semestersJson.length - 1);
    return json5Decode(unescapingJsonStr(semestersJson));
  } else {
    return null;
  }
}

Map<String, dynamic>? extractCurrentSemester(String jsCode) {
  RegExp currentSemesterRegExp =
      RegExp(r'(var|let|const)\s+currentSemester\s*=\s*(.*);', multiLine: true);

  RegExpMatch? currentSemesterMatch = currentSemesterRegExp.firstMatch(jsCode);
  if (currentSemesterMatch != null) {
    String currentSemesterJson = currentSemesterMatch.group(2)!.trim();
    return json5Decode(currentSemesterJson);
  } else {
    return null;
  }
}

class TermService {
  @Deprecated("Old system")
  static Future<List<Term>> getTermList() async {
    final resp = await AppNetwork.get().bkjwDio.get("comm/getlabarrangeterm");
    final respData = TermResponse.fromJson(resp.data);
    return respData.data;
  }

  static Future<List<Term>> getSystem2TermList() async {
    https: //bkjwsrv.guet.edu.cn/Comm/GetTerm?_dc=1725807886294&page=1&start=0&limit=25
    final resp = await AppNetwork.get().bkjwDio.get("Comm/GetTerm",
        queryParameters: {"_dc": DateTime.timestamp().millisecondsSinceEpoch});
    final respData = TermResponse.fromJson(resp.data);
    return respData.data..map((e) => e..systemId = 2).toList();
  }

  static Future<SemesterNewResponse> getSemestersNew(Dio dio) async {
    final resp = await dio.get(
        'eams5-evaluation-service/api/v1/common/drop-down/stu_semester?enabled=true&idc_=self');
    return SemesterNewResponse.fromJson(resp.data);
  }

  static Future<(List<Semester>, CurrentSemesters)> getSemesters(
      Dio dio) async {
    final resp = await dio.get('student/for-std/course-table');
    final data = resp.data;
    final doc = htmlParser.parse(data);
    final scripts = doc
        .querySelectorAll('script:not([src])')
        .map((e) => e.text)
        .toList()
        .join('\n\n');

    final semesters = extractSemesters(scripts);

    if (semesters == null) {
      logger.d(data);
      throw Exception('Semesters not found');
    }
    final currentSemester = extractCurrentSemester(scripts)!;
    return (
      semestersListFormJson(semesters),
      CurrentSemesters.fromJson(currentSemester)
    );
  }
}
