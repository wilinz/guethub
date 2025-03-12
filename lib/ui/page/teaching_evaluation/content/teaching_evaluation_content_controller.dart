import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guethub/data/model/teaching_evaluation/teaching_evaluation.dart';
import 'package:guethub/data/model/teaching_evaluation_content/teaching_evaluation_content.dart';
import 'package:guethub/data/model/teaching_evaluation_questions/teaching_evaluation_questions.dart';
import 'package:guethub/data/model/teaching_evaluation_submit/teaching_evaluation_submit.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/teaching_evaluation.dart';
import 'package:guethub/data/service/teaching_evaluation.dart';
import 'package:guethub/logger.dart';
import 'package:guethub/ui/util/toast.dart';

class TeachingEvaluationContentController extends GetxController {
  final Rx<Task> task;
  final Teachers teacher;

  final questions = <TeachingEvaluationQuestionChapter>[].obs;

  GlobalKey formKey = GlobalKey<FormState>();

  // questionId, QuestionAndAnswer
  final questionsAndAnswers = <int, QuestionAndAnswer>{}.obs;

  final teachingEvaluationContent = Rx<TeachingEvaluationContent?>(null);

  final answersEditControllers = <String, TextEditingController>{}.obs;

  TeachingEvaluationContentController(Task task, this.teacher)
      : this.task = Rx(task);

  TextEditingController getTextEditingController(
      String questionnaireId, String questionId) {
    return answersEditControllers["${questionnaireId}_${questionId}"]!;
  }

  void setTextEditingController({
    required String questionnaireId,
    required String questionId,
    required TextEditingController controller,
  }) {
    answersEditControllers["${questionnaireId}_${questionId}"] = controller;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    final resp = await TeachingEvaluationRepository.get()
        .getTeachingEvaluationContentResponse(
            evaluationQuestionnaireId:
                this.task.value.evaluationQuestionnaireId);
    teachingEvaluationContent.value = resp.data;

    for (final question in resp.data.questions) {
      for (final content in question.contents) {
        final questionAndAnswer =
            QuestionAndAnswer(questionnaireId: resp.data.id, question: content);
        questionsAndAnswers[content.id] = questionAndAnswer;
        final controller = TextEditingController();
        controller.addListener(() {
          questionsAndAnswers[content.id]?.answer.answer = controller.text;
        });
        setTextEditingController(
          questionnaireId: resp.data.id,
          questionId: content.id.toString(),
          controller: controller,
        );
      }
    }
    questions.value = resp.data.questions;
  }

  submit(bool anonymous) async {
    if (!(formKey.currentState as FormState).validate()) {
      toastFailure0("请检查输入");
      return;
    }
    String? getAnswer(String type, int score, String? answer) {
      if (type == "3") {
        return score.toString();
      } else if (type == "4") {
        return answer;
      } else {
        return null;
      }
    }

    final body = TeachingEvaluationSubmit(
        stdSumTaskId: teacher.stdSumTaskId,
        anonymous: anonymous,
        evaluationQuestionnaireRes: EvaluationQuestionnaireRes(
            questionnaireId: task.value.evaluationQuestionnaireId,
            questionnaireName: task.value.evaluationQuestionnaireName,
            enable: true,
            answer: "[]",
            score: 0,
            questionAnsSaveList: questionsAndAnswers.values
                .map((e) => e.answer.copyWith(
                    answer: getAnswer(
                        e.answer.type, e.answer.score, e.answer.answer)))
                .toList()));

    logger.d(JsonEncoder.withIndent("  ").convert(body));

    final resp = await TeachingEvaluationService.submit(
        await AppNetwork.get().bkjwTestDio,
        body: body);
    if (resp['ok'] == true) {
      toastSuccess0("成功");
    } else {
      toastFailure0("失败", error: resp['msg']);
    }
  }
}
