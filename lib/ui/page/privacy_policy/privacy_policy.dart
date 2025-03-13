import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends State<PrivacyPolicyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("隐私政策"),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MarkdownWidget(data: userAgreementContent),
      ),
    );
  }
}

const String userAgreementContent = """### **隐私政策（Privacy Policy）**

**最后更新日期：** 2025-3-13
**生效日期：** 2025-1-1

**1. 引言**
欢迎使用"GUET校园圈（GUETHUB）"（以下简称"本APP"）。我们高度重视您的隐私安全。本政策明确说明本APP如何处理您的个人信息，请在使用前仔细阅读。

**2. 信息收集与存储**

- **教务系统信息**：包括学号、密码、成绩、课表等数据仅通过桂林电子科技大学官方教务系统接口获取，且**100%存储于您设备的本地数据库**（SQLite/其他本地存储技术），不会上传至任何服务器。
- **设备权限**：本APP可能需要访问网络权限以同步教务数据。
- **设备标识符（Device ID）**：本APP可能会收集设备唯一标识符以用于**日活统计与分析**，但不会与个人身份信息关联。
    - **iOS**：identifierForVendor（存储至 Keychain 以保持持久性）
    - **Android**：Settings.Secure.ANDROID_ID
    - **Mac**：kIOPlatformUUIDKey
    - **Windows**：BIOS UUID
    - **Linux**：Machine ID


**3. 数据安全**

- 本地数据库采用设备系统提供的加密机制（如Android Keystore/iOS Keychain）以及系统沙箱功能隔离保护。
- 您的教务账号密码仅用于教务系统登录验证，仅存储于您的本地设备，不会上传到任何服务器。

**4. 数据共享与披露**

- **零共享原则**：我们不会将您的个人信息与任何第三方共享，除非获得您明确授权或法律强制要求。
- 匿名化统计数据可能用于优化APP功能，但不包含任何个人身份信息。

**5. 用户权利**

- 您可随时通过卸载APP或者使用设备文件管理功能删除本地数据库文件，彻底移除所有个人信息。

**6. 政策更新**
更新后的政策将通过APP内公告通知。继续使用视为接受修订内容。""";
