import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:guethub/common/json.dart';
import 'package:guethub/data/model/exam_scores/exam_scores.dart';
import 'package:guethub/data/model/exam_scores_new/exam_scores_new.dart';
import 'package:guethub/data/model/exam_scores_sort/exam_scores_sort.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/user.dart';

class ExamScoresService {
  @Deprecated("Old system")
  static Future<ExamScoresResponse> getExamScores(
    Dio dio, {
    String term = "",
    List<ExamScoresSort>? sort = null,
    int page = 1,
    int start = 0,
    int limit = 100,
  }) async {
    final result = await dio.get("Student/GetStuScore", queryParameters: {
      "_dc": DateTime.timestamp().millisecondsSinceEpoch,
      "term": term,
      "page": page,
      "start": start,
      "limit": limit,
      "sort": sort != null
          ? jsonEncode(sort.toJson())
          : """[{"property":"stid","direction":"ASC"},{"property":"term","direction":"ASC"}]"""
    });
    return ExamScoresResponse.fromJson(result.data);
  }

  static Future<ExamScoresNewResponse> getExamScoresNew(Dio dio,
      {int? semester}) async {
    final studentId =
        await UserRepository.get().getNewSystemStudentIdFromLocal();

    final realUrl = "student/for-std/grade/sheet/info/${studentId}";
    final resp2 =
        await dio.get(realUrl, queryParameters: {'semester': semester});
    return ExamScoresNewResponse.fromJsonWithPreprocessJson(resp2.data);
  }
}
