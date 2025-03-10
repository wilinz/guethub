import 'dart:typed_data';

import 'package:guethub/common/key.dart';
import 'package:guethub/data/database/database.dart';
import 'package:guethub/data/model/dynamic_code/dynamic_code.dart';
import 'package:guethub/data/model/dynamic_code/reauth.dart';
import 'package:guethub/data/model/user/user.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/campus_network.dart';
import 'package:guethub/data/repository/network_detection.dart';
import 'package:guethub/data/service/captcha_solver.dart';
import 'package:guethub/data/service/login.dart';
import 'package:guethub/logger.dart';
import 'package:rxdart/rxdart.dart';

class LoginRepository {

  final _onLoginEvent = BehaviorSubject<User>();

  ValueStream<User> get onLoginEvent => _onLoginEvent.stream;

  static Future<String> defaultCaptchaHandler(Uint8List image) async {
    return await CaptchaSolverService.ocr(AppNetwork.get().appDio, image);
  }

  Future<void> loginAcademicAffairsSystem(
    String username,
    String password, {
    required CaptchaHandler captchaHandler,
    bool isOnlyUseOldSystem = false,
    bool isUpgradedUndergrad = false,
    bool isPostgraduate = false,
  }) async {
    captchaHandler = defaultCaptchaHandler;
    final db = await getDatabase();
    var user = await db.userDao.get(username);
    if (user == null) {
      user = User(
        updateTime: DateTime.now(),
        username: username,
        password: password,
        isActive: false,
        isOnlyUseOldSystem: isOnlyUseOldSystem,
      );
      db.userDao.insertOrUpdateUser(user);
    }

    final isCampusNetwork =
        await NetworkDetectionRepository.get().isCampusNetwork;

    try {
      user.password = password;
      user.updateTime = DateTime.now();
      user.isOnlyUseOldSystem = isOnlyUseOldSystem;
      user.isUpgradedUndergrad = isUpgradedUndergrad;
      user.isPostgraduate = isPostgraduate;

      await LoginService.login(
          AppNetwork.get(username: username).casDio, username, password,
          captchaHandler: captchaHandler,
          isOnlyUseOldSystem: isOnlyUseOldSystem,
          isOnlyUseNewSystem: user.isOnlyUseNewSystem(),
          isUpgradedUndergrad: isUpgradedUndergrad,
          isPostgraduate: isPostgraduate,
          isCampusNetwork: isCampusNetwork ?? false);

      user.isActive = true;
      await db.userDao.updateUser(user);
      await db.userDao.offlineOtherUser(user.username);
      logger.d("发射登录事件");
      _onLoginEvent.add(user);
    } catch (e) {
      await db.userDao.updateUser(user);
      rethrow;
    }
  }

  Future<DynamicCode> sendDynamicCode(String username) async =>
      LoginService.sendDynamicCode(
          username: username,
          dio: AppNetwork.get().casDio,
          isCampusNetwork:
              (await NetworkDetectionRepository.get().isCampusNetwork) ?? true);

  Future<ReAuth> reAuthCheck(String code) async => LoginService.reAuthCheck(
      code: code,
      dio: AppNetwork.get().casDio,
      isCampusNetwork:
          (await NetworkDetectionRepository.get().isCampusNetwork) ?? true);

  LoginRepository._create();

  static LoginRepository? _instance;

  factory LoginRepository.get() => _instance ??= LoginRepository._create();
}
