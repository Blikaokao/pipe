import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/logic/all_logic.dart';

import 'global_model.dart';

class AllMainPageModel extends ChangeNotifier {
  AllMainPageLogic logic;
  BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<TaskBean> selectedTasks = [];
  List<TaskBean> tasks = [];
  LinkedHashMap<DateTime, List<TaskBean>> kEvents =
      LinkedHashMap<DateTime, List<TaskBean>>();

  ///当前选中的日期
  DateTime currentChooseDate = DateTime.now();

  ///当前的用户名
  String currentUserName = "";

  CancelToken cancelToken = CancelToken();

  ///用于在AllMainPage销毁后将GlobalModel中的AllMainPageModel销毁
  GlobalModel globalModel;
  // GlobalModel _globalModel;

  //写了一个构造函数   构造logic
  AllMainPageModel() {
    logic = AllMainPageLogic(this);
  }

  void setContext(BuildContext context, {GlobalModel globalModel}) {
    if (this.context == null) {
      this.context = context;

      this.globalModel = globalModel;
      // this._globalModel = globalModel;
      //异步方法
      Future.wait(
        [
          logic.getAllTasks(),
        ],
      ).then((value) {
        //通知构建函数
        refresh();
      });
    }
    ;
  }

  //销毁UI
  @override
  void dispose() {
    super.dispose();
    scaffoldKey?.currentState?.dispose();
    if (!cancelToken.isCancelled) cancelToken.cancel();
    // _globalModel.mainPageModel = null;
    globalModel.allMainPageModel = null;

    debugPrint("AllMainPageModel销毁了");
  }

  void refresh() {
    notifyListeners();
  }
}
