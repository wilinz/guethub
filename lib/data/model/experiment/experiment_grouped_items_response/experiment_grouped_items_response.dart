import 'package:json_annotation/json_annotation.dart';

part 'experiment_grouped_items_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ExperimentGroupedItemsResponse {

  ExperimentGroupedItemsResponse(
      {required this.success,
      required this.message,
      required this.code,
      required this.result,
      required this.timestamp});

  @JsonKey(name: "success", defaultValue: false)
  bool success;

  @JsonKey(name: "message", defaultValue: "")
  String message;

  @JsonKey(name: "code", defaultValue: 0)
  int code;

  @JsonKey(name: "result", defaultValue: [])
  List<ExperimentGroupedItems> result;

  @JsonKey(name: "timestamp", defaultValue: 0)
  int timestamp;


  factory ExperimentGroupedItemsResponse.fromJson(Map<String, dynamic> json) => _$ExperimentGroupedItemsResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ExperimentGroupedItemsResponseToJson(this);
  
  factory ExperimentGroupedItemsResponse.emptyInstance() => ExperimentGroupedItemsResponse(success: false, message: "", code: 0, result: [], timestamp: 0);
}

@JsonSerializable(explicitToJson: true)
class ItemList {

  ItemList(
      {required this.schoolTime,
      required this.time,
      required this.subjectId,
      required this.subjectName,
      required this.beginSection});

  @JsonKey(name: "schoolTime", defaultValue: "")
  String schoolTime;

  @JsonKey(name: "time", defaultValue: "")
  String time;

  @JsonKey(name: "subjectId", defaultValue: "")
  String subjectId;

  @JsonKey(name: "subjectName", defaultValue: "")
  String subjectName;

  @JsonKey(name: "beginSection", defaultValue: "")
  String beginSection;


  factory ItemList.fromJson(Map<String, dynamic> json) => _$ItemListFromJson(json);
  
  Map<String, dynamic> toJson() => _$ItemListToJson(this);
  
  factory ItemList.emptyInstance() => ItemList(schoolTime: "", time: "", subjectId: "", subjectName: "", beginSection: "");
}

@JsonSerializable(explicitToJson: true)
class GroupInfo {

  GroupInfo(
      {required this.id,
      required this.name,
      required this.courseId,
      required this.calendarId,
      required this.targetString,
      required this.ruleTargetId,
      required this.ruleType,
      required this.maxConflict,
      required this.selectEndTime,
      required this.selectBeginTime,
      required this.publishFlag,
      required this.createBy,
      required this.createTime});

  @JsonKey(name: "id", defaultValue: "")
  String id;

  @JsonKey(name: "name", defaultValue: "")
  String name;

  @JsonKey(name: "courseId", defaultValue: "")
  String courseId;

  @JsonKey(name: "calendarId", defaultValue: "")
  String calendarId;

  @JsonKey(name: "targetString", defaultValue: "")
  String targetString;

  @JsonKey(name: "ruleTargetId", defaultValue: "")
  String ruleTargetId;

  @JsonKey(name: "ruleType", defaultValue: 0)
  int ruleType;

  @JsonKey(name: "maxConflict", defaultValue: 0)
  int maxConflict;

  @JsonKey(name: "selectEndTime", defaultValue: "")
  String selectEndTime;

  @JsonKey(name: "selectBeginTime", defaultValue: "")
  String selectBeginTime;

  @JsonKey(name: "publishFlag", defaultValue: 0)
  int publishFlag;

  @JsonKey(name: "createBy", defaultValue: "")
  String createBy;

  @JsonKey(name: "createTime", defaultValue: "")
  String createTime;


  factory GroupInfo.fromJson(Map<String, dynamic> json) => _$GroupInfoFromJson(json);
  
  Map<String, dynamic> toJson() => _$GroupInfoToJson(this);
  
  factory GroupInfo.emptyInstance() => GroupInfo(id: "", name: "", courseId: "", calendarId: "", targetString: "", ruleTargetId: "", ruleType: 0, maxConflict: 0, selectEndTime: "", selectBeginTime: "", publishFlag: 0, createBy: "", createTime: "");
}

@JsonSerializable(explicitToJson: true)
class ExperimentGroupedItems {

  ExperimentGroupedItems(
      {required this.maxConflict,
      required this.selectCount,
      required this.hasSelect,
      required this.itemList,
      required this.groupInfo,
      required this.sort,
      required this.maxCount});

  @JsonKey(name: "maxConflict", defaultValue: 0)
  int maxConflict;

  @JsonKey(name: "selectCount", defaultValue: 0)
  int selectCount;

  @JsonKey(name: "hasSelect", defaultValue: false)
  bool hasSelect;

  @JsonKey(name: "itemList", defaultValue: [])
  List<ItemList> itemList;

  @JsonKey(name: "groupInfo", defaultValue: GroupInfo.emptyInstance)
  GroupInfo groupInfo;

  @JsonKey(name: "sort", defaultValue: "")
  String sort;

  @JsonKey(name: "maxCount", defaultValue: 0)
  int maxCount;


  factory ExperimentGroupedItems.fromJson(Map<String, dynamic> json) => _$ExperimentGroupedItemsFromJson(json);
  
  Map<String, dynamic> toJson() => _$ExperimentGroupedItemsToJson(this);
  
  factory ExperimentGroupedItems.emptyInstance() => ExperimentGroupedItems(maxConflict: 0, selectCount: 0, hasSelect: false, itemList: [], groupInfo: GroupInfo.emptyInstance(), sort: "", maxCount: 0);
}


