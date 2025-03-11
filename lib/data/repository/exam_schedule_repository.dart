import 'package:guethub/data/database/database.dart';
import 'package:guethub/data/model/exam_schedule/exam_schedule.dart';
import 'package:guethub/data/model/exam_scheduling/exam_schedule.dart' as old;
import 'package:guethub/data/repository/common.dart';
import 'package:guethub/data/repository/user.dart';
import 'package:guethub/data/service/exam_schedule.dart';

class ExamScheduleRepository {
  @Deprecated("Old system")
  Future<old.ExamScheduleResponse> getExamSchedule({
    String term = "",
    int page = 1,
    int start = 0,
    int limit = 100,
  }) =>
      ExamScheduleService.getExamSchedule(
          term: term, page: page, start: start, limit: limit);

  Map<String, List<ExamSchedule>> cache = {};

  Future<List<ExamSchedule>> getExamScheduleNew({required bool isFlush}) async {
    final user = await UserRepository.get().getActiveUser();
    if (user == null) throw NotLoggedInException("未登录");

    final cacheKey = "cache_exam_schedule_${user.username}";
    if (!isFlush) {
      final cacheData = cache[cacheKey];
      if(cacheData != null && cacheData.isNotEmpty) return cacheData;
      final db = await getDatabase();
      final dbData = await db.examScheduleDao.getAllByUsername(user.username);
      if (dbData.isNotEmpty) return dbData;
    }

    var data = await ExamScheduleService.getExamScheduleNew(studentId: user.newSystemStudentId!);
    data = data.map((e) => e..username = user.username).toList();
    cache[cacheKey] = data;
    final db = await getDatabase();
    await db.examScheduleDao.deleteByUsername(user.username);
    await db.examScheduleDao.insertOrUpdateAll(data);
    return data;
  }

  ExamScheduleRepository._();

  static ExamScheduleRepository? _instance;

  factory ExamScheduleRepository.get() =>
      _instance ??= ExamScheduleRepository._();
}
