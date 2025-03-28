// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment_grouped_items_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExperimentGroupedItemsResponse _$ExperimentGroupedItemsResponseFromJson(
        Map<String, dynamic> json) =>
    ExperimentGroupedItemsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      code: (json['code'] as num?)?.toInt() ?? 0,
      result: (json['result'] as List<dynamic>?)
              ?.map((e) =>
                  ExperimentGroupedItems.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ExperimentGroupedItemsResponseToJson(
        ExperimentGroupedItemsResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'code': instance.code,
      'result': instance.result.map((e) => e.toJson()).toList(),
      'timestamp': instance.timestamp,
    };

ItemList _$ItemListFromJson(Map<String, dynamic> json) => ItemList(
      schoolTime: json['schoolTime'] as String? ?? '',
      time: json['time'] as String? ?? '',
      subjectId: json['subjectId'] as String? ?? '',
      subjectName: json['subjectName'] as String? ?? '',
      beginSection: json['beginSection'] as String? ?? '',
    );

Map<String, dynamic> _$ItemListToJson(ItemList instance) => <String, dynamic>{
      'schoolTime': instance.schoolTime,
      'time': instance.time,
      'subjectId': instance.subjectId,
      'subjectName': instance.subjectName,
      'beginSection': instance.beginSection,
    };

GroupInfo _$GroupInfoFromJson(Map<String, dynamic> json) => GroupInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      calendarId: json['calendarId'] as String? ?? '',
      targetString: json['targetString'] as String? ?? '',
      ruleTargetId: json['ruleTargetId'] as String? ?? '',
      ruleType: (json['ruleType'] as num?)?.toInt() ?? 0,
      maxConflict: (json['maxConflict'] as num?)?.toInt() ?? 0,
      selectEndTime: json['selectEndTime'] as String? ?? '',
      selectBeginTime: json['selectBeginTime'] as String? ?? '',
      publishFlag: (json['publishFlag'] as num?)?.toInt() ?? 0,
      createBy: json['createBy'] as String? ?? '',
      createTime: json['createTime'] as String? ?? '',
    );

Map<String, dynamic> _$GroupInfoToJson(GroupInfo instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'courseId': instance.courseId,
      'calendarId': instance.calendarId,
      'targetString': instance.targetString,
      'ruleTargetId': instance.ruleTargetId,
      'ruleType': instance.ruleType,
      'maxConflict': instance.maxConflict,
      'selectEndTime': instance.selectEndTime,
      'selectBeginTime': instance.selectBeginTime,
      'publishFlag': instance.publishFlag,
      'createBy': instance.createBy,
      'createTime': instance.createTime,
    };

ExperimentGroupedItems _$ExperimentGroupedItemsFromJson(
        Map<String, dynamic> json) =>
    ExperimentGroupedItems(
      maxConflict: (json['maxConflict'] as num?)?.toInt() ?? 0,
      selectCount: (json['selectCount'] as num?)?.toInt() ?? 0,
      hasSelect: json['hasSelect'] as bool? ?? false,
      itemList: (json['itemList'] as List<dynamic>?)
              ?.map((e) => ItemList.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      groupInfo: json['groupInfo'] == null
          ? GroupInfo.emptyInstance()
          : GroupInfo.fromJson(json['groupInfo'] as Map<String, dynamic>),
      sort: json['sort'] as String? ?? '',
      maxCount: (json['maxCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ExperimentGroupedItemsToJson(
        ExperimentGroupedItems instance) =>
    <String, dynamic>{
      'maxConflict': instance.maxConflict,
      'selectCount': instance.selectCount,
      'hasSelect': instance.hasSelect,
      'itemList': instance.itemList.map((e) => e.toJson()).toList(),
      'groupInfo': instance.groupInfo.toJson(),
      'sort': instance.sort,
      'maxCount': instance.maxCount,
    };
