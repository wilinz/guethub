import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:guethub/data/repository/login.dart';
import 'package:guethub/data/service/login.dart';
import 'package:guethub/data/model/user/user.dart';
import 'package:guethub/logger.dart';
import 'package:guethub/ui/login/captcha_dialog.dart';
import 'package:guethub/ui/login/verification_code_dialog.dart';
import 'package:get/get.dart';
import 'package:guethub/data/repository/network_detection.dart';
import 'package:guethub/data/repository/user.dart';
import 'package:guethub/ui/route.dart';
import 'package:guethub/ui/util/toast.dart';
import 'package:kt_dart/standard.dart';

import 'login.dart'; // 使用你原有的 toast 函数

class LoginViewModel extends GetxController {
  final LoginPageArgs args;

  LoginViewModel(this.args);

  final isLoading = false.obs;
  final isOnlyUseOldSystem = false.obs;
  final isUpgradedUndergrad = false.obs;
  final isPostgraduate = false.obs;
  final passwordVisible = false.obs;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController vcodeController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final agreeToTerms = false.obs;

  @override
  void onInit() {
    super.onInit();
    isUpgradedUndergrad.listen((it) {
      isOnlyUseOldSystem.value = it;
    });
    args.username?.let((it) {
      usernameController.text = it;
    });
    args.password?.let((it) {
      passwordController.text = it;
    });
    getRecentUser().then((user) {
      if (user != null) {
        usernameController.text = user.username;
        passwordController.text = user.password;
        isUpgradedUndergrad.value = user.isUpgradedUndergrad;
      }
    });
  }

  Future<bool?> get isCampusNetwork =>
      NetworkDetectionRepository.get().isCampusNetwork;

  Stream<bool?> get isCampusNetworkState =>
      NetworkDetectionRepository.get().isCampusNetworkState;

  Future<void> login(
      BuildContext context, FormState formKey, bool popUpAfterSuccess) async {
    if (!formKey.validate()) {
      toastFailure(
          message: "请检查输入", gravity: ToastGravity.TOP); // 使用你原来的 toast 函数
      return;
    }

    if (!agreeToTerms.value) {
      toast("请先同意用户协议和隐私政策", gravity: ToastGravity.TOP);
      return;
    }

    isLoading.value = true;
    final retryCount = 3;
    for (var i = 0; i < retryCount; i++) {
      try {
        await LoginRepository.get().loginAcademicAffairsSystem(
          usernameController.text,
          passwordController.text,
          captchaHandler: (image) async {
            final result = await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => CaptchaDialog(image: image),
            );
            return result;
          },
          isOnlyUseOldSystem: isOnlyUseOldSystem.value,
          isUpgradedUndergrad: isUpgradedUndergrad.value,
          isPostgraduate: isPostgraduate.value,
        );

        toastSuccess(
            message: "登录成功", gravity: ToastGravity.TOP); // 使用你原来的 toast 函数
        final navigator = Navigator.of(context);
        if (popUpAfterSuccess) {
          navigator.pop();
        } else {
          Navigator.pushReplacementNamed(context, AppRoute.mainPage);
        }
        break;
      } on RequireLoginVerificationCodeException {
        final result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              VerificationCodeDialog(username: usernameController.text),
        );
        if (result == true) {
          login(context, formKey, popUpAfterSuccess);
          return;
        }
      } catch (e, st) {
        logger.e("登录失败：", error: e, stackTrace: st);
        var error = e.toString();
        if (error.contains("密码有误") && i != retryCount - 1) {
          continue;
        } else {
          toastFailure(
            message: "失败，请重试",
            error: error,
            duration: Duration(seconds: 2),
            gravity: ToastGravity.TOP,
          ); // 使用你原来的 toast 函数
          break;
        }
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<User?> getRecentUser() async => UserRepository.get().getRecentUser();
}
