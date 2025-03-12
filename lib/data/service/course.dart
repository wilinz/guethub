import 'package:dio/dio.dart';
import 'package:guethub/data/model/common/common_response.dart';
import 'package:guethub/data/model/course/course_lab_response.dart';
import 'package:guethub/data/model/course/course_response.dart';
import 'package:guethub/data/model/plan_course/plan_course_detail_response.dart';
import 'package:guethub/data/model/plan_course/plan_course_response.dart';
import '../model/template.dart';
import '../network.dart';

class CourseService {
  static Future<List<OldCourse>> getCourseList(Dio dio, String term) async {
    final resp = await dio
        .get("student/getstutable", queryParameters: {"term": term});
    final respData = CourseResponse.fromJson(resp.data);
    return respData.data;
  }

  static Future<List<CourseLab>> getCourseLabList(Dio dio, String term) async {
    final resp = await dio
        .get("student/getlabtable", queryParameters: {"term": term});
    final respData = CourseLabResponse.fromJson(resp.data);
    return respData.data;
  }

  static Future<List<PlanCourse>> getPlan(
      Dio dio,
      String term,
    String grade,
    String dptno,
    String spno,
  ) async {
    final resp = await dio.get("student/GetPlan",
        queryParameters: {
          "term": term,
          "grade": grade,
          "dptno": dptno,
          "spno": spno,
          "stype": "正常"
        });
    final data = PlanCourseResponse.fromJson(resp.data).data;
    return data;
  }

  static Future<List<PlanCourseDetail>> getPlanCourseDetail(
      Dio dio,
      String id, String courseid) async {
    final resp = await dio
        .get("student/GetPlanCno", queryParameters: {
      "id": id,
      "courseid": courseid,
      // "term": term,
    });
    final data = PlanCourseDetailResponse.fromJson(resp.data);
    return data.data;
  }

  static Future<String> selectPage(Dio dio) async {
  //   Student/StuSct
    final resp = await dio.get("Student/StuSct");
    return resp.data;
  }

  static Future<CommonResponse> select(
      Dio dio,
      PlanCourseDetail planCourseDetail) async {
    final resp = await dio.post("student/SctSave",
        data: planCourseDetail.toJson(),
        options: Options(contentType: AppNetwork.typeUrlEncode));
    final data = CommonResponse.fromJson(resp.data);
    return data;
  }

  static Future<CommonResponse> unselect(
      Dio dio,
      PlanCourseDetail planCourseDetail) async {
    final resp = await dio.post("student/UnSct",
        data: planCourseDetail.toJson(),
        options: Options(contentType: AppNetwork.typeUrlEncode));
    final data = CommonResponse.fromJson(resp.data);
    return data;
  }

}
