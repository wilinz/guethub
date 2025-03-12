import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:guethub/common/encrypt/webvpn_new.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/repository/network_detection.dart';
import 'package:guethub/ui/page/webview/webview.dart';
import 'package:guethub/ui/route.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:guethub/ui/util/toast.dart';

Future<String> getWebViewUrl(String url) async {
  final isCampusNetwork =
      await NetworkDetectionRepository.get().isCampusNetwork;
  if(isCampusNetwork == true) return url;
  return getWebVPNUrl(url);
}

// 定义实体类 ToolboxItem
class ToolboxItem {
  final String title;
  final String url;

  ToolboxItem({required this.title, required this.url});
}

class Toolbox extends StatefulWidget {
  const Toolbox({super.key});

  @override
  State<Toolbox> createState() => _ToolboxState();
}

class _ToolboxState extends State<Toolbox> {
  // 使用 ToolboxItem 实体类创建工具箱项目列表
  final List<ToolboxItem> toolboxItems = [
    ToolboxItem(
      title: "智慧校园综合门户",
      url: "https://pcportal.guet.edu.cn/",
    ),
    ToolboxItem(
      title: "一站式服务大厅",
      url: "https://fwdt.guet.edu.cn/EIP/user/index.htm",
    ),
    ToolboxItem(
      title: "本科教务系统",
      url: "https://bkjwtest.guet.edu.cn/student/home",
    ),
    ToolboxItem(
      title: "本科教务系统（旧）",
      url: "https://bkjw.guet.edu.cn",
    ),
    ToolboxItem(
      title: "本科教务系统二（专升本）",
      url: "https://bkjwsrv.guet.edu.cn",
    ),
    ToolboxItem(
      title: "研究生教务系统",
      url: "https://yjsjy.guet.edu.cn/",
    ),
    ToolboxItem(
      title: "校园WebVPN",
      url: "https://v.guet.edu.cn/",
    ),
    ToolboxItem(
      title: "课程直播平台（桌面版）",
      url: "https://classroom.guet.edu.cn",
    ),
    ToolboxItem(
      title: "课程直播平台（手机版）",
      url: "https://yjapp.guet.edu.cn",
    ),
    ToolboxItem(
      title: "智慧教学平台（手机版）",
      url: "https://mobile.guet.edu.cn",
    ),
    // ToolboxItem(
    //   title: "图书馆",
    //   url: "https://www.guet.edu.cn/lib",
    // ),
    // ToolboxItem(
    //   title: "数据库导航",
    //   url: "http://202.193.70.166:8020/index.asp",
    // ),
    ToolboxItem(
      title: "校园网认证地址（已登录校园网建议用这个）",
      url: "http://10.0.1.5",
    ),
    ToolboxItem(
      title: "校园网认证地址1（未登录校园网建议用这个）",
      url: "http://10.0.1.55",
    ),
  ];

  // 分享功能
  Future<void> share(BuildContext context,
      {required String subject, required String text}) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      text,
      subject: subject,
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("工具箱"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: toolboxItems.map((item) {
            return ListTile(
              onTap: () {
                launcherWebView(item);
              },
              leading: Icon(Icons.link_outlined),
              title: Text(item.title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      launchUrl(Uri.parse(item.url),
                          mode: LaunchMode.externalApplication);
                      // launcherWebView(item);
                    },
                    icon: Icon(Icons.open_in_browser),
                  ),
                  IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: item.url));
                        toastSuccess(message: "${item.title}复制成功");
                      },
                      icon: Icon(Icons.copy)),
                  IconButton(
                      onPressed: () {
                        share(context,
                            subject: item.title,
                            text: item.url);
                      },
                      icon: Icon(Icons.share)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> launcherWebView(ToolboxItem item) async {
    Get.toNamed(AppRoute.webView, arguments: WebViewArgs(url: item.url));
  }

}
