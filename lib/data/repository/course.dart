import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:guethub/data/database/database.dart';
import 'package:guethub/data/model/course/course_lab_response.dart';
import 'package:guethub/data/model/course/course_response.dart';
import 'package:guethub/data/model/course/semester_schedule.dart';
import 'package:guethub/data/model/plan_course/plan_course_detail_response.dart';
import 'package:guethub/data/model/plan_course/plan_course_response.dart';
import 'package:guethub/data/model/semesters/semesters.dart';
import 'package:guethub/data/model/term/term.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/user.dart';
import 'package:guethub/data/service/new_course_schedule.dart';
import 'package:guethub/data/service/term.dart';
import 'package:guethub/logger.dart';
import 'package:guethub/util/list.dart';
import 'package:guethub/util/weeks_between.dart';
import 'package:rxdart/rxdart.dart';

import '../model/common/common_response.dart';
import '../service/course.dart';

class CourseRepository {
  Future<Dio> get oldDio => AppNetwork.get().bkjwDio;

  Future<Dio> get dio => AppNetwork.get().bkjwTestDio;

  final _onDatabaseChangeEvent = BehaviorSubject();

  ValueStream get onDatabaseChangeEvent => _onDatabaseChangeEvent.stream;

  Future<void> deleteSemesterSchedule(SemesterSchedule schedule) async {
    final db = await getDatabase();
    await db.semesterScheduleDao.deleteData(schedule);
    await syncChangeToMemory();
    _onDatabaseChangeEvent.add("");
  }

  Future<void> insertOrUpdateSemesterSchedule(SemesterSchedule schedule) async {
    final db = await getDatabase();
    await db.semesterScheduleDao.insertOrUpdateSemesterSchedule(schedule);
    await syncChangeToMemory();
    _onDatabaseChangeEvent.add("");
  }

  @Deprecated('Old system')
  Term? getCurrentTerm(List<Term> terms, bool holidayForward) {
    final now = DateTime.now();
    final term = terms.firstWhereOrNull((e) =>
        getRealStartDate(e.startDate).isBefore(now) &&
        getRealEndDate(e.endDate).isAfter(now));
    if (term == null) {
      final sortedList = List.of(terms)
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      if (holidayForward) {
        final nextTerm = sortedList
            .firstWhereOrNull((e) => getRealEndDate(e.endDate).isAfter(now));
        if (nextTerm != null) return nextTerm;
      }
      final lastTerm = sortedList
          .lastWhereOrNull((e) => getRealEndDate(e.endDate).isBefore(now));
      return lastTerm;
    }
    return term;
  }

  @Deprecated('Old system')
  Future<CommonResponse> select(PlanCourseDetail planCourseDetail) async {
    return CourseService.select(await oldDio, planCourseDetail);
  }

  @Deprecated('Old system')
  Future<CommonResponse> unselect(PlanCourseDetail planCourseDetail) async {
    return CourseService.unselect(await oldDio, planCourseDetail);
  }

  @Deprecated('Old system')
  Map<int, List<Term>> terms = {};

  //   Future<List<Semester>> getSemesters({bool isFlush = false}) async {
  //     final db = await getDatabase();
  //     if (!isFlush) {
  //       if (semesters.isNotEmpty) return sortSemesters(semesters);
  //       semesters = await db.semesterDao.getAll();
  //       if (semesters.isNotEmpty) return sortSemesters(semesters);
  //     }
  //     final (semesterList, current) =
  //         await TermService.getSemesters(AppNetwork.get().dio2);
  //     semesters = semesterList;
  //     logger.d("插入新学期");
  //     db.semesterDao.insertAll(semesters);
  //     return sortSemesters(semesters);
  //   }

  @Deprecated('Old system')
  Future<List<Term>> getTermList({required bool isFlush}) async {
    final db = await getDatabase();
    final user = await UserRepository.get().getActiveUser();
    final systemId = user?.isUpgradedUndergrad == true ? 2 : 0;
    if (!isFlush) {
      if (terms[systemId] != null) return terms[systemId]!;
      terms[systemId] = await db.termDao.getAll(systemId);
      if (terms[systemId] != null) return terms[systemId]!;
    }

    List<Term> termData;
    logger.d("获取学期列表: ${user}");
    if (user?.isUpgradedUndergrad == true) {
      termData = (await TermService.getSystem2TermList(await oldDio)).map(
        (e) {
          e.startDate = getRealStartDate(e.startDate);
          e.endDate = getRealStartDate(e.endDate);
          return e;
        },
      ).toList();
    } else {
      termData = (jsonDecode(_oldTermListJson) as List<dynamic>)
          .map((e) => Term.fromJson(e as Map<String, dynamic>))
          .map(
        (e) {
          e.startDate = getRealStartDate(e.startDate);
          e.endDate = getRealStartDate(e.endDate);
          return e;
        },
      ).toList();
    }

    terms[systemId] = termData
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    db.termDao.insertAll(termData);
    return termData;
  }

  @Deprecated('Old system')
  int getWeek(Term term, DateTime dateTime) {
    final weeks = calculateWeekNumber(term.startDate, dateTime);
    return weeks + 1;
  }

  @Deprecated('Old system')
  Future<List<OldCourse>> getCourseList(String term) async =>
      CourseService.getCourseList(await oldDio, term);

  @Deprecated('Old system')
  Future<List<CourseLab>> getCourseLabList(String term) async {
    return CourseService.getCourseLabList(await oldDio, term);
  }

  @Deprecated('Old system')
  Future<List<PlanCourse>> getPlan(
    String term,
    String grade,
    String dptno,
    String spno,
  ) async {
    return CourseService.getPlan(await oldDio, term, grade, dptno, spno)
        .then((value) => value..sort((a, b) => a.tname.compareTo(b.tname)));
  }

  @Deprecated('Old system')
  Future<List<PlanCourseDetail>> getPlanCourseDetail(
      String id, String courseid) async {
    return CourseService.getPlanCourseDetail(await oldDio, id, courseid);
  }

  Map<String, List<SemesterSchedule>> _semesterScheduleCache = {};

  @Deprecated('Old system')
  Future<List<SemesterSchedule>> getSemesterSchedule(String term,
      {bool isFlush = false}) async {
    final user = await UserRepository.get().getActiveUser();
    if (user == null) throw new Exception("未登录");
    final systemId = user.isUpgradedUndergrad == true ? 2 : 0;

    final cacheKey = "cache_${user.username}_${term.replaceAll("_", "^")}";

    if (!isFlush) {
      if (_semesterScheduleCache[cacheKey] != null)
        return _semesterScheduleCache[cacheKey]!;
      var dbCache = (await appDatabase.semesterScheduleDao
          .getAllByTermAndUsername(term, user.username));
      _semesterScheduleCache[cacheKey] = dbCache;
      if (dbCache.isNotEmpty) {
        dbCache = dbCache;
        return dbCache;
      }
    }

    // final dbCache = await db.semesterScheduleDao.getAll();
    // if (dbCache.isNotEmpty) return dbCache;
    List<SemesterSchedule> semesterSchedule;
    if (systemId == 0) {
      List responses =
          await Future.wait([getCourseList(term), getCourseLabList(term)]);
      semesterSchedule =
          generateSemesterSchedule(responses[0], responses[1], user.username);
    } else {
      List<OldCourse> responses = await getCourseList(term);
      semesterSchedule =
          generateSystem2SemesterSchedule(responses, user.username);
    }

    semesterSchedule = semesterSchedule;

    await appDatabase.semesterScheduleDao.deleteByUsernameAndSourceAndTerm(
        user.username, [SemesterScheduleSource.manual], term);

    await appDatabase.semesterScheduleDao
        .insertOrUpdateSemesterSchedules(semesterSchedule);

    final newData = await appDatabase.semesterScheduleDao
        .getAllByTermAndUsername(term, user.username);

    _semesterScheduleCache[cacheKey] = newData;

    return newData;
  }

  DateTime getRealStartDate(DateTime t) {
    // Calculate how many days to subtract to get to the nearest Monday
    final int daysToMonday =
        t.weekday == DateTime.monday ? 0 : (t.weekday - DateTime.monday) % 7;
    return t.subtract(Duration(days: daysToMonday));
  }

  DateTime getRealEndDate(DateTime t) {
    // Calculate how many days to add to get to the nearest Sunday
    final int daysToSunday = DateTime.sunday - t.weekday;
    return t.add(Duration(days: daysToSunday));
  }

  Semester? getCurrentSemester(List<Semester> terms, bool holidayForward) {
    final now = DateTime.now();

    final term = terms.firstWhereOrNull((e) =>
        getRealStartDate(e.startDate).isBefore(now) &&
        getRealEndDate(e.endDate).isAfter(now));
    if (term == null) {
      final sortedList = List.of(terms)
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      if (holidayForward) {
        final nextTerm = sortedList
            .firstWhereOrNull((e) => getRealEndDate(e.endDate).isAfter(now));
        if (nextTerm != null) return nextTerm;
      }
      final lastTerm = sortedList
          .lastWhereOrNull((e) => getRealEndDate(e.endDate).isBefore(now));
      return lastTerm;
    }
    return term;
  }

  List<int> getLastSixYears() {
    var currentYear = DateTime.now().year;
    var lastFiveYears = <int>[];

    for (var i = 0; i < 6; i++) {
      lastFiveYears.add(currentYear - i);
    }
    return lastFiveYears;
  }

  int getWeekNew(Semester term, DateTime dateTime) {
    final weeks = calculateWeekNumber(term.startDate, dateTime);
    return weeks + 1;
  }

  List<Semester> semesters = [];

  sortSemesters(List<Semester> semesters) => semesters
    ..sort((a, b) {
      return a.startDate.isBefore(b.startDate) ? 1 : -1;
    });

  Future<List<Semester>> getSemesters({bool isFlush = false}) async {
    final db = await getDatabase();
    if (!isFlush) {
      if (semesters.isNotEmpty) return sortSemesters(semesters);
      semesters = await db.semesterDao.getAll();
      if (semesters.isNotEmpty) return sortSemesters(semesters);
    }
    final (semesterList, current) =
        await TermService.getSemesters(await AppNetwork.get().bkjwTestDio);
    semesters = semesterList.map((e) {
      e.startDate = getRealStartDate(e.startDate);
      e.endDate = getRealStartDate(e.endDate);
      return e;
    }).toList();
    logger.d("插入新学期");
    db.semesterDao.insertAll(semesters);
    return sortSemesters(semesters);
  }

  Future<void> syncChangeToMemory() async {
    for (final k in _semesterScheduleNewCache.keys) {
      final keySpilt = k.split("_");
      final username = keySpilt[1];
      final semester = keySpilt[2];
      final dbData = (await appDatabase.semesterScheduleDao
          .getAllByTermAndUsername(semester, username));
      _semesterScheduleNewCache[k] = dbData;
    }
    for (final k in _semesterScheduleCache.keys) {
      final keySpilt = k.split("_");
      final username = keySpilt[1];
      final term = keySpilt[2].replaceAll("^", "_");
      final dbData = (await appDatabase.semesterScheduleDao
          .getAllByTermAndUsername(term, username));
      _semesterScheduleCache[k] = dbData;
    }
  }

  Map<String, List<SemesterSchedule>> _semesterScheduleNewCache = {};

  Future<List<SemesterSchedule>> getSemesterScheduleNew(Semester semester,
      {bool isFlush = false}) async {
    final user = await UserRepository.get().getActiveUser();
    if (user == null) throw new Exception("未登录");

    final cacheKey = "cache_${user.username}_${semester.id}";

    if (!isFlush) {
      if (_semesterScheduleNewCache[cacheKey] != null)
        return _semesterScheduleNewCache[cacheKey]!;
      var dbCache = (await appDatabase.semesterScheduleDao
          .getAllByTermAndUsername(semester.id.toString(), user.username));
      _semesterScheduleNewCache[cacheKey] = dbCache;
      if (dbCache.isNotEmpty) {
        dbCache = dbCache;
        return dbCache;
      }
    }

    // final dbCache = await db.semesterScheduleDao.getAll();
    // if (dbCache.isNotEmpty) return dbCache;
    final responses = await NewCourseService.getPrintData(
        dio: await AppNetwork.get().bkjwTestDio, semesterId: semester.id);

    var semesterSchedule =
        generateSemesterScheduleNew(responses, user.username, semester);

    semesterSchedule = semesterSchedule;

    await appDatabase.semesterScheduleDao.deleteByUsernameAndSourceAndTerm(
        user.username, [SemesterScheduleSource.manual], semester.id.toString());

    await appDatabase.semesterScheduleDao
        .insertOrUpdateSemesterSchedules(semesterSchedule);

    final newData = await appDatabase.semesterScheduleDao
        .getAllByTermAndUsername(semester.id.toString(), user.username);

    _semesterScheduleNewCache[cacheKey] = newData;

    return newData;
  }

  CourseRepository._();

  static CourseRepository? _instance;

  factory CourseRepository.get() => _instance ??= CourseRepository._();
}

const _oldTermListJson1 = """[
    {
      "term": "2023-2024_1",
      "startdate": "2023/9/4 0:00:00",
      "enddate": "2024/1/15 0:00:00",
      "weeknum": "18",
      "termname": "2023-2024上学期",
      "schoolyear": "2023",
      "comm": null
    },
    {
      "term": "2022-2023_3",
      "startdate": "2023/7/5 0:00:00",
      "enddate": "2023/7/30 0:00:00",
      "weeknum": "4",
      "termname": "2022-2023三学期",
      "schoolyear": "2022",
      "comm": null
    },
    {
      "term": "2022-2023_2",
      "startdate": "2023/2/13 0:00:00",
      "enddate": "2023/7/5 0:00:00",
      "weeknum": "18",
      "termname": "2022-2023下学期",
      "schoolyear": "2022",
      "comm": null
    },
    {
      "term": "2023-2024_2",
      "startdate": "2022/9/5 0:00:00",
      "enddate": "2023/1/8 0:00:00",
      "weeknum": "18",
      "termname": "2022-2023上学期",
      "schoolyear": "2022",
      "comm": null
    }
]
""";

const _oldTermListJson = """[
    {
      "term": "2023-2024_1",
      "startdate": "2023/9/4 0:00:00",
      "enddate": "2024/1/15 0:00:00",
      "weeknum": "18",
      "termname": "2023-2024上学期",
      "schoolyear": "2023",
      "comm": null
    },
    {
      "term": "2022-2023_3",
      "startdate": "2023/7/5 0:00:00",
      "enddate": "2023/7/30 0:00:00",
      "weeknum": "4",
      "termname": "2022-2023三学期",
      "schoolyear": "2022",
      "comm": null
    },
    {
      "term": "2022-2023_2",
      "startdate": "2023/2/13 0:00:00",
      "enddate": "2023/7/5 0:00:00",
      "weeknum": "18",
      "termname": "2022-2023下学期",
      "schoolyear": "2022",
      "comm": null
    },
    {
      "term": "2022-2023_1",
      "startdate": "2022/9/5 0:00:00",
      "enddate": "2023/1/8 0:00:00",
      "weeknum": "18",
      "termname": "2022-2023上学期",
      "schoolyear": "2022",
      "comm": null
    },
    {
      "term": "2021-2022_3",
      "startdate": "2022/2/21 0:00:00",
      "enddate": "2022/7/30 0:00:00",
      "weeknum": "4",
      "termname": "2021-2022三学期",
      "schoolyear": "2021",
      "comm": null
    },
    {
      "term": "2021-2022_2",
      "startdate": "2022/2/21 0:00:00",
      "enddate": "2022/7/30 0:00:00",
      "weeknum": "22",
      "termname": "2021-2022下学期",
      "schoolyear": "2021",
      "comm": null
    },
    {
      "term": "2021-2022_1",
      "startdate": "2021/9/6 0:00:00",
      "enddate": "2022/1/9 0:00:00",
      "weeknum": "18",
      "termname": "2021-2022上学期",
      "schoolyear": "2021",
      "comm": null
    },
    {
      "term": "2020-2021_3",
      "startdate": "2021/2/21 0:00:00",
      "enddate": "2021/7/30 0:00:00",
      "weeknum": "4",
      "termname": "2020-2021三学期",
      "schoolyear": "2020",
      "comm": null
    },
    {
      "term": "2020-2021_2",
      "startdate": "2021/2/21 0:00:00",
      "enddate": "2021/7/30 0:00:00",
      "weeknum": "22",
      "termname": "2020-2021下学期",
      "schoolyear": "2020",
      "comm": null
    },
    {
      "term": "2020-2021_1",
      "startdate": "2020/9/6 0:00:00",
      "enddate": "2021/1/9 0:00:00",
      "weeknum": "18",
      "termname": "2020-2021上学期",
      "schoolyear": "2020",
      "comm": null
    }
  ]""";
