import 'package:guethub/data/database/database.dart';
import 'package:guethub/data/model/user/user.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/common.dart';
import 'package:guethub/data/repository/login.dart';
import 'package:guethub/data/service/student_info.dart';
import 'package:guethub/util/list.dart';

class UserRepository {

  User? _cachedActiveUser = null;

  Future<User?> getRecentUser() async {
    final db = await getDatabase();
    final user = await db.userDao.getRecent();
    return user.firstOrNull();
  }

  Future<void> deleteUser(User user) async {
    final db = await getDatabase();
    await db.userDao.deleteUser(user);
  }

  Future<List<User>> getUsersPaginated(int limit, int offset) async {
    final db = await getDatabase();
    final user = await db.userDao.getUsersPaginated(limit, offset);
    return user;
  }

  Future<User?> getActiveUser() async {
    if (_cachedActiveUser != null) return _cachedActiveUser;
    final db = await getDatabase();
    final user = await db.userDao.getActive();
    _cachedActiveUser = user;
    return user;
  }

  Future<int> getNewSystemStudentIdFromLocal() async {
    final db = await getDatabase();
    final user = await db.userDao.getActive();
    if (user == null) {
      throw NotLoggedInException();
    }
    if (user.newSystemStudentId != null) {
      return user.newSystemStudentId!;
    }
    final id = await StudentInfoService.getNewSystemStudentId(await AppNetwork.get().bkjwTestDio);
    user.newSystemStudentId = id;
    db.userDao.updateUser(user);
    return id;
  }

  Future<void> updateUser(User user) async {
    final db = await getDatabase();
    db.userDao.updateUser(user);
  }

  init() async {
    LoginRepository.get().onLoginEvent.listen((user){
      _cachedActiveUser = user;
    });
    final db = await getDatabase();
    db.userDao.getActiveStream().listen((user){
      _cachedActiveUser = user;
    });
  }

  UserRepository._create(){
    init();
  }

  static UserRepository? _instance;

  factory UserRepository.get() =>
      _instance ??= UserRepository._create();
}
