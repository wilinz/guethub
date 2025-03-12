import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:guethub/data/database/database.dart';
import 'package:guethub/data/get_storage.dart';
import 'package:guethub/data/model/exam_scores/exam_scores.dart';
import 'package:guethub/data/model/exam_scores_new/exam_scores_new.dart';
import 'package:guethub/data/model/exam_scores_sort/exam_scores_sort.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/common.dart';
import 'package:guethub/data/repository/user.dart';
import 'package:guethub/data/service/exam_scores.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:guethub/logger.dart';

class ExamScoresRepository {
  Future<Dio> get oldDio => AppNetwork.get().bkjwDio;

  Future<Dio> get dio => AppNetwork.get().bkjwTestDio;

  static const String oldExamScoresCacheKey = "old_exam_scores_cache_key";

  Future<ExamScoresResponse?> getExamScoresCache() async {
    final user = await UserRepository.get().getActiveUser();
    if (user == null) throw NotLoggedInException("未登录");
    final key = oldExamScoresCacheKey + "_" + user.username;
    final json = networkCacheStorage.read(key);
    if (json != null) {
      return ExamScoresResponse.fromJson(jsonDecode(json));
    }
    return null;
  }

  Future<void> setExamScoresCache(ExamScoresResponse data) async {
    final user = await UserRepository.get().getActiveUser();
    if (user == null) throw NotLoggedInException("未登录");
    final key = oldExamScoresCacheKey + "_" + user.username;
    networkCacheStorage.write(key, jsonEncode(data.toJson()));
  }

  @Deprecated("Old system")
  Future<ExamScoresResponse> getExamScores({
    String term = "",
    List<ExamScoresSort>? sort = null,
    int page = 1,
    int start = 0,
    int limit = 100,
  }) async {
    try {
      final resp = await ExamScoresService.getExamScores(await oldDio,
          term: term, sort: sort, page: page, start: start, limit: limit);
      setExamScoresCache(resp);
      return resp;
    } catch (e) {
      logger.e(e);
      throw Exception("旧系统成绩加载失败：$e");
    }
  }

  Future<List<ExamScoresNew>> getExamScoresNewFormDB() async {
    final user = await UserRepository.get().getActiveUser();
    if (user == null) throw NotLoggedInException("未登录");
    final scores =
        await appDatabase.examScoresNewDao.getAllByUsername(user.username);
    return scores;
  }

  Future<void> updateExamScoresNewList(List<ExamScoresNew> unreadScores) async {
    await appDatabase.examScoresNewDao
        .insertOrUpdateExamScoresNews(unreadScores);
  }

  Future<List<ExamScoresNew>> getExamScoresNew() async {
    try {
      final data = await ExamScoresService.getExamScoresNew(await dio);
      data.examScoresNews =
          data.examScoresNews.map((list) => handleData(list)).toList();
      return data.examScoresNews.expand((e) => e).toList();
    } catch (e) {
      logger.e(e);
      throw Exception("新系统成绩加载失败：$e");
    }
  }

  Future<List<ExamScoresNew>> mergeRemoteAndLocalData(
      List<ExamScoresNew> remoteData, List<ExamScoresNew> localData) async {
    final user = await UserRepository.get().getActiveUser();
    if (user == null) throw NotLoggedInException("未登录");

    final localMap = {for (var score in localData) score.id: score};
    final remoteMap = {for (var score in remoteData) score.id: score};

    final updatedScores = <ExamScoresNew>[];
    final scoresToDelete = <ExamScoresNew>[];
    final newScores = <ExamScoresNew>[];

    // Find differences and update unread field
    for (var remoteScore in remoteData) {
      final localScore = localMap[remoteScore.id];
      if (localScore == null) {
        if (localData.isNotEmpty) {
          remoteScore.unread = true;
        }
        updatedScores.add(remoteScore);
        newScores.add(remoteScore);
      } else {
        remoteScore.unread = localScore.unread;
        remoteScore.createTime = localScore.createTime;
        newScores.add(remoteScore);
        if (localScore != remoteScore) {
          updatedScores.add(remoteScore);
        }
      }
    }

    for (var localScore in localData) {
      if (!remoteMap.containsKey(localScore.id)) {
        scoresToDelete.add(localScore);
      }
    }

    // Update database with new data and remove outdated data
    await appDatabase.examScoresNewDao.insertOrUpdateExamScoresNews(
        updatedScores.map((e) => e..username = user.username).toList());
    await appDatabase.examScoresNewDao.deleteAll(scoresToDelete);

    // Return new list of data
    return newScores;
  }

  List<ExamScoresNew> handleData(List<ExamScoresNew> examScoresNew) {
    examScoresNew = examScoresNew.map((e) {
      e.gradeDetail = getTextElements(
              html_parser.parse(e.gradeDetail).querySelectorAll("span"))
          .map((e) => e.text)
          .join(" ");
      e.gaGrade = e.gaGrade.contains("span")
          ? getTextElements(
                  html_parser.parse(e.gaGrade).querySelectorAll("span"))
              .map((e) => e.text)
              .join(" ")
          : e.gaGrade;
      e.gaGrade = getCorrectOverallScoreNew(e.gaGrade);
      return e;
    }).toList();
    return examScoresNew;
  }

  String getCorrectOverallScoreNew(String scores) {
    switch (scores) {
      case "优":
        return '95';
      case "良":
        return '85';
      case "中":
        return '75';
      case "及格":
        return '65';
      case "合格":
        return '60';
      case "不及格":
        return '40';
      default:
    }
    return scores;
  }

  List<Element> getTextElements(List<Element> nodes) {
    List<Element> textElements = [];

    void traverse(Node node) {
      if (node is Element && node.text.trim().isNotEmpty) {
        textElements.add(node);
      }
      for (var child in node.nodes) {
        traverse(child);
      }
    }

    for (var node in nodes) {
      traverse(node);
    }

    return textElements;
  }

  calculateCreditGrades(List<ExamScore> scores) {}

  ExamScoresRepository._();

  static ExamScoresRepository? _instance;

  factory ExamScoresRepository.get() => _instance ??= ExamScoresRepository._();
}
