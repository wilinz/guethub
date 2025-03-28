import 'package:dio/dio.dart';
import 'package:guethub/data/model/experiment/experiment_batch_response/experiment_batch_response.dart';
import 'package:guethub/data/model/experiment/experiment_common_response/experiment_common_response.dart';
import 'package:guethub/data/model/experiment/experiment_courses_response/experiment_courses_response.dart';
import 'package:guethub/data/model/experiment/experiment_grouped_items_response/experiment_grouped_items_response.dart';
import 'package:guethub/data/model/experiment/experiment_items_response/experiment_items_response.dart';
import 'package:guethub/data/model/experiment/teacher_calendar_response/teacher_calendar_response.dart';
import 'package:guethub/data/redirect_interceptor.dart';
import 'package:guethub/logger.dart';

class ExperimentService {
  /// Add to x-access-token header
  static Future<String> getToken(Dio dio) async {
    final resp = await dio.get(
        "student/for-std/extra-system/newcapec-experiment/course/stu",
        options: Options(extra: {RedirectInterceptor.followRedirects: false}));
    final location = resp.headers.value('location');
    if (location == null) {
      throw Exception("获取token失败");
    }
    final uri = Uri.parse(location.replaceAll(
        "?bizTypeId=2#", Uri.encodeComponent("?bizTypeId=2#")));
    final token0 = uri.queryParameters["token"];
    if (token0 == null) {
      throw Exception("获取token失败");
    }

    final authResp = await dio.get(
        "guet-lab-system/api/authentication/getAccessTokenByEduToken",
        queryParameters: {
          '_t': DateTime.timestamp().millisecondsSinceEpoch,
          'token': token0
        });
    final token = authResp.data['result']['token'];
    return token;
  }

  /// 获取实验课程列表
  ///
  /// [teacherCalendarId] 示例: "1712296043783131138"
  static Future<ExperimentCoursesResponse> getExperimentCourses(Dio dio,
      {required String teacherCalendarId}) async {
    const String url =
        'guet-lab-system/experiment/mesTeachTask/queryListByStuId';

    final Map<String, dynamic> queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch,
      'teacherCalendarId': teacherCalendarId,
      'column': 'createTime',
      'order': 'desc',
      'field': 'id,,courseName,courseProcess',
      'pageNo': 1,
      'pageSize': 1000,
    };

    final response = await dio.get(url, queryParameters: queryParams);
    return ExperimentCoursesResponse.fromJson(response.data);
  }

  /// 获取实验项目列表
  ///
  /// [taskId] 示例: "sync252750"
  static Future<Object> getExperimentItems(Dio dio,
      {required String taskId}) async {
    const String url =
        'guet-lab-system/experiment/mesTeachTask/getSubjectSelectionList';

    final Map<String, dynamic> queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch,
      'taskId': taskId,
    };

    final response = await dio.get(url, queryParameters: queryParams);
    final data = response.data;
    if (data?["result"]?[0]?["groupInfo"] != null) {
      return ExperimentGroupedItemsResponse.fromJson(data);
    }
    return ExperimentItemsResponse.fromJson(data);
  }

  /// 获取实验批次列表
  ///
  /// [subjectId] 示例: "1858683920732598273"
  /// [taskId] 示例: "sync252750"
  static Future<ExperimentBatchResponse> getExperimentBatch(Dio dio,
      {required String subjectId, required String taskId}) async {
    const String url =
        'guet-lab-system/schedule/ScheduleItemBySubject/getItemListToSelect';

    final Map<String, dynamic> queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch,
      'subjectId': subjectId,
      'taskId': taskId,
      'theoryFlag': true,
    };

    final response = await dio.get(url, queryParameters: queryParams);
    return ExperimentBatchResponse.fromJson(response.data);
  }

  static Future<ExperimentCommonResponse> selectGroupedExperimentCourse(
    Dio dio, {
    required String groupId,
    required int selectWey,
    required String taskId}) async {
    const String url =
        'guet-lab-system/schedule/ScheduleItemBySubject/stuSelectGroup';

    final Map<String, dynamic> queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch,
      'groupId': groupId,
      'selectWey': selectWey,
      'taskId': taskId,
    };

    final response = await dio.get(url, queryParameters: queryParams);
    return ExperimentCommonResponse.fromJson(response.data);
  }

  static Future<ExperimentCommonResponse> dropGroupedExperimentCourse(Dio dio,
      {required String groupId,
        required String taskId}) async {
    const String url =
        'guet-lab-system/schedule/ScheduleItemBySubject/stuDropCourseByGroup';

    final Map<String, dynamic> queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch,
      'groupId': groupId,
      'taskId': taskId,
    };

    final response = await dio.get(url, queryParameters: queryParams);
    return ExperimentCommonResponse.fromJson(response.data);
  }

  /// 选课
  ///
  /// [itemIds] 示例: "1859789772523085825, 1859789772728606722"
  /// [selectWey] 示例: "1"
  /// [taskId] 示例: "sync252750"
  /// [stuId] 示例: "1712296052754747400"
  static Future<ExperimentCommonResponse> selectExperimentCourse(Dio dio,
      {required List<String> itemIds,
      required int selectWey,
      required String taskId,
      required String stuId}) async {
    const String url =
        'guet-lab-system/schedule/ScheduleItemBySubject/stuSelectItem';

    final Map<String, dynamic> queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch,
      'itemIds': itemIds.join(", "),
      'selectWey': selectWey,
      'taskId': taskId,
      'stuId': stuId,
    };

    final response = await dio.get(url, queryParameters: queryParams);
    return ExperimentCommonResponse.fromJson(response.data);
  }

  /// 退课
  ///
  /// [stuId] 示例: "1712296052754747400"
  /// [subjectId] 示例: "1858683920732598273"
  /// [taskId] 示例: "sync252750"
  static Future<ExperimentCommonResponse> dropExperimentCourse(Dio dio,
      {required String stuId,
      required String subjectId,
      required String taskId}) async {
    const String url =
        'guet-lab-system/schedule/ScheduleItemBySubject/stuDropCourse';

    final Map<String, dynamic> queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch,
      'stuId': stuId,
      'subjectId': subjectId,
      'taskId': taskId,
    };

    final response = await dio.get(url, queryParameters: queryParams);
    return ExperimentCommonResponse.fromJson(response.data);
  }

  static Future<TeacherCalendarResponse> getTeacherCalendar(Dio dio) async {
    const String url =
        'guet-lab-system/mesTeacherCalendar/mesTeacherCalendar/getTeachCalendarOptions';
    final Map<String, dynamic> queryParams = {
      '_t': DateTime.now().millisecondsSinceEpoch,
    };

    final response = await dio.get(url, queryParameters: queryParams);
    return TeacherCalendarResponse.fromJson(response.data);
  }
}
