import 'dart:convert';

import 'package:rust_module/rust_module.dart' as rsCrypto;
import 'package:rust_module/src/rust/frb_generated.dart';

final vpnKey = utf8.encode("wrdvpnisthebest!");
final vpnIV = utf8.encode("wrdvpnisthebest!");
const String vpnBaseUrl = "https://v.guet.edu.cn";
const String vpnHost = "v.guet.edu.cn";

String getWebVPNUrl(String url) => rsCrypto.getWebVpnUrl(
    url: url, key: vpnKey, iv: vpnIV, vpnBaseUrl: vpnBaseUrl);

String getWebVPNOrdinaryUri(String url) =>
    rsCrypto.getWebVpnOrdinaryUrl(url: url, key: vpnKey, iv: vpnIV);

String getEncryptWebVpnHost(String host) =>
    rsCrypto.getEncryptWebVpnHost(plaintext: host, key: vpnKey, iv: vpnIV);

String getDecryptWebVpnHost(String host) =>
    rsCrypto.getDecryptWebVpnHost(ciphertext: host, key: vpnKey, iv: vpnIV);

Uri getOrdinaryUriIfNeed(Uri uri) {
  return uri.host == vpnHost
      ? Uri.parse(getWebVPNOrdinaryUri(uri.toString()))
      : uri;
}

Future<void> main() async {
  await RustLib.init();
  final url = 'https://bkjwtest.guet.edu.cn/student/home';
  print('From ordinary url: \n${getWebVPNUrl(url)}');

  final vpnUrl =
      'https://v.guet.edu.cn/https/77726476706e69737468656265737421e6b94689222426557a1dc7af96/';
  print('\nFrom webVPN url: \n${getWebVPNUrl(vpnUrl)}');
}
