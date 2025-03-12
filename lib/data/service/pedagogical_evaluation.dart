import 'package:dio/dio.dart';
import 'package:guethub/data/model/common/common_response.dart';
import 'package:guethub/data/model/pedagogical_evaluation/pedagogical_evaluation_data.dart';
import 'package:guethub/data/model/pedagogical_evaluation/pedagogical_evaluation_questions_response.dart';
import 'package:guethub/data/model/pedagogical_evaluation/pedagogical_evaluation_questions_save_request.dart';
import 'package:guethub/data/model/pedagogical_evaluation/pedagogical_evaluation_response.dart';
import 'package:guethub/data/network.dart';

class PedagogicalEvaluationService {
  static Future<List<PedagogicalEvaluation>> get(String term) async {
    final resp = await AppNetwork.get().bkjwDio
        .get("student/getpjcno", queryParameters: {"term": term});
    final respData = PedagogicalEvaluationResponse.fromJson(resp.data);
    return respData.data;
  }

  static Future<List<PedagogicalEvaluationQuestion>> getQuestions(
      String term, String courseno, String teacherno) async {
    final resp = await AppNetwork.get().bkjwDio.get("student/jxpgdata",
        queryParameters: {
          "term": term,
          "courseno": courseno,
          "teacherno": teacherno
        });
    final respData = PedagogicalEvaluationQuestionsResponse.fromJson(resp.data);
    return respData.data;
  }

  static Future<CommonResponse> submitQuestions(
      {required String term,
      required String courseid,
      required String courseno,
      required String teacherno,
      required int lb,
      required List<PedagogicalEvaluationQuestion> questions}) async {
    final data = questions
        .map((resp) => PedagogicalEvaluationQuestionsSaveRequest.fromResponse(
            resp, term, courseid, teacherno, courseno, lb))
        .where((e) => e != null)
        .toList();
    final resp = await AppNetwork.get().bkjwDio.post("student/SaveJxpg",
        queryParameters: {
          "term": term,
          "courseno": courseno,
          "teacherno": teacherno
        },
        data: data);
    final respData = CommonResponse.fromJson(resp.data);
    return respData;
  }

  static Future<CommonResponse> submit(
      {required PedagogicalEvaluation data,
      required String comment,
      required num score,
      required bool isSaveOnly}) async {
    //  student/SaveJxpgJg
    final path = isSaveOnly ? "student/SaveJxpgJg" : "student/SaveJxpgJg/1";
    final resp = await AppNetwork.get().bkjwDio.post(path,
        data: PedagogicalEvaluationData.fromResponse(data, comment, score)
            .toJson(),
        options: Options(contentType: AppNetwork.typeUrlEncode));
    return CommonResponse.fromJson(resp.data);
  }

  static Future<PedagogicalEvaluationData> getCurrent(
      {required String term,
      required String courseno,
      required String teacherno}) async {
    final resp = await AppNetwork.get().bkjwDio.post("student/JxpgJg",
        data: {
          "term": term,
          "courseno": courseno,
          "teacherno": teacherno
        });
    final respData = PedagogicalEvaluationData.fromJson(CommonResponse.fromJson(resp.data).data);
    return respData;
  }
//  student/JxpgJg
}
