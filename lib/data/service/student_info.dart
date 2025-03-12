import 'package:dart_extensions/dart_extensions.dart';
import 'package:dio/dio.dart';
import 'package:guethub/data/model/student/student_info.dart';
import 'package:guethub/data/model/student_info_new/student_info_new.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/redirect_interceptor.dart';
import 'package:guethub/data/repository/student_info.dart';
import 'package:guethub/data/repository/user.dart';
import 'package:guethub/data/util/util.dart';

class StudentInfoService {
  static Future<StudentInfo> get(Dio dio) async {
    final resp = await dio.get("student/StuInfo");
    final respData = StudentInfo.fromJson(resp.data);
    return respData;
  }

  static Future<int> getNewSystemStudentId(Dio dio) async {
    final resp1 = await dio.get(
        "student/for-std/std-info-check-apply",
        options: Options(extra: {RedirectInterceptor.followRedirects: false}));
    final location = resp1.headers.value('location');
    if (location == null) {
      throw Exception("获取失败：重定向失败");
    }
    return int.parse(getStudentId(location));
  }

  static Future<StudentInfo> getNewInfo(Dio dio,) async {
    final studentId = await UserRepository.get().getNewSystemStudentIdFromLocal();
    final resp = await dio.get("student/for-std/std-info-check-apply/apply/getStudent?applyId=&studentId=${studentId}");
    final newInfo = StudentInfoNew.fromJson(resp.data);
    final respData = StudentInfo.fromNewSystem(newInfo);
    return respData;
  }

}