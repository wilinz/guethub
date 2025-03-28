import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:guethub/data/model/experiment/experiment_batch_response/experiment_batch_response.dart';
import 'package:guethub/data/repository/experiment.dart';
import 'package:guethub/ui/util/toast.dart';
import 'package:guethub/logger.dart';

import 'experiment_batch.dart';

class ExperimentBatchController extends GetxController {
  final experimentBatch = <ExperimentBatch>[].obs;

  var isLoading = false.obs; // Tracks loading state
  var hasError = false.obs;

  final ExperimentBatchPageArgs args;

  ExperimentBatchController({required this.args}); // Tracks if there's an error

  @override
  Future<void> onInit() async {
    super.onInit();
    await getData();
  }

  Future<void> getData() async {
    try {
      isLoading(true);
      hasError(false);
      experimentBatch.value = (await ExperimentRepository.get()
              .getExperimentBatch(
                  taskId: args.taskId, subjectId: args.subjectId))
          .result;
    } catch (e) {
      logger.e(e);
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

  Future<void> select(List<String> itemIds) async {
    try {
      final resp = await ExperimentRepository.get().selectExperimentCourse(
          itemIds: itemIds,
          selectWey: 1,
          taskId: args.taskId,
          stuId: args.stuId);
      toast(resp.message);
      if (resp.success) {
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
