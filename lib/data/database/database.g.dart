// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  SemesterScheduleDao? _semesterScheduleDaoInstance;

  UserDao? _userDaoInstance;

  AppUserDao? _appUserDaoInstance;

  TermDao? _termDaoInstance;

  SemesterDao? _semesterDaoInstance;

  StudentInfoDao? _studentInfoDaoInstance;

  CampusNetworkUserDao? _campusNetworkUserDaoInstance;

  ExamScoresNewDao? _examScoresNewDaoInstance;

  ExamScheduleDao? _examScheduleDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 22,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `semester_schedule` (`id` TEXT NOT NULL, `username` TEXT NOT NULL, `source` TEXT NOT NULL, `start_datetime` INTEGER, `end_datetime` INTEGER, `start_time` TEXT, `end_time` TEXT, `type` TEXT NOT NULL, `typename` TEXT NOT NULL, `exam_type` TEXT NOT NULL, `college_name` TEXT NOT NULL, `major_name` TEXT NOT NULL, `grade` TEXT NOT NULL, `name` TEXT NOT NULL, `course_no` TEXT NOT NULL, `teachers` TEXT NOT NULL, `term` TEXT NOT NULL, `term_name` TEXT NOT NULL, `capacity` INTEGER NOT NULL, `selected` INTEGER NOT NULL, `credits` REAL NOT NULL, `is_lab` INTEGER NOT NULL, `lab_lesson_id` TEXT NOT NULL, `batch` INTEGER NOT NULL, `comment` TEXT NOT NULL, `experiment` TEXT NOT NULL, `experiment_no` TEXT NOT NULL, `classroom` TEXT NOT NULL, `classroom_alias` TEXT NOT NULL, `start_week` INTEGER NOT NULL, `end_week` INTEGER NOT NULL, `weekday` INTEGER NOT NULL, `section` INTEGER NOT NULL, `create_time` INTEGER NOT NULL, `update_time` INTEGER NOT NULL, PRIMARY KEY (`id`, `username`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `users` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `username` TEXT NOT NULL, `name` TEXT, `new_system_student_id` INTEGER, `password` TEXT NOT NULL, `is_active` INTEGER NOT NULL, `is_only_use_old_system` INTEGER NOT NULL, `teaching_evaluation_token` TEXT, `course_select_token` TEXT, `experiment_system_token` TEXT, `changke_session_id` TEXT, `is_upgraded_undergrad` INTEGER NOT NULL, `is_postgraduate` INTEGER NOT NULL, `create_time` INTEGER NOT NULL, `update_time` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `app_users` (`id` INTEGER NOT NULL, `username` TEXT NOT NULL, `password` TEXT NOT NULL, `is_active` INTEGER NOT NULL, `create_time` INTEGER NOT NULL, `update_time` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `student_info` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `term` TEXT NOT NULL, `grade` TEXT NOT NULL, `college_no` TEXT NOT NULL, `college_name` TEXT NOT NULL, `major_no` TEXT NOT NULL, `major_name` TEXT NOT NULL, `student_id` TEXT NOT NULL, `name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `terms` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `term` TEXT NOT NULL, `start_date` INTEGER NOT NULL, `end_date` INTEGER NOT NULL, `week_num` INTEGER NOT NULL, `term_name` TEXT NOT NULL, `school_year` INTEGER NOT NULL, `comment` TEXT NOT NULL, `system_id` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `campus_network_users` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `username` TEXT NOT NULL, `password` TEXT NOT NULL, `isp` TEXT NOT NULL, `is_default` INTEGER NOT NULL, `create_time` INTEGER NOT NULL, `update_time` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `semesters` (`nameZh` TEXT NOT NULL, `nameEn` TEXT NOT NULL, `id` INTEGER NOT NULL, `code` TEXT NOT NULL, `calendarAssoc` INTEGER NOT NULL, `schoolYear` TEXT NOT NULL, `startDate` INTEGER NOT NULL, `endDate` INTEGER NOT NULL, `weekStartOnSunday` INTEGER NOT NULL, `countInTerm` INTEGER NOT NULL, `season` TEXT NOT NULL, `enabled` INTEGER NOT NULL, `fileInfoAssoc` TEXT, `approvedYear` TEXT NOT NULL, `lessonGenCode` TEXT NOT NULL, `includeMonths` TEXT NOT NULL, `transient` INTEGER NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `exam_scores_new` (`id` INTEGER NOT NULL, `username` TEXT NOT NULL, `semester_id` INTEGER NOT NULL, `semester_name` TEXT NOT NULL, `course_code` TEXT NOT NULL, `course_name` TEXT NOT NULL, `course_name_en` TEXT NOT NULL, `lesson_code` TEXT NOT NULL, `lesson_name` TEXT NOT NULL, `minor_course_code` TEXT, `minor_course_name` TEXT, `minor_course_name_en` TEXT, `credits` REAL NOT NULL, `course_type` TEXT NOT NULL, `course_property` TEXT NOT NULL, `ga_grade` TEXT NOT NULL, `scores` REAL NOT NULL, `grade_grades` TEXT NOT NULL, `credits_course` INTEGER NOT NULL, `passed` INTEGER NOT NULL, `grade_detail` TEXT NOT NULL, `published` INTEGER NOT NULL, `compulsory` INTEGER NOT NULL, `unread` INTEGER NOT NULL, `create_time` INTEGER NOT NULL, `update_time` INTEGER NOT NULL, PRIMARY KEY (`id`, `username`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `exam_schedule` (`id` TEXT NOT NULL, `username` TEXT NOT NULL, `time` TEXT NOT NULL, `start_time` INTEGER, `end_time` INTEGER, `section` INTEGER NOT NULL, `weekday` INTEGER NOT NULL, `week` INTEGER, `campus` TEXT NOT NULL, `building` TEXT NOT NULL, `room` TEXT NOT NULL, `course` TEXT NOT NULL, `tag` TEXT NOT NULL, `status` TEXT NOT NULL, PRIMARY KEY (`id`, `username`))');
        await database.execute(
            'CREATE INDEX `index_semester_schedule_source` ON `semester_schedule` (`source`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_users_username` ON `users` (`username`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_app_users_username` ON `app_users` (`username`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_student_info_student_id` ON `student_info` (`student_id`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_terms_term` ON `terms` (`term`)');
        await database.execute(
            'CREATE UNIQUE INDEX `index_campus_network_users_username` ON `campus_network_users` (`username`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SemesterScheduleDao get semesterScheduleDao {
    return _semesterScheduleDaoInstance ??=
        _$SemesterScheduleDao(database, changeListener);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  AppUserDao get appUserDao {
    return _appUserDaoInstance ??= _$AppUserDao(database, changeListener);
  }

  @override
  TermDao get termDao {
    return _termDaoInstance ??= _$TermDao(database, changeListener);
  }

  @override
  SemesterDao get semesterDao {
    return _semesterDaoInstance ??= _$SemesterDao(database, changeListener);
  }

  @override
  StudentInfoDao get studentInfoDao {
    return _studentInfoDaoInstance ??=
        _$StudentInfoDao(database, changeListener);
  }

  @override
  CampusNetworkUserDao get campusNetworkUserDao {
    return _campusNetworkUserDaoInstance ??=
        _$CampusNetworkUserDao(database, changeListener);
  }

  @override
  ExamScoresNewDao get examScoresNewDao {
    return _examScoresNewDaoInstance ??=
        _$ExamScoresNewDao(database, changeListener);
  }

  @override
  ExamScheduleDao get examScheduleDao {
    return _examScheduleDaoInstance ??=
        _$ExamScheduleDao(database, changeListener);
  }
}

class _$SemesterScheduleDao extends SemesterScheduleDao {
  _$SemesterScheduleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _semesterScheduleInsertionAdapter = InsertionAdapter(
            database,
            'semester_schedule',
            (SemesterSchedule item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'source': item.source,
                  'start_datetime':
                      _dateTimeNullableConverter.encode(item.startDateTime),
                  'end_datetime':
                      _dateTimeNullableConverter.encode(item.endDateTime),
                  'start_time': item.startTime,
                  'end_time': item.endTime,
                  'type': item.type,
                  'typename': item.typename,
                  'exam_type': item.examType,
                  'college_name': item.collegeName,
                  'major_name': item.majorName,
                  'grade': item.grade,
                  'name': item.name,
                  'course_no': item.courseNo,
                  'teachers': item.teachers,
                  'term': item.term,
                  'term_name': item.termName,
                  'capacity': item.capacity,
                  'selected': item.selected,
                  'credits': item.credits,
                  'is_lab': item.isLab ? 1 : 0,
                  'lab_lesson_id': item.labLessonId,
                  'batch': item.batch,
                  'comment': item.comment,
                  'experiment': item.experiment,
                  'experiment_no': item.experimentNo,
                  'classroom': item.classroom,
                  'classroom_alias': item.classroomAlias,
                  'start_week': item.startWeek,
                  'end_week': item.endWeek,
                  'weekday': item.weekday,
                  'section': item.section,
                  'create_time': _dateTimeConverter.encode(item.createTime),
                  'update_time': _dateTimeConverter.encode(item.updateTime)
                }),
        _semesterScheduleDeletionAdapter = DeletionAdapter(
            database,
            'semester_schedule',
            ['id', 'username'],
            (SemesterSchedule item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'source': item.source,
                  'start_datetime':
                      _dateTimeNullableConverter.encode(item.startDateTime),
                  'end_datetime':
                      _dateTimeNullableConverter.encode(item.endDateTime),
                  'start_time': item.startTime,
                  'end_time': item.endTime,
                  'type': item.type,
                  'typename': item.typename,
                  'exam_type': item.examType,
                  'college_name': item.collegeName,
                  'major_name': item.majorName,
                  'grade': item.grade,
                  'name': item.name,
                  'course_no': item.courseNo,
                  'teachers': item.teachers,
                  'term': item.term,
                  'term_name': item.termName,
                  'capacity': item.capacity,
                  'selected': item.selected,
                  'credits': item.credits,
                  'is_lab': item.isLab ? 1 : 0,
                  'lab_lesson_id': item.labLessonId,
                  'batch': item.batch,
                  'comment': item.comment,
                  'experiment': item.experiment,
                  'experiment_no': item.experimentNo,
                  'classroom': item.classroom,
                  'classroom_alias': item.classroomAlias,
                  'start_week': item.startWeek,
                  'end_week': item.endWeek,
                  'weekday': item.weekday,
                  'section': item.section,
                  'create_time': _dateTimeConverter.encode(item.createTime),
                  'update_time': _dateTimeConverter.encode(item.updateTime)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<SemesterSchedule> _semesterScheduleInsertionAdapter;

  final DeletionAdapter<SemesterSchedule> _semesterScheduleDeletionAdapter;

  @override
  Future<List<SemesterSchedule>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM semester_schedule',
        mapper: (Map<String, Object?> row) => SemesterSchedule(
            id: row['id'] as String,
            username: row['username'] as String,
            source: row['source'] as String,
            startDateTime: _dateTimeNullableConverter
                .decode(row['start_datetime'] as int?),
            endDateTime:
                _dateTimeNullableConverter.decode(row['end_datetime'] as int?),
            startTime: row['start_time'] as String?,
            endTime: row['end_time'] as String?,
            type: row['type'] as String,
            typename: row['typename'] as String,
            examType: row['exam_type'] as String,
            collegeName: row['college_name'] as String,
            majorName: row['major_name'] as String,
            grade: row['grade'] as String,
            name: row['name'] as String,
            courseNo: row['course_no'] as String,
            teachers: row['teachers'] as String,
            term: row['term'] as String,
            termName: row['term_name'] as String,
            capacity: row['capacity'] as int,
            selected: row['selected'] as int,
            credits: row['credits'] as double,
            isLab: (row['is_lab'] as int) != 0,
            labLessonId: row['lab_lesson_id'] as String,
            batch: row['batch'] as int,
            startWeek: row['start_week'] as int,
            endWeek: row['end_week'] as int,
            weekday: row['weekday'] as int,
            section: row['section'] as int,
            experiment: row['experiment'] as String,
            experimentNo: row['experiment_no'] as String,
            classroom: row['classroom'] as String,
            classroomAlias: row['classroom_alias'] as String,
            comment: row['comment'] as String,
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?)));
  }

  @override
  Future<List<SemesterSchedule>> getAllByTermAndUsername(
    String term,
    String username,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM semester_schedule WHERE term = ?1 AND username = ?2',
        mapper: (Map<String, Object?> row) => SemesterSchedule(
            id: row['id'] as String,
            username: row['username'] as String,
            source: row['source'] as String,
            startDateTime: _dateTimeNullableConverter
                .decode(row['start_datetime'] as int?),
            endDateTime:
                _dateTimeNullableConverter.decode(row['end_datetime'] as int?),
            startTime: row['start_time'] as String?,
            endTime: row['end_time'] as String?,
            type: row['type'] as String,
            typename: row['typename'] as String,
            examType: row['exam_type'] as String,
            collegeName: row['college_name'] as String,
            majorName: row['major_name'] as String,
            grade: row['grade'] as String,
            name: row['name'] as String,
            courseNo: row['course_no'] as String,
            teachers: row['teachers'] as String,
            term: row['term'] as String,
            termName: row['term_name'] as String,
            capacity: row['capacity'] as int,
            selected: row['selected'] as int,
            credits: row['credits'] as double,
            isLab: (row['is_lab'] as int) != 0,
            labLessonId: row['lab_lesson_id'] as String,
            batch: row['batch'] as int,
            startWeek: row['start_week'] as int,
            endWeek: row['end_week'] as int,
            weekday: row['weekday'] as int,
            section: row['section'] as int,
            experiment: row['experiment'] as String,
            experimentNo: row['experiment_no'] as String,
            classroom: row['classroom'] as String,
            classroomAlias: row['classroom_alias'] as String,
            comment: row['comment'] as String,
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?)),
        arguments: [term, username]);
  }

  @override
  Future<SemesterSchedule?> find(
    String id,
    String username,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM semester_schedule WHERE id = ?1 and username = ?2',
        mapper: (Map<String, Object?> row) => SemesterSchedule(
            id: row['id'] as String,
            username: row['username'] as String,
            source: row['source'] as String,
            startDateTime: _dateTimeNullableConverter
                .decode(row['start_datetime'] as int?),
            endDateTime:
                _dateTimeNullableConverter.decode(row['end_datetime'] as int?),
            startTime: row['start_time'] as String?,
            endTime: row['end_time'] as String?,
            type: row['type'] as String,
            typename: row['typename'] as String,
            examType: row['exam_type'] as String,
            collegeName: row['college_name'] as String,
            majorName: row['major_name'] as String,
            grade: row['grade'] as String,
            name: row['name'] as String,
            courseNo: row['course_no'] as String,
            teachers: row['teachers'] as String,
            term: row['term'] as String,
            termName: row['term_name'] as String,
            capacity: row['capacity'] as int,
            selected: row['selected'] as int,
            credits: row['credits'] as double,
            isLab: (row['is_lab'] as int) != 0,
            labLessonId: row['lab_lesson_id'] as String,
            batch: row['batch'] as int,
            startWeek: row['start_week'] as int,
            endWeek: row['end_week'] as int,
            weekday: row['weekday'] as int,
            section: row['section'] as int,
            experiment: row['experiment'] as String,
            experimentNo: row['experiment_no'] as String,
            classroom: row['classroom'] as String,
            classroomAlias: row['classroom_alias'] as String,
            comment: row['comment'] as String,
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?)),
        arguments: [id, username]);
  }

  @override
  Future<SemesterSchedule?> deleteNotIn(List<String> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.query(
        'DELETE FROM semester_schedule WHERE id NOT IN (' +
            _sqliteVariablesForIds +
            ')',
        mapper: (Map<String, Object?> row) => SemesterSchedule(
            id: row['id'] as String,
            username: row['username'] as String,
            source: row['source'] as String,
            startDateTime: _dateTimeNullableConverter
                .decode(row['start_datetime'] as int?),
            endDateTime:
                _dateTimeNullableConverter.decode(row['end_datetime'] as int?),
            startTime: row['start_time'] as String?,
            endTime: row['end_time'] as String?,
            type: row['type'] as String,
            typename: row['typename'] as String,
            examType: row['exam_type'] as String,
            collegeName: row['college_name'] as String,
            majorName: row['major_name'] as String,
            grade: row['grade'] as String,
            name: row['name'] as String,
            courseNo: row['course_no'] as String,
            teachers: row['teachers'] as String,
            term: row['term'] as String,
            termName: row['term_name'] as String,
            capacity: row['capacity'] as int,
            selected: row['selected'] as int,
            credits: row['credits'] as double,
            isLab: (row['is_lab'] as int) != 0,
            labLessonId: row['lab_lesson_id'] as String,
            batch: row['batch'] as int,
            startWeek: row['start_week'] as int,
            endWeek: row['end_week'] as int,
            weekday: row['weekday'] as int,
            section: row['section'] as int,
            experiment: row['experiment'] as String,
            experimentNo: row['experiment_no'] as String,
            classroom: row['classroom'] as String,
            classroomAlias: row['classroom_alias'] as String,
            comment: row['comment'] as String,
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?)),
        arguments: [...ids]);
  }

  @override
  Future<void> deleteByUsernameAndSourceAndTerm(
    String username,
    List<String> excludeSources,
    String term,
  ) async {
    const offset = 3;
    final _sqliteVariablesForExcludeSources = Iterable<String>.generate(
        excludeSources.length, (i) => '?${i + offset}').join(',');
    await _queryAdapter.queryNoReturn(
        'DELETE FROM semester_schedule WHERE username = ?1 AND source NOT IN (' +
            _sqliteVariablesForExcludeSources +
            ') AND term = ?2',
        arguments: [username, term, ...excludeSources]);
  }

  @override
  Future<void> insertOrUpdateSemesterSchedule(
      SemesterSchedule semesterSchedule) async {
    await _semesterScheduleInsertionAdapter.insert(
        semesterSchedule, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertOrUpdateSemesterSchedules(
      List<SemesterSchedule> semesterSchedules) async {
    await _semesterScheduleInsertionAdapter.insertList(
        semesterSchedules, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteData(SemesterSchedule data) async {
    await _semesterScheduleDeletionAdapter.delete(data);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'users',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'name': item.name,
                  'new_system_student_id': item.newSystemStudentId,
                  'password': item.password,
                  'is_active': item.isActive ? 1 : 0,
                  'is_only_use_old_system': item.isOnlyUseOldSystem ? 1 : 0,
                  'teaching_evaluation_token': item.teachingEvaluationToken,
                  'course_select_token': item.courseSelectToken,
                  'experiment_system_token': item.experimentSystemToken,
                  'changke_session_id': item.changkeSessionId,
                  'is_upgraded_undergrad': item.isUpgradedUndergrad ? 1 : 0,
                  'is_postgraduate': item.isPostgraduate ? 1 : 0,
                  'create_time': _dateTimeConverter.encode(item.createTime),
                  'update_time': _dateTimeConverter.encode(item.updateTime)
                },
            changeListener),
        _userDeletionAdapter = DeletionAdapter(
            database,
            'users',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'name': item.name,
                  'new_system_student_id': item.newSystemStudentId,
                  'password': item.password,
                  'is_active': item.isActive ? 1 : 0,
                  'is_only_use_old_system': item.isOnlyUseOldSystem ? 1 : 0,
                  'teaching_evaluation_token': item.teachingEvaluationToken,
                  'course_select_token': item.courseSelectToken,
                  'experiment_system_token': item.experimentSystemToken,
                  'changke_session_id': item.changkeSessionId,
                  'is_upgraded_undergrad': item.isUpgradedUndergrad ? 1 : 0,
                  'is_postgraduate': item.isPostgraduate ? 1 : 0,
                  'create_time': _dateTimeConverter.encode(item.createTime),
                  'update_time': _dateTimeConverter.encode(item.updateTime)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final DeletionAdapter<User> _userDeletionAdapter;

  @override
  Stream<User?> getActiveStream() {
    return _queryAdapter.queryStream(
        'SELECT * FROM users WHERE is_active = 1 LIMIT 1',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int?,
            name: row['name'] as String?,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0,
            isOnlyUseOldSystem: (row['is_only_use_old_system'] as int) != 0,
            teachingEvaluationToken:
                row['teaching_evaluation_token'] as String?,
            newSystemStudentId: row['new_system_student_id'] as int?,
            courseSelectToken: row['course_select_token'] as String?,
            experimentSystemToken: row['experiment_system_token'] as String?,
            isUpgradedUndergrad: (row['is_upgraded_undergrad'] as int) != 0,
            isPostgraduate: (row['is_postgraduate'] as int) != 0),
        queryableName: 'users',
        isView: false);
  }

  @override
  Future<User?> getActive() async {
    return _queryAdapter.query(
        'SELECT * FROM users WHERE is_active = 1 LIMIT 1',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int?,
            name: row['name'] as String?,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0,
            isOnlyUseOldSystem: (row['is_only_use_old_system'] as int) != 0,
            teachingEvaluationToken:
                row['teaching_evaluation_token'] as String?,
            newSystemStudentId: row['new_system_student_id'] as int?,
            courseSelectToken: row['course_select_token'] as String?,
            experimentSystemToken: row['experiment_system_token'] as String?,
            isUpgradedUndergrad: (row['is_upgraded_undergrad'] as int) != 0,
            isPostgraduate: (row['is_postgraduate'] as int) != 0));
  }

  @override
  Future<User?> get(String username) async {
    return _queryAdapter.query(
        'SELECT * FROM users WHERE username = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int?,
            name: row['name'] as String?,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0,
            isOnlyUseOldSystem: (row['is_only_use_old_system'] as int) != 0,
            teachingEvaluationToken:
                row['teaching_evaluation_token'] as String?,
            newSystemStudentId: row['new_system_student_id'] as int?,
            courseSelectToken: row['course_select_token'] as String?,
            experimentSystemToken: row['experiment_system_token'] as String?,
            isUpgradedUndergrad: (row['is_upgraded_undergrad'] as int) != 0,
            isPostgraduate: (row['is_postgraduate'] as int) != 0),
        arguments: [username]);
  }

  @override
  Future<List<User>> getRecent() async {
    return _queryAdapter.queryList(
        'SELECT * FROM users ORDER BY update_time DESC LIMIT 5',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int?,
            name: row['name'] as String?,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0,
            isOnlyUseOldSystem: (row['is_only_use_old_system'] as int) != 0,
            teachingEvaluationToken:
                row['teaching_evaluation_token'] as String?,
            newSystemStudentId: row['new_system_student_id'] as int?,
            courseSelectToken: row['course_select_token'] as String?,
            experimentSystemToken: row['experiment_system_token'] as String?,
            isUpgradedUndergrad: (row['is_upgraded_undergrad'] as int) != 0,
            isPostgraduate: (row['is_postgraduate'] as int) != 0));
  }

  @override
  Future<List<User>> searchUsers(String keyword) async {
    return _queryAdapter.queryList('SELECT * FROM users WHERE username LIKE ?1',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int?,
            name: row['name'] as String?,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0,
            isOnlyUseOldSystem: (row['is_only_use_old_system'] as int) != 0,
            teachingEvaluationToken:
                row['teaching_evaluation_token'] as String?,
            newSystemStudentId: row['new_system_student_id'] as int?,
            courseSelectToken: row['course_select_token'] as String?,
            experimentSystemToken: row['experiment_system_token'] as String?,
            isUpgradedUndergrad: (row['is_upgraded_undergrad'] as int) != 0,
            isPostgraduate: (row['is_postgraduate'] as int) != 0),
        arguments: [keyword]);
  }

  @override
  Future<List<User>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM users',
        mapper: (Map<String, Object?> row) => User(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int?,
            name: row['name'] as String?,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0,
            isOnlyUseOldSystem: (row['is_only_use_old_system'] as int) != 0,
            teachingEvaluationToken:
                row['teaching_evaluation_token'] as String?,
            newSystemStudentId: row['new_system_student_id'] as int?,
            courseSelectToken: row['course_select_token'] as String?,
            experimentSystemToken: row['experiment_system_token'] as String?,
            isUpgradedUndergrad: (row['is_upgraded_undergrad'] as int) != 0,
            isPostgraduate: (row['is_postgraduate'] as int) != 0));
  }

  @override
  Future<List<User>> getUsersPaginated(
    int limit,
    int offset,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM users ORDER BY is_active DESC, update_time DESC LIMIT ?1 OFFSET ?2',
        mapper: (Map<String, Object?> row) => User(updateTime: _dateTimeConverter.decode(row['update_time'] as int), createTime: _dateTimeNullableConverter.decode(row['create_time'] as int?), id: row['id'] as int?, name: row['name'] as String?, username: row['username'] as String, password: row['password'] as String, isActive: (row['is_active'] as int) != 0, isOnlyUseOldSystem: (row['is_only_use_old_system'] as int) != 0, teachingEvaluationToken: row['teaching_evaluation_token'] as String?, newSystemStudentId: row['new_system_student_id'] as int?, courseSelectToken: row['course_select_token'] as String?, experimentSystemToken: row['experiment_system_token'] as String?, isUpgradedUndergrad: (row['is_upgraded_undergrad'] as int) != 0, isPostgraduate: (row['is_postgraduate'] as int) != 0),
        arguments: [limit, offset]);
  }

  @override
  Future<void> offlineOtherUser(String username) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE users SET is_active = 0 WHERE username <> ?1',
        arguments: [username]);
  }

  @override
  Future<void> updateName(
    String username,
    String name,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE users SET name = ?2 WHERE username = ?1',
        arguments: [username, name]);
  }

  @override
  Future<void> insertOrUpdateUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteUser(User user) async {
    await _userDeletionAdapter.delete(user);
  }
}

class _$AppUserDao extends AppUserDao {
  _$AppUserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _appUserInsertionAdapter = InsertionAdapter(
            database,
            'app_users',
            (AppUser item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'password': item.password,
                  'is_active': item.isActive ? 1 : 0,
                  'create_time': _dateTimeConverter.encode(item.createTime),
                  'update_time': _dateTimeConverter.encode(item.updateTime)
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AppUser> _appUserInsertionAdapter;

  @override
  Future<AppUser?> getActive() async {
    return _queryAdapter.query(
        'SELECT * FROM app_users WHERE is_active = 1 LIMIT 1',
        mapper: (Map<String, Object?> row) => AppUser(
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0));
  }

  @override
  Stream<AppUser?> getActiveStream() {
    return _queryAdapter.queryStream(
        'SELECT * FROM app_users WHERE is_active = 1 LIMIT 1',
        mapper: (Map<String, Object?> row) => AppUser(
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0),
        queryableName: 'app_users',
        isView: false);
  }

  @override
  Future<AppUser?> get(String username) async {
    return _queryAdapter.query(
        'SELECT * FROM app_users WHERE username = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => AppUser(
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0),
        arguments: [username]);
  }

  @override
  Future<List<AppUser>> getRecent() async {
    return _queryAdapter.queryList(
        'SELECT * FROM app_users ORDER BY update_time DESC LIMIT 5',
        mapper: (Map<String, Object?> row) => AppUser(
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0));
  }

  @override
  Stream<List<AppUser>> getRecentStream() {
    return _queryAdapter.queryListStream(
        'SELECT * FROM app_users ORDER BY update_time DESC LIMIT 5',
        mapper: (Map<String, Object?> row) => AppUser(
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0),
        queryableName: 'app_users',
        isView: false);
  }

  @override
  Future<List<AppUser>> searchAppUsers(String keyword) async {
    return _queryAdapter.queryList(
        'SELECT * FROM app_users WHERE username LIKE ?1',
        mapper: (Map<String, Object?> row) => AppUser(
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0),
        arguments: [keyword]);
  }

  @override
  Future<List<AppUser>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM app_users',
        mapper: (Map<String, Object?> row) => AppUser(
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            id: row['id'] as int,
            username: row['username'] as String,
            password: row['password'] as String,
            isActive: (row['is_active'] as int) != 0));
  }

  @override
  Future<void> offlineCurrent() async {
    await _queryAdapter.queryNoReturn(
        'UPDATE app_users SET is_active = 0 WHERE is_active = 1');
  }

  @override
  Future<void> offlineOtherUser(String username) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE app_users SET is_active = 0 WHERE username <> ?1',
        arguments: [username]);
  }

  @override
  Future<void> insertUser(AppUser user) async {
    await _appUserInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await _appUserInsertionAdapter.insert(user, OnConflictStrategy.replace);
  }
}

class _$TermDao extends TermDao {
  _$TermDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _termInsertionAdapter = InsertionAdapter(
            database,
            'terms',
            (Term item) => <String, Object?>{
                  'id': item.id,
                  'term': item.term,
                  'start_date': _dateTimeConverter.encode(item.startDate),
                  'end_date': _dateTimeConverter.encode(item.endDate),
                  'week_num': item.weekNum,
                  'term_name': item.termName,
                  'school_year': item.schoolYear,
                  'comment': item.comment,
                  'system_id': item.systemId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Term> _termInsertionAdapter;

  @override
  Future<List<Term>> getAll(int systemId) async {
    return _queryAdapter.queryList('SELECT * FROM terms WHERE system_id = ?1',
        mapper: (Map<String, Object?> row) => Term(
            term: row['term'] as String,
            startDate: _dateTimeConverter.decode(row['start_date'] as int),
            endDate: _dateTimeConverter.decode(row['end_date'] as int),
            weekNum: row['week_num'] as int,
            termName: row['term_name'] as String,
            schoolYear: row['school_year'] as int,
            comment: row['comment'] as String,
            systemId: row['system_id'] as int),
        arguments: [systemId]);
  }

  @override
  Future<void> insert(Term term) async {
    await _termInsertionAdapter.insert(term, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertAll(List<Term> terms) async {
    await _termInsertionAdapter.insertList(terms, OnConflictStrategy.replace);
  }

  @override
  Future<void> update(Term term) async {
    await _termInsertionAdapter.insert(term, OnConflictStrategy.replace);
  }
}

class _$SemesterDao extends SemesterDao {
  _$SemesterDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _semesterInsertionAdapter = InsertionAdapter(
            database,
            'semesters',
            (Semester item) => <String, Object?>{
                  'nameZh': item.nameZh,
                  'nameEn': item.nameEn,
                  'id': item.id,
                  'code': item.code,
                  'calendarAssoc': item.calendarAssoc,
                  'schoolYear': item.schoolYear,
                  'startDate': _dateTimeConverter.encode(item.startDate),
                  'endDate': _dateTimeConverter.encode(item.endDate),
                  'weekStartOnSunday': item.weekStartOnSunday ? 1 : 0,
                  'countInTerm': item.countInTerm ? 1 : 0,
                  'season': item.season,
                  'enabled': item.enabled ? 1 : 0,
                  'fileInfoAssoc': item.fileInfoAssoc,
                  'approvedYear': item.approvedYear,
                  'lessonGenCode': item.lessonGenCode,
                  'includeMonths': _listIntConverter.encode(item.includeMonths),
                  'transient': item.transient ? 1 : 0,
                  'name': item.name
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Semester> _semesterInsertionAdapter;

  @override
  Future<List<Semester>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM semesters',
        mapper: (Map<String, Object?> row) => Semester(
            nameZh: row['nameZh'] as String,
            nameEn: row['nameEn'] as String,
            id: row['id'] as int,
            code: row['code'] as String,
            calendarAssoc: row['calendarAssoc'] as int,
            schoolYear: row['schoolYear'] as String,
            startDate: _dateTimeConverter.decode(row['startDate'] as int),
            endDate: _dateTimeConverter.decode(row['endDate'] as int),
            weekStartOnSunday: (row['weekStartOnSunday'] as int) != 0,
            countInTerm: (row['countInTerm'] as int) != 0,
            season: row['season'] as String,
            enabled: (row['enabled'] as int) != 0,
            fileInfoAssoc: row['fileInfoAssoc'] as String?,
            approvedYear: row['approvedYear'] as String,
            lessonGenCode: row['lessonGenCode'] as String,
            includeMonths:
                _listIntConverter.decode(row['includeMonths'] as String),
            transient: (row['transient'] as int) != 0,
            name: row['name'] as String));
  }

  @override
  Future<void> insert(Semester term) async {
    await _semesterInsertionAdapter.insert(term, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertAll(List<Semester> terms) async {
    await _semesterInsertionAdapter.insertList(
        terms, OnConflictStrategy.replace);
  }

  @override
  Future<void> update(Semester term) async {
    await _semesterInsertionAdapter.insert(term, OnConflictStrategy.replace);
  }
}

class _$StudentInfoDao extends StudentInfoDao {
  _$StudentInfoDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _studentInfoInsertionAdapter = InsertionAdapter(
            database,
            'student_info',
            (StudentInfo item) => <String, Object?>{
                  'id': item.id,
                  'term': item.term,
                  'grade': item.grade,
                  'college_no': item.collegeNo,
                  'college_name': item.collegeName,
                  'major_no': item.majorNo,
                  'major_name': item.majorName,
                  'student_id': item.studentId,
                  'name': item.name
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<StudentInfo> _studentInfoInsertionAdapter;

  @override
  Future<StudentInfo?> get(String username) async {
    return _queryAdapter.query(
        'SELECT * FROM student_info WHERE student_id = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => StudentInfo(
            term: row['term'] as String,
            grade: row['grade'] as String,
            collegeNo: row['college_no'] as String,
            collegeName: row['college_name'] as String,
            majorNo: row['major_no'] as String,
            majorName: row['major_name'] as String,
            studentId: row['student_id'] as String,
            name: row['name'] as String),
        arguments: [username]);
  }

  @override
  Future<List<StudentInfo>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM student_info',
        mapper: (Map<String, Object?> row) => StudentInfo(
            term: row['term'] as String,
            grade: row['grade'] as String,
            collegeNo: row['college_no'] as String,
            collegeName: row['college_name'] as String,
            majorNo: row['major_no'] as String,
            majorName: row['major_name'] as String,
            studentId: row['student_id'] as String,
            name: row['name'] as String));
  }

  @override
  Future<void> insertOrUpdate(StudentInfo info) async {
    await _studentInfoInsertionAdapter.insert(info, OnConflictStrategy.replace);
  }

  @override
  Future<void> update(StudentInfo info) async {
    await _studentInfoInsertionAdapter.insert(info, OnConflictStrategy.replace);
  }
}

class _$CampusNetworkUserDao extends CampusNetworkUserDao {
  _$CampusNetworkUserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _campusNetworkUserInsertionAdapter = InsertionAdapter(
            database,
            'campus_network_users',
            (CampusNetworkUser item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'password': item.password,
                  'isp': item.isp,
                  'is_default': item.isDefault ? 1 : 0,
                  'create_time': _dateTimeConverter.encode(item.createTime),
                  'update_time': _dateTimeConverter.encode(item.updateTime)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CampusNetworkUser> _campusNetworkUserInsertionAdapter;

  @override
  Future<CampusNetworkUser?> getActive() async {
    return _queryAdapter.query(
        'SELECT * FROM campus_network_users WHERE is_default = 1 LIMIT 1',
        mapper: (Map<String, Object?> row) => CampusNetworkUser(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isDefault: (row['is_default'] as int) != 0,
            isp: row['isp'] as String));
  }

  @override
  Future<CampusNetworkUser?> get(String username) async {
    return _queryAdapter.query(
        'SELECT * FROM campus_network_users WHERE username = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => CampusNetworkUser(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isDefault: (row['is_default'] as int) != 0,
            isp: row['isp'] as String),
        arguments: [username]);
  }

  @override
  Future<List<CampusNetworkUser>> getRecent() async {
    return _queryAdapter.queryList(
        'SELECT * FROM campus_network_users ORDER BY update_time DESC LIMIT 5',
        mapper: (Map<String, Object?> row) => CampusNetworkUser(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isDefault: (row['is_default'] as int) != 0,
            isp: row['isp'] as String));
  }

  @override
  Future<List<CampusNetworkUser>> searchUsers(String keyword) async {
    return _queryAdapter.queryList(
        'SELECT * FROM campus_network_users WHERE username LIKE ?1',
        mapper: (Map<String, Object?> row) => CampusNetworkUser(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isDefault: (row['is_default'] as int) != 0,
            isp: row['isp'] as String),
        arguments: [keyword]);
  }

  @override
  Future<List<CampusNetworkUser>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM campus_network_users',
        mapper: (Map<String, Object?> row) => CampusNetworkUser(
            updateTime: _dateTimeConverter.decode(row['update_time'] as int),
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            username: row['username'] as String,
            password: row['password'] as String,
            isDefault: (row['is_default'] as int) != 0,
            isp: row['isp'] as String));
  }

  @override
  Future<void> unsetDefaultOtherUser(String username) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE campus_network_users SET is_default = 0 WHERE username <> ?1',
        arguments: [username]);
  }

  @override
  Future<void> insertUser(CampusNetworkUser user) async {
    await _campusNetworkUserInsertionAdapter.insert(
        user, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateUser(CampusNetworkUser user) async {
    await _campusNetworkUserInsertionAdapter.insert(
        user, OnConflictStrategy.replace);
  }
}

class _$ExamScoresNewDao extends ExamScoresNewDao {
  _$ExamScoresNewDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _examScoresNewInsertionAdapter = InsertionAdapter(
            database,
            'exam_scores_new',
            (ExamScoresNew item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'semester_id': item.semesterId,
                  'semester_name': item.semesterName,
                  'course_code': item.courseCode,
                  'course_name': item.courseName,
                  'course_name_en': item.courseNameEn,
                  'lesson_code': item.lessonCode,
                  'lesson_name': item.lessonName,
                  'minor_course_code': item.minorCourseCode,
                  'minor_course_name': item.minorCourseName,
                  'minor_course_name_en': item.minorCourseNameEn,
                  'credits': item.credits,
                  'course_type': item.courseType,
                  'course_property': item.courseProperty,
                  'ga_grade': item.gaGrade,
                  'scores': item.scores,
                  'grade_grades': item.gradeGrades,
                  'credits_course': item.creditsCourse ? 1 : 0,
                  'passed': item.passed ? 1 : 0,
                  'grade_detail': item.gradeDetail,
                  'published': item.published ? 1 : 0,
                  'compulsory': item.compulsory ? 1 : 0,
                  'unread': item.unread ? 1 : 0,
                  'create_time': _dateTimeConverter.encode(item.createTime),
                  'update_time': _dateTimeConverter.encode(item.updateTime)
                }),
        _examScoresNewDeletionAdapter = DeletionAdapter(
            database,
            'exam_scores_new',
            ['id', 'username'],
            (ExamScoresNew item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'semester_id': item.semesterId,
                  'semester_name': item.semesterName,
                  'course_code': item.courseCode,
                  'course_name': item.courseName,
                  'course_name_en': item.courseNameEn,
                  'lesson_code': item.lessonCode,
                  'lesson_name': item.lessonName,
                  'minor_course_code': item.minorCourseCode,
                  'minor_course_name': item.minorCourseName,
                  'minor_course_name_en': item.minorCourseNameEn,
                  'credits': item.credits,
                  'course_type': item.courseType,
                  'course_property': item.courseProperty,
                  'ga_grade': item.gaGrade,
                  'scores': item.scores,
                  'grade_grades': item.gradeGrades,
                  'credits_course': item.creditsCourse ? 1 : 0,
                  'passed': item.passed ? 1 : 0,
                  'grade_detail': item.gradeDetail,
                  'published': item.published ? 1 : 0,
                  'compulsory': item.compulsory ? 1 : 0,
                  'unread': item.unread ? 1 : 0,
                  'create_time': _dateTimeConverter.encode(item.createTime),
                  'update_time': _dateTimeConverter.encode(item.updateTime)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ExamScoresNew> _examScoresNewInsertionAdapter;

  final DeletionAdapter<ExamScoresNew> _examScoresNewDeletionAdapter;

  @override
  Future<List<ExamScoresNew>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM exam_scores_new',
        mapper: (Map<String, Object?> row) => ExamScoresNew(
            id: row['id'] as int,
            username: row['username'] as String,
            semesterId: row['semester_id'] as int,
            semesterName: row['semester_name'] as String,
            courseCode: row['course_code'] as String,
            courseName: row['course_name'] as String,
            courseNameEn: row['course_name_en'] as String,
            lessonCode: row['lesson_code'] as String,
            lessonName: row['lesson_name'] as String,
            minorCourseCode: row['minor_course_code'] as String?,
            minorCourseName: row['minor_course_name'] as String?,
            minorCourseNameEn: row['minor_course_name_en'] as String?,
            credits: row['credits'] as double,
            courseType: row['course_type'] as String,
            courseProperty: row['course_property'] as String,
            gaGrade: row['ga_grade'] as String,
            passed: (row['passed'] as int) != 0,
            gradeDetail: row['grade_detail'] as String,
            published: (row['published'] as int) != 0,
            compulsory: (row['compulsory'] as int) != 0,
            unread: (row['unread'] as int) != 0,
            scores: row['scores'] as double,
            gradeGrades: row['grade_grades'] as String,
            creditsCourse: (row['credits_course'] as int) != 0,
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?)));
  }

  @override
  Future<List<ExamScoresNew>> getAllByUsername(String username) async {
    return _queryAdapter.queryList(
        'SELECT * FROM exam_scores_new WHERE username = ?1',
        mapper: (Map<String, Object?> row) => ExamScoresNew(
            id: row['id'] as int,
            username: row['username'] as String,
            semesterId: row['semester_id'] as int,
            semesterName: row['semester_name'] as String,
            courseCode: row['course_code'] as String,
            courseName: row['course_name'] as String,
            courseNameEn: row['course_name_en'] as String,
            lessonCode: row['lesson_code'] as String,
            lessonName: row['lesson_name'] as String,
            minorCourseCode: row['minor_course_code'] as String?,
            minorCourseName: row['minor_course_name'] as String?,
            minorCourseNameEn: row['minor_course_name_en'] as String?,
            credits: row['credits'] as double,
            courseType: row['course_type'] as String,
            courseProperty: row['course_property'] as String,
            gaGrade: row['ga_grade'] as String,
            passed: (row['passed'] as int) != 0,
            gradeDetail: row['grade_detail'] as String,
            published: (row['published'] as int) != 0,
            compulsory: (row['compulsory'] as int) != 0,
            unread: (row['unread'] as int) != 0,
            scores: row['scores'] as double,
            gradeGrades: row['grade_grades'] as String,
            creditsCourse: (row['credits_course'] as int) != 0,
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?)),
        arguments: [username]);
  }

  @override
  Future<ExamScoresNew?> find(
    String id,
    String username,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM exam_scores_new WHERE id = ?1 and username = ?2',
        mapper: (Map<String, Object?> row) => ExamScoresNew(
            id: row['id'] as int,
            username: row['username'] as String,
            semesterId: row['semester_id'] as int,
            semesterName: row['semester_name'] as String,
            courseCode: row['course_code'] as String,
            courseName: row['course_name'] as String,
            courseNameEn: row['course_name_en'] as String,
            lessonCode: row['lesson_code'] as String,
            lessonName: row['lesson_name'] as String,
            minorCourseCode: row['minor_course_code'] as String?,
            minorCourseName: row['minor_course_name'] as String?,
            minorCourseNameEn: row['minor_course_name_en'] as String?,
            credits: row['credits'] as double,
            courseType: row['course_type'] as String,
            courseProperty: row['course_property'] as String,
            gaGrade: row['ga_grade'] as String,
            passed: (row['passed'] as int) != 0,
            gradeDetail: row['grade_detail'] as String,
            published: (row['published'] as int) != 0,
            compulsory: (row['compulsory'] as int) != 0,
            unread: (row['unread'] as int) != 0,
            scores: row['scores'] as double,
            gradeGrades: row['grade_grades'] as String,
            creditsCourse: (row['credits_course'] as int) != 0,
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?)),
        arguments: [id, username]);
  }

  @override
  Future<ExamScoresNew?> deleteNotIn(List<String> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.query(
        'DELETE FROM exam_scores_new WHERE id NOT IN (' +
            _sqliteVariablesForIds +
            ')',
        mapper: (Map<String, Object?> row) => ExamScoresNew(
            id: row['id'] as int,
            username: row['username'] as String,
            semesterId: row['semester_id'] as int,
            semesterName: row['semester_name'] as String,
            courseCode: row['course_code'] as String,
            courseName: row['course_name'] as String,
            courseNameEn: row['course_name_en'] as String,
            lessonCode: row['lesson_code'] as String,
            lessonName: row['lesson_name'] as String,
            minorCourseCode: row['minor_course_code'] as String?,
            minorCourseName: row['minor_course_name'] as String?,
            minorCourseNameEn: row['minor_course_name_en'] as String?,
            credits: row['credits'] as double,
            courseType: row['course_type'] as String,
            courseProperty: row['course_property'] as String,
            gaGrade: row['ga_grade'] as String,
            passed: (row['passed'] as int) != 0,
            gradeDetail: row['grade_detail'] as String,
            published: (row['published'] as int) != 0,
            compulsory: (row['compulsory'] as int) != 0,
            unread: (row['unread'] as int) != 0,
            scores: row['scores'] as double,
            gradeGrades: row['grade_grades'] as String,
            creditsCourse: (row['credits_course'] as int) != 0,
            createTime:
                _dateTimeNullableConverter.decode(row['create_time'] as int?),
            updateTime:
                _dateTimeNullableConverter.decode(row['update_time'] as int?)),
        arguments: [...ids]);
  }

  @override
  Future<void> deleteByUsernameAndSourceAndTerm(
    String username,
    bool is_manually_add,
    String term,
  ) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM exam_scores_new WHERE username = ?1 AND is_manually_add = ?2 AND term = ?3',
        arguments: [username, is_manually_add ? 1 : 0, term]);
  }

  @override
  Future<void> insertOrUpdateExamScoresNew(ExamScoresNew ExamScoresNew) async {
    await _examScoresNewInsertionAdapter.insert(
        ExamScoresNew, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertOrUpdateExamScoresNews(
      List<ExamScoresNew> ExamScoresNews) async {
    await _examScoresNewInsertionAdapter.insertList(
        ExamScoresNews, OnConflictStrategy.replace);
  }

  @override
  Future<void> deleteAll(List<ExamScoresNew> ExamScoresNews) async {
    await _examScoresNewDeletionAdapter.deleteList(ExamScoresNews);
  }
}

class _$ExamScheduleDao extends ExamScheduleDao {
  _$ExamScheduleDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _examScheduleInsertionAdapter = InsertionAdapter(
            database,
            'exam_schedule',
            (ExamSchedule item) => <String, Object?>{
                  'id': item.id,
                  'username': item.username,
                  'time': item.time,
                  'start_time':
                      _dateTimeNullableConverter.encode(item.startTime),
                  'end_time': _dateTimeNullableConverter.encode(item.endTime),
                  'section': item.section,
                  'weekday': item.weekday,
                  'week': item.week,
                  'campus': item.campus,
                  'building': item.building,
                  'room': item.room,
                  'course': item.course,
                  'tag': item.tag,
                  'status': item.status
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ExamSchedule> _examScheduleInsertionAdapter;

  @override
  Future<List<ExamSchedule>> getAllByUsername(String username) async {
    return _queryAdapter.queryList(
        'SELECT * FROM exam_schedule WHERE username = ?1',
        mapper: (Map<String, Object?> row) => ExamSchedule(
            id: row['id'] as String,
            username: row['username'] as String,
            time: row['time'] as String,
            startTime:
                _dateTimeNullableConverter.decode(row['start_time'] as int?),
            endTime: _dateTimeNullableConverter.decode(row['end_time'] as int?),
            campus: row['campus'] as String,
            building: row['building'] as String,
            room: row['room'] as String,
            course: row['course'] as String,
            tag: row['tag'] as String,
            status: row['status'] as String,
            section: row['section'] as int,
            weekday: row['weekday'] as int,
            week: row['week'] as int?),
        arguments: [username]);
  }

  @override
  Future<void> deleteByUsername(String username) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM exam_schedule WHERE username = ?1',
        arguments: [username]);
  }

  @override
  Future<void> insertOrUpdate(ExamSchedule ExamScoresNew) async {
    await _examScheduleInsertionAdapter.insert(
        ExamScoresNew, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertOrUpdateAll(List<ExamSchedule> ExamScoresNews) async {
    await _examScheduleInsertionAdapter.insertList(
        ExamScoresNews, OnConflictStrategy.replace);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _dateTimeNullableConverter = DateTimeNullableConverter();
final _listIntConverter = ListIntConverter();
