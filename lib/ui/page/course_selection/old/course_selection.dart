import 'dart:ffi';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dart_extensions/dart_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guethub/common/list.dart';
import 'package:guethub/data/model/majors/majors_response.dart';
import 'package:guethub/data/model/plan_course/plan_course_response.dart';
import 'package:guethub/data/model/term/term.dart';
import 'package:guethub/data/network.dart';
import 'package:guethub/data/service/course.dart';
import 'package:guethub/logger.dart';
import 'package:guethub/main.dart';
import 'package:guethub/ui/page/course_selection/old/course_selection_vm.dart';
import 'package:kt_dart/kt.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

@Deprecated("Old system")
class CourseSelectionPageOld extends StatefulWidget {
  const CourseSelectionPageOld({Key? key}) : super(key: key);

  @override
  State<CourseSelectionPageOld> createState() => _CourseSelectionPageOldState();
}

@Deprecated("Old system")
class _CourseSelectionPageOldState extends State<CourseSelectionPageOld> {
  var text = "";
  final _controller = TextEditingController(text: "");
  var isNetworkOnly = false;
  var isRemainderOnly = false;

  var _refreshController = RefreshController();

  final viewModel = Get.put(CourseSelectionOldViewModel());

  // var isB
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("选课"),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(8.0, 0, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCourses(context),
            ],
          ),
        ));
  }

  Expanded buildCourses(BuildContext context) {
    return Expanded(
      child: SmartRefresher(
        enablePullDown: false,
        enablePullUp: false,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("上拉加载");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("加载失败！点击重试！");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("松手,加载更多!");
            } else {
              body = Text("没有更多数据了!");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: () {},
        onLoading: () {},
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildDropdownButtons(),
                  buildButtons(),
                  buildCheckboxs(),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: Obx(() => SliverList(
                    //列表项高度固定
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        return Obx(() {
                          final dataWrapper = viewModel.planCourses[i];
                          final item = dataWrapper.data;
                          return GestureDetector(
                            onTap: () {
                              if (!dataWrapper.isExpand.value &&
                                  item.details.isEmpty) {
                                showSnackBar(context, "第${i + 1}个课程正在加载", 500);
                                viewModel.getDetail(dataWrapper).then((value) {
                                  // showSnackBar(context, "第${i + 1}个课程加载成功", 500);
                                }).onError((error, stackTrace) {
                                  showSnackBar(
                                      context, "第${i + 1}个课程加载失败", 500);
                                });
                              } else {
                                // viewModel.planCourses[i] =
                                dataWrapper.isExpand.toggle();

                                // viewModel.planCourses[i] = item
                              }
                            },
                            child: Card(
                                child: Container(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                                    "${i + 1}. ${item.tname}: ${item.cname}: ${item.xf}学分")),
                                            // if (item.details.isEmpty)
                                            Text(
                                              !dataWrapper.isExpand.value
                                                  ? "点击加载详情"
                                                  : "点击收起",
                                              style: TextStyle(
                                                  color: Colors.green),
                                            )
                                          ],
                                        ),
                                        if (dataWrapper.isExpand.value)
                                          buildCourseDetails(item, context)
                                      ],
                                    ))),
                          );
                        });
                      },
                      childCount: viewModel.planCourses.length,
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Container buildCourseDetails(PlanCourse item, BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: const EdgeInsets.only(left: 16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: item.details.mapIndexed((i, detail) {
            return Row(
              children: [
                Expanded(
                  child: Text(
                      "(${i + 1}) ${detail.sctcnt}/${detail.maxstu} ${detail.name}: ${detail.ap}"),
                ),
                TextButton(
                    onPressed: () {
                      Get.snackbar("失败", "此功能暂不可用！");
                      // viewModel.select(detail).then((value) {
                      //   showSnackBar(context, value.msg, 2000);
                      // }).onError((error, stackTrace) {
                      //   showSnackBar(context, "失败：$error", 2000);
                      // });
                    },
                    child: Text("选课")),
              ],
            );
          }).toList()),
    );
  }

  Wrap buildCheckboxs() {
    return Wrap(
        spacing: 8.0,
        // 主轴(水平)方向间距
        runSpacing: 4.0,
        // 纵轴（垂直）方向间距
        alignment: WrapAlignment.start,
        //沿主轴方向居中
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Container(
            width: 4,
          ),
          // Obx(() => _isGeneralStudiesClass(viewModel)
          //     ? ConstrainedBox(
          //         constraints: BoxConstraints(maxWidth: 200),
          //         child: CheckboxListTile(
          //             title: Text("只看网课"),
          //             controlAffinity: ListTileControlAffinity.leading,
          //             value: isNetworkOnly,
          //             onChanged: (v) {
          //               setState(() {
          //                 isNetworkOnly = v!;
          //                 if (isNetworkOnly) {
          //                   viewModel.filter("networkFilter", (e) {
          //                     return e.cname.contains("网络");
          //                   });
          //                 } else {
          //                   viewModel.undoFilter("networkFilter");
          //                 }
          //               });
          //             }),
          //       )
          //     : SizedBox())
          // ConstrainedBox(
          //   constraints: BoxConstraints(maxWidth: 200),
          //   child: CheckboxListTile(
          //       title: Text("只看剩余"),
          //       controlAffinity: ListTileControlAffinity.leading,
          //       value: isRemainderOnly,
          //       onChanged: (v) {
          //         setState(() {
          //           isRemainderOnly = v!;
          //           if (isRemainderOnly) {
          //             viewModel.filter("remainderFilter", (v) {
          //               return v.maxstu - v.sctcnt > 0;
          //             });
          //           } else {
          //             viewModel.undoFilter("remainderFilter");
          //           }
          //         });
          //       }),
          // ),
        ]);
  }

  Container buildButtons() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
          // spacing: 8.0,
          // // 主轴(水平)方向间距
          // runSpacing: 4.0,
          // // 纵轴（垂直）方向间距
          // alignment: WrapAlignment.start,
          // //沿主轴方向居中
          // crossAxisAlignment: WrapCrossAlignment.center,
          children: [
        ElevatedButton(
            onPressed: () {
              viewModel.currentAcademy.value = viewModel.academy
                  .firstWhereOrNull(
                      (e) => e.dptno == viewModel.studentInfo?.collegeNo);
              viewModel.currentMajor.value = viewModel.major.firstWhereOrNull(
                  (e) => e.spno == viewModel.studentInfo?.majorNo);
              viewModel.studentInfo?.grade.let((it) {
                viewModel.currentGrade.value = int.parse(it);
              });
            },
            child: Text("选择所在学院及专业")),
        SizedBox(height: 16),
        ElevatedButton(
            onPressed: () {
              viewModel.currentAcademy.value =
                  viewModel.academy.firstWhereOrNull((e) => e.dptno == "0");
              viewModel.currentMajor.value =
                  viewModel.major.firstWhereOrNull((e) => e.spno == "000000");
            },
            child: Text("选择通识课")),
        SizedBox(height: 16),
        Obx(() => ElevatedButton(
            onPressed: !_isCanQuery(viewModel)
                ? null
                : () {
                    viewModel.getPlan(
                        term: viewModel.currentTerm.value!.term,
                        grade: viewModel.currentGrade.value!.toString(),
                        dptno: viewModel.currentAcademy.value!.dptno,
                        spno: viewModel.currentMajor.value!.spno);
                  },
            child: Text("查询"))),
        SizedBox(height: 16),
        Obx(() => _isGeneralStudiesClass(viewModel)
            ? ElevatedButton(
                onPressed: !_isCanQuery(viewModel)
                    ? null
                    : () {
                        viewModel.getPlan(
                            term: viewModel.currentTerm.value!.term,
                            grade: viewModel.currentGrade.value!.toString(),
                            dptno: viewModel.currentAcademy.value!.dptno,
                            spno: viewModel.currentMajor.value!.spno,
                            networkCourseOnly: true);
                      },
                child: Text("仅查询网课"))
            : Container())
      ].mapList((e) => SizedBox(
                width: double.infinity,
                child: e,
              ))),
    );
  }

  Container buildDropdownButtons() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
          // spacing: 8.0,
          // // 主轴(水平)方向间距
          // runSpacing: 4.0,
          // // 纵轴（垂直）方向间距
          // alignment: WrapAlignment.start,
          // //沿主轴方向居中
          // crossAxisAlignment: WrapCrossAlignment.center,
          children: [
        buildGradeDropdownButton(),
        SizedBox(height: 8),
        buildTermDropdownButton(),
        SizedBox(height: 8),
        buildAcademyDropdownButton(),
        SizedBox(height: 8),
        buildMajorDropdownButton(),
      ].mapList((e) => SizedBox(
                width: double.infinity,
                child: e,
              ))),
    );
  }

  bool _isCanQuery(CourseSelectionOldViewModel vm) {
    return vm.currentTerm.value != null &&
        vm.currentMajor.value != null &&
        vm.currentAcademy.value != null &&
        vm.currentGrade.value != null;
  }

  bool _isGeneralStudiesClass(CourseSelectionOldViewModel vm) {
    return vm.currentMajor.value?.spno == "000000" &&
        vm.currentAcademy.value?.dptno == "0";
  }

  Widget buildTermDropdownButton() {
    return Obx(() => DropdownButton<Term>(
        borderRadius: BorderRadius.circular(16),
        items: createTermItemList(viewModel),
        hint: Container(
            padding: EdgeInsets.all(8), child: Center(child: Text("请选择学期"))),
        value: viewModel.currentTerm.value,
        onChanged: (v) {
          v as String;
          viewModel.currentTerm.value =
              viewModel.terms.firstWhere((e) => e.term == v);
        }));
  }

  createTermItemList(CourseSelectionOldViewModel viewModel) {
    return viewModel.terms.map((t) {
      return DropdownMenuItem<Term>(
        child: Container(
            padding: EdgeInsets.all(8), child: Center(child: Text(t.termName))),
        value: t,
      );
    }).toList();
  }

  Widget buildGradeDropdownButton() {
    return Obx(() => DropdownButton<int?>(
        borderRadius: BorderRadius.circular(16),
        items: createGradeItemList(viewModel),
        hint: Container(
            padding: EdgeInsets.all(8), child: Center(child: Text("请选择年级"))),
        value: viewModel.currentGrade.value,
        onChanged: (v) {
          viewModel.currentGrade.value = v;
        }));
  }

  createGradeItemList(CourseSelectionOldViewModel viewModel) {
    return viewModel.grades.map((t) {
      return DropdownMenuItem<int?>(
        child: Container(
            padding: EdgeInsets.all(8),
            child: Center(child: Text(t.toString()))),
        value: t,
      );
    }).toList();
  }

  Widget buildAcademyDropdownButton() {
    return Obx(() => DropdownButton(
        borderRadius: BorderRadius.circular(16),
        items: createAcademyItemList(viewModel),
        hint: Container(
            padding: EdgeInsets.all(8),
            child: Center(child: SizedBox(width: 200, child: Text("请选择学院")))),
        value: viewModel.currentAcademy.value?.dptno,
        onChanged: (v) {
          v as String;
          viewModel.currentAcademy.value =
              viewModel.academy.firstWhere((e) => e.dptno == v);
        }));
  }

  createAcademyItemList(CourseSelectionOldViewModel viewModel) {
    return viewModel.academy.map((t) {
      return DropdownMenuItem(
        child: Container(
            padding: EdgeInsets.all(8), child: Text(t.dptno + " " + t.dptname)),
        value: t.dptno,
      );
    }).toList();
  }

  Widget buildMajorDropdownButton() {
    return Obx(() => DropdownButton<Major>(
        borderRadius: BorderRadius.circular(16),
        items: createMajorItemList(viewModel),
        hint: Container(
            padding: EdgeInsets.all(8), child: Center(child: Text("请选择专业"))),
        value: viewModel.currentMajor.value,
        onChanged: (v) {
          viewModel.currentMajor.value = v;
        }));
  }

  createMajorItemList(CourseSelectionOldViewModel viewModel) {
    var flag = false;
    var lastChar = "";
    return viewModel.major.map((t) {
      if (lastChar != t.firstPinyin) {
        flag = !flag;
      }
      lastChar = t.firstPinyin;
      return DropdownMenuItem<Major>(
        child: Container(
          padding: EdgeInsets.all(8),
          child: SizedBox(
            width: 200,
            child: AutoSizeText(
              t.firstPinyin + " " + t.spname + " " + t.spno,
              style: TextStyle(
                fontSize: 12,
                color: flag ? Colors.green : Colors.blue,
              ),
              maxLines: 2,
              minFontSize: 10,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        value: t,
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    CourseService.selectPage(await AppNetwork.get().bkjwDio).then((value) {
      logger.d(value);
      Future.wait([
        viewModel.getTermList(isFlush: true),
        viewModel.getAcademy(),
        viewModel.getMajors(),
      ]).then((value) {
        viewModel.getStudentInfo();
      });
      return value;
    });
  }

}
