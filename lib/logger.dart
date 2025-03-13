import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:guethub/data/get_storage.dart';
import 'package:guethub/ui/settings/settings_controller.dart';
import 'package:logger/logger.dart';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/v4.dart';

/// Custom LogOutput that writes logs to a file
class FileOutput extends LogOutput {
  final File file;

  FileOutput(this.file);

  @override
  void output(OutputEvent event) {
    // Append the log messages to the file
    file.writeAsStringSync(
      event.lines.join('\n') + '\n',
      mode: FileMode.append,
      flush: true,
    );
  }
}

late Logger _logger;

Logger get logger => _logger;

late void Function(Object object) _loggerPrint;

void Function(Object object) get dioLoggerPrint => _loggerPrint;

late PrettyDioLogger _dioLogger;

PrettyDioLogger get dioLogger => _dioLogger;

final _onPrettyDioLoggerChangeEvent = BehaviorSubject<PrettyDioLogger>();

ValueStream<PrettyDioLogger> get onPrettyDioLoggerChangeEvent =>
    _onPrettyDioLoggerChangeEvent.stream;

Future<void> initLoggerOnLaunch() async {
  var level = kDebugMode ? Level.debug : Level.fatal;

  String? debugDeviceId = getStorage.read(SettingsKeys.debugDeviceIdKey);
  if (debugDeviceId == null) {
    debugDeviceId = UuidV4().generate();
    getStorage.write(SettingsKeys.debugDeviceIdKey, debugDeviceId);
  }
  final bool? isDebugMode = getStorage.read(SettingsKeys.debugModeKey);

  if (kDebugMode) {
    level = Level.all;
  } else if (isDebugMode == true) {
    final int? lastChangeDebugModeUnixTimestamp =
        getStorage.read(SettingsKeys.lastChangeDebugModeUnixTimestampKey);
    final lastChangeDebugModeTime = DateTime.fromMillisecondsSinceEpoch(
        lastChangeDebugModeUnixTimestamp ?? 0);
    if (DateTime.now().difference(lastChangeDebugModeTime).inMinutes > 60) {
      getStorage.write(SettingsKeys.debugModeKey, false);
      level = Level.fatal;
    } else {
      level = Level.all;
    }
  } else {
    level = Level.fatal;
  }

  await initLogger(level: level);
}

Future<void> initLogger({Level? level}) async {
  level ??= kDebugMode ? Level.debug : Level.fatal;
  final dir = await getApplicationSupportDirectory();
  // Specify the log file path
  File? file = File(join(dir.path, 'app.log'));
  try {
    if (!(await file.exists())) {
      await file.create(recursive: true);
    }
    if(!(await file.exists())){
      file = null;
    }
  } catch (e) {
    logger.d(e);
  }

  void loggerPrint(Object object) {
    if (level!.value <= Level.debug.value) {
      print(object);
      file?.writeAsStringSync(
        object.toString() + '\n',
        mode: FileMode.append,
        flush: true,
      );
    }
  }

  _loggerPrint = loggerPrint;

  if (level.value <= Level.debug.value) {
    _dioLogger = PrettyDioLogger(
      requestHeader: true,
      requestBody: false,
      responseBody: false,
      responseHeader: true,
      error: true,
      compact: true,
      maxWidth: 200,
      logPrint: dioLoggerPrint,
    );
  } else {
    _dioLogger = PrettyDioLogger(
      requestHeader: true,
      requestBody: false,
      responseBody: false,
      responseHeader: true,
      error: true,
      compact: false,
      maxWidth: 200,
      logPrint: dioLoggerPrint,
    );
  }

  _onPrettyDioLoggerChangeEvent.add(_dioLogger);

  // Initialize the logger with the custom FileOutput
  _logger = Logger(
      printer: PrettyPrinter(
          printEmojis: false,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart),
      // You can customize the printer as needed
      output: MultiOutput([
        ConsoleOutput(), // To also print logs to the console
        if (level.value <= Level.debug.value && file != null)
          FileOutput(file), // To write logs to the file
      ]),
      level: level);

}
