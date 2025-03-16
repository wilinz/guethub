import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:guethub/data/model/graduate_info/graduate_info.dart';
import 'package:guethub/data/model/program_completion_info/program_completion_info.dart';
import 'package:guethub/data/repository/user.dart';
import 'package:guethub/logger.dart';
import 'package:guethub/util/string_ext.dart';
import 'package:html/parser.dart';
import 'package:kt_dart/kt.dart';
import 'package:rust_module/rust_module.dart';

class ProgramCompletionInfoService {
  static Future<GraduateInfo?> getGraduateInfo(Dio dio) async {
    final studentId =
        await UserRepository.get().getNewSystemStudentIdFromLocal();

    final url = "student/for-std/program-completion-preview/info/${studentId}";
    final resp2 =
        await dio.get(url, options: Options(responseType: ResponseType.bytes));
    final t1 = DateTime.timestamp();
    final graduateInfoRust = await parseGraduateInfo(html: resp2.data);
    final t2 = DateTime.timestamp();
    logger.i("parseGraduateInfo: ${t2.difference(t1).inMilliseconds}  ms");

    return graduateInfoRust?.let((it) =>
        GraduateInfo.fromJson(jsonDecode(utf8.decode(graduateInfoRust))));
  }

  static Future<ProgramCompletionInfo> getProgramCompletionInfo(Dio dio,
      {required String programId}) async {
    final resp = await dio.get(
        "student/for-std/credit-certification-apply/other_apply/get-all-course-module?programId=${programId}");
    return ProgramCompletionInfo.fromJson(resp.data);
  }
}

final _fieldKeyMap = {
  "毕业": "graduation",
  "学位": "degree",
  "学分绩": "gpa",
};

GraduateInfo? _parseGraduateInfoDart(String html) {
  final doc = parse(html);
  final graduateInfo = doc.querySelector(".graduate-info");
  final items = graduateInfo?.querySelectorAll("p");
  if (items == null) return null;
  final result = <String, String?>{};
  for (final item in items) {
    final key = item.querySelector("strong")?.text.replaceAll("：", "").trim();
    var value = item.querySelector("span")?.text.trim().trimChars("()（）");
    if (['学位', '毕业'].contains(key) && value != null) {
      value = value.replaceAll(RegExp(r'\s+'), '');
    }
    if (key != null) {
      final englishKey = _fieldKeyMap[key] ?? key;
      result[englishKey] = value;
    }
  }

  String? programId = doc
      .querySelector('input[name="targetProgramAssoc"]')
      ?.attributes['value'];
  result['programId'] = programId;
  return GraduateInfo.fromJson(result);
}
