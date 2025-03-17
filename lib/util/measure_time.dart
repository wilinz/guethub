import 'dart:async';

FutureOr<T> measureTime<T>(FutureOr<T> Function() block, {String? label}) {
  final stopwatch = Stopwatch()..start();
  final result = block();
  if (result is Future<T>) {
    return result.then((value) {
      stopwatch.stop();
      _log(stopwatch, label);
      return value;
    });
  } else {
    stopwatch.stop();
    _log(stopwatch, label);
    return result;
  }
}

void _log(Stopwatch stopwatch, String? label) {
  final tag = label != null ? '[$label]' : '[TimeMeasure]';
  print('$tag took: ${stopwatch.elapsedMilliseconds} ms');
}
