import 'package:guethub/data/model/academy/academy_response.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/service/academy.dart';

class AcademyRepository {
  List<Academy> academyCache = [];

  Future<List<Academy>> getAcademy() async {
    if (academyCache.isNotEmpty) return academyCache;
    final data = await AcademyService.get(await AppNetwork.get().bkjwDio);
    data.sort((i, j) {
      return int.parse(i.dptno).compareTo(int.parse(j.dptno));
    });
    academyCache = data;
    return data;
  }

  AcademyRepository._();

  static AcademyRepository? _instance = null;

  factory AcademyRepository.get() =>
      _instance ??= AcademyRepository._();
}
