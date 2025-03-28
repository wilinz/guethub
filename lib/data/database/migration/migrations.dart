import 'package:floor/floor.dart';

final migration5to6 = Migration(5, 6, (database) async {
  await database.execute(
      'CREATE TABLE IF NOT EXISTS `app_users` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `username` TEXT NOT NULL, `password` TEXT NOT NULL, `is_active` INTEGER NOT NULL, `create_time` INTEGER NOT NULL, `update_time` INTEGER NOT NULL)');
  await database.execute(
      'CREATE UNIQUE INDEX `index_app_users_username` ON `app_users` (`username`)');
});

//------------------------------------------------------

final migration6to7 = Migration(6, 7, (database) async {
  // Step 1: 创建一个临时表，结构与最终表一致
  await database.execute('''
    CREATE TABLE IF NOT EXISTS app_users_temp (
      id INTEGER NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      is_active INTEGER NOT NULL,
      create_time INTEGER NOT NULL,
      update_time INTEGER NOT NULL,
      PRIMARY KEY (id)
    )
  ''');

  // Step 2: 将旧表中的数据复制到新表中
  await database.execute('''
    INSERT INTO app_users_temp (id, username, password, is_active, create_time, update_time)
    SELECT id, username, password, is_active, create_time, update_time FROM app_users
  ''');

  // Step 3: 删除旧表
  await database.execute('DROP TABLE app_users');

  // Step 4: 将临时表重命名为旧表名称
  await database.execute('ALTER TABLE app_users_temp RENAME TO app_users');
});

//---------------------------------------------------------

final migration7to8 = Migration(7, 8, (database) async {
  await database.execute(
      'ALTER TABLE `users` ADD COLUMN `is_only_use_old_system` INTEGER NOT NULL DEFAULT 0');
});

final migration8to9 = Migration(8, 9, (database) async {
  await database.execute(
      "ALTER TABLE `users` ADD COLUMN `teaching_evaluation_token` TEXT DEFAULT NULL ");
});

final migration9to10 = Migration(9, 10, (database) async {
  await database.execute(
      "ALTER TABLE `users` ADD COLUMN `new_system_student_id` INTEGER DEFAULT NULL ");
});

final migration10to11 = Migration(10, 11, (database) async {
  await database.execute(
      "ALTER TABLE `users` ADD COLUMN `course_select_token` TEXT DEFAULT NULL ");
});

final migration11to12 = Migration(11, 12, (database) async {
  await database.execute(
      'ALTER TABLE `users` ADD COLUMN `is_upgraded_undergrad` INTEGER NOT NULL DEFAULT 0');
  await database.execute(
      'ALTER TABLE `users` ADD COLUMN `is_postgraduate` INTEGER NOT NULL DEFAULT 0');
});

final migration12to13 = Migration(12, 13, (database) async {
  await database.execute(
      "ALTER TABLE `terms` ADD COLUMN `system_id` INTEGER NOT NULL DEFAULT 0");
});

final migration13to14 = Migration(13, 14, (database) async {
  // 1. 删除重复的 term 数据，保留每组重复项中的第一条记录
  await database.execute('''
    DELETE FROM terms
    WHERE rowid NOT IN (
      SELECT MIN(rowid)
      FROM terms
      GROUP BY term
    );
  ''');
  await database
      .execute('CREATE UNIQUE INDEX `index_terms_term` ON `terms` (`term`)');
});

final migration14to15 = Migration(14, 15, (database) async {
  await database.execute("ALTER TABLE `users` ADD COLUMN `name` TEXT DEFAULT NULL");
  await database.execute(
      """
UPDATE users 
SET name = (SELECT student_info.name 
            FROM student_info 
            WHERE student_info.student_id = users.username)
WHERE username IN (SELECT student_info.student_id 
                   FROM student_info);
      """);
});

final migration15to16 = Migration(15, 16, (database) async {
  await database.execute(
      'CREATE TABLE IF NOT EXISTS `exam_schedule` (`id` TEXT NOT NULL, `username` TEXT NOT NULL, `time` TEXT NOT NULL, `start_time` INTEGER, `end_time` INTEGER, `section` INTEGER NOT NULL, `weekday` INTEGER NOT NULL, `week` INTEGER, `campus` TEXT NOT NULL, `building` TEXT NOT NULL, `room` TEXT NOT NULL, `course` TEXT NOT NULL, `tag` TEXT NOT NULL, `status` TEXT NOT NULL, PRIMARY KEY (`id`, `username`))');
});

final migration16to17 = Migration(16, 17, (database) async {
  await database.execute(
      'ALTER TABLE `semester_schedule` ADD COLUMN `start_time` INTEGER');
  await database.execute(
      'ALTER TABLE `semester_schedule` ADD COLUMN `end_time` INTEGER');
});

final migration17to18 = Migration(17, 18, (database) async {
  // Step 1: 创建新表，使用合并后的表结构
  await database.execute('''
    CREATE TABLE semester_schedule_new (
      id TEXT NOT NULL,
      username TEXT NOT NULL,
      source TEXT NOT NULL,
      start_datetime INTEGER,          -- 原 start_time 改为 start_datetime
      end_datetime INTEGER,            -- 原 end_time 改为 end_datetime
      start_time TEXT,                 -- 新增 start_time
      end_time TEXT,                   -- 新增 end_time
      type TEXT NOT NULL,
      typename TEXT NOT NULL,
      exam_type TEXT NOT NULL,
      college_name TEXT NOT NULL,
      major_name TEXT NOT NULL,
      grade TEXT NOT NULL,
      name TEXT NOT NULL,
      course_no TEXT NOT NULL,
      teachers TEXT NOT NULL,          -- 原 teacher 改为 teachers
      term TEXT NOT NULL,
      term_name TEXT NOT NULL,
      capacity INTEGER NOT NULL,
      selected INTEGER NOT NULL,
      credits REAL NOT NULL,
      is_lab INTEGER NOT NULL,
      lab_lesson_id TEXT NOT NULL,
      batch INTEGER NOT NULL,
      comment TEXT NOT NULL,
      experiment TEXT NOT NULL,
      experiment_no TEXT NOT NULL,     -- 原 experimentNo 改为 experiment_no
      classroom TEXT NOT NULL,
      classroom_alias TEXT NOT NULL,
      start_week INTEGER NOT NULL,
      end_week INTEGER NOT NULL,
      weekday INTEGER NOT NULL,
      section INTEGER NOT NULL,
      create_time INTEGER NOT NULL,
      update_time INTEGER NOT NULL,
      PRIMARY KEY (id, username)
    )
  ''');

  // Step 2: 将旧表数据迁移到新表
  await database.execute('''
    INSERT INTO semester_schedule_new (
      id, username, source, start_datetime, end_datetime, start_time, end_time,
      type, typename, exam_type, college_name, major_name, grade, name,
      course_no, teachers,                      -- teacher 重命名为 teachers
      term, term_name, capacity, selected,
      credits, is_lab, lab_lesson_id, batch, comment, experiment, experiment_no,
      classroom, classroom_alias, start_week, end_week, weekday,
      section, create_time, update_time
    )
    SELECT 
      id, username, source, 
      start_time AS start_datetime,    -- 原 start_time 映射到 start_datetime
      end_time AS end_datetime,        -- 原 end_time 映射到 end_datetime
      NULL AS start_time,              -- 新增 start_time 字段初始为 NULL
      NULL AS end_time,                -- 新增 end_time 字段初始为 NULL
      type, typename, exam_type, college_name, major_name, grade, name,
      course_no, teacher AS teachers,           -- teacher 映射到 teachers
      term, term_name, capacity, selected,
      credits, is_lab, lab_lesson_id, batch, comment, experiment,
      '' AS experiment_no,            -- 新增 experiment_no
      classroom, classroom_alias, start_week, end_week, weekday,
      section, create_time, update_time
    FROM semester_schedule
  ''');

  // Step 3: 删除旧表
  await database.execute('DROP TABLE semester_schedule');

  // Step 4: 将新表重命名为旧表的名称
  await database.execute('ALTER TABLE semester_schedule_new RENAME TO semester_schedule');

});

final migration18to19 = Migration(18, 19, (database) async {
  await database.execute(
      'CREATE INDEX `index_semester_schedule_source` ON `semester_schedule` (`source`)');
});

final migration19to20 = Migration(19, 20, (database) async {
  await database.execute('ALTER TABLE `exam_scores_new` ADD COLUMN `scores` REAL NOT NULL DEFAULT 0');
  await database.execute('ALTER TABLE `exam_scores_new` ADD COLUMN `grade_grades` TEXT NOT NULL DEFAULT ""');
  await database.execute('ALTER TABLE `exam_scores_new` ADD COLUMN `credits_course` INTEGER NOT NULL DEFAULT 1');
});

final migration20to21 = Migration(20, 21, (database) async {
  var res = await database.rawQuery("PRAGMA table_info(users)");
  bool columnExists = res.any((column) => column['name'] == 'experiment_system_token');
  if (!columnExists) {
    await database.execute("ALTER TABLE `users` ADD COLUMN `experiment_system_token` TEXT DEFAULT NULL");
  }
});

final migration21to22 = Migration(21, 22, (database) async {
  var res = await database.rawQuery("PRAGMA table_info(users)");
  bool columnExists = res.any((column) => column['name'] == 'changke_session_id');
  if (!columnExists) {
    await database.execute("ALTER TABLE `users` ADD COLUMN `changke_session_id` TEXT DEFAULT NULL");
  }
});