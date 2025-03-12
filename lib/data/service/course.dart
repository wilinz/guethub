import 'package:dio/dio.dart';
import 'package:guethub/data/model/common/common_response.dart';
import 'package:guethub/data/model/course/course_lab_response.dart';
import 'package:guethub/data/model/course/course_response.dart';
import 'package:guethub/data/model/plan_course/plan_course_detail_response.dart';
import 'package:guethub/data/model/plan_course/plan_course_response.dart';
import '../model/template.dart';
import '../network.dart';

class CourseService {
  static Future<List<OldCourse>> getCourseList(String term) async {
    final resp = await AppNetwork.get().bkjwDio
        .get("student/getstutable", queryParameters: {"term": term});
    final respData = CourseResponse.fromJson(resp.data);
    return respData.data;
  }

  static Future<List<CourseLab>> getCourseLabList(String term) async {
    final resp = await AppNetwork.get().bkjwDio
        .get("student/getlabtable", queryParameters: {"term": term});
    final respData = CourseLabResponse.fromJson(resp.data);
    return respData.data;
  }

  static Future<List<PlanCourse>> getPlan(
    String term,
    String grade,
    String dptno,
    String spno,
  ) async {
    final resp = await AppNetwork.get().bkjwDio.get("student/GetPlan",
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
      String id, String courseid) async {
    final resp = await AppNetwork.get().bkjwDio
        .get("student/GetPlanCno", queryParameters: {
      "id": id,
      "courseid": courseid,
      // "term": term,
    });
    final data = PlanCourseDetailResponse.fromJson(resp.data);
    return data.data;
  }

  static Future<String> selectPage() async {
  //   Student/StuSct
    final resp = await AppNetwork.get().bkjwDio.get("Student/StuSct");
    return resp.data;
  }

  static Future<CommonResponse> select(
      PlanCourseDetail planCourseDetail) async {
    final resp = await AppNetwork.get().bkjwDio.post("student/SctSave",
        data: planCourseDetail.toJson(),
        options: Options(contentType: AppNetwork.typeUrlEncode));
    final data = CommonResponse.fromJson(resp.data);
    return data;
  }

  static Future<CommonResponse> unselect(
      PlanCourseDetail planCourseDetail) async {
    final resp = await AppNetwork.get().bkjwDio.post("student/UnSct",
        data: planCourseDetail.toJson(),
        options: Options(contentType: AppNetwork.typeUrlEncode));
    final data = CommonResponse.fromJson(resp.data);
    return data;
  }

}
