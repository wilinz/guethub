import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

class UserAgreementPage extends StatefulWidget {
  const UserAgreementPage({super.key});

  @override
  State<UserAgreementPage> createState() => _UserAgreementPageState();
}

class _UserAgreementPageState extends State<UserAgreementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("用户协议"),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MarkdownWidget(data: userAgreementContent),
      ),
    );
  }
}

const String userAgreementContent = """### **用户协议（User Agreement）**

**最后更新日期：** 2025-1-1  
**生效日期：** 2025-1-1

**1. 服务说明**  
本APP为桂林电子科技大学学生提供课程表查询、成绩查看等校园服务，所有功能均基于教务系统数据本地化处理。

**_[注：本APP为第三方工具，与桂林电子科技大学无官方隶属关系]_**

**2. 用户责任**

- 您需保证提供的账号信息真实有效，且为本人所有
- **禁止**下列行为：  
  ✓ 利用本APP或其开源代码进行数据爬取、开发抢课脚本、自动化请求等干扰教务系统正常运行的行为  
  ✓ 任何违反《中华人民共和国网络安全法》《桂林电子科技大学学生守则》的行为

**3. 知识产权**  
3.1 本APP基于 **Mozilla Public License 2.0** 开源，您须遵守以下条款：

- 源代码使用需保留原始版权声明（包含于LICENSE文件）
- 修改后的代码必须遵循相同开源协议公开  ·

3.2 教务系统数据（含课程表、成绩等）所有权归属桂林电子科技大学，本APP仅为信息展示工具，不持有相关数据权利

**4. 免责声明**  
4.1 技术风险免责：  
✓ 因教务系统接口变更导致的功能失效  
✓ 设备故障/系统升级导致的本地数据丢失  
✓ 不可抗力（网络中断、自然灾害等）

4.2 法律风险免责：

- 如因您实施以下行为产生法律后果，需**自行承担全部责任**：  
  ✓ 利用本APP及其开源代码开发违反国家法律的应用程序  
  ✓ 通过本APP及其开源代码实施侵害他人隐私/知识产权行为
  ✓ 通过本APP及其开源代码实施其他违法行为

**5. 协议终止**  
5.1 您可随时卸载APP终止服务

**6. 争议解决**  
6.1 本协议适用中华人民共和国法律

**7. 协议更新**  

7.1 更新后的协议将通过APP内公告通知。继续使用视为接受修订内容。
""";
