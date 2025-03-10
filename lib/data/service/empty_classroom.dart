import 'package:dart_extensions/dart_extensions.dart';
import 'package:dio/dio.dart';
import 'package:guethub/common/list.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:guethub/data/network.dart';

@Deprecated("Old system")
class EmptyClassroomPageParameters {
  final String viewState;
  final String eventValidation;

  EmptyClassroomPageParameters(
      {required this.viewState, required this.eventValidation});
}

@Deprecated("Old system")
class EmptyClassRoom {
  static final _url = "EmptyClassRoom.aspx";

  @Deprecated("Old system")
  static Future<EmptyClassroomPageParameters>
      getEmptyClassRoomPageParameters() async {
    final resp = await AppNetwork.get().casDio.get(_url);
    final doc = htmlParser.parse(resp.data);
    final viewState =
        doc.getElementById("__VIEWSTATE")?.attributes["value"] ?? "";
    final eventValidation =
        doc.getElementById("__EVENTVALIDATION")?.attributes["value"] ?? "";
    return EmptyClassroomPageParameters(
        viewState: viewState, eventValidation: eventValidation);
  }

  /// classroom: eg. "17211"
  /// date: eg. "2023-10-16"
  @Deprecated("Old system")
  static Future<List<EmptyClassroomData>> getEmptyClassRoom(
      {required String classroom,
      required String date,
      required int startSequence,
      required int endSequence}) async {
    final parameters = await getEmptyClassRoomPageParameters();
    final resp = await AppNetwork.get().casDio.post(_url,
        options: Options(
            contentType: AppNetwork.typeUrlEncode,
            responseType: ResponseType.plain),
        data: {
          "__EVENTTARGET": "",
          "__VIEWSTATEENCRYPTED": "",
          "__VIEWSTATE": parameters.viewState,
          "__EVENTVALIDATION": parameters.eventValidation,
          "txtcroomno": classroom,
          "txtdate": date,
          "txtstartsequence": startSequence,
          "txtendsequence": endSequence,
          "Button1": "确定"
        });
    try {
      final doc = htmlParser.parse(resp.data);
      final table = doc.getElementById("GridView1")!;
      final children = table.getElementsByTagName("tbody")[0].children;
      List<String> header = [];
      List<Map<String, String>> dataList = [];

      for (int i = 0; i < children.length; i++) {
            final row = children[i];
            if (i == 0) {
              header = row.children.mapList((e) => e.text.trim());
              continue;
            }
            final data = row.children
                .mapIndexed((i, e) => {header[i]: e.text.trim()})
                .toList();
            final resultMap = data.fold<Map<String, String>>(
              {},
              (previousValue, element) => previousValue..addAll(element),
            );
            dataList.add(resultMap);
          }

      return emptyClassroomListFromJson(dataList);
    } catch (e) {
      return [];
    }
  }
}
