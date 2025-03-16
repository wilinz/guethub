import 'package:dart_extensions/dart_extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_buildings/empty_classroom_buildings.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_config/empty_classroom_config.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_query_body/empty_classroom_query_body.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_query_result/empty_classroom_query_result.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_rooms/empty_classroom_rooms.dart';
import 'package:guethub/util/js.dart';
import 'package:guethub/util/string_ext.dart';
import 'package:html/parser.dart';
import 'package:json5/json5.dart';

class EmptyClassroomNewService {
  static Future<EmptyClassroomQueryResult> queryEmptyClassroom(Dio dio,
      {required EmptyClassroomQueryBody body}) async {
    final resp =
        await dio.post("student/ws/room-borrow/free-list", data: body.toJson());
    return EmptyClassroomQueryResult.fromJson(resp.data);
  }

  static Future<List<EmptyClassroomRoom>> getEmptyClassroomRooms(Dio dio,
      {required int buildingId,
      bool hasDataPermission = false,
      bool hasUsableDepartPermission = false}) async {
    final resp = await dio.get("student/ws/room/get-rooms", queryParameters: {
      'buildingId': buildingId,
      'hasDataPermission': hasDataPermission,
      'hasUsableDepartPermission': hasUsableDepartPermission
    });
    return emptyClassroomRoomsListFormJson(resp.data);
  }

  static Future<List<EmptyClassroomBuilding>> getEmptyClassroomBuildings(
      Dio dio,
      {required int campusId,
      bool hasDataPermission = false}) async {
    final resp = await dio.get("student/ws/room/get-buildings",
        queryParameters: {
          'campusId': campusId,
          'hasDataPermission': hasDataPermission
        });
    return emptyClassroomBuildingsListFormJson(resp.data);
  }

  static Future<EmptyClassroomConfig> getEmptyClassroomConfig(Dio dio) async {
    final resp = await dio.get("student/for-std/room-free");
    return await parseEmptyClassroomHtmlAsync(resp.data);
  }

  static Future<EmptyClassroomConfig> parseEmptyClassroomHtmlAsync(
          String html) =>
      compute(parseEmptyClassroomHtml, html);

  static EmptyClassroomConfig parseEmptyClassroomHtml(String html) {
    final doc = parse(html);
    final variableName = [
      "_semesterStart",
      "_semesterWeeks",
      "_units",
      "_campusList",
      "_roomTypeList",
      "_weekStartOnSunday"
    ];
    final scripts = doc
        .querySelectorAll('script:not([src])')
        .where((codeNode) =>
            variableName.all((field) => codeNode.text.contains(field)))
        .map((e) => e.text)
        .toList()
        .join('\n\n');
    final vars = getVariableByJavaScript(scripts, variableName);
    Map<String, dynamic> newVars = {};
    newVars['semesterStart'] = vars['_semesterStart']!.trimChars("'");
    newVars['semesterWeeks'] = vars['_semesterWeeks']!.toIntOrNull();
    newVars['units'] = json5Decode(vars['_units']!);
    newVars['campusList'] = json5Decode(vars['_campusList']!);
    newVars['roomTypeList'] = json5Decode(vars['_roomTypeList']!);
    newVars['weekStartOnSunday'] = bool.parse(vars['_weekStartOnSunday']!);
    return EmptyClassroomConfig.fromJson(newVars);
  }
}
