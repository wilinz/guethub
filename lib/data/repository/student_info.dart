import 'package:guethub/data/database/database.dart';
import 'package:guethub/data/model/student/student_info.dart';
import 'package:guethub/data/model/user/user.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/common.dart';
import 'package:guethub/data/repository/user.dart';
import 'package:guethub/data/service/student_info.dart';

class StudentInfoRepository {
  Future<StudentInfo> getStudentInfo() async {
    final db = await getDatabase();
    final user = await UserRepository.get().getActiveUser();
    if (user == null) {
      throw NotLoggedInException("Not sign in");
    }

    final userInfo0 = await db.studentInfoDao.get(user.username);
    if (userInfo0 != null) {
      await updateUserRealName(user, db, userInfo0);
      return userInfo0;
    }

    StudentInfo userInfo;
    if (user.isOnlyUseOldSystem == true) {
      userInfo = await StudentInfoService.get(await AppNetwork.get().bkjwDio);
    } else {
      userInfo = await StudentInfoService.getNewInfo(await AppNetwork.get().bkjwTestDio);
    }
    await updateUserRealName(user, db, userInfo);
    await db.studentInfoDao.insertOrUpdate(userInfo);
    return userInfo;
  }

  Future<void> updateUserRealName(User user, AppDatabase db, StudentInfo userInfo) async {
    if(user.name == null) {
      await db.userDao.updateName(user.username, userInfo.name);
    }
  }

  StudentInfoRepository._();

  static StudentInfoRepository? _instance = null;

  factory StudentInfoRepository.get() =>
      _instance ??= StudentInfoRepository._();
}
