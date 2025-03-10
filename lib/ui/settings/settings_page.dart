import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/logger.dart';
import 'package:guethub/package_info.dart';
import 'package:guethub/ui/route.dart';
import 'package:guethub/ui/util/toast.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/get_storage.dart';
import 'settings_controller.dart';

class SettingsPage extends StatelessWidget {
  final SettingsController c = Get.put(SettingsController(getStorage));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr),
      ),
      body: Obx(() => Column(
            children: [
              /*ListTile(
            title: Text('theme'.tr),
            trailing: Obx(
              () => DropdownButton(
                padding: EdgeInsets.only(left: 12, right: 12),
                value: _settingsController.themeMode.value,
                focusColor: Colors.transparent,
                // 设置焦点颜色为透明
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('follow_system'.tr),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('light'.tr),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('dark'.tr),
                  ),
                ],
                onChanged: (value) => _settingsController.setThemeMode(value!),
              ),
            ),
          ),*/
              ListTile(
                title: Text('language'.tr),
                trailing: DropdownButton(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  value: c.locale.value?.toLocaleCode(),
                  focusColor: Colors.transparent,
                  // 设置焦点颜色为透明
                  items: <DropdownMenuItem<String?>>[
                    DropdownMenuItem(
                      value: null,
                      child: Text('follow_system'.tr),
                    ),
                    DropdownMenuItem(
                      value: "en_US",
                      child: Text('English'),
                    ),
                    DropdownMenuItem(
                      value: "zh_CN",
                      child: Text('中文'),
                    ),
                  ],
                  onChanged: (value) => c.changeLanguage(value),
                ),
              ),
              ListTile(
                onTap: () async {
                  Get.toNamed(AppRoute.authorPage);
                },
                leading: Icon(Icons.account_circle_outlined),
                title: Text("开发者"),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              ListTile(
                onTap: () async {
                  launchUrl(Uri.parse("https://github.com/wilinz/guethub"), mode: LaunchMode.externalApplication);
                },
                leading: Icon(Icons.account_circle_outlined),
                title: Text("开源地址：https://github.com/wilinz/guethub"),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              ListTile(
                onTap: () async {
                  c.tapCount.value += 1;
                  if (c.tapCount.value == 7) {
                    toast("您已清除 cookie ");
                    AppNetwork.getCookieJar(
                            username: AppNetwork.currentUsername)
                        .deleteAll();
                    c.tapCount.value = 0;
                  } else if (c.tapCount >= 3) {
                    toast("再点击 ${7 - c.tapCount.value} 次即可清除 Cookie!",
                        duration: Duration(milliseconds: 300));
                  }
                },
                onLongPress: () async {
                  if (c.isDebugMode.isFalse) {
                    await initLogger(level: Level.all);
                    c.setDebugMode(true);
                    toast("已经开启调试模式");
                  } else {
                    await initLogger(level: Level.fatal);
                    c.setDebugMode(false);
                    toast("已经关闭调试模式");
                  }
                },
                leading: Icon(Icons.info_outline),
                title: Text("版本：${packageInfo.version ?? ""}"),
                trailing: Icon(Icons.arrow_forward_ios_outlined),
              ),
              if (c.isDebugMode.value)
                Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(children: [
                      Text(
                          "当前处于调试模式，如您不需要协助开发者进行错误排查，请再次长按版本号关闭此模式，在此模式下运行App, 可能会增加App存储空间的占用，还会影响App的性能，此模式开启1小时后会自动关闭"),
                      SizedBox(height: 16),
                      Obx(() => TextButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: c.debugDeviceId.string));
                            toastSuccess(message: "已经复制到剪切板");
                          },
                          child: Text("调试ID(点击复制): ${c.debugDeviceId}"))),
                      SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: Obx(() => ElevatedButton(
                                onPressed: c.isLogUploading.isFalse
                                    ? () {
                                        c.uploadLogs();
                                      }
                                    : null,
                                child: Text(c.isLogUploading.isFalse
                                    ? "点此上传日志给开发者"
                                    : "正在上传..."),
                              ))),
                      SizedBox(height: 16),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                _showResetLogsDialog(context);
                              },
                              child: Text("重置日志"))),
                    ]),
                  );
                })
            ],
          )),
    );
  }

  // Show a confirmation dialog before resetting logs
  void _showResetLogsDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text("确认重置日志"),
        content: Text("您确定要重置日志吗？此操作不可撤销。"),
        actions: [
          TextButton(
            onPressed: () {
              // Close the dialog
              Get.back();
            },
            child: Text("取消"),
          ),
          TextButton(
            onPressed: () {
              // Perform log reset action here
              c.resetLogs(); // Assuming this method exists in your controller
              toast("日志已重置");
              Get.back(); // Close the dialog after confirming
            },
            child: Text("确认"),
          ),
        ],
      ),
    );
  }
}
