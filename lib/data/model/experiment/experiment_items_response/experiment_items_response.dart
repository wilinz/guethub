import 'package:json_annotation/json_annotation.dart';

part 'experiment_items_response.g.dart';

@JsonSerializable(explicitToJson: true)
class ExperimentItemsResponse {

  ExperimentItemsResponse(
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
  List<Result> result;

  @JsonKey(name: "timestamp", defaultValue: 0)
  int timestamp;

  void setSubItemType(){
    for (final e in result) {
      for (final item in e.list) {
        item.type = e.type;
      }
    }
  }

  factory ExperimentItemsResponse.fromJson(Map<String, dynamic> json) => _$ExperimentItemsResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ExperimentItemsResponseToJson(this);
  
  factory ExperimentItemsResponse.emptyInstance() => ExperimentItemsResponse(success: false, message: "", code: 0, result: [], timestamp: 0);
}

@JsonSerializable(explicitToJson: true)
class ExperimentItems {

  ExperimentItems(
      {required this.name,
      required this.selectItem,
      required this.selectItemString,
      required this.id,
      required this.stuId,
      required this.relation,
      required this.type});

  @JsonKey(name: "name", defaultValue: "")
  String name;

  @JsonKey(name: "selectItem")
  String? selectItem;

  @JsonKey(name: "selectItemString")
  String? selectItemString;

  @JsonKey(name: "id", defaultValue: "")
  String id;

  @JsonKey(name: "stuId", defaultValue: "")
  String stuId;

  @JsonKey(name: "relation", defaultValue: "")
  String relation;

  @JsonKey(name: "type", defaultValue: "")
  String type;

  factory ExperimentItems.fromJson(Map<String, dynamic> json) => _$ExperimentItemsFromJson(json);
  
  Map<String, dynamic> toJson() => _$ExperimentItemsToJson(this);
  
  factory ExperimentItems.emptyInstance() => ExperimentItems(name: "", selectItem: null, selectItemString: null, id: "", stuId: "", relation: "", type: "");
}

@JsonSerializable(explicitToJson: true)
class Result {

  Result(
      {required this.selectCount,
      required this.needComplete,
      required this.type,
      required this.list});

  @JsonKey(name: "selectCount", defaultValue: 0)
  int selectCount;

  @JsonKey(name: "needComplete", defaultValue: 0)
  int needComplete;

  @JsonKey(name: "type", defaultValue: "")
  String type;

  @JsonKey(name: "list", defaultValue: [])
  List<ExperimentItems> list;


  factory Result.fromJson(Map<String, dynamic> json) => _$ResultFromJson(json);
  
  Map<String, dynamic> toJson() => _$ResultToJson(this);
  
  factory Result.emptyInstance() => Result(selectCount: 0, needComplete: 0, type: "", list: []);
}


