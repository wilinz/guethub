import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:guethub/ui/page/changke/changke_controller.dart';

import '../../route.dart';
import '../webview/webview.dart';

class ChangkePage extends StatelessWidget {
  const ChangkePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ChangkeController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('桂林电子科大学'),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: () {
              final url = "https://mobile.guet.edu.cn";
              Get.toNamed(AppRoute.webView, arguments: WebViewArgs(url: url));
            },
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              backgroundColor: WidgetStateProperty.all(
                  Color(0xff1DB6C2 /* : 0xffff4853*/)),
              elevation: WidgetStateProperty.all(0), // 关闭按钮自身的阴影
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text("完整版请点此打开网页版", style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 夜间提示
              Obx(() {
                return Text(
                  c.greeting.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),

              const SizedBox(height: 16),

              // 上方两个卡片按钮（扫码、签到）
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 0), // 可根据需要调整阴影偏移
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: buildCardWithSemiCircle(
                        buttonGradient: LinearGradient(
                          colors: [Color(0xFF00BBBD), Color(0xFF0EB0D4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          transform: GradientRotation(234.32 * 3.1416 / 180), // 传入的角度
                        ),
                        icon: SvgPicture.asset("assets/images/scan_code.svg", color: Colors.white),
                        label: "扫码",
                        onTap: () {
                          c.scanQr();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: buildCardWithSemiCircle(
                        buttonGradient: LinearGradient(
                          colors: [Color(0xFF59BE30), Color(0xFF44BE30)],
                          stops: [-0.0063, 1.0064],  // 设置颜色位置（%转换为0到1之间的值）
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          transform: GradientRotation(266.66 * 3.1416 / 180),  // 设置渐变角度
                        ),
                        icon: SvgPicture.asset("assets/images/sign.svg", color: Colors.white),
                        label: "签到",
                        onTap: () {
                          final url = "https://mobile.guet.edu.cn/ongoing-rollcall-list";
                          Get.toNamed(AppRoute.webView, arguments: WebViewArgs(url: url));
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 最近访问
              const Text(
                "最近访问",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // SizedBox(
              //   height: 100, // 视具体需求可调整
              //   child: Obx(() {
              //     return ListView.separated(
              //       scrollDirection: Axis.horizontal,
              //       itemCount: c.recentItems.length,
              //       separatorBuilder: (context, index) =>
              //       const SizedBox(width: 8),
              //       itemBuilder: (context, index) {
              //         final item = c.recentItems[index];
              //         return _buildRecentItemCard(item);
              //       },
              //     );
              //   }),
              // ),

              // const SizedBox(height: 24),

              // 待办事项示例
              const Text(
                "待办事项",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // const SizedBox(height: 8),
              // _buildTodoList(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建卡片按钮
  Widget _buildCardButton({
    required LinearGradient gradient, // 传入完整的渐变对象
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: gradient, // 使用外部传入的渐变
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCardWithSemiCircle({
    required LinearGradient buttonGradient,
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Stack(
      clipBehavior: Clip.none, // 允许溢出显示
      children: [
        // 按钮主体
        _buildCardButton(
          gradient: buttonGradient,
          icon: icon,
          label: label,
          onTap: onTap,
        ),
        // 右下角半圆：这里创建一个完整的圆形，然后调整位置，使之只显示半个
        Positioned(
          right: -15,
          bottom: -15,
          child: Container(
            width: 50, // 圆的直径
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.0),
                ],
                stops: [0.0, 0.9623],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建最近访问卡片
  Widget _buildRecentItemCard(String title) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// 构建待办事项列表
  Widget _buildTodoList() {
    // 这里简单模拟一下待办事项
    final todoItems = [
      "计算机视觉课程调研问卷",
      "作业提交",
      "论文写作进度跟进",
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(), // 禁止内部滚动，避免和外层冲突
      shrinkWrap: true,
      itemCount: todoItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final todo = todoItems[index];
        return ListTile(
          title: Text(todo),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // 点击事件...
          },
        );
      },
    );
  }
}
