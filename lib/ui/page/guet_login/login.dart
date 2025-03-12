import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:guethub/data/model/user/user.dart';
import 'package:guethub/ui/util/toast.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher.dart';
import 'login_viewmodel.dart';
import 'package:guethub/ui/route.dart';

class LoginPageArgs {
  final bool popUpAfterSuccess;
  final String? username;
  final String? password;

  LoginPageArgs(
      {required this.popUpAfterSuccess, this.username, this.password});
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.args}) : super(key: key);

  final LoginPageArgs args;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final c = Get.put(LoginViewModel(widget.args));
    return Scaffold(
      appBar: AppBar(
        title: const Text("登录"),
        actions: [
          TextButton(
              onPressed: () async {
                final User? user =
                await Get.toNamed<dynamic>(AppRoute.userListPage);
                if (user != null) {
                  c.usernameController.text = user.username;
                  c.passwordController.text = user.password;
                  c.isUpgradedUndergrad.value = user.isUpgradedUndergrad;
                }
              },
              child: Text("用户列表"))
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Form(
                  key: c.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36.0),
                        child: Column(
                          children: [
                            Text("登录教务系统账户",
                                style: Theme.of(context).textTheme.titleLarge),
                            SizedBox(height: 16),
                            Text(
                              "教务系统账户是您在使用教务功能时需要登录，包括课表等功能",
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      TextFormField(
                        controller: c.usernameController,
                        autofocus: false,
                        decoration: InputDecoration(
                          labelText: "学号",
                          hintText: "您的学号",
                          prefixIcon: Icon(Icons.person),
                          border: const OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(16))),
                        ),
                        validator: (v) {
                          return v!.trim().length > 0 ? null : "账号不能为空";
                        },
                      ),
                      SizedBox(height: 16),
                      Obx(() => TextFormField(
                        controller: c.passwordController,
                        obscureText: !c.passwordVisible.value,
                        autofocus: false,
                        decoration: InputDecoration(
                          labelText: "智慧校园密码",
                          hintText: "初始为 Guet@身份证后六位",
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              c.passwordVisible.value
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                c.passwordVisible.toggle();
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(16))),
                        ),
                        validator: (v) {
                          return v!.trim().length > 0 ? null : "密码不能为空";
                        },
                      )),
                      SizedBox(height: 16),
                      StreamBuilder(
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                (snapshot.data! ? "当前处于校园网，目前建议使用移动数据登录，校园网可能存在无法登陆的BUG" : "当前处于非校园网"),
                                textAlign: TextAlign.center,
                              );
                            }
                            return Container();
                          },
                          stream: c.isCampusNetworkState,
                          initialData: null),
                      SizedBox(height: 16),
                      // 添加用户协议和隐私政策同意条款
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: (){
                          c.agreeToTerms.toggle();
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Obx(
                                  () => Checkbox(
                                value: c.agreeToTerms.value,
                                onChanged: (value) {
                                  c.agreeToTerms.value = value ?? false;
                                },
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(text: '我已阅读并同意 '),
                                    TextSpan(
                                      text: '《用户协议》',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.toNamed(AppRoute.userAgreementPage);
                                        },
                                    ),
                                    TextSpan(text: ' 和 '),
                                    TextSpan(
                                      text: '《隐私政策》',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Get.toNamed(AppRoute.privacyPolicyPage);
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Obx(() => ElevatedButton(
                        onPressed: c.isLoading.value
                            ? null
                            : () => c.login(
                            context,
                            c.formKey.currentState as FormState,
                            widget.args.popUpAfterSuccess),
                        style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50)),
                        child: c.isLoading.value
                            ? Text("正在登录...")
                            : Text("登录"),
                      )),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              launcher.launchUrl(
                                  Uri.parse(
                                      "https://cas.guet.edu.cn/retrieve-password/activationMobile/index.html"),
                                  mode: LaunchMode.inAppBrowserView);
                            },
                            child: Text("账号激活"),
                          ),
                          TextButton(
                            onPressed: () {
                              launcher.launchUrl(
                                  Uri.parse(
                                      "https://www.guet.edu.cn/xjzx/2023/0316/c1590a84915/page.htm"),
                                  mode: LaunchMode.inAppBrowserView);
                            },
                            child: Text("帮助"),
                          ),
                          Expanded(child: SizedBox()),
                          TextButton(
                            onPressed: () {
                              launcher.launchUrl(
                                  Uri.parse(
                                      "https://cas.guet.edu.cn/retrieve-password/passwordMobile/index.html"),
                                  mode: LaunchMode.inAppBrowserView);
                            },
                            child: Text("forgot_password".tr),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              c.isUpgradedUndergrad.toggle();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(child: Text("使用专升本教务系统")),
                                SizedBox(width: 8),
                                SizedBox(
                                  height: 24.0,
                                  width: 24.0,
                                  child: Obx(() => Checkbox(
                                      materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                      value: c.isUpgradedUndergrad.value,
                                      onChanged: (v) {
                                        c.isUpgradedUndergrad.value = v!;
                                      })),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Get.toNamed(AppRoute.appLoginPage);
                            },
                            child: Text("去登录App账户"),
                          ),
                          IconButton(
                            onPressed: () {
                              toast("App账户是您在使用非教务功能时才需要登录，例如论坛等功能",
                                  gravity: ToastGravity.TOP);
                            },
                            icon: Icon(
                              Icons.help_outline_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }
}