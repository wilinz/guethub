import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guethub/data/model/experiment/experiment_items_data_type.dart';
import 'package:guethub/ui/page/experiment/experiment_batch/experiment_batch.dart';
import 'package:guethub/ui/route.dart';

import 'experiment_items_controller.dart';

class ExperimentItemsPageArgs {
  final String taskId;

  ExperimentItemsPageArgs({required this.taskId});
}

class ExperimentItemsPage extends StatelessWidget {
  const ExperimentItemsPage({super.key, required this.args});

  final ExperimentItemsPageArgs args;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ExperimentItemsController(args: args));

    return Scaffold(
      appBar: AppBar(
        title: Text("实验课选课系统"),
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 24.0),
          //   child: Text("tip: 如果教务系统有课但是这里没显示数据，这可能是我们还没适配你学院的实验课选课系统，请联系开发者反馈", style: TextStyle(color: Colors.grey, fontSize: 10),),
          // ),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return Center(child: CircularProgressIndicator()); // 显示加载指示器
              } else if (c.hasError.value) {
                return Center(
                  child: TextButton(
                    onPressed: () {
                      c.refreshData();
                    },
                    child: Text(
                      "加载失败，点击重试",
                      style: GoogleFonts.longCang(
                        textStyle: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    await c.refreshData();
                  },
                  child: c.experimentItemsDataType == ExperimentItemsDataType.typeDefault
                      ? _Type0Page(c: c, args: args)
                      : _Type1Page(c: c, args: args),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}

class _Type0Page extends StatelessWidget {
  const _Type0Page({
    super.key,
    required this.c,
    required this.args,
  });

  final ExperimentItemsController c;
  final ExperimentItemsPageArgs args;

  @override
  Widget build(BuildContext context) {
    return Obx(() => c.experimentItems.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "当前课程暂时没有实验课项目安排",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 8);
            },
            padding: EdgeInsets.fromLTRB(8, 0, 8, 24),
            itemCount: c.experimentItems.length,
            itemBuilder: (context, index) {
              final item = c.experimentItems[index];
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  onTap: () {},
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Builder(builder: (context) {
                            return SelectableText(
                                "${index + 1}. ${item.name}-${item.type}");
                          }),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      item.selectItemString != null
                          ? "已选中：${item.selectItemString}"
                          : "未选中",
                      style: TextStyle(
                          color: item.selectItemString != null
                              ? Colors.green
                              : Colors.red),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.selectItem != null)
                          TextButton(
                            onPressed: () {
                              c.unselect(subjectId: item.id, stuId: item.stuId);
                            },
                            child: Text("退课"),
                          ),
                        // if (item.selectItem != null)
                        TextButton(
                          onPressed: () {
                            Get.toNamed(AppRoute.experimentBatchPage,
                                arguments: ExperimentBatchPageArgs(
                                    taskId: args.taskId,
                                    subjectId: item.id,
                                    stuId: item.stuId,
                                    selectItems: item.selectItem));
                          },
                          child: Text(
                            "去选课",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ));
  }
}

class _Type1Page extends StatelessWidget {
  const _Type1Page({
    super.key,
    required this.c,
    required this.args,
  });

  final ExperimentItemsController c;
  final ExperimentItemsPageArgs args;

  @override
  Widget build(BuildContext context) {
    return Obx(() => c.experimentGroupedItems.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "当前课程暂时没有实验课项目安排",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          )
        : ListView.separated(
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: 8);
            },
            padding: EdgeInsets.fromLTRB(8, 0, 8, 24),
            itemCount: c.experimentGroupedItems.length,
            itemBuilder: (context, index) {
              final item = c.experimentGroupedItems[index];
              return ExpansionTile(
                title: Text(
                    "${item.groupInfo.name} ${item.selectCount}/${item.maxCount}"),
                initiallyExpanded: true,
                enabled: true,
                // collapsedShape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(0.0),
                //   side: BorderSide(color: Colors.transparent),
                // ),
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(0.0),
                //   side: BorderSide(color: Colors.transparent),
                // ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        if(item.hasSelect){
                          c.unselectGroup(item.groupInfo.id);
                        }else{
                          c.selectGroup(item.groupInfo.id);
                        }
                      },
                      child: Text(
                        item.hasSelect ? "退课" : "选课",
                        style: TextStyle(
                            color: item.hasSelect
                                ? Colors.red
                                : Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
                children: List.generate(item.itemList.length, (i) {
                  final subitem = item.itemList[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 16.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("${subitem.subjectName}"),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                                "${i + 1}. ${subitem.subjectName} ${subitem.time}"),
                          ),
                          Builder(builder: (context) {
                            final itemIsSelected = item.hasSelect;
                            return Flexible(
                              child: Text(
                                itemIsSelected ? "已选中" : "未选中",
                                style: TextStyle(
                                    color: itemIsSelected
                                        ? Colors.green
                                        : Colors.red),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ));
  }
}
