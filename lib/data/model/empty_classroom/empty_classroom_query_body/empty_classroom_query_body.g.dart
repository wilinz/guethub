// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empty_classroom_query_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmptyClassroomQueryBody _$EmptyClassroomQueryBodyFromJson(
        Map<String, dynamic> json) =>
    EmptyClassroomQueryBody(
      buildingId: json['buildingId'] as String?,
      campusId: (json['campusId'] as num?)?.toInt() ?? 0,
      roomId: json['roomId'] as String?,
      dateTimeSegmentCmd: json['dateTimeSegmentCmd'] == null
          ? DateTimeSegmentCmd.emptyInstance()
          : DateTimeSegmentCmd.fromJson(
              json['dateTimeSegmentCmd'] as Map<String, dynamic>),
      roomType: (json['roomType'] as num?)?.toInt(),
      seatsForLessonGte: json['seatsForLessonGte'] as String?,
      hasDataPermission: json['hasDataPermission'] as bool? ?? false,
    );

Map<String, dynamic> _$EmptyClassroomQueryBodyToJson(
        EmptyClassroomQueryBody instance) =>
    <String, dynamic>{
      'buildingId': instance.buildingId,
      'campusId': instance.campusId,
      'roomId': instance.roomId,
      'dateTimeSegmentCmd': instance.dateTimeSegmentCmd.toJson(),
      'roomType': instance.roomType,
      'seatsForLessonGte': instance.seatsForLessonGte,
      'hasDataPermission': instance.hasDataPermission,
    };

DateTimeSegmentCmd _$DateTimeSegmentCmdFromJson(Map<String, dynamic> json) =>
    DateTimeSegmentCmd(
      startDateTime: json['startDateTime'] as String?,
      endDateTime: json['endDateTime'] as String?,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      weeks:
          (json['weeks'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      weekdays: (json['weekdays'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      units:
          (json['units'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
    );

Map<String, dynamic> _$DateTimeSegmentCmdToJson(DateTimeSegmentCmd instance) =>
    <String, dynamic>{
      'startDateTime': instance.startDateTime,
      'endDateTime': instance.endDateTime,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'weeks': instance.weeks,
      'weekdays': instance.weekdays,
      'units': instance.units,
    };
