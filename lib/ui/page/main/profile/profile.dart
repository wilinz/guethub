import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:guethub/check_update.dart';
import 'package:guethub/package_info.dart';
import 'package:guethub/ui/page/guet_login/login.dart';
import 'package:guethub/ui/page/main/profile/profile_vm.dart';
import 'package:guethub/ui/route.dart';
import 'package:guethub/ui/util/toast.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:url_launcher/url_launcher_string.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  final c = Get.put(ProfileViewModel());

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("个人主页"),
        actions: [],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoute.loginPage,
                      arguments: LoginPageArgs(
                        popUpAfterSuccess: true,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          // onTap: () {
                          //   Get.toNamed(AppRoute.userProfile);
                          // },
                          child: Image(
                            image: AssetImage("images/logo.png"),
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder(
                                stream: c.getActiveUserStream(),
                                builder: (context, item) {
                                  final user = item.data;
                                  return Text(
                                    user == null ? "未登录App账户" : user.username,
                                    // style: Get.theme.textTheme.titleMedium,
                                  );
                                }),
                            SizedBox(height: 4),
                            Obx(() {
                              final info = c.studentInfo.value;
                              if (info != null) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text((info.studentId) + (info.name)),
                                    SizedBox(height: 4),
                                    Text(info.collegeName),
                                  ],
                                );
                              }
                              return Text("未登录教务系统账户");
                            }),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: SingleChildScrollView(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ListTile(
                          //   onTap: () {
                          //     Navigator.of(context)
                          //         .pushNamed(AppRoute.pedagogicalEvaluationPage);
                          //   },
                          //   leading: Icon(Icons.rate_review_outlined),
                          //   // Icon for "评教"
                          //   title: Text("评教（旧）"),
                          //   trailing: Icon(Icons.arrow_forward_ios_outlined),
                          // ),
                          ListTile(
                            onTap: () {
                              Get.toNamed(AppRoute.userProfile);
                            },
                            leading: Icon(Icons.person_outline),
                            // Icon for "关于"
                            title: Text("用户资料（HUB）"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              Get.toNamed(AppRoute.examScoresPage);
                            },
                            leading: Icon(Icons.assignment_outlined),
                            // Icon for "关于"
                            title: Text("成绩单"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          if (c.isUpgradedUndergrad.isFalse)
                            ListTile(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoute.examSchedulePage);
                              },
                              leading: Icon(Icons.calendar_today_outlined),
                              title: Text("考试安排"),
                              trailing: Icon(Icons.arrow_forward_ios_outlined),
                            ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.changkePage);
                            },
                            leading: SvgPicture.asset("assets/images/tron_class.svg"),
                            title: Text("畅课教学平台（新）"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          if (c.isUpgradedUndergrad.isFalse)
                            ListTile(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoute.teachingEvaluation);
                              },
                              leading: Icon(Icons.rate_review_outlined),
                              // Icon for "评教"
                              title: Text("评教"),
                              trailing: Icon(Icons.arrow_forward_ios_outlined),
                            ),
                          if (c.isUpgradedUndergrad.isFalse)
                            ListTile(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoute.textbookEvaluatePage);
                              },
                              leading: Icon(Icons.book_outlined),
                              title: Text("教材评价"),
                              trailing: Icon(Icons.arrow_forward_ios_outlined),
                            ),
                          if (c.isUpgradedUndergrad.isFalse)
                            ListTile(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoute.experimentCoursesPage);
                              },
                              leading: Icon(Icons.science_outlined),
                              title: Text("实验课选课"),
                              trailing: Icon(Icons.arrow_forward_ios_outlined),
                            ),
                          if (c.isUpgradedUndergrad.isFalse)
                            ListTile(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed(AppRoute.emptyClassroomNewPage);
                              },
                              leading: Icon(Icons.meeting_room_outlined),
                              title: Text("空教室查询"),
                              trailing: Icon(Icons.arrow_forward_ios_outlined),
                            ),
                          // ListTile(
                          //   onTap: () {
                          //     Navigator.of(context)
                          //         .pushNamed(AppRoute.courseSelectionPage);
                          //   },
                          //   leading: Icon(Icons.menu_book_outlined),
                          //   // Icon for "评教"
                          //   title: Text("选课"),
                          //   trailing: Icon(Icons.arrow_forward_ios_outlined),
                          // ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.campusNetworkPage);
                            },
                            leading: Icon(Icons.wifi_outlined),
                            // Icon for "连接校园网"
                            title: Text("连接校园网（测试版）"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.campusMapPage);
                            },
                            leading: Icon(Icons.map_outlined),
                            // Icon for "连接校园网"
                            title: Text("校园地图"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.timetablePage);
                            },
                            leading: Icon(Icons.schedule),
                            title: Text("作息时间表"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.toolboxPage);
                            },
                            leading: Icon(Icons.link),
                            // Icon for "连接校园网"
                            title: Text("常用网站"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              launcher.launchUrl(
                                  Uri.parse("https://www.guethub.net"),
                                  mode: LaunchMode.externalApplication);
                            },
                            leading: Icon(Icons.web), // Icon for "关于"
                            title: Text("下载地址（官网）"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () async {
                              // '嘿朋友们，我发现了一个超棒的应用，赶紧来看看吧！\n\n这个应用叫 GUET校园圈 (GUET HUB)，支持 Android 和 IOS。\n\n它有几个非常实用的功能：\n1. 可以直接连接桂电的教务系统，查看课表和成绩。\n2. 它是一个校园服务平台，可以帮你处理各种校园周边的服务项目。\n3. 还有一个叫“校园圈”的功能，类似一个论坛，可以在上面和大家交流。\n\n快去官网下载试试吧: https://www.guethub.net');
                              await c.share(context);
                            },
                            leading: Icon(Icons.share),
                            title: Text("分享应用"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.themeChangerPage);
                            },
                            leading: Icon(Icons.style_outlined),
                            // Icon for "连接校园网"
                            title: Text("主题"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.feedbackPage);
                            },
                            leading: Icon(Icons.feedback_outlined),
                            // Icon for "连接校园网"
                            title: Text("反馈"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.settingsPage);
                            },
                            leading: Icon(Icons.settings_outlined),
                            // Icon for "连接校园网"
                            title: Text("设置"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.userAgreementPage);
                            },
                            leading: Icon(Icons.article_outlined),
                            title: Text("用户协议"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoute.privacyPolicyPage);
                            },
                            leading: Icon(Icons.lock_outline),
                            title: Text("隐私政策"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () async {
                              if (kIsWeb) return;
                              await c.checkUpdate();
                              final appVersion = c.appVersion.value;
                              if (appVersion != null) {
                                if (appVersion.isHasNewVersion(packageInfo) &&
                                    appVersion.enabledSystem.contains(Platform
                                        .operatingSystem
                                        .toLowerCase())) {
                                  showDialog(
                                      context: Get.context!,
                                      barrierDismissible: !appVersion.isForce,
                                      builder: (context) =>
                                          UpdateDialog(appVersion: appVersion));
                                } else {
                                  showDialog(
                                      context: Get.context!,
                                      barrierDismissible: true,
                                      builder: (context) =>
                                          VersionChangelogWidget(
                                              changelog: "**当前版本已经是最新版本**\n\n" +
                                                  appVersion.changelog));
                                }
                              } else {
                                toastFailure0("获取版本信息失败");
                              }
                            },
                            leading: Icon(Icons.info_outline),
                            title: Obx(() {
                              final appVersion = c.appVersion.value;
                              if (appVersion != null &&
                                  appVersion.isHasNewVersion(packageInfo) &&
                                  appVersion.enabledSystem.contains(
                                      Platform.operatingSystem.toLowerCase())) {
                                return Text(
                                    "版本：${packageInfo.version} -> ${appVersion.versionName}");
                              }
                              return Text("版本：${packageInfo.version ?? ""}");
                            }),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          ListTile(
                            onTap: () {
                              logout(c);
                            },
                            leading: Icon(Icons.logout_outlined),
                            title: Text("退出App账户"),
                            trailing: Icon(Icons.arrow_forward_ios_outlined),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text.rich(
                                TextSpan(children: [
                                  // TextSpan(
                                  //     text: "https://github.com/sanyuankexie/guet_toolbox\n\n",
                                  //     style: TextStyle(
                                  //       color: Colors.blue,
                                  //     ),
                                  //     recognizer: TapGestureRecognizer()
                                  //       ..onTap = () {
                                  //         launcher.launchUrl(
                                  //             Uri.parse(
                                  //                 "https://github.com/sanyuankexie/guet_toolbox"),
                                  //             mode: LaunchMode.externalApplication);
                                  //       }),
                                  TextSpan(
                                    text:
                                        "点击链接加入群聊【GUET 校园圈 App 内测群】482024244 \n\n",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        Clipboard.setData(
                                            ClipboardData(text: "482024244"));
                                        toastSuccess(
                                            message: "群号码复制成功, 2秒后跳转QQ");
                                        await Future.delayed(
                                            Duration(seconds: 2));
                                        launcher.launchUrl(
                                            Uri.parse(
                                                "https://qm.qq.com/q/hUJTPAemR2"),
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                  ),
                                  TextSpan(
                                    text:
                                        "友情链接：三院科协：https://hello.kexie.space\n",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        launcher.launchUrl(
                                            Uri.parse(
                                                "https://hello.kexie.space"),
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void logout(ProfileViewModel c) {
    showDialog(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
            title: Text("确定"),
            content: Text("确定退出登录？"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("取消")),
              TextButton(
                  onPressed: () async {
                    await c.logout();
                    Navigator.pop(context);
                  },
                  child: Text("确定"))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
