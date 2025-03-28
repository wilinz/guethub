import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guethub/ui/page/changke/changke_controller.dart';

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
              Row(
                children: [
                  Expanded(
                    child: _buildCardButton(
                      icon: Icons.qr_code,
                      label: "扫码",
                      onTap: () {
                        c.scanQr();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCardButton(
                      icon: Icons.check_circle_outline,
                      label: "签到",
                      onTap: () {
                        // 业务逻辑...
                      },
                    ),
                  ),
                ],
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

              SizedBox(
                height: 100, // 视具体需求可调整
                child: Obx(() {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: c.recentItems.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = c.recentItems[index];
                      return _buildRecentItemCard(item);
                    },
                  );
                }),
              ),

              const SizedBox(height: 24),

              // 待办事项示例
              const Text(
                "待办事项",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildTodoList(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建卡片按钮
  Widget _buildCardButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
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
