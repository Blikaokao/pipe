import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_list/json/task_icon_bean.dart';

///单个任务的json数据
///id、任务名、账户、任务类型
class TaskBean {
  int id;
  String taskName;
  String taskType;
  String account;
  int taskStatus;
  int period;//周期
  int label;
  int eventType;
  ///子任务数量
  int taskDetailNum = 0;
  int eventId;
  // ///子任务完成数
  // int taskDetailComplete = 0;

  double overallProgress;
  ///存放在云端后拿到的云数据库Id,若[cloudId]为空，表示尚未上传到云端
  int uniqueId;

  ///是否需要在云端更新,true or false
  // String needUpdateToCloud;

  ///任务修改次数
  int changeTimes;

  ///创建任务的时间
  String createDate;

  ///任务完成的时间
  String finishDate;

  ///用户设置的任务开始时间
  String startDate;

  ///用户设置的任务结束时间
  String deadLine;
  ///用户设置的提醒时间
  int alert;

  ///当前任务的图标信息
  // TaskIconBean taskIconBean;

  ///任务详情列表
  List<TaskDetailBean> detailList = [];

  ///以下内容，只存储在本地数据库内。

  ///当前字体颜色
  // ColorBean textColor;

  ///当前卡片背景图片地址
  // String backgroundUrl;

  TaskBean({
    this.taskName = "",
    this.taskType = "",
    this.taskStatus = TaskStatus.todo,
    this.taskDetailNum,
    this.label,
    this.period,
    // this.taskDetailComplete = 0,
    this.overallProgress = 0.0,
    this.uniqueId,
    this.eventId,
    // this.needUpdateToCloud = 'true',
    this.changeTimes = 0,
    this.createDate = "",
    this.finishDate = "",
    this.account = "default",
    this.startDate = "",
    this.deadLine = "",
    // this.taskIconBean,
    this.detailList,
    this.alert,
    this.eventType,
    // this.textColor,
    // this.backgroundUrl,
  });

  static TaskBean fromMap(Map<String, dynamic> map) {
    TaskBean taskBean = new TaskBean();
    taskBean.id = map['id'];
    taskBean.taskName = map['taskName'];
    // taskBean.taskType = map['taskType'];
    // taskBean.taskDetailComplete = map['taskDetailComplete'];
    taskBean.taskDetailNum = map['taskDetailNum'];
    taskBean.taskStatus = map['taskStatus'];
    taskBean.account = map['account'];
    taskBean.uniqueId = map['uniqueid'];
    taskBean.label = map['label'];
    taskBean.period = map['period'];
    // taskBean.needUpdateToCloud = map['needUpdateToCloud'] ?? 'false';
    taskBean.changeTimes = int.parse(map['changeTimes'] ?? '0');
    taskBean.overallProgress = double.parse(map['overallProgress']);
    taskBean.createDate = map['createDate'];
    taskBean.finishDate = map['finishDate'];
    taskBean.startDate = map['startDate'];
    taskBean.deadLine = map['deadLine'];
    taskBean.alert = map['alert'];
    taskBean.period = map['period'];
    taskBean.eventId = map['eventId'];
    taskBean.eventType = map['eventType'];
    // if (map['taskIconBean'] is String) {
    //   var taskIconBean = jsonDecode(map['taskIconBean']);
    //   taskBean.taskIconBean = TaskIconBean.fromMap(taskIconBean);
    // } else {
    //   taskBean.taskIconBean = TaskIconBean.fromMap(map['taskIconBean']);
    // }
      taskBean.detailList = TaskDetailBean.fromMapList(map['detailtaskList']);

    // if (map['textColor'] is String) {
    //   var textColor = jsonDecode(map['textColor']);
    //   taskBean.textColor = ColorBean.fromMap(textColor);
    // } else {
    //   taskBean.textColor = ColorBean.fromMap(map['textColor']);
    // }
    // taskBean.backgroundUrl = map['backgroundUrl'];
    return taskBean;
  }

  static TaskBean fromNetMap(Map<String, dynamic> map) {

    TaskBean taskBean = new TaskBean();
    taskBean.id = map['id'];
    taskBean.taskName = map['taskName'];
    // taskBean.taskType = map['taskType'];
    taskBean.taskDetailNum = map['taskDetailNum'] ?? 0;
    // taskBean.taskDetailComplete = int.parse(map['taskDetailComplete'] ?? '0');
    taskBean.taskStatus = map['taskStatus'] ?? 0;
    taskBean.account = map['account'];
    taskBean.eventId = map['eventId'];
    taskBean.uniqueId = map['uniqueid'];
    taskBean.label = map['label'];
    taskBean.period = map['period'];
    // taskBean.needUpdateToCloud = map['needUpdateToCloud'] ?? 'false';
    taskBean.changeTimes = int.parse(map['changeTimes'] ?? '0');
    taskBean.overallProgress = map['overallProgress']==null?double.parse(map['overallProgress']):0.0;
    taskBean.createDate = map['createDate'];
    taskBean.finishDate = map['finishDate'];
    taskBean.startDate = map['startDate'];
    taskBean.deadLine = map['deadLine'];
    taskBean.alert = map['alert'];
    taskBean.eventType = map['eventType'];
    // if (map['taskIconBean'] is String) {
    //   var taskIconBean = jsonDecode(map['taskIconBean']);
    //   taskBean.taskIconBean = TaskIconBean.fromMap(taskIconBean);
    // } else {
    //   taskBean.taskIconBean = TaskIconBean.fromMap(map['taskIconBean']);
    // }
    taskBean.detailList = TaskDetailBean.fromMapList(map['detailtaskList']);
    return taskBean;
  }

  static List<TaskBean> fromMapList(dynamic mapList) {
    List<TaskBean> list = List.filled(mapList.length, null);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

  static List<TaskBean> fromNetMapList(List mapList) {

    int length = mapList.length;
    List<TaskBean> list = [];

    for (int i = 0; i < length; i++) {
      list.add(fromNetMap(mapList[i]));
    }


    return list;
  }

  Map<String, dynamic> toMap() {
    return {
    'taskName': taskName,
    // 'taskType':taskBean.taskType,
    'account': account,
      'taskType':taskType,
    'uniqueid': uniqueId.toString(),
    // 'taskStatus': '${taskStatus}',
    'taskDetailNum': '${taskDetailNum}',
    'overallProgress': '${overallProgress}',
    'changeTimes': '${changeTimes}',
    'finishDate': finishDate,
    'startDate': startDate,
    'deadLine': deadLine,
    'alert': alert,
      'label':label,
      'period':period,
    'eventId':eventId,
      'eventType':eventType,
    // 'taskIconBean':jsonEncode(taskBean.taskIconBean.toMap()),
    'detailtaskList': List.generate(detailList.length, (index) {
    return detailList[index].toMap();
      })
    };
    //把list转换为string的时候不要直接使用tostring，要用jsonEncode
  }

  @override
  String toString() {
    return 'TaskBean{id: $id, taskName: $taskName, taskType: $taskType, account: $account, taskStatus: $taskStatus, taskDetailNum: $taskDetailNum, overallProgress: $overallProgress, uniqueId: $uniqueId,'
        // ' needUpdateToCloud: $needUpdateToCloud,'
        ' changeTimes: $changeTimes, eventId:$eventId,createDate: $createDate, finishDate: $finishDate, startDate: $startDate, deadLine: $deadLine, '
        // 'taskIconBean: $taskIconBean, '
        'detailList: $detailList, alert:$alert,eventType:$eventType,label:$label,period:$period,}';
  }

  ///是否需要在云端更新
  bool getNeedUpdateToCloud(TaskBean taskBean) {
    return true;
    // final uniqueId = taskBean.uniqueId;
    // final account = taskBean.account;
    // if (account == 'default') return false;
    // if (uniqueId == null) {
    //   // taskBean.needUpdateToCloud = 'true';
    //   return true;
    // }
    // if (taskBean.needUpdateToCloud == null) {
    //   taskBean.needUpdateToCloud = 'true';
    //   return true;
    // }
    // return taskBean.needUpdateToCloud == 'true';
  }
}

///单个任务详情的json数据
///子任务名、进度
class TaskDetailBean {
  int id;
  int parentId;
  String taskDetailName;
  int itemProgress;

  TaskDetailBean({this.id,this.parentId,this.taskDetailName = "", this.itemProgress = 0});

  static TaskDetailBean fromMap(Map<String, dynamic> map) {

    TaskDetailBean taskDetailBean = new TaskDetailBean();
    taskDetailBean.id = map['id'];
    taskDetailBean.parentId = map['parentId'];
    taskDetailBean.taskDetailName = map['taskDetailName'];
    taskDetailBean.itemProgress = map['itemProgress'];

    return taskDetailBean;
  }

  static List<TaskDetailBean> fromMapList(List<dynamic> mapList) {
    if(mapList==null){
      return [];
    }
    List<TaskDetailBean> list = [];
    for (int i = 0; i < mapList.length; i++) {
      list.add(fromMap(mapList[i]));
    }

    return list;
  }

  Map<dynamic, dynamic> toMap() {
    return {
      'taskDetailName': taskDetailName,
      'itemProgress': itemProgress.toString()
    };
  }
}

///任务状态
///todo 0\doing 1\done 2
class TaskStatus {
  static const int todo = 0;
  static const int doing = 1;
  static const int done = 2;
}

class TaskLabel{
  static const int red = 0; //重要且紧急
  static const int orange = 1;//重要不紧急
  static const int green = 2;//不重要紧急
  static const int blue = 3;//不重要不紧急
}