import 'package:dart_extensions/dart_extensions.dart';
import 'package:get/get.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_buildings/empty_classroom_buildings.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_config/empty_classroom_config.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_query_body/empty_classroom_query_body.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_rooms/empty_classroom_rooms.dart';
import 'package:guethub/data/model/empty_classroom/empty_classroom_query_result/empty_classroom_query_result.dart';
import 'package:guethub/data/repository/empty_classroom_new.dart';

class EmptyClassroomNewController extends GetxController {
  final config = Rxn<EmptyClassroomConfig>();
  final buildings = <EmptyClassroomBuilding>[].obs;
  final rooms = <EmptyClassroomRoom>[].obs;

  // 选中的校区、教学楼、教室、教室类型、容量
  final selectedCampus = Rxn<Campus>();
  final selectedBuilding = Rxn<EmptyClassroomBuilding?>(null);
  final selectedRoom = Rxn<EmptyClassroomRoom?>(null);
  final selectedRoomType = Rxn<RoomType?>(null); // 允许为空
  final capacity = RxnInt();

  // 多选的周次、节次、星期几
  final selectedWeeks = <String>[].obs;
  final selectedUnits = <String>[].obs;
  final selectedWeekdays = <String>[].obs;

  // 起止日期字符串
  final startDatetime = RxnString();
  final endDatetime = RxnString();

  // 起止时间字符串
  final startTime = RxString("");
  final endTime = RxString("");

  // 切换状态：true 表示“按教学周”，false 表示“按日期”
  final isByWeek = true.obs;
  // 切换状态：true 表示“按时间”，false 表示“按节次”
  final isByTime = false.obs;

  // 全局加载 & 错误（用于初始加载配置）
  var isLoading = false.obs;
  var hasError = false.obs;

  // 局部加载状态：教学楼、教室
  var isLoadingBuildings = false.obs;
  var isLoadingRooms = false.obs;

  // 查询时局部加载，不覆盖全屏
  var isQueryLoading = false.obs;

  // 查询结果
  final queryResult = Rxn<EmptyClassroomQueryResult>();

  @override
  void onInit() {
    super.onInit();
    listener();
    getData();
  }

  void listener() {
    // 当校区变化时，获取教学楼
    selectedCampus.listen((data) {
      if (data != null) {
        getBuildings(campusId: data.value);
      } else {
        buildings.clear();
      }
    });
    // 当教学楼变化时，获取教室
    selectedBuilding.listen((data) {
      if (data != null) {
        getRooms(buildingId: data.id);
      } else {
        rooms.clear();
        selectedRoom.value = null;
      }
    });
  }

  // 获取基础配置（全局加载时使用）
  Future<void> getData() async {
    try {
      isLoading.value = true;
      config.value =
      await EmptyClassroomNewRepository.get().getEmptyClassroomConfig();
      selectedCampus(config.value?.campus.firstOrNull);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // 获取教学楼（局部加载，不影响全屏）
  Future<void> getBuildings({required int campusId}) async {
    try {
      isLoadingBuildings.value = true;
      buildings.value = await EmptyClassroomNewRepository.get()
          .getEmptyClassroomBuildings(campusId: campusId);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoadingBuildings.value = false;
    }
  }

  // 获取教室（局部加载，不影响全屏）
  Future<void> getRooms({required int buildingId}) async {
    try {
      isLoadingRooms.value = true;
      rooms.value = await EmptyClassroomNewRepository.get()
          .getEmptyClassroomRooms(buildingId: buildingId);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoadingRooms.value = false;
    }
  }

  /// 点击查询空教室（仅局部 loading，不全屏）
  Future<void> searchEmptyClassroom() async {
    isQueryLoading.value = true;
    hasError.value = false;
    queryResult.value = null;
    try {
      final body = EmptyClassroomQueryBody(
        campusId: selectedCampus.value!.value,
        buildingId: selectedBuilding.value?.id?.toString(),
        roomId: selectedRoom.value?.id?.toString(),
        roomType: selectedRoomType.value?.value, // 允许为 null
        seatsForLessonGte: capacity.value?.toString(),
        hasDataPermission: false,
        dateTimeSegmentCmd: DateTimeSegmentCmd(
          startDateTime: startDatetime.value,
          endDateTime: endDatetime.value,
          startTime: startTime.value,
          endTime: endTime.value,
          weeks: selectedWeeks.toList(),
          weekdays: selectedWeekdays.toList(),
          units: selectedUnits.toList(),
        ),
      );

      final result = await EmptyClassroomNewRepository.get()
          .queryEmptyClassroom(body: body);
      queryResult.value = result;
    } catch (e) {
      hasError.value = true;
    } finally {
      isQueryLoading.value = false;
    }
  }
}
