import 'package:get/get.dart';

class ChangkeController extends GetxController {
  // 示例状态：夜间提示
  var greeting = "夜深了，请注意休息".obs;

  // 最近访问的示例数据
  var recentItems = <String>[
    "模式识别（双语教学）",
    "计算机视觉（双语教学）",
  ].obs;

  Future<void> scanQr() async {

  }

// 其他需要的状态、方法等
// ...
}