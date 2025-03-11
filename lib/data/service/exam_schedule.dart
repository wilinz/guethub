import 'dart:async';
import 'dart:convert';

import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:guethub/data/model/exam_schedule/exam_schedule.dart';
import 'package:guethub/data/model/exam_scheduling/exam_schedule.dart' as old;
import 'package:guethub/data/network.dart';
import 'package:guethub/data/util/md5sum.dart';
import 'package:guethub/data/util/section_finder.dart';
import 'package:guethub/util/datetime.dart';
import 'package:guethub/util/list.dart';
import 'package:html/parser.dart' as html_parser;

class ExamScheduleService {
  @Deprecated("Old system")
  static Future<old.ExamScheduleResponse> getExamSchedule({
    String term = "",
    int page = 1,
    int start = 0,
    int limit = 100,
  }) async {
    final resp =
        await AppNetwork.get().dio2.get("student/getexamap", queryParameters: {
      "_dc": DateTime.timestamp().millisecondsSinceEpoch,
      "term": term,
      "page": page,
      "start": start,
      "limit": limit,
    });
    return old.ExamScheduleResponse.fromJson(resp.data);
  }

  // https://bkjwtest.guet.edu.cn/student/for-std/exam-arrange
  // 302 to https://bkjwtest.guet.edu.cn/student/for-std/exam-arrange/info/104676
  static Future<List<ExamSchedule>> getExamScheduleNew({required int studentId}) async {
    final resp =
        await AppNetwork.get().bkjwTestDio.get("student/for-std/exam-arrange/info/${studentId}");
    final data = await compute<String, List<Map<String, dynamic>>>(
        _parseSchedules, resp.data);
    return examScheduleListFormJson(data);;
  }
}

(DateTime, DateTime) _parseTime(String time) {
  try {
// 提取日期部分
    String datePart = time.split(' ')[0];

// 将时间字符串按 `~` 分隔，并提取时间部分
    List<String> parts = time.split('~');
    if (parts.length == 2) {
      String startTimePart = parts[0].trim().split(' ')[1];
      String endTimePart = parts[1].trim();

      DateTime start = DateTime.parse('$datePart $startTimePart');
      DateTime end = DateTime.parse('$datePart $endTimePart');

      return (start, end);
    }
  } catch (e) {
    throw ExamSchedulingDatetimeParseError(e.toString());
  }
// 返回默认值以防解析失败
  throw ExamSchedulingDatetimeParseError("Exam time frame parsing failed! ");
}

// 将 parseSchedules 方法移到类外，作为顶级函数
List<Map<String, dynamic>> _parseSchedules(String html) {
  final document = html_parser.parse(html);
  final table = document.querySelector('#exams')!;
  final scheduleElements = table.querySelectorAll('tr[data-finished]');

  return scheduleElements.map((element) {
    final time = element.querySelector('.time')?.text.trim() ?? "";
    final spans = element
        .querySelector('.time ~ div')
        ?.getElementsByTagName("span")
        .filter((it) => it.text.isNotBlank);
    final campus = spans?.getOrNull(0)?.text.trim() ?? '';
    final building = spans?.getOrNull(1)?.text.trim() ?? '';
    final room = spans?.getOrNull(2)?.text.trim() ?? '';
    final course = element
            .querySelector('.tag-span')
            ?.parent
            ?.parent
            ?.querySelector('div:first-child span')
            ?.text
            .trim() ??
        '';
    final tag = element.querySelector('.tag-span')?.text.trim() ?? '';
    final status = element.querySelector('.text-center')?.text.trim() ?? '';

    final (startTime, endTime) = _parseTime(time);
    int section = findClosestSection(startTime, endTime)?.section ?? 1;

    return {
      'id': md5sum(course),
      'username': "",
      'time': time,
      'start_time': DateTimeUtils.toRfc3339(startTime),
      'end_time': DateTimeUtils.toRfc3339(endTime),
      'weekday': startTime.weekday,
      'section': section,
      'campus': campus,
      'building': building,
      'room': room,
      'course': course,
      'tag': tag,
      'status': status,
      'week': null, // 如果有需要，可以在这里计算 week 值
    };
  }).toList();
}

class ExamSchedulingDatetimeParseError implements Exception {
  final String message;

  ExamSchedulingDatetimeParseError(
      [this.message = 'Error parsing DateTime for exam scheduling.']);

  @override
  String toString() {
    return 'ExamSchedulingDatetimeParseError: $message';
  }
}
