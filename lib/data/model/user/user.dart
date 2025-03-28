import 'dart:async';
import 'package:autoequal/autoequal.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:floor/floor.dart';
import 'package:guethub/data/model/db/base.dart';

part 'user.g.dart';

@Entity(tableName: 'users', indices: [
  Index(unique: true, value: ["username"])
])
@autoequal
class User extends BaseEntityEquatable {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String username;

  String? name;

  @ColumnInfo(name: "new_system_student_id")
  int? newSystemStudentId;

  String password;

  @ColumnInfo(name: "is_active")
  bool isActive;

  @ColumnInfo(name: "is_only_use_old_system")
  bool isOnlyUseOldSystem;

  @ColumnInfo(name: "teaching_evaluation_token")
  String? teachingEvaluationToken;

  @ColumnInfo(name: "course_select_token")
  String? courseSelectToken;

  @ColumnInfo(name: "experiment_system_token")
  String? experimentSystemToken;

  @ColumnInfo(name: "changke_session_id")
  String? changkeSessionId;

  @ColumnInfo(name: "is_upgraded_undergrad")
  bool isUpgradedUndergrad;

  @ColumnInfo(name: "is_postgraduate")
  bool isPostgraduate;

  bool isOnlyUseNewSystem() => isOnlyUseNewSystemStatic(username);

  static bool isOnlyUseNewSystemStatic(String username) {
    try {
      if(username.length > 10) return false;
      final grade = username.substring(0, 2).toIntOrNull();
      if (grade == null) {
        return false;
      }
      return grade >= 24;
    } catch (e) {
      return false;
    }
  }

  User({
    required DateTime updateTime,
    DateTime? createTime,
    this.id,
    this.name,
    required this.username,
    required this.password,
    required this.isActive,
    this.isOnlyUseOldSystem = false,
    this.teachingEvaluationToken,
    this.newSystemStudentId,
    this.courseSelectToken,
    this.experimentSystemToken,
    this.isUpgradedUndergrad = false,
    this.isPostgraduate = false
  }) : super(updateTime: updateTime, createTime: createTime);

  @override
  List<Object?> get props => _$props;
}
