import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/model/analysis_page_model.dart';
import 'package:todo_list/model/image_cropper_page_model.dart';
import 'package:todo_list/pages/all_page.dart';
import 'package:todo_list/pages/main/add_class_page.dart';
import 'package:todo_list/pages/main/data_analysis_page.dart';
import 'package:todo_list/widgets/add_task_widget.dart';
import 'package:todo_list/widgets/events_chooser_widget.dart';
import 'package:todo_list/widgets/image_cropper.dart';

class ProviderConfig {
  static ProviderConfig _instance;

  static ProviderConfig getInstance() {
    if (_instance == null) {
      _instance = ProviderConfig._internal();
    }
    return _instance;
  }

  /*
  * 私有的命名式构造方法：
  * 通过它可以实现一个类可以有多个构造函数，子类不能继承
  * internal不是关键字，可定义其他
  * */
  ProviderConfig._internal();

  ///全局provider
  ChangeNotifierProvider<GlobalModel> getGlobal(Widget child) {
    return ChangeNotifierProvider<GlobalModel>(
      create: (context) => GlobalModel(),
      child: child,
    );
  }

  ///主页provider
  /*
  * 数据监听
  * 把state传进去，当state发生改变的时候
  * 通知改变
  * */
  ChangeNotifierProvider<MainPageModel> getMainPage() {
    return ChangeNotifierProvider<MainPageModel>(
      create: (context) => MainPageModel(),
      child: MainPage(),
    );
  }

  ///添加课程页
  ChangeNotifierProvider<AddClassPageModel> getAddClassPage(bool isAdd,
      {ClassBean classBean}) {
    return ChangeNotifierProvider<AddClassPageModel>(
      create: (context) => AddClassPageModel(classBean),
      child: AddClassPage(isAdd),
    );
  }

  ///任务总览页provider
  ChangeNotifierProvider<AllMainPageModel> getAllMainPageModel() {
    return ChangeNotifierProvider<AllMainPageModel>(
      create: (context) => AllMainPageModel(),
      child: AllMainPage(),
    );
  }

  ///任务详情页provider
  ChangeNotifierProvider<TaskDetailPageModel> getTaskDetailPage(
    int index,
    TaskBean taskBean, {
    //要把其他页面的数据模型传入
    DoneTaskPageModel doneTaskPageModel,
    SearchPageModel searchPageModel,
  }) {
    return ChangeNotifierProvider<TaskDetailPageModel>(
      create: (context) => TaskDetailPageModel(
        taskBean,
        doneTaskPageModel: doneTaskPageModel,
        searchPageModel: searchPageModel,
        heroTag: index,
      ),
      child: TaskDetailPage(),
    );
  }

  ///任务添加页provider
  ChangeNotifierProvider<EditTaskPageModel> getAddTaskWidget(
      EditTaskPageModel editTaskPageModel) {
    return ChangeNotifierProvider<EditTaskPageModel>(
      create: (context) => editTaskPageModel,
      child: EventsChooseWidget(),
    );
  }

  ///任务编辑页provider
  ChangeNotifierProvider<EditTaskPageModel> getEditTaskWidget(
      TaskBean taskBean) {
    return ChangeNotifierProvider<EditTaskPageModel>(
      create: (context) => EditTaskPageModel(oldTaskBean: taskBean),
      child: AddTaskWidget(),
    );
  }

  // ChangeNotifierProvider<EditTaskPageModel> getEditTaskWidget(
  //     {TaskDetailPageModel taskDetailPageModel,
  //       TaskBean taskBean}) {
  //   return ChangeNotifierProvider<EditTaskPageModel>(
  //     create: (context) => EditTaskPageModel(oldTaskBean: taskBean),
  //     child: EventsChooseWidget(),
  //   );
  // }

  ///图标设置页provider
  ChangeNotifierProvider<IconSettingPageModel> getIconSettingPage() {
    return ChangeNotifierProvider<IconSettingPageModel>(
      create: (context) => IconSettingPageModel(),
      child: IconSettingPage(),
    );
  }

  ///主题设置页provider
  ChangeNotifierProvider<ThemePageModel> getThemePage() {
    return ChangeNotifierProvider<ThemePageModel>(
      create: (context) => ThemePageModel(),
      child: ThemePage(),
    );
  }

  ///头像裁剪页provider
  ChangeNotifierProvider<AvatarPageModel> getAvatarPage(
      {MainPageModel mainPageModel}) {
    return ChangeNotifierProvider<AvatarPageModel>(
      create: (context) => AvatarPageModel(),
      child: AvatarPage(
        mainPageModel: mainPageModel,
      ),
    );
  }

  ///图片裁剪页provider
  ChangeNotifierProvider<ImageCropperPageModel> getImageCropperPage(XFile file,
      {EditTaskPageModel model}) {
    return ChangeNotifierProvider<ImageCropperPageModel>(
      create: (context) => ImageCropperPageModel(file, model),
      child: ImageCropperWidget(),
    );
  }

  ///完成列表页provider
  ChangeNotifierProvider<DoneTaskPageModel> getDoneTaskPage() {
    return ChangeNotifierProvider<DoneTaskPageModel>(
      create: (context) => DoneTaskPageModel(),
      child: DoneTaskPage(),
    );
  }

  ///数据分析页provider
  ChangeNotifierProvider<AnalysisPageModel> getDataAnalysisPage() {
    return ChangeNotifierProvider<AnalysisPageModel>(
      create: (context) => AnalysisPageModel(),
      child: DataAnalysisPage(),
    );
  }

  ///搜索任务页provider
  ChangeNotifierProvider<SearchPageModel> getSearchPage() {
    return ChangeNotifierProvider<SearchPageModel>(
      create: (context) => SearchPageModel(),
      child: SearchPage(),
    );
  }

  ///意见反馈页provider
  ChangeNotifierProvider<FeedbackPageModel> getFeedbackPage(
      FeedbackWallPageModel feedbackWallPageModel) {
    return ChangeNotifierProvider<FeedbackPageModel>(
      create: (context) => FeedbackPageModel(),
      child: FeedbackPage(feedbackWallPageModel),
    );
  }

  ///意见反馈墙页provider
  ChangeNotifierProvider<FeedbackWallPageModel> getFeedbackWallPage() {
    return ChangeNotifierProvider<FeedbackWallPageModel>(
      create: (context) => FeedbackWallPageModel(),
      child: FeedbackWallPage(),
    );
  }

  ///登录页provider
  ChangeNotifierProvider<LoginPageModel> getLoginPage({bool isFirst = false}) {
    return ChangeNotifierProvider<LoginPageModel>(
      create: (context) => LoginPageModel(isFirst: isFirst),
      child: LoginPage(),
    );
  }

  ///注册页provider
  ChangeNotifierProvider<RegisterPageModel> getRegisterPage() {
    return ChangeNotifierProvider<RegisterPageModel>(
      create: (context) => RegisterPageModel(),
      child: RegisterPage(),
    );
  }

  ///重设密码页provider,可以设重设密码，也可以设是记密码
  ChangeNotifierProvider<ResetPasswordPageModel> getResetPasswordPage(
      {bool isReset = true}) {
    return ChangeNotifierProvider<ResetPasswordPageModel>(
      create: (context) => ResetPasswordPageModel(isReset),
      child: ResetPasswordPage(),
    );
  }

  // ///网络图片页provider，用于设置账号页面的背景，或者侧滑栏的头部,或者主页背景
  // ChangeNotifierProvider<NetPicturesPageModel> getNetPicturesPage(
  //     {@required String useType,
  //     AccountPageModel accountPageModel,
  //     TaskBean taskBean}) {
  //   return ChangeNotifierProvider<NetPicturesPageModel>(
  //     create: (context) => NetPicturesPageModel(
  //       useType: useType,
  //       accountPageModel: accountPageModel,
  //       taskBean: taskBean,
  //     ),
  //     child: NetPicturesPage(),
  //   );
  // }

  ///账号页面的provider
  ChangeNotifierProvider<AccountPageModel> getAccountPage() {
    return ChangeNotifierProvider<AccountPageModel>(
      create: (context) => AccountPageModel(),
      child: AccountPage(),
    );
  }

  //新的搜索界面
  /* ChangeNotifierProvider<AccountPageModel> getSearchPageModel() {
    return ChangeNotifierProvider<SearchModel>(
      create: (context) => SearchModel(),
      child: SearchIow(),
    );} */

}
