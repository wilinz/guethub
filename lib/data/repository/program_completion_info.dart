import 'package:dio/dio.dart';
import 'package:guethub/data/model/credits_course_info/credits_course_info.dart';
import 'package:guethub/data/model/graduate_info/graduate_info.dart';
import 'package:guethub/data/model/program_completion_info/program_completion_info.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/service/program_completion_info.dart';

class ProgramCompletionInfoRepository {
  Future<Dio> get dio => AppNetwork.get().bkjwTestDio;

  Future<GraduateInfo?> getGraduateInfo() async {
    return ProgramCompletionInfoService.getGraduateInfo(await dio);
  }

  Future<ProgramCompletionInfo> getProgramCompletionInfo(
      {required String programId}) async {
    return await ProgramCompletionInfoService.getProgramCompletionInfo(await dio,
        programId: programId);
  }

  List<CreditsCourseInfo> getCreditsCourseInfo(ProgramCompletionInfo info) {
    return info.children
        .expand((e) => e.planCourses)
        .map((e) => CreditsCourseInfo(
            courseName: e.course.nameZh,
            courseNameEn: e.course.nameEn,
            courseCode: e.course.code,
            creditsCourse: e.courseType.creditsCourse))
        .toList();
  }

  Future<List<CreditsCourseInfo>> getCreditsCourseInfo1({required String programId}) async {
    final info = await ProgramCompletionInfoService.getProgramCompletionInfo(await dio,
        programId: programId);
    return getCreditsCourseInfo(info);
  }

  ProgramCompletionInfoRepository._();

  static ProgramCompletionInfoRepository? _instance = null;

  factory ProgramCompletionInfoRepository.get() =>
      _instance ??= ProgramCompletionInfoRepository._();
}
