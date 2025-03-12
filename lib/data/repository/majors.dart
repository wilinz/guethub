import 'package:dio/dio.dart';
import 'package:guethub/data/model/majors/majors_response.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/service/majors.dart';

class MajorsRepository {

  Future<Dio> get dio => AppNetwork.get().bkjwDio;

  List<Major> majorCache = [];

  Future<List<Major>> getMajors() async {
    if (majorCache.isNotEmpty) return majorCache;
    majorCache = await MajorsService.get(await dio);
    return majorCache;
  }

  MajorsRepository._();

  static MajorsRepository? _instance = null;

  factory MajorsRepository.get() => _instance ??= MajorsRepository._();
}
