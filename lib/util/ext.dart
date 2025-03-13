import 'dart:math';

import 'package:guethub/common/encrypt/webvpn_new.dart';
import 'package:guethub/data/network.dart';
import 'package:intl/intl.dart';

import '../common/encrypt/webvpn.dart';

extension ListRotateExtension<T> on List<T> {
  /// 随机获取一个索引，并将该索引之前的元素移动到列表末尾
  void rotateFromRandomIndex() {
    if (this.isEmpty) return;

    final randomIndex = Random().nextInt(this.length);
    final firstPart = this.sublist(0, randomIndex);
    final secondPart = this.sublist(randomIndex);

    // 清空列表并重新添加元素
    this
      ..clear()
      ..addAll(secondPart)
      ..addAll(firstPart);
  }
}

extension UriExtension on Uri {
  Uri toWebVpnUrl() {
    // return Uri.parse(this.toString() + "/");
    return Uri.parse(getWebVPNUrl(this.toString()));
  }

  Uri removeQueryParams() {
    return replace(queryParameters: {});
  }

  /// 获取Uri的基本URL（协议+域名）+ "/"
  String getBaseUrl() {
    // 确保Uri包含有效的主机名
    if (this.host.isEmpty) {
      throw ArgumentError("Uri does not contain a valid host.");
    }

    // 构建基本URL
    String baseUrl = '${this.scheme}://${this.host}';

    // 如果Uri指定了非标准端口，也包含在内
    if (this.hasPort && !isStandardPortForScheme(this.scheme, this.port)) {
      baseUrl += ':${this.port}';
    }

    return baseUrl + "/";
  }

  /// 判断指定的端口是否为给定协议的标准端口
  bool isStandardPortForScheme(String scheme, int port) {
    switch (scheme.toLowerCase()) {
      case 'http':
        return port == 80;
      case 'https':
        return port == 443;
      default:
        // 对于其他协议，没有清晰的"标准"端口定义，因此默认为非标准
        return false;
    }
  }
}

extension NumExtension on num {
  num abs() => this < 0 ? -this : this;
}

extension DateTimeExtensions on DateTime {
  String formattedString(String format) {
    return DateFormat(format).format(this);
  }

  String timeAgoString({String? suffix}) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(this);

    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    List<String> parts = [];

    if (hours > 0) {
      parts.add('${hours.toString()}小时');
    }
    if (minutes > 0 || hours > 0) {
      parts.add('${minutes.toString()}分');
    }
    parts.add('${seconds.toString()}秒');

    return parts.join('') + (suffix ?? "");
  }
}
