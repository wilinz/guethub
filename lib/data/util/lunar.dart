import 'package:dart_extensions/dart_extensions.dart';
import 'package:intl/intl.dart';
import 'package:lunar/lunar.dart';

class AdjustedWorkday {
  String name;
  final DateTime target;
  final DateTime adjustedWorkday;
  final DateTime originalDay;
  int originalWeek;
  int adjustedWeek;

  AdjustedWorkday({
    required this.name,
    required this.target,
    required this.adjustedWorkday,
    required this.originalDay,
    this.adjustedWeek = -1,
    this.originalWeek = -1,
  });

  // factory AdjustedWorkday.fromJson(Map<String, String> map) {
  //   return AdjustedWorkday(
  //     name: map['name']!,
  //     target: map['target']!,
  //     adjustedWorkday: map['adjusted_workday']!,
  //     originalDay: map['original_day']!,
  //   );
  // }
  //
  // Map<String, String> toJson() {
  //   return {
  //     'name': name,
  //     'target': target,
  //     'adjusted_workday': adjustedWorkday,
  //     'original_day': originalDay,
  //   };
  // }
}

class HolidayInfo {
  final String holidayName;
  final List<DateTime> holidayDates;
  final List<AdjustedWorkday> adjustedMapping;
  final String target;

  HolidayInfo({
    required this.holidayName,
    required this.holidayDates,
    required this.adjustedMapping,
    required this.target,
  });

// factory HolidayInfo.fromJson(Map<String, dynamic> map) {
//   return HolidayInfo(
//     holidayName: map['holiday_name'],
//     target: map['target'],
//     holidayDates: List<String>.from(map['holiday_dates']).map(),
//     adjustedMapping: (map['adjusted_mapping'] as List)
//         .map((e) => AdjustedWorkday.fromJson(Map<String, String>.from(e)))
//         .toList(),
//   );
// }
//
// Map<String, dynamic> toJson() {
//   return {
//     'holiday_name': holidayName,
//     "target": target,
//     'holiday_dates': holidayDates,
//     'adjusted_mapping': adjustedMapping.map((e) => e.toJson()).toList(),
//   };
// }
}

// 计算假期调休关系的函数
List<AdjustedWorkday> _calculateAdjustedWorkdayRelationship(
    {required List<Holiday> holidays, // 假期列表
    required String holidayName, // 假期名称
    required int Function(String holidayName) getHolidayLength}) {
  // 用于获取假期长度的函数
  final dataTimeFormat = DateFormat("yyyy-MM-dd"); // 定义日期格式化工具，将日期格式化为字符串

  // 将每个假期的日期解析成 DateTime 对象
  final holidayDays =
      holidays.map((e) => dataTimeFormat.parse(e.getDay())).toList();

  // 过滤出不包含调休的假期
  final trueHoliday = holidays.filter((e) => !e.isWork()).toList();

  // 将不包含调休的假期解析成 DateTime 对象
  final trueHolidayDays =
      trueHoliday.map((e) => dataTimeFormat.parse(e.getDay())).toList();

  // 获取不包含调休假期的开始日期
  final holidayRawStartDay =
      dataTimeFormat.parse(trueHoliday.first.getTarget());

  // 获取假期的原始长度
  final holidayRawLength = getHolidayLength(holidayName);

  // 创建一个保存假期原始天数的列表
  final holidayRawDays = <DateTime>[];

  // 根据假期长度添加每一天的日期到列表中
  for (int i = 0; i < holidayRawLength; i++) {
    holidayRawDays.add(holidayRawStartDay.add(Duration(days: i)));
  }
  // 创建假期天数的副本
  final holidayRawDaysCopy = List.from(holidayRawDays);

  var i = 1; // 用于追踪日期的增量
  for (final day in holidayRawDays) {
    // 检查原始长度假期的每一天是否是周末
    if (day.isWeekend()) {
      // 如果是周末，则向后寻找下一个非周末的工作日
      var newDay =
          holidayRawDays[holidayRawDays.length - 1].add(Duration(days: i));
      while (true) {
        // 如果新的日期也是周末，则继续加一天，跳过周末
        if (newDay.isWeekend()) {
          i++;
          newDay = newDay.add(Duration(days: 1));
        } else {
          break; // 找到非周末的日期，跳出循环
        }
      }
      // 将这个新找到的日期添加到假期副本列表中
      holidayRawDaysCopy.add(newDay);
      i++; // 增加日期的增量
    }
  }

  // 创建一个列表，保存原始的调休工作日
  final originalDaysByAdjustedWorkDays = <DateTime>[];
  for (final day in trueHolidayDays) {
    // 如果日期既不是周末也不在调休假期中，则将其加入调休工作日列表
    if (!day.isWeekend() && !holidayRawDaysCopy.contains(day)) {
      originalDaysByAdjustedWorkDays.add(day);
    }
  }

  // 筛选出调休后的工作日
  final adjustedWorkDays =
      holidayDays.where((day) => !trueHolidayDays.contains(day)).toList();

  // 创建一个列表，保存调休后的工作日信息
  final adjustedDaysList = <AdjustedWorkday>[];
  for (int j = 0; j < adjustedWorkDays.length; j++) {
    // 将调休后的工作日信息存入 AdjustedWorkday 对象，并加入到列表中
    final adjustedDaysMap = AdjustedWorkday(
      name: holidayName,
      target: _dateTimeFormat.parse(trueHoliday.last.getTarget()),
      adjustedWorkday: adjustedWorkDays[j],
      originalDay: originalDaysByAdjustedWorkDays[j],
    );
    adjustedDaysList.add(adjustedDaysMap);
  }

  // 返回调休后的工作日列表
  return adjustedDaysList;
}

final _dateTimeFormat = DateFormat("yyyy-MM-dd");

List<HolidayInfo> _getHolidayInfoWithAdjustedMapping(
    List<Holiday> holidays, List<AdjustedWorkday> adjustedWorkdays) {
  final rawAdjustedWorkdays = holidays.where((holiday) => holiday.isWork());
  final actualHolidays = holidays.where((holiday) => !holiday.isWork());

  final groupedHolidays =
      holidays.groupBy((Holiday holiday) => holiday.getName());
  return groupedHolidays.keys.map((holidayName) {
    return HolidayInfo(
        holidayName: holidayName,
        target: actualHolidays
            .where((holiday) => holiday.getName() == holidayName)
            .first
            .getDay(),
        holidayDates: actualHolidays
            .where((holiday) => holiday.getName() == holidayName)
            .map((holiday) => _dateTimeFormat.parse(holiday.getDay()))
            .toList(),
        adjustedMapping: rawAdjustedWorkdays
            .where((workdayHoliday) => workdayHoliday.getName() == holidayName)
            .map((workdayHoliday) {
          return adjustedWorkdays.firstOrNullWhere((adjustedWorkday) =>
              adjustedWorkday.adjustedWorkday == _dateTimeFormat.parse(workdayHoliday.getDay()))!
            ..name = holidayName;
        }).toList());
  }).toList();
}

List<HolidayInfo> getYearHolidays(int year) {
  final holidaysYear = HolidayUtil.getHolidaysByYear(year); // 获取2024年的假期列表
  if(year == 2025) {
    holidaysYear.add(Holiday("2025-03-29", "广西三月三", false, "2025-03-31"));
    holidaysYear.add(Holiday("2025-03-30", "广西三月三", false, "2025-03-31"));
    holidaysYear.add(Holiday("2025-03-31", "广西三月三", false, "2025-03-31"));
    holidaysYear.add(Holiday("2025-04-01", "广西三月三", false, "2025-03-31"));
  }
  final nationalDayAndMidAutumnFestival =
      holidaysYear.firstOrNullWhere((e) => e.getName() == "国庆中秋") != null;

  // 按假期名称分组
  final holidays = holidaysYear.groupBy((Holiday e) => _getHolidayGroupName(e));

  // 计算调休工作日关系
  final adjustedMappingData = holidays.entries
      .map((e) => _calculateAdjustedWorkdayRelationship(
          holidays: e.value,
          holidayName: _getHolidayGroupName(e.value.first),
          getHolidayLength: (name) =>
              _getHolidayLength(name, nationalDayAndMidAutumnFestival, year)))
      .where((it) => it.isNotEmpty) // 过滤掉没有调休的假期
      .toList();

  // 调用新函数，将 holidays 和 result 结合，获取完整的节日信息
  final holidayInfoList = _getHolidayInfoWithAdjustedMapping(
      holidaysYear, adjustedMappingData.expand((e) => e).toList());

  return holidayInfoList;
}

// 获取假期长度的函数
int _getHolidayLength(
    String name, bool nationalDayAndMidAutumnFestival, int year) {
  if (year >= 2025) {
    if (name == '春节') return 4;
    if (name == '劳动节') return 2;
  }
  if (RegExp("春节|国庆").hasMatch(name)) {
    // 如果是"国庆"且同时有"国庆中秋"，返回4天假期长度
    if (nationalDayAndMidAutumnFestival && name.contains("国庆")) {
      return 4;
    }
    return 3;
  }
  return 1; // 其他假期返回1天假期长度
}

// 获取假期分组名称的函数
String _getHolidayGroupName(Holiday e) => e.getName().contains("国庆中秋")
    ? e.getName().replaceAll("国庆中秋", "国庆节") // 替换"国庆中秋"为"国庆节"
    : e.getName(); // 其他假期返回原名称

// 为 DateTime 扩展的一个方法，用于判断某天是否为周末
extension _WeekendExt on DateTime {
  bool isWeekend() {
    return weekday == 6 || weekday == 7; // 判断当前日期是否为周六或周日
  }
}
