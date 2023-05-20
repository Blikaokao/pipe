import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/api_strategy.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/date_picker_util.dart';
import 'package:todo_list/utils/shared_util.dart';

class AllMainPageLogic {
  final AllMainPageModel _model;
  CancelToken cancelToken = CancelToken();
  List<Color> taskItemColor = [
    const Color(0XFFACC8E8),
    const Color(0XFFE8CBCE),
    const Color(0XFFF3D074),
    const Color(0XFF96C58E),
  ];

  AllMainPageLogic(this._model);

  //获得index对应人
  List<TaskBean> getPerDayTask(int index) {
    if (index >= _model.globalModel.allId.length) {
      return [];
    }
    int id = _model.globalModel.allId[index];

    List<TaskBean> list = [];
    TaskBean task;

    for (int i = 0; i < _model.selectedTasks.length; i++) {
      task = _model.selectedTasks[i];
      if (task.uniqueId == id) {
        list.add(task);
      }
    }

    return list;
  }

  ///获得一个人每天的任务列表容器
  List<Widget> getPerDayTaskContainer(
      double cellWidth, double height, List<TaskBean> list, index) {
    if (list.length == 0) {
      return [
        Center(
            child: Container(
          width: cellWidth,
          height: height * 24,
          // color: Colors.yellow,
          // child: Text(
          //     "什么都没有"
          // ),
        ))
      ];
    }

    //计算每个container的高度
    List<Container> containerHeight = [];
    DateTime startTime, endTime;
    int slot;
    int i;

    for (i = 0; i < list.length; i++) {
      if (i == 0) {
        startTime = DateTime.parse(list[i].startDate);
        slot = startTime
            .difference(
                DateTime(startTime.year, startTime.month, startTime.day))
            .inMinutes;
      } else {
        startTime = DateTime.parse(list[i - 1].deadLine);
        endTime = DateTime.parse(list[i].startDate);
        slot = endTime.difference(startTime).inMinutes;
      }

      if (slot < 0) {
        continue;
      }
      //与前一个的时间槽
      containerHeight.add(Container(
        width: cellWidth,
        height: slot * height / 60,
      ));
      //跨天
      if (DateTime.parse(list[i].deadLine).day >
          DateTime.parse(list[i].startDate).day) {
        DateTime date = DateTime.parse(list[i].startDate);
        slot = DateTime(
          date.year,
          date.month,
          date.day + 1,
        ).difference(date).inMinutes;
      } else {
        slot = DateTime.parse(list[i].deadLine)
            .difference(DateTime.parse(list[i].startDate))
            .inMinutes;
      }

      containerHeight.add(Container(
        decoration: BoxDecoration(
            color: const Color(0xFFF4F4F4),
            // color: Colors.blueGrey[100],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: taskItemColor[index],
              width: 2,
            )),
        width: cellWidth,
        height: slot * height / 60,
        child: Center(
            child: Text(
          list[i].taskName,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        )),
      ));
    }

    //与24：00
    startTime = DateTime.parse(list[i - 1].deadLine);
    if (startTime.day != DateTime.parse(list[i - 1].startDate).day) {
      slot = 0;
    } else {
      slot = DateTime(startTime.year, startTime.month, startTime.day + 1)
          .difference(startTime)
          .inMinutes;
    }
    containerHeight.add(Container(
      width: cellWidth,
      height: slot * height / 60,
    ));

    return containerHeight;
  }

  ///获得图标+文字
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
            icon,
            SizedBox(
              width: 4,
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  ///获取任务Map{date[task1,task2……],}
  Future getAllTasks() async {
    int id = await SharedUtil.instance.getInt(Keys.id);

    ApiService.instance.getAllTasks(
      params: {
        'id': id.toString(),
      },
      success: (CloudTaskBean bean) async {
        final tasks = bean.taskList;
        _model.tasks.clear();
        _model.tasks.addAll(tasks);
        final _kEventSource = Map<DateTime, List<TaskBean>>();
        DateTime dateTime;
        for (TaskBean event in _model.tasks) {
          dateTime = DateTime.parse(event.startDate);
          dateTime = DateTime.utc(dateTime.year, dateTime.month, dateTime.day);

          if (_kEventSource.containsKey(dateTime)) {
            //存在
            _kEventSource[dateTime].add(event);
            _kEventSource[dateTime]
                .sort((a, b) => a.startDate.compareTo(b.startDate));
          }
          //不存在，插入新元素
          else
            _kEventSource.putIfAbsent(dateTime, () => [event]);
        }
        _model.kEvents = LinkedHashMap<DateTime, List<TaskBean>>(
          equals: isSameDay,
          hashCode: getHashCode,
        )..addAll(_kEventSource);

        // List<TaskBean> needUpdateTasks = [];
        // List<TaskBean> needCreateTasks = [];
        // for (var task in tasks) {
        //   final uniqueId = task.uniqueId;
        //   final localTask = await DBProvider.db.getTaskByUniqueId(uniqueId);
        //   ///如果本地没有查到这个task，就需要在本地重新创建
        //   if(localTask == null){
        //     needCreateTasks.add(task);
        //   } else {
        //     task.id = localTask[0].id;
        //     // task.backgroundUrl = localTask[0].backgroundUrl;
        //     // task.textColor = localTask[0].textColor;
        //     needUpdateTasks.add(task);
        //   }
        // }
        // await DBProvider.db.updateTasks(needUpdateTasks);
        // await DBProvider.db.createTasks(needCreateTasks);
        // widget.mainPageModel.logic.getTasks().then((v){
        //   // widget.mainPageModel.needSyn = false;
        //   widget.mainPageModel.refresh();
        // });
        // setState(() {
        //   synFlag = SynFlag.noNeedSynced;
        // });noNeedSynced
      },
      failed: (CloudTaskBean bean) {
        // setState(() {
        //
        // });
      },
      error: (msg) {
        // setState(() {
        //   synFlag = SynFlag.failSynced;
        // });
      },
      token: cancelToken,
    );
  }

  ///获得当前用户的用户名
  Future getCurrentUserName() async {
    final currentUserName =
        await SharedUtil.instance.getString(Keys.currentUserName);
    if (currentUserName == null) return;
    if (currentUserName == _model.currentUserName) return;
    _model.currentUserName = currentUserName;
  }

  ///当任务列表为空时显示的内容
  Widget getEmptyWidget(GlobalModel globalModel) {
    final context = _model.context;
    final size = MediaQuery.of(context).size;
    final theMin = min(size.width, size.height) / 2;
    return Container(
      margin: EdgeInsets.only(top: 40),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        "svgs/empty_list.svg",
        // color: globalModel.logic.getWhiteInDark(),
        color: Colors.blue,
        width: theMin,
        height: theMin,
        semanticsLabel: 'empty list',
      ),
    );
  }
}
