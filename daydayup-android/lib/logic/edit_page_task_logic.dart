import 'dart:core';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/local_calender_service.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/widgets/alert_picker_widget.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/widgets/repeat_picker_widget.dart';
import 'package:todo_list/widgets/tag_picker_widget.dart';

class EditTaskPageLogic {
  final EditTaskPageModel _model;
  List<int> repeatTime = [0,1,7,14,30,365];
  EditTaskPageLogic(this._model);

  bool isEdit(){
    return _model.oldTaskBean!=null;
  }

  Widget getIconText({Icon icon, String text, VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.grey.withOpacity(0.2)),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: icon,
            ),
            SizedBox(
              width: 4,
            ),
            Expanded(
              flex: 5,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///提交一项任务
  void submitOneItem() {
    final controller = _model.textEditingController;
    String text = controller.text;
    if (text.isEmpty) return;
    _model.taskDetails.add(TaskDetailBean(taskDetailName: text));
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.clear());
    controller.clear();
    _model.refresh();
    final scroller = _model.scrollController;
    scroller
        ?.animateTo(scroller?.position?.maxScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.easeInOutSine)
        ?.then((a) {
      controller.text = "";
    });
  }

  //监测软键盘
  void scrollToEndWhenEdit() {
    //检测软键盘是否弹出
    if (MediaQuery.of(_model.context).viewInsets.bottom > 100) {
      debugPrint("软键盘弹出}");
      final scroller = _model.scrollController;
      debugPrint(
          "当前:${scroller?.position?.pixels ?? 100}  全:${scroller?.position?.maxScrollExtent ?? 100}");
      scroller?.animateTo(scroller?.position?.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.easeInOutSine);
    } else {
      debugPrint("软键盘收起");
    }
  }

  //监听文字，提交按钮是否可以点击
  void editListener() {
    final text = _model.textEditingController.text;
    if (text.isEmpty && _model.canAddTaskDetail) {
      _model.canAddTaskDetail = false;
      _model.refresh();
    } else if (text.isNotEmpty && !_model.canAddTaskDetail) {
      _model.canAddTaskDetail = true;
      _model.refresh();
    }
  }

  //删除一项子任务
  void removeItem(int index) {
    _model.taskDetails.removeAt(index);
    _model.refresh();
  }

  //选择任务结束时间
  void pickEndTimeWhenEdit(GlobalModel globalModel) {

    DateTime initialDate = _model.deadLine ?? DateTime.now();
    initialDate = initialDate.add(Duration(minutes: 30));
    DateTime firstDate = DateTime.now();
    DateTime lastDate = initialDate.add(Duration(days: 365));

    showDP(firstDate, initialDate, lastDate).then((day) {
      if (day == null) return;
      if (_model.startDate!= null) {
        if (day.isBefore(_model.startDate)) {
          showDialog(
              context: _model.context,
              builder: (ctx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content:
                  Text(IntlLocalizations.of(_model.context).endBeforeStart),
                );
              });
          return;
        }
      }
      _model.deadLine = day;
      _model.refresh();
    });
  }


  //选择任务结束时间
  void pickEndTime(GlobalModel globalModel) {
    if(isEdit()){
      pickEndTimeWhenEdit(globalModel);
    }else{
      DateTime initialDate = _model.deadLines[_model.index] ?? DateTime.now();
      initialDate = initialDate.add(Duration(minutes: 30));
      DateTime firstDate = DateTime.now();
      DateTime lastDate = initialDate.add(Duration(days: 365));

      showDP(firstDate, initialDate, lastDate).then((day) {
        if (day == null) return;
        if (_model.startDates[_model.index] != null) {
          if (day.isBefore(_model.startDates[_model.index])) {
            showDialog(
                context: _model.context,
                builder: (ctx) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content:
                    Text(IntlLocalizations.of(_model.context).endBeforeStart),
                  );
                });
            return;
          }
        }
        _model.deadLines[_model.index] = day;
        _model.refresh();
      });
    }
  }

  void pickRepeat() async{
    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: _model.context,
        builder: (_) {
          return Container(
              padding: EdgeInsets.all(30),
              height: 350,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: RepeatPickerWidget((int v){
                _model.repeatIndex = v;
              }));
        });
    _model.refresh();
  }

  void pickTag() async {

    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: _model.context,
        builder: (_) {
          return Container(
              padding: EdgeInsets.all(30),
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: TagPickerWidget((int v){
                _model.tagIndex = v;
              }));
        });
    _model.refresh();
  }

  void pickAlertTime() async {

    await showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: _model.context,
        builder: (_) {
          return Container(
              padding: EdgeInsets.all(30),
              height: 700,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: AlertPickerWidget((int v){
                _model.alertIndex = v;
              }));
        });
    _model.refresh();
  }


  void pickStartTimeWhenEdit(GlobalModel globalModel) {
    DateTime firstDate = DateTime.now();
    DateTime initialDate = _model.startDate ?? DateTime.now();
    DateTime lastDate = initialDate.add(Duration(days: 365));

    showDP(firstDate, initialDate, lastDate).then((day) {
      if (day == null) return;
      if (_model.deadLine!= null) {
        if (day.isAfter(_model.deadLine)) {
          showDialog(
              context: _model.context,
              builder: (ctx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  content:
                  Text(IntlLocalizations.of(_model.context).startAfterEnd),
                );
              });
          return;
        }
      }
      _model.startDate = day;
      _model.refresh();
    });
  }

  void pickStartTime(GlobalModel globalModel) {
    if(isEdit()){
      pickStartTimeWhenEdit(globalModel);
    }else{
      DateTime firstDate = DateTime.now();
      DateTime initialDate = _model.startDates[_model.index] ?? DateTime.now();
      DateTime lastDate = initialDate.add(Duration(days: 365));

      showDP(firstDate, initialDate, lastDate).then((day) {
        if (day == null) return;
        if (_model.deadLines[_model.index] != null) {
          if (day.isAfter(_model.deadLines[_model.index])) {
            showDialog(
                context: _model.context,
                builder: (ctx) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content:
                    Text(IntlLocalizations.of(_model.context).startAfterEnd),
                  );
                });
            return;
          }
        }
        _model.startDates[_model.index] = day;
        _model.refresh();
      });
    }
  }

  //时间选择

  Future<DateTime> showDP(
    DateTime firstDate,
    DateTime initialDate,
    DateTime lastDate,
  ) async {
    DateTime dateSelected;

    await showModalBottomSheet(
        context: _model.context,
        builder: (_) {
          return CupertinoDatePicker(
              use24hFormat: true,
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: initialDate,
              minimumDate: firstDate,
              maximumDate: lastDate,
              onDateTimeChanged: (_date) => dateSelected = _date);
        });
    return dateSelected;
  }



  //将结束时间做个转换
  String getEndTimeText() {
    if(isEdit()){
      return getEndTimeTextWhenEdit();
    }else{
      if (_model.deadLines[_model.index] != null) {
        final time = _model.deadLines[_model.index];
        return DateFormat('yyyy-MM-dd HH:mm').format(time);
      }
      return IntlLocalizations.of(_model.context).deadline;
    }
  }

  //将结束时间做个转换
  String getEndTimeTextWhenEdit() {
    if (_model.deadLine != null) {
      final time = _model.deadLine;
      return DateFormat('yyyy-MM-dd HH:mm').format(time);
    }
    return IntlLocalizations.of(_model.context).deadline;
  }

  String getAlertText(){
    List<String> slotText = ["日程发生时","5分钟前","15分钟前","30分钟前","1小时前","2小时前","1天前","2天前","7天前"];

    if(_model.alertIndex!=-1){
      return slotText[_model.alertIndex];
    }
    if(_model.alert!=null){
      switch(_model.alert){
        case 0: return slotText[0];
        case 5: return slotText[1];
        case 15: return slotText[2];
        case 30: return slotText[3];
        case 60: return slotText[4];
        case 120: return slotText[5];
        case 1440: return slotText[6];
        case 2880: return slotText[7];
        case 10080: return slotText[8];
        default:return _model.alert.toString() +"分钟前";
      }
    }
    return "";
  }

  String getRepeatText(){
    List<String> repeatText = ["仅一次","每天","每周","每两周","每月","每年"];

    if(_model.repeatIndex!=-1){
      return repeatText[_model.repeatIndex];
    }
    return "";
  }

   Color getTagColor(){
    List<Color> TagColors =  [Colors.red,Colors.orange,Colors.green,Colors.blue];
    if(_model.tagIndex!=-1){
      return TagColors[_model.tagIndex];
    }
    return Colors.blue;
  }

  //将开始时间做转换
  String getStartTimeText() {
    if(isEdit()){
      return getStartTimeTextWhenEdit();
    }else{
      if (_model.startDates[_model.index] != null) {
        final time = _model.startDates[_model.index];
        // return "${time.year}.${time.month}.${time.day} ${time.hour}:${time.minute<10?}";
        return DateFormat('yyyy-MM-dd HH:mm').format(time);
      }
      return IntlLocalizations.of(_model.context).startDate;
    }
  }



  //将开始时间做转换
  String getStartTimeTextWhenEdit() {
    if (_model.startDate != null) {
      final time = _model.startDate;
      // return "${time.year}.${time.month}.${time.day} ${time.hour}:${time.minute<10?}";
      return DateFormat('yyyy-MM-dd HH:mm').format(time);
    }
    return IntlLocalizations.of(_model.context).startDate;
  }


  //右上角的提交按钮
  void onSubmitTap() {
    bool isEdit = isEditOldTask();
    isEdit ?  submitOldTask() : submitNewTask();
  }

  //创建新的任务
  void submitNewTask() async {
    // if (_model.taskDetails.length == 0) {
    //   showDialog(
    //       context: _model.context,
    //       builder: (ctx) {
    //         return AlertDialog(
    //           shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
    //           content: Text(
    //               IntlLocalizations.of(_model.context).writeAtLeastOneTaskItem),
    //         );
    //       });
    //   return;
    // }
    bool fail = false;
    for(int i=0;i<_model.eventsNum;i++)
   {
     if(_model.startDates[i]==null||_model.deadLines[i]==null){
       Fluttertoast.showToast(
           msg: "时间未填写完整",
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.CENTER,
           timeInSecForIosWeb: 1,
           backgroundColor: Colors.grey,
           textColor: Colors.white,
           fontSize: 16.0
       );
       fail = true;break;
     } if(_model.startDates[i]==null||_model.deadLines[i]==null){
       Fluttertoast.showToast(
           msg: "请填写完整的起止时间",
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.CENTER,
           timeInSecForIosWeb: 1,
           backgroundColor: Colors.grey,
           textColor: Colors.white,
           fontSize: 16.0
       );
       fail = true;break;
     }if( _model.currentTaskNames[i].isEmpty){
       Fluttertoast.showToast(
           msg: "请填写完整事件名称",
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.CENTER,
           timeInSecForIosWeb: 1,
           backgroundColor: Colors.grey,
           textColor: Colors.white,
           fontSize: 16.0
       );
       fail = true;break;
     }
   }

    if(!fail){
      List<TaskBean> taskBeans = await transformDataToBean();
      // if(taskBean.account == 'default'){
      //   await exitWithSubmitNewTask(taskBean);
      // } else {

      postCreateTask(taskBeans);
    }

    // }
  }

  Future exitWithSubmitNewTask(
      {bool needCancelDialog = false}) async {
    // // await DBProvider.db.createTask(taskBean);
    // await _model.mainPageModel.logic.getTasks();
    // _model.mainPageModel.refresh();
    // Navigator.of(_model.context).pop();
    // if (needCancelDialog) Navigator.of(_model.context).pop();
    Navigator.of(_model.context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) {
          return ProviderConfig.getInstance().getMainPage();
        }), (router) => router == null);
  }

  Future exitWhenSubmitOldTask() async {
    // DBProvider.db.updateTask(taskBean);
    await _model.mainPageModel.logic.getTasks();
    _model.mainPageModel.refresh();
    if (_model.taskDetailPageModel != null) {
      _model.taskDetailPageModel.isExiting = true;
      _model.taskDetailPageModel.refresh();
    }
    Navigator.of(_model.context).popUntil((route) => route.isFirst);
  }

  //修改旧的任务
  void submitOldTask() async {
    // if (_model.taskDetails.length == 0) {
    //   showDialog(
    //       context: _model.context,
    //       builder: (ctx) {
    //         return AlertDialog(
    //           shape: RoundedRectangleBorder(
    //               borderRadius: BorderRadius.all(Radius.circular(20.0))),
    //           content: Text(
    //               IntlLocalizations.of(_model.context).writeAtLeastOneTaskItem),
    //         );
    //       });
    //   return;
    // }
    TaskBean taskBean = await transformDataToBeanWhenEdit(
        id: _model.oldTaskBean.id, overallProgress: _getOverallProgress());
    taskBean.changeTimes++;
    // if(taskBean.account == 'default'){
    //   await exitWhenSubmitOldTask(taskBean);
    // } else {
    //   taskBean.uniqueId == null ?
    postUpdateTask(taskBean);
    // : postUpdateTask(taskBean);
    // }
  }

  ///在云端创建一个任务
  void postCreateTask(List<TaskBean> taskBeans, {bool isSubmitOldTask = false}) async {
    showDialog(
        context: _model.context,
        builder: (ctx) {
          return NetLoadingWidget();
        });
    // final token = await SharedUtil.instance.getString(Keys.token);
    ApiService.instance.postCreateTask(
      _model.globalModel.currentId,
      success: (UploadTaskBean bean) {
        // taskBean.uniqueId = bean.uniqueId;
        // taskBean.needUpdateToCloud = 'false';
        // 编辑任务？
        // isSubmitOldTask ? exitWhenSubmitOldTask(taskBean) :
        exitWithSubmitNewTask(needCancelDialog: true);
      },
      failed: (UploadTaskBean bean) {
        // taskBean.needUpdateToCloud = 'true';
        // _model.mainPageModel.needSyn = true;
        // isSubmitOldTask ? exitWhenSubmitOldTask(taskBean) :
        exitWithSubmitNewTask( needCancelDialog: true);
      },
      error: (msg) {
        // taskBean.needUpdateToCloud = 'true';
        // _model.mainPageModel.needSyn = true;
        // isSubmitOldTask ? exitWhenSubmitOldTask(taskBean) :
        exitWithSubmitNewTask(needCancelDialog: true);
      },
      taskBeans: taskBeans,
      // token: token,
      cancelToken: _model.cancelToken,
    );
  }

  ///在云端更新一个任务
  void postUpdateTask(TaskBean taskBean) async {
    showDialog(
        context: _model.context,
        builder: (ctx) {
          return NetLoadingWidget();
        });
    // final token = await SharedUtil.instance.getString(Keys.token);
    ApiService.instance.postUpdateTask(
      success: (CommonBean bean) {
        // taskBean.needUpdateToCloud = 'false';
        exitWhenSubmitOldTask();
      },
      failed: (CommonBean bean) {
        // taskBean.needUpdateToCloud = 'true';
        // _model.mainPageModel.needSyn = true;
        exitWhenSubmitOldTask();
      },
      error: (msg) {
        // taskBean.needUpdateToCloud = 'true';
        // _model.mainPageModel.needSyn = true;
        exitWhenSubmitOldTask();
      },
      taskBean: taskBean,
      // token: token,
      cancelToken: _model.cancelToken,
    );
  }

  //获取当前任务总进度
  double _getOverallProgress() {
    int length = _model.taskDetails.length;
    double overallProgress = 0.0;
    for (int i = 0; i < length; i++) {
      overallProgress += _model.taskDetails[i].itemProgress / length;
    }
    return overallProgress;
  }

  Future<TaskBean> transformDataToBeanWhenEdit(
      {int id, double overallProgress = 0.0}) async {

    // final phone = await SharedUtil.instance.getString(Keys.phone);
    final taskName = _model.currentTaskName.isEmpty
        ? ""
        : _model.currentTaskName;
    final createDate = _model?.createDate != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.createDate)
        : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    List<int> slot = [0,5,15,30,60,120,1440,2880,10080];
    int eventId;
    int alert;
    //编辑任务

    if (_model.eventId != null) {
      eventId = _model.eventId;
    } else {//逐个获取提醒时间
      if (_model.alertIndex != -1) {
        alert = slot[_model.alertIndex];
      }else{
        alert = -1;
      }

      String description = "所属者:" +
          _model.globalModel.logic.getUserName(_model.globalModel.currentId);
      if(_model.taskDetails.length>0){

        description = description + "\n子任务:";
        int i = 0;
        for(TaskDetailBean taskDetailBean in _model.taskDetails){
          i++;
          description = description + "${i}."+ taskDetailBean.taskDetailName;
        }
      }
      eventId = await LocalCalenderService.instance.add(
          taskName,
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.startDates[_model.index]),
          DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.deadLines[_model.index]),
          description,
          alert: alert);
    }

    TaskBean taskBean = TaskBean(
      taskName: taskName,
      account: _model.account,
      taskStatus: _model.oldTaskBean?.taskStatus ?? TaskStatus.todo,
      // needUpdateToCloud: _model.oldTaskBean?.needUpdateToCloud ?? 'false',
      uniqueId: _model.uniqueId ?? null,
      label:_model.tagIndex==-1?3:_model.tagIndex,
      period: _model.repeatIndex==-1?0:repeatTime[_model.repeatIndex],
      // taskType: _model.taskIcon.taskName,
      taskDetailNum: _model.taskDetails.length,
      createDate: createDate,
      eventType: _model.repeatIndex==-1?0:2,
      startDate: _model.startDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.startDate)
          : null,
      deadLine: _model.deadLine != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.deadLine)
          : null,
      detailList: _model.taskDetails,
      // taskIconBean: _model.taskIcon,
      eventId: eventId,
      changeTimes: _model.changeTimes,
      overallProgress: overallProgress,
      alert: _model.alertIndex != -1
          ? slot[_model.alertIndex]
          : null,
      // backgroundUrl: _model.backgroundUrl,
      // textColor: _model.textColorBean,
      finishDate: _model.finishDate != null
          ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.finishDate)
          : null,
    );
    if (id != null) {
      taskBean.id = id;
    }
    return taskBean;
  }

  Future <List<TaskBean>> transformDataToBean(
      {int id, double overallProgress = 0.0}) async {

    if(isEdit()){
      transformDataToBeanWhenEdit(id:id);
    }else{
      List<TaskBean> tasks = [];
      for(int i=0;i<_model.eventsNum;i++){
        if(_model.flag[i]){
          // final phone = await SharedUtil.instance.getString(Keys.phone);
          final taskName = _model.currentTaskNames[i].isEmpty
              ? ""
              : _model.currentTaskNames[i];
          final createDate = _model?.createDate != null
              ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.createDate)
              : DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
          List<int> slot = [0,5,15,30,60,120,1440,2880,10080];
          int eventId;
          int alert;
          //编辑任务
          if (_model.eventId != null) {
            eventId = _model.eventId;
          } else {//逐个获取提醒时间
            if (_model.alertIndex != -1) {
              alert = slot[_model.alertIndex];
            }else{
              alert = -1;
            }

            String description = "所属者:" +
                _model.globalModel.logic.getUserName(_model.globalModel.currentId);
            if(_model.taskDetails.length>0){
              description = description + "\n子任务:";
              int i = 0;
              for(TaskDetailBean taskDetailBean in _model.taskDetails){
                i++;
                description = description + "${i}."+ taskDetailBean.taskDetailName;
              }
            }
            eventId = await LocalCalenderService.instance.add(
                taskName,
                DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.startDates[i]),
                DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.deadLines[i]),
                description,
                alert: alert);
          }

          TaskBean taskBean = TaskBean(
            taskName: taskName,
            account: _model.account,
            taskStatus: _model.oldTaskBean?.taskStatus ?? TaskStatus.todo,
            taskType: _model.taskType,
            // needUpdateToCloud: _model.oldTaskBean?.needUpdateToCloud ?? 'false',
            uniqueId: _model.uniqueId ?? null,
            label:_model.tagIndex==-1?3:_model.tagIndex,
            period: _model.repeatIndex==-1?0:repeatTime[_model.repeatIndex],
            eventType: _model.repeatIndex==-1?0:2,
            taskDetailNum: _model.taskDetails.length,
            createDate: createDate,
            startDate: _model.startDates[i] != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.startDates[i])
                : null,
            deadLine: _model.deadLines[i] != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.deadLines[i])
                : null,
            detailList: _model.taskDetails,
            eventId: eventId,
            changeTimes: _model.changeTimes,
            overallProgress: overallProgress,
            alert: _model.alertIndex != -1
                ? slot[_model.alertIndex]
                : null,
            // backgroundUrl: _model.backgroundUrl,
            // textColor: _model.textColorBean,
            finishDate: _model.finishDate != null
                ? DateFormat('yyyy-MM-dd HH:mm:ss').format(_model.finishDate)
                : null,
          );
          if (id != null) {
            taskBean.id = id;
          }
          tasks.add(taskBean);
        }

      }
      return tasks;
    }
  }

  //用旧任务数据初始化所有数据
  void initialDataFromOld(TaskBean oldTaskBean) {
    if (oldTaskBean != null) {
      _model.taskDetails.clear();
      _model.taskDetails.addAll(oldTaskBean.detailList);
      _model.uniqueId = oldTaskBean.uniqueId;
      _model.account = oldTaskBean.account;
      _model.id = oldTaskBean.id;
      _model.eventId = oldTaskBean.eventId;
      if (oldTaskBean.deadLine != null)
        _model.deadLine = DateTime.parse(oldTaskBean.deadLine);
      if (oldTaskBean.startDate != null)
        _model.startDate = DateTime.parse(oldTaskBean.startDate);
      _model.createDate = DateTime.parse(oldTaskBean.createDate);
      // if(oldTaskBean.finishDate.isNotEmpty)
      if (_model.oldTaskBean.finishDate != null)
        _model.finishDate = DateTime.parse(oldTaskBean.finishDate);
      _model.changeTimes = oldTaskBean.changeTimes ?? 0;
      // _model.taskIcon = oldTaskBean.taskIconBean;
      _model.currentTaskName = oldTaskBean.taskName;
      if (_model.oldTaskBean.alert != null)
        _model.alert = oldTaskBean.alert;
      // _model.backgroundUrl = oldTaskBean.backgroundUrl;
      // _model.textColorBean = oldTaskBean.textColor;
    }
  }

  ///表示当前是属于创建新的任务还是修改旧的任务
  bool isEditOldTask() {
    return _model.oldTaskBean != null;
  }


  ///将当前item置于顶层
  void moveToTop(int index, List list) {
    final item = list[index];
    list.removeAt(index);
    list.insert(0, item);
    _model.refresh();
  }



  void moveTaskDetail(int oldIndex, int newIndex) {
    var oldDetail = _model.taskDetails.removeAt(oldIndex);
    if (newIndex >= _model.taskDetails.length) {
      _model.taskDetails.add(oldDetail);
    } else {
      _model.taskDetails.insert(newIndex, oldDetail);
    }
    _model.refresh();
  }
}
