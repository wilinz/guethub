import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:guethub/data/model/experiment/experiment_grouped_items_response/experiment_grouped_items_response.dart';
import 'package:guethub/data/model/experiment/experiment_items_data_type.dart';
import 'package:guethub/data/model/experiment/experiment_items_response/experiment_items_response.dart';
import 'package:guethub/data/repository/experiment.dart';
import 'package:guethub/ui/page/experiment/experiment_items/experiment_items.dart';
import 'package:guethub/ui/util/toast.dart';
import 'package:guethub/logger.dart';

class ExperimentItemsController extends GetxController {
  final experimentItems = <ExperimentItems>[].obs;
  final experimentGroupedItems = <ExperimentGroupedItems>[].obs;
  final experimentItemsDataType = ExperimentItemsDataType.typeDefault.obs;

  var isLoading = false.obs; // Tracks loading state
  var hasError = false.obs;

  final ExperimentItemsPageArgs args;

  ExperimentItemsController({required this.args}); // Tracks if there's an error

  @override
  Future<void> onInit() async {
    super.onInit();
    await getData();
  }

  Future<void> getData() async {
    try {
      isLoading(true);
      hasError(false);
      final experimentItemsResponse = (await ExperimentRepository.get()
          .getExperimentItems(taskId: args.taskId));
      if (experimentItemsResponse is ExperimentItemsResponse) {
        experimentItemsDataType.value = ExperimentItemsDataType.typeDefault;
        experimentItems.value =
            experimentItemsResponse.result.expand((e) => e.list).toList();
      } else if (experimentItemsResponse is ExperimentGroupedItemsResponse) {
        experimentItemsDataType.value = ExperimentItemsDataType.typeGroup;
        experimentGroupedItems.value = experimentItemsResponse.result;
      }
    } catch (e, st) {
      logger.e(e, stackTrace: st);
      hasError(true);
      toastFailure0("获取数据失败", error: e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async {
    await getData();
    if (!hasError.value) {
      toastSuccess0("刷新成功");
    } else {
      toastFailure0("刷新失败");
    }
  }

  Future<void> selectGroup(String groupId) async {
    try {
      final resp = await ExperimentRepository.get().selectGroupedExperimentCourse(
          groupId: groupId, selectWey: 1, taskId: args.taskId);
      toast(resp.message);
      if(resp.success) {
        isLoading(true);
        await getData();
      }
    } catch (e) {
      logger.e(e);
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> unselectGroup(String groupId) async {
    try {
      final resp = await ExperimentRepository.get()
              .dropGroupedExperimentCourse(groupId: groupId, taskId: args.taskId);
      toast(resp.message);
      if(resp.success) {
        isLoading(true);
        await getData();
      }
    } catch (e) {
      logger.e(e);
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  Future<void> unselect(
      {required String subjectId, required String stuId}) async {
    try {
      final resp = await ExperimentRepository.get().dropExperimentCourse(
          subjectId: subjectId, taskId: args.taskId, stuId: stuId);
      toast(resp.message);
      if(resp.success) {
        isLoading(true);
        await getData();
      }
    } catch (e) {
      logger.e(e);
      hasError(true);
    } finally {
      isLoading(false);
    }
  }
}
