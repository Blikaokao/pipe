import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:todo_list/json/task_bean.dart';
import 'dart:collection';
import 'global_model.dart';



class AnalysisPageModel extends ChangeNotifier {
  AnalysisPageModelLogic logic;
  BuildContext context;
  GlobalModel globalModel;
  List<num> eventStatusList = [4,2,3];
  List<num> taskTypeList = [1,2,3];
  List<num> taskNumList=[2,2,3,1];



  AnalysisPageModel() {
    logic = AnalysisPageModelLogic(this);
  }

  void setContext(BuildContext context, GlobalModel globalModel) {
    if (this.context == null) {
      this.context = context;
      this.globalModel = globalModel;
      logic.getData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void refresh() {
    notifyListeners();
  }
}


