import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'global_model.dart';

class AddClassPageModel extends ChangeNotifier {
  bool isTimeSame = true;
  AddClassPageLogic logic;
  BuildContext context;
  final ClassBean classBean;
  List<String> timeStartList = ["08:00","8:00","8:00","8:00","8:00","8:00","8:00","8:00","8:00","8:00",];
  List<String> timeEndList = ["08:00","8:00","8:00","8:00","8:00","8:00","8:00","8:00","8:00","8:00",];
  int classLength = 45;
  int restLength = 10;

  AddClassPageModel(this.classBean) {
    logic = AddClassPageLogic(this);
  }

  void setContext(BuildContext context, {GlobalModel globalModel}) {
    if (this.context == null) {
      this.context = context;
    }

  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("MainPageModel销毁了");
  }

  void refresh() {
    notifyListeners();
  }
}
