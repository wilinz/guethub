import 'package:get/get.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/service/changke.dart';
import 'package:guethub/data/util/changke.dart';
import 'package:guethub/logger.dart';
import 'package:guethub/ui/page/changke/scan_qr.dart';
import 'package:guethub/ui/page/changke/sign_result.dart';
import 'package:guethub/ui/util/toast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ChangkeController extends GetxController {
  // 示例状态：夜间提示
  var greeting = "夜深了，请注意休息".obs;

  // 最近访问的示例数据
  var recentItems = <String>[
    "模式识别（双语教学）",
    "计算机视觉（双语教学）",
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _updateGreeting();
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      greeting.value = "早上好，今天也是充满活力的一天！";
    } else if (hour >= 12 && hour < 18) {
      greeting.value = "下午好，保持充实的一天！";
    } else if (hour >= 18 && hour < 24) {
      greeting.value = "晚上好，放松一下吧！";
    } else {
      greeting.value = "夜深了，请注意休息";
    }
  }

  Future<void> scanQr() async {

    if(GetPlatform.isMobile) {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        toast("请允许相机权限才能进行扫描二维码");
        return;
      }
    }

    final codeResult = await Get.to<BarcodeCapture>(() => Scan());
    final code = codeResult?.barcodes.firstOrNull?.rawValue;
    if(code == null){
      toastFailure0("未识别到二维码");
      return;
    }

    final codeData = parseChangkeScanUrl(code);

    if (!(codeData is Map)) {
      toastFailure0("二维码格式错误: ${codeData.runtimeType}");
      return;
    }

    final rollcallId = codeData['rollcallId']?.toString();
    final data = codeData['data'];

    if (rollcallId == null || data == null) {
      toastFailure0("二维码格式错误");
      return;
    }
    toast("正在签到，请稍后");

    final deviceId = Uuid().v4();
    final resp = await ChangKeService.signQr(await AppNetwork.get().changkeDio,
        rollcallId: rollcallId, data: data, deviceId: deviceId);
    final message = resp['message'];
    final mappingMessage = getMappingMessage(message);

    Get.to(() => ChangkeSignResult(successful: true, message: mappingMessage));
    logger.i("签到结果：${message}");
  }

  String getMappingMessage(String key) => messageMap[key] ?? key;

  final messageMap = {
    "rollcall_closed": "二维码签到已结束",
    "device_used": "该设备已签到，请更换设备重新扫描",
    "QR_code_expired": "签到二维码已过期",
    "unknown_student": "您还不是本课学生，请先加入课程",
    "failed": "签到失败，请及时告知老师",
    "wrongNumberCode": "签到密码错误，请重试",
    "rollcallFinished": "签到失败，点名已结束",
    "getPositionFailed": "获取位置信息失败",
    "getPositionFailedTimeout": "获取位置信息超时",
    "getPositionFailedPermissionDeined": "没有权限获取定位信息",
    "getPositionFailedUnavailable": "获取定位信息功能不可用",
    "retry": "签到失败，请重试",
    "outofScope": "当前定位信息获取异常，可能导致签到失败，请尝试重新签到",
    "fetchStudentsError": "学生信息获取失败，请稍后重试",
    "deviceAlreadyInUse": "已有学生使用该设备签到，请更换设备再试",

    "answer": "去签到",
    "answered": "已签到",
    "updatedAt": "最后修改时间",
    "inProgress": "进行中",
    "searchPlaceholder": "姓名/人员编号",
    "discardChangesConfirm": "点名结果已更改，是否保存？",
    "deleteConfirm": "是否删除此点名？",
    "history": "点名记录",
    "haveRollcallInProgress": "已有进行中的点名，将自动进入",
    "success": "签到成功",
    "failed": "签到失败",
    "pleaseInputPassword": "请输入签到密码",

    "rollcallCode": "签到密码",
    "noTimeLimit": "不限时",
    "absent": "未到",
    "numberRollcallInProgressJoinConfirm": "数字点名正在进行，是否签到？",
    "total": "全部",
    "radarToggleTip": "你需要开启位置才能点名哦!",
    "doNotLeaveAnswerPage": "正在尝试签到，请勿离开此页面",
    "noRollcallRecord": "没有任何点名记录",
    "notCreateRollcall": "课程在此时间内无课表信息，无法发起点名",
  };
}
