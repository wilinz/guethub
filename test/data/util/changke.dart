import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:guethub/data/util/changke.dart';

void main() {
  test('QRCode Base64 解码后输入测试', () {
    // 提供的 Base64 字符串
    final String base64Str =
        "L2o/cD0wfhA5b2MhM34xNzQyMzQzODY0ZDc2NzM1YzA0NGZkMGNiYzM1ZTM4OGQ5NDBiZTFiZjEhNH4QMjRv";
    // 解码 Base64 得到原始字符串
    final decoded = utf8.decode(base64.decode(base64Str));
    // 传入解析函数
    final result = parseChangkeScanUrl(decoded);
    // 输出解析结果到控制台，便于调试
    print("Decoded QR code result: $result");
    // 这里只检查返回结果为 Map，你可以根据实际解析结果添加更多断言
    expect(result, isA<Map>());
  });
}