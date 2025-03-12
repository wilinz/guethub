import 'package:guethub/data/model/teaching_evaluation/teaching_evaluation.dart';
import 'package:guethub/data/model/teaching_evaluation_content/teaching_evaluation_content.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/service/teaching_evaluation.dart';

class TeachingEvaluationRepository {
  Future<TeachingEvaluationResponse> getTeachingEvaluationResponse(
      {required int semesterId,
      int startPage = 0,
      int endPage = 100,
      String orderBy = "",
      bool evaluated = false}) async {
    final resp = await TeachingEvaluationService.getTeachingEvaluationResponse(
        await AppNetwork.get().bkjwTestDio,
        semesterId: semesterId,
        startPage: startPage,
        endPage: endPage,
        orderBy: orderBy,
        evaluated: evaluated);
    return resp;
  }

  Future<TeachingEvaluationContentResponse>
      getTeachingEvaluationContentResponse(
          {required String evaluationQuestionnaireId}) async {
    final resp =
        await TeachingEvaluationService.getTeachingEvaluationContentResponse(
            await AppNetwork.get().bkjwTestDio,
            evaluationQuestionnaireId: evaluationQuestionnaireId);
    return resp;
  }

  TeachingEvaluationRepository._create();

  static TeachingEvaluationRepository? _instance;

  factory TeachingEvaluationRepository.get() =>
      _instance ??= TeachingEvaluationRepository._create();
}
