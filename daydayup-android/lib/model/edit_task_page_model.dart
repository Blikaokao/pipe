import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/json/task_icon_bean.dart';
import 'package:todo_list/logic/all_logic.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/model/main_page_model.dart';
import 'package:todo_list/model/task_detail_page_model.dart';

class EditTaskPageModel extends ChangeNotifier{

  EditTaskPageLogic logic;
  String taskType;
  BuildContext context;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  int index=0;
  MainPageModel mainPageModel;
  TaskDetailPageModel taskDetailPageModel;
  GlobalModel globalModel;
  CancelToken cancelToken = CancelToken();
  int eventsNum = 1;
  List<TaskBean> tasks;
  List<bool> flag = [true];
  List<DateTime> startDates= [null];
  List<DateTime> deadLines = [null];
  List<String> currentTaskNames = [""];
  int eventId;
  ///任务清单
  List<TaskDetailBean> taskDetails = [];
  ///截止日期
  DateTime deadLine;
  ///开始日期
  DateTime startDate;
  String currentTaskName;
  int alert;
  int alertIndex = -1;
  int tagIndex = -1;
  int repeatIndex = -1;
  ///创建日期
  DateTime createDate;
  ///结束日期
  DateTime finishDate;

  int changeTimes = 0;
  int uniqueId;
  int id;
  String account;


  ///能否添加一项任务
  bool canAddTaskDetail = false;

  ///当这个值不为空的时候，表示不是新增一个task，而是编辑已存在的task
  TaskBean oldTaskBean;

  EditTaskPageModel({TaskBean oldTaskBean}){
    this.oldTaskBean = oldTaskBean;
    logic = EditTaskPageLogic(this);
    this.id = oldTaskBean?.id;
    logic.initialDataFromOld(oldTaskBean);
  }

  void setContext(BuildContext context){
    if(this.context == null){
        this.context = context;
    }
  }



  @override
  void dispose(){
    super.dispose();
    textEditingController?.removeListener(logic.editListener);
    textEditingController?.dispose();
    scrollController?.dispose();
    if(!cancelToken.isCancelled) cancelToken.cancel();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    debugPrint("EditTaskPageModel销毁了");
  }

  void refresh(){
    notifyListeners();
  }

  // //可删
  // void setTaskIcon(TaskIconBean taskIcon) {
  //   if(this.taskIcon == null){
  //     this.taskIcon = taskIcon;
  //   }
  // }

  void setMainPageModel(MainPageModel mainPageModel) {
    this.mainPageModel = mainPageModel;
  }
  void setGlobalModel(GlobalModel globalModel) {
    this.globalModel = globalModel;
  }

  void setTaskDetailPageModel(TaskDetailPageModel taskDetailPageModel) {
    if(this.taskDetailPageModel == null){
      this.taskDetailPageModel = taskDetailPageModel;
    }
  }

}