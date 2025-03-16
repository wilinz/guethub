import 'package:json_annotation/json_annotation.dart';

part 'graduate_info.g.dart';

@JsonSerializable(explicitToJson: true)
class GraduateInfo {
  GraduateInfo(
      {required this.graduation,
      required this.degree,
      required this.gpa,
      required this.programId});

  @JsonKey(name: "graduation", defaultValue: "")
  String graduation;

  @JsonKey(name: "degree", defaultValue: "")
  String degree;

  @JsonKey(name: "gpa", defaultValue: "")
  String gpa;

  @JsonKey(name: "programId", defaultValue: "")
  String programId;

  factory GraduateInfo.fromJson(Map<String, dynamic> json) =>
      _$GraduateInfoFromJson(json);

  Map<String, dynamic> toJson() => _$GraduateInfoToJson(this);

  factory GraduateInfo.emptyInstance() =>
      GraduateInfo(graduation: "", degree: "", gpa: "", programId: "");
}
