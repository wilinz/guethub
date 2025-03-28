import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guethub/data/model/course/semester_schedule.dart';
import 'package:guethub/data/model/pedagogical_evaluation/pedagogical_evaluation_response.dart';
import 'package:guethub/ui/page/app/login/login.dart';
import 'package:guethub/ui/page/app/regiester/register.dart';
import 'package:guethub/ui/page/app/reset_password/reset_password.dart';
import 'package:guethub/ui/page/author.dart';
import 'package:guethub/ui/page/campus_network/campus_network.dart';
import 'package:guethub/ui/page/campusmap/campusmap.dart';
import 'package:guethub/ui/page/changke/changke.dart';
import 'package:guethub/ui/page/course_detail/course_detail.dart';
import 'package:guethub/ui/page/course_selection/course_selection.dart';
import 'package:guethub/ui/page/exam_schedule/exam_schedule_page.dart';
import 'package:guethub/ui/page/exam_scores/exam_scores_page.dart';
import 'package:guethub/ui/page/experiment/experiment_batch/experiment_batch.dart';
import 'package:guethub/ui/page/experiment/experiment_courses.dart';
import 'package:guethub/ui/page/experiment/experiment_items/experiment_items.dart';
import 'package:guethub/ui/page/feedback/feedback_page.dart';
import 'package:guethub/ui/page/guet_login/guet_user_list.dart';
import 'package:guethub/ui/page/guet_login/login.dart';
import 'package:guethub/ui/page/guet_timetable/guet_timetable.dart';
import 'package:guethub/ui/page/main/forum/post_detail_page.dart';
import 'package:guethub/ui/page/main/forum/send_post_page.dart';
import 'package:guethub/ui/page/main/main.dart';
import 'package:guethub/ui/page/pedagogical_evaluation/pedagogical_evaluation_edit.dart';
import 'package:guethub/ui/page/privacy_policy/privacy_policy.dart';
import 'package:guethub/ui/page/splash/splash.dart';
import 'package:guethub/ui/page/teaching_evaluation/teaching_evaluation.dart';
import 'package:guethub/ui/page/teaching_evaluation/content/teaching_evaluation_content.dart';
import 'package:guethub/ui/page/theme/theme_changer_page.dart';
import 'package:guethub/ui/page/toolbox/toolbox.dart';
import 'package:guethub/ui/page/user_agreement/user_agreement.dart';
import 'package:guethub/ui/page/userprofile/user_profile.dart';
import 'package:guethub/ui/settings/settings_page.dart';
import 'package:guethub/ui/widget/window_caption.dart';

import 'page/empty_classroom/empty_classroom_new.dart';
import 'page/image_list_view/image_list_view.dart';
import 'page/pedagogical_evaluation/pedagogical_evaluation.dart';
import 'page/textbook_evaluate/textbook_evaluate.dart';
import 'page/textbook_evaluate/textbook_evaluate_detail/textbook_evaluate_detail.dart';
import 'page/webview/webview.dart';

class AppRoute {
  static String currentPage = splashPage;

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String loginPage = "/loginPage";

  static const String splashPage = "/";

  static const String mainPage = "/mainPage";

  static const String settingsPage = "/SettingsPage";

  @Deprecated("Old system")
  static const String courseSelectionOldPage = "/courseSelectionOldPage";

  static const String courseSelectionPage = "/courseSelectionPage";

  @Deprecated("Old system")
  static const String pedagogicalEvaluationPage = "/pedagogicalEvaluationPage";

  static const String teachingEvaluation = "/TeachingEvaluation";

  static const String teachingEvaluationContentPage =
      "/TeachingEvaluationContentPage";

  static const String pedagogicalEvaluationEditPage =
      "/pedagogicalEvaluationEditPage";

  static const String campusNetworkPage = "/CampusNetworkPage";

  static const String campusMapPage = "/CampusMapPage";

  static const String courseDetailPage = "/CourseDetailPage";

  static const String examScoresPage = "/ExamScoresPage";

  @Deprecated("Old system")
  static const String emptyClassroomPage = "/EmptyClassroomPage";

  static const String examSchedulePage = "/ExamSchedulePage";

  static const String themeChangerPage = "/ThemeChangerPage";

  // FeedbackPage
  static const String feedbackPage = "/FeedbackPage";

  static const String appLoginPage = "/AppLoginPage";

  static const String registerPage = "/RegisterPage";

  static const String resetPasswordPage = "/ResetPasswordPage";

  static const String postDetailPage = "/PostDetailPage";

  static const String sendPostPage = "/SendPostPage";

  static const String userProfile = "/UserProfile";

  static const String imageListViewer = "/ImageListViewer";

  static const String authorPage = "/AuthorPage";

  static const String toolboxPage = "/ToolBoxPage";

  static const String userListPage = "/UserListPage";

  static const String timetablePage = "/TimetablePage";

  static const String textbookEvaluatePage = "/TextbookEvaluatePage";

  static const String textbookEvaluateDetailPage =
      "/TextbookEvaluateDetailPage";

  static const String experimentCoursesPage = "/ExperimentCoursesPage";

  static const String experimentItemsPage = "/ExperimentItemsPage";

  static const String experimentBatchPage = "/ExperimentBatchPage";

  static const String emptyClassroomNewPage = "/EmptyClassroomNewPage";

  static const String webView = "/WebView";
  
  static const String userAgreementPage = "/userAgreementPage";

  static const String privacyPolicyPage = "/privacyPolicyPage";

  static const String changkePage = "/ChangkePage";

  static List<GetPage> routes = [
    GetPage(
      name: changkePage,
      page: () => ChangkePage(),
    ),
    GetPage(
      name: webView,
      page: () => WebView(args: Get.arguments),
    ),
    GetPage(
      name: userAgreementPage,
      page: () => UserAgreementPage(),
    ),
    GetPage(
      name: privacyPolicyPage,
      page: () => PrivacyPolicyPage(),
    ),
    GetPage(
      name: emptyClassroomNewPage,
      page: () => EmptyClassroomNewPage(),
    ),
    GetPage(
      name: experimentBatchPage,
      page: () => ExperimentBatchPage(args: Get.arguments),
    ),
    GetPage(
      name: experimentItemsPage,
      page: () => ExperimentItemsPage(args: Get.arguments),
    ),
    GetPage(
      name: experimentCoursesPage,
      page: () => ExperimentCoursesPage(),
    ),
    GetPage(
      name: textbookEvaluateDetailPage,
      page: () => TextbookEvaluateDetailPage(args: Get.arguments),
    ),
    GetPage(
      name: textbookEvaluatePage,
      page: () => TextbookEvaluatePage(),
    ),
    GetPage(
      name: timetablePage,
      page: () => TimetablePage(),
    ),
    GetPage(
      name: userListPage,
      page: () => UserListPage(),
    ),
    GetPage(
      name: courseSelectionPage,
      page: () => CourseSelectionPage(),
    ),
    GetPage(
      name: toolboxPage,
      page: () => Toolbox(),
    ),
    GetPage(
      name: authorPage,
      page: () => AuthorsPage(),
    ),
    GetPage(
      name: imageListViewer,
      page: () => ImageListViewer(args: Get.arguments),
    ),
    GetPage(
      name: campusMapPage,
      page: () => CampusMapPage(),
    ),
    GetPage(
      name: userProfile,
      page: () => UserProfile(),
    ),
    GetPage(
      name: teachingEvaluationContentPage,
      page: () => TeachingEvaluationContentPage(args: Get.arguments),
    ),
    GetPage(
      name: teachingEvaluation,
      page: () => TeachingEvaluationPage(),
    ),
    GetPage(
      name: appLoginPage,
      page: () => AppLoginPage(),
    ),
    GetPage(
      name: sendPostPage,
      page: () => SendPostPage(args: Get.arguments),
    ),
    GetPage(
      name: postDetailPage,
      page: () => PostDetailPage(args: Get.arguments),
    ),
    GetPage(
      name: registerPage,
      page: () => RegisterPage(
          username: Get.arguments['username'],
          password: Get.arguments['password']),
    ),
    GetPage(
      name: resetPasswordPage,
      page: () => ResetPasswordPage(username: Get.arguments['username']),
    ),
    GetPage(
      name: feedbackPage,
      page: () => FeedbackPage(),
    ),
    GetPage(
      name: themeChangerPage,
      page: () => ThemeChangerPage(),
    ),
    GetPage(
      name: examSchedulePage,
      page: () => ExamSchedulePage(),
    ),
    GetPage(
      name: loginPage,
      page: () => LoginPage(args: Get.arguments),
    ),
    GetPage(
      name: splashPage,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: settingsPage,
      page: () => SettingsPage(),
    ),
    GetPage(
      name: mainPage,
      page: () => const MainPage(),
    ),
    GetPage(
      name: pedagogicalEvaluationPage,
      page: () => PedagogicalEvaluationPage(),
    ),
    GetPage(
      name: pedagogicalEvaluationEditPage,
      page: () => PedagogicalEvaluationEditPage(
          pedagogicalEvaluation: Get.arguments as PedagogicalEvaluation),
    ),
    GetPage(
      name: campusNetworkPage,
      page: () => CampusNetworkPage(),
    ),
    GetPage(
      name: courseDetailPage,
      page: () => CourseDetailPage(args: Get.arguments as CourseDetailPageArgs),
    ),
    GetPage(
      name: examScoresPage,
      page: () => ExamScoresPage(),
    ),
  ].map((e) => e.copy(middlewares: [WindowTopBarMiddleWare()])).toList();
}

class ImageBackgroundWare extends GetMiddleware {
  @override
  int? get priority => 1;

  //该函数将在调用 GetPage.page 函数后立即调用，并为您提供函数的结果。并获取将显示的小部件
  @override
  Widget onPageBuilt(Widget page) {
    return Stack(children: [
      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            fit: BoxFit.cover, // 填充方式
          ),
        ),
      ),
      page
    ]);
  }
}

class WindowTopBarMiddleWare extends GetMiddleware {
  @override
  int? get priority => 1;

  //该函数将在调用 GetPage.page 函数后立即调用，并为您提供函数的结果。并获取将显示的小部件
  @override
  Widget onPageBuilt(Widget page) {
    return GetPlatform.isDesktop && !GetPlatform.isWeb
        ? DesktopWindow(page: page, title: Text('app_name'.tr))
        : page;
  }
}

class DesktopWindow extends StatefulWidget {
  const DesktopWindow({super.key, required this.page, required this.title});

  final Widget page;
  final Widget title;

  @override
  State<DesktopWindow> createState() => _DesktopWindowState();
}

class _DesktopWindowState extends State<DesktopWindow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: GetPlatform.isMacOS
            ? SizedBox(
                height: kWindowCaptionHeight,
                child: Center(child: widget.title),
              )
            : WindowCaption(
                brightness: Get.theme.brightness,
                title: widget.title,
              ),
        preferredSize: const Size.fromHeight(kWindowCaptionHeight),
      ),
      body: widget.page,
    );
  }
}
