import 'dart:async';
import 'package:floor/floor.dart';
import 'package:guethub/data/dao/app_user.dart';
import 'package:guethub/data/dao/campus_network_user.dart';
import 'package:guethub/data/dao/exam_schedule.dart';
import 'package:guethub/data/dao/exam_scores_new.dart';
import 'package:guethub/data/dao/semester.dart';
import 'package:guethub/data/database/datetime_converter.dart';
import 'package:guethub/data/dao/schedule.dart';
import 'package:guethub/data/dao/student.dart';
import 'package:guethub/data/dao/term.dart';
import 'package:guethub/data/dao/user.dart';
import 'package:guethub/data/database/listconverter.dart';
import 'package:guethub/data/database/migration/migration1to2.dart';
import 'package:guethub/data/database/migration/migration2to3.dart';
import 'package:guethub/data/database/migration/migration3to4.dart';
import 'package:guethub/data/database/migration/migration4to5.dart';
import 'package:guethub/data/database/migration/migrations.dart';
import 'package:guethub/data/model/app/user/app_user.dart';
import 'package:guethub/data/model/course/semester_schedule.dart';
import 'package:guethub/data/model/exam_scores_new/exam_scores_new.dart';
import 'package:guethub/data/model/semesters/semesters.dart';
import 'package:guethub/data/model/student/student_info.dart';
import 'package:guethub/data/model/term/term.dart';
import 'package:guethub/data/model/user/campus_network_user.dart';
import 'package:guethub/data/model/user/user.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import '../model/exam_schedule/exam_schedule.dart';

part 'database.g.dart'; // the generated code will be there

@TypeConverters(
    [DateTimeConverter, DateTimeNullableConverter, ListIntConverter])
@Database(version: 22, entities: [
  SemesterSchedule,
  User,
  AppUser,
  StudentInfo,
  Term,
  CampusNetworkUser,
  Semester,
  ExamScoresNew,
  ExamSchedule
])
abstract class AppDatabase extends FloorDatabase {
  SemesterScheduleDao get semesterScheduleDao;

  UserDao get userDao;

  AppUserDao get appUserDao;

  TermDao get termDao;

  SemesterDao get semesterDao;

  StudentInfoDao get studentInfoDao;

  CampusNetworkUserDao get campusNetworkUserDao;

  ExamScoresNewDao get examScoresNewDao;

  ExamScheduleDao get examScheduleDao;
}

// 以下是OnConflictStrategy枚举中可用的选项：
//
// OnConflictStrategy.rollback: 回滚事务并撤销插入操作，以便回到插入之前的状态。
// OnConflictStrategy.abort: 中止插入操作并回滚事务。
// OnConflictStrategy.fail: 抛出一个异常以表示插入操作失败。
// OnConflictStrategy.ignore: 忽略冲突并继续执行操作，不会抛出异常或撤销操作。
// OnConflictStrategy.replace: 替换现有记录的值，并继续执行操作，不会抛出异常或撤销操作。

late AppDatabase appDatabase;

Future<AppDatabase> getDatabase() async => appDatabase;

Future<void> initAppDatabase() async {
  appDatabase = await _getDatabase();
}

final migrationList = [
  Migration1to2(),
  Migration2to3(),
  Migration3to4(),
  migration4to5,
  migration5to6,
  migration6to7,
  migration7to8,
  migration8to9,
  migration9to10,
  migration10to11,
  migration11to12,
  migration12to13,
  migration13to14,
  migration14to15,
  migration15to16,
  migration16to17,
  migration17to18,
  migration18to19,
  migration19to20,
  migration20to21,
  migration21to22
];

Future<AppDatabase> _getDatabase() async {
  final dir = await getApplicationSupportDirectory();
  return $FloorAppDatabase
      .databaseBuilder(join(dir.path, 'app_database.db'))
      .addMigrations(migrationList)
      .build();
}
