import 'dart:math';

String getRandomUserAgent() {
  List<String> platforms = [
    "Windows NT 10.0; Win64; x64",
    "Macintosh; Intel Mac OS X 10_15_7",
    "X11; Linux x86_64",
    "Android 10; Mobile",
    "iPhone; CPU iPhone OS 14_0 like Mac OS X",
  ];

  List<String> browsers = [
    "Chrome/" + (80 + Random().nextInt(30)).toString() + ".0.0.0",
    "Firefox/" + (70 + Random().nextInt(20)).toString() + ".0",
    "Safari/537.36",
    "Edge/" + (90 + Random().nextInt(10)).toString() + ".0.0.0",
  ];

  String platform = platforms[Random().nextInt(platforms.length)];
  String browser = browsers[Random().nextInt(browsers.length)];

  return "Mozilla/5.0 ($platform) AppleWebKit/537.36 (KHTML, like Gecko) $browser";
}

void main() {
  print(getRandomUserAgent());
}