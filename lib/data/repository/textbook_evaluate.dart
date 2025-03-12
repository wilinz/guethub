import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:guethub/data/model/textbook_evaluate/textbook_evaluate_detail/textbook_evaluate_detail.dart';
import 'package:guethub/data/model/textbook_evaluate/textbook_evaluate_info/textbook_evaluate_info.dart';
import 'package:guethub/data/model/textbook_evaluate/textbook_evaluate_result/textbook_evaluate_result.dart';
import 'package:guethub/data/model/textbook_evaluate/textbook_evaluate_save/textbook_evaluate_save.dart';
import 'package:guethub/data/model/textbook_evaluate/textbook_evaluate_save_result/textbook_evaluate_save_result.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/common.dart';
import 'package:guethub/data/repository/user.dart';
import 'package:guethub/data/service/textbook_evaluate.dart';
import 'package:guethub/exceptions/exceptions.dart';

class TextbookEvaluateRepository {
  Future<Dio> get dio => AppNetwork.get().bkjwTestDio;

  bool isTestData = false;

  Future<TextbookEvaluateSaveResult> saveTextbookEvaluate(
          {required TextbookEvaluateSave data}) async =>
      TextbookEvaluateService.saveTextbookEvaluate(await dio, data: data);

  Future<TextbookEvaluateResult> getTextbookEvaluateResult({
    required int semesterId,
  }) async {
    final studentId = await getNewSystemStudentId();
    return TextbookEvaluateService.getTextbookEvaluateResult(await dio,
        studentId: studentId, semesterId: semesterId);
  }

  Future<int> getNewSystemStudentId() async {
    final user = await UserRepository.get().getRecentUser();
    if (user == null) throw NotLoggedInException();
    if (user.newSystemStudentId == null) throw UserNewSystemIDNullException();
    return user.newSystemStudentId!;
  }

  Future<TextbookEvaluateInfo> getTextbookEvaluateInfo({
    required int semesterId,
  }) async {
    final studentId = await getNewSystemStudentId();

    return isTestData
        ? Future.value(TextbookEvaluateInfo.fromJson(
            jsonDecode(testTextbookEvaluateInfoData)))
        : TextbookEvaluateService.getTextbookEvaluateInfo(await dio,
            studentId: studentId, semesterId: semesterId);
  }

  Future<List<TextbookEvaluateDetail>?> getTextbookEvaluateDetail(
      {required int semesterId,
      required int batchId,
      required int courseId,
      required int textbookId,
      String? redirectUrl}) async {
    final studentId = await getNewSystemStudentId();
    return TextbookEvaluateService.getTextbookEvaluateDetail(await dio,
        studentId: studentId,
        semesterId: semesterId,
        batchId: batchId,
        courseId: courseId,
        textbookId: textbookId);
  }

  TextbookEvaluateRepository._create();

  static TextbookEvaluateRepository? _instance;

  factory TextbookEvaluateRepository.get() =>
      _instance ??= TextbookEvaluateRepository._create();

  static const testTextbookEvaluateInfoData = """{
  "batchOpen": true,
  "data": [
    {
      "course": {
        "id": 9652,
        "nameZh": "计算机网络（双语教学）",
        "nameEn": "Computer Network",
        "code": "2200031X0",
        "credits": 3
      },
      "textbook": {
        "id": 431,
        "nameZh": "计算机网络（第8版）",
        "nameEn": null,
        "author": "谢希仁",
        "isbn": "9787121411748",
        "press": {
          "nameZh": "电子工业出版社",
          "nameEn": null
        }
      },
      "evaluateIndex": {
        "nameZh": "学生评价表",
        "nameEn": null
      }
    },
    {
      "course": {
        "id": 29291,
        "nameZh": "体测3",
        "nameEn": "Physical Fitness Test 3",
        "code": "000098",
        "credits": 0
      },
      "textbook": {
        "id": 789,
        "nameZh": "大学体育基础教程",
        "nameEn": null,
        "author": "宾金生",
        "isbn": "9787564428006",
        "press": {
          "nameZh": "北京体育大学出版社",
          "nameEn": null
        }
      },
      "evaluateIndex": {
        "nameZh": "学生评价表",
        "nameEn": null
      }
    }
  ],
  "evaluateBatch": {
    "id": 1,
    "startTime": "2024-11-04 10:55:58",
    "endTime": "2025-02-16 23:00:00",
    "bulletin": null
  }
}""";
}
