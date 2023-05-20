import 'package:flutter/material.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/items/task_detail_item.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/json/task_icon_bean.dart';
// import 'package:todo_list/widgets/popmenu_botton.dart';

// class TaskInfoWidget extends StatelessWidget {
//   final TaskBean taskBean;
//   TaskItemInner(this.taskBean);
//
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Column(
//       children: <Widget>[
//         Container(
//           margin: EdgeInsets.only(
//               left: 50,
//               top: size.width > size.height ? 0 : 20,
//               right: 50),
//           child: NewTaskInfoWidget(
//
//             taskBean: taskBean,
//           ),
//         ),
//         Expanded(
//           child: Container(
//             margin: EdgeInsets.only(top: 20),
//             child: !model.isExiting
//                 ? NotificationListener<OverscrollIndicatorNotification>(
//                 onNotification: (overScroll) {
//                   overScroll.disallowGlow();
//                   return true;
//                 },
//                 child: ListView(
//                   children: List.generate(
//                     model?.taskBean?.detailList?.length ?? 0,
//                         (index) {
//                       TaskDetailBean taskDetailBean =
//                       model.taskBean.detailList[index];
//                       return Container(
//                         margin: EdgeInsets.only(
//                             bottom: index ==
//                                 model.taskBean.detailList
//                                     .length -
//                                     1
//                                 ? 20
//                                 : 0,
//                             left: 50,
//                             right: 50),
//                         child: TaskDetailItem(
//                           index: index,
//                           showAnimation:
//                           model.doneTaskPageModel == null,
//                           itemProgress: taskDetailBean.itemProgress,
//                           itemName: taskDetailBean.taskDetailName,
//                           iconColor: taskColor,
//                           textColor: textColor,
//                           onProgressChanged: (progress) {
//                             model.logic.refreshProgress(
//                                 taskDetailBean,
//                                 progress,
//                                 mainPageModel);
//                             model.refresh();
//                           },
//                           onChecked: (progress) {
//                             model.logic.refreshProgress(
//                                 taskDetailBean,
//                                 progress,
//                                 mainPageModel);
//                             model.refresh();
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ))
//                 : SizedBox(),
//           ),
//         )
//       ],
//     );
//   }
// }

///由简介+子事务构成，此类是简介
class TaskInfoWidget extends StatefulWidget {
  final int index;
  final double space;
  final TaskBean taskBean;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isCardChangeWithBg;
  final bool isExisting;
  final bool isDetail;

  TaskInfoWidget(
    this.isDetail,
    this.index, {
    this.space = 20,
    this.taskBean,
    this.onEdit,
    this.onDelete,
    this.isCardChangeWithBg = false,
    this.isExisting = false,
  });

  @override
  _TaskInfoWidgetState createState() => _TaskInfoWidgetState();
}

class _TaskInfoWidgetState extends State<TaskInfoWidget> {
  int index;
  double space;
  TaskBean taskBean;
  VoidCallback onDelete;
  VoidCallback onEdit;
  bool isCardChangeWithBg;
  bool isExisting;

  @override
  Widget build(BuildContext context) {

    index = widget.index;
    space = widget.space;
    taskBean = widget.taskBean;
    onDelete = widget.onDelete;
    onEdit = widget.onEdit;
    isCardChangeWithBg = widget.isCardChangeWithBg;
    isExisting = widget.isExisting;


    DateTime startTime = DateTime.parse(taskBean.startDate);
    DateTime deadLine = DateTime.parse(taskBean.deadLine);

    // final iconColor = isCardChangeWithBg
    //     ? Theme.of(context).primaryColor
    //     : ColorBean.fromBean(taskBean.taskIconBean.colorBean);
    final iconColor = Theme.of(context).primaryColor;
    final textColor = getTextColor(context);
    // final taskIconData = IconBean.fromBean(taskBean.taskIconBean.iconBean);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Checkbox(
                shape: CircleBorder(),
                value: taskBean.overallProgress == 1.0,
                onChanged: (value) {
                  setState(() {
                    taskBean.changeTimes++;
                    if (value) {
                      //设置完成
                      taskBean.overallProgress = 1;
                      // taskBean.taskDetailComplete = taskBean.taskDetailNum;
                      taskBean.finishDate = DateTime.now().toIso8601String();
                      // taskBean.taskStatus = TaskStatus.done;
                    } else {
                      //取消完成
                      taskBean.overallProgress = 0;
                      // taskBean.taskStatus = TaskStatus.done;
                    }
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),

              //完成标识或开始时间点
              // Expanded(
              //   flex: 2,
              //   child: Container(
              //     margin: EdgeInsets.only(top: 16),
              //     alignment: Alignment.bottomLeft,
              //     //任务已完成且该条目不存在
              //     child: taskBean.overallProgress >= 1.0 && !isExisting
              //         ? Hero(
              //       tag: "task_complete$index",
              //       child: Icon(
              //         Icons.check_circle,
              //         size: 24,
              //         color: Colors.greenAccent,
              //       ),
              //     )
              //         : getStatusWidget(context, iconColor),
              //   ),
              // ),
              Expanded(
                flex: 8,
                //任务名
                child: Text(
                  "${taskBean.taskName}",
                  maxLines: widget.isDetail?10:1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    // fontWeight: FontWeight.bold
                  ),
                ),
              ),
              if(taskBean.eventType==1)
                Expanded(
                  flex: 1,
                  //任务名
                  child: Image.asset("images/course.png",width: 25),
                ),
              Expanded(
                flex: 1,
                //任务名
                child: Container(),
              ),
              //任务图标
              // Expanded(
              //   flex: 4,
              //   child: Container(
              //     margin: EdgeInsets.only(top: 16),
              //     child: Hero(
              //       tag: "task_icon$index",
              //       child: Container(
              //           width: 42,
              //           height: 42,
              //           decoration: BoxDecoration(
              //               border: Border.all(
              //                 color: iconColor,
              //               ),
              //               shape: BoxShape.circle),
              //           child: Icon(
              //             // taskIconData,
              //             Icons.money,
              //             color: iconColor,
              //           )),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        //时间
        // getStatusWidget(context, iconColor),
        Container(
          padding: EdgeInsets.only(left: 15),
          child: Text(
            //时间
            "${DateFormat("HH:mm").format(startTime)}~${DateFormat("HH:mm").format(deadLine)}",
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),

        SizedBox(
          height: 5,
        ),
        //子任务
        taskBean.taskDetailNum > 0 ? _item() : Container(),

        // Row(
        //   children: <Widget>[
        //     //扩展按钮
        //     Expanded(
        //       child: Container(
        //         alignment: Alignment.centerRight,
        //         child: Container(
        //             width: 42,
        //             height: 42,
        //             margin: EdgeInsets.only(top: 16),
        //             child: space == 20
        //                 ? SizedBox()
        //                 : Hero(
        //                     tag: "task_more$index",
        //                     child: Material(
        //                         color: Colors.transparent,
        //                         child: PopMenuBt(
        //                           iconColor: iconColor,
        //                           onDelete: onDelete,
        //                           onEdit: onEdit,
        //                           taskBean: taskBean,
        //                         )))),
        //       ),
        //     )
        //   ],
        // ),
        // Column(
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: <Widget>[
        //     //是否需要在云端更新
        //     taskBean.getNeedUpdateToCloud(taskBean)
        //         ? Hero(
        //             tag: "task_syn$index",
        //             child: Material(
        //               color: Colors.transparent,
        //               child: Text(
        //                 "(${IntlLocalizations.of(context).notSynced})",
        //                 style: TextStyle(
        //                   color: textColor,
        //                   fontSize: 12,
        //                 ),
        //               ),
        //             ),
        //           )
        //         : Container(),
        //
        //     // //子任务数
        //     // Container(
        //     //   margin: EdgeInsets.only(top: 5),
        //     //   alignment: Alignment.bottomLeft,
        //     //   child: Hero(
        //     //     tag: "task_items$index",
        //     //     child: Material(
        //     //       color: Colors.transparent,
        //     //       child: Text(
        //     //         "${IntlLocalizations.of(context).itemNumber(taskBean.taskDetailNum)}",
        //     //         style: TextStyle(fontSize: 10, color: textColor),
        //     //       ),
        //     //     ),
        //     //   ),
        //     // ),
        //     // //完成率
        //     // Container(
        //     //   alignment: Alignment.centerRight,
        //     //   child: Hero(
        //     //     tag: "task_progress$index",
        //     //     child: Material(
        //     //         color: Colors.transparent,
        //     //         child: Text(
        //     //           "${(taskBean.overallProgress * 100).toInt()}%",
        //     //           style: TextStyle(
        //     //               fontSize: 10,
        //     //               fontWeight: FontWeight.bold,
        //     //               color: textColor),
        //     //         )),
        //     //   ),
        //     // ),
        //     // //进度条
        //     // Hero(
        //     //   tag: "task_progressbar$index",
        //     //   child: Container(
        //     //     height: 10,
        //     //     margin: EdgeInsets.only(top: 12, bottom: 10),
        //     //     child: ClipRRect(
        //     //       borderRadius: BorderRadius.all(Radius.circular(10)),
        //     //       child: LinearProgressIndicator(
        //     //         valueColor: AlwaysStoppedAnimation(iconColor),
        //     //         value: taskBean.overallProgress,
        //     //         backgroundColor: Color.fromRGBO(224, 224, 224, 1),
        //     //       ),
        //     //     ),
        //     //   ),
        //     // ),
        //   ],
        // )
      ],
    );
  }

  //任务完成比
  Widget _item() {


    int taskComplete = 0;
    for (TaskDetailBean detailBean in taskBean.detailList) {

      if (detailBean.itemProgress == 1) {
        taskComplete++;
      }
    }
    return ExpansionTile(
      title: Text(
        taskComplete.toString() + "/" + taskBean.taskDetailNum.toString(),
        style: TextStyle(color: Colors.black54, fontSize: 15),
      ),
      children: (taskBean.detailList)
          .map((taskDetail) => _buildSub(taskDetail))
          .toList(),
    );
  }

  Widget _buildSub(TaskDetailBean taskDetail) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: Container(
        // height: 50,
        // margin: EdgeInsets.only(bottom: 2),
        // decoration: BoxDecoration(color:Colors.lightBlueAccent),
        child: TaskDetailItem(
            taskDetail, onDetailCheck, taskBean.overallProgress == 1.0),
      ),
    );
  }

  Widget getStatusWidget(BuildContext context, Color taskColor) {
    final startDate = taskBean.startDate ?? "";
    final deadLine = taskBean.deadLine ?? "";
    final now = DateTime.now();
    if (startDate.isNotEmpty && deadLine.isNotEmpty) {
      final begin = DateTime.parse(startDate);
      final end = DateTime.parse(deadLine);

      ///如果当前时间小于设置的开始时间
      if (now.isBefore(begin)) {
        return getBeginIcon(begin, now, context, taskColor);
      }

      ///如果当前时间在设置的起止时间内
      if (now.isAfter(begin) && now.isBefore(end)) {
        return getEndIcon(end, now, context, taskColor);
      }
    } else if (startDate.isNotEmpty) {
      final begin = DateTime.parse(startDate);
      if (now.isBefore(begin)) {
        return getBeginIcon(begin, now, context, taskColor);
      }
    } else if (deadLine.isNotEmpty) {
      final end = DateTime.parse(deadLine);
      if (now.isBefore(end)) {
        return getEndIcon(end, now, context, taskColor);
      }
    }
    return SizedBox();
  }

  Widget getEndIcon(
      DateTime end, DateTime now, BuildContext context, Color taskColor) {
    int days = end.difference(now).inDays;
    int hours = end.difference(now).inHours;
    bool showHour = days == 0;
    return Row(
      children: <Widget>[
        Hero(
            tag: "time_icon$index",
            child: Icon(
              Icons.timelapse,
              color: taskColor,
            )),
        Expanded(
          child: Hero(
              tag: "time_text$index",
              child: Material(
                color: Colors.transparent,
                child: Text(
                  showHour
                      ? IntlLocalizations.of(context).hours(hours)
                      : IntlLocalizations.of(context).days(days),
                  style: TextStyle(
                    color: taskColor,
                  ),
                ),
              )),
        ),
      ],
    );
  }

  Color getTextColor(BuildContext context) {
    // final textColor = taskBean.textColor;
    // if (textColor != null) return ColorBean.fromBean(textColor);
    return DefaultTextStyle.of(context).style.color;
  }

  Widget getBeginIcon(
      DateTime begin, DateTime now, BuildContext context, Color taskColor) {
    int days = begin.difference(now).inDays;
    int hours = begin.difference(now).inHours;
    bool showHour = days == 0;
    return Row(
      children: <Widget>[
        Hero(
            tag: "time_icon$index",
            child: Icon(
              Icons.timer,
              color: taskColor,
            )),
        Expanded(
          child: Hero(
              tag: "time_text$index",
              child: Material(
                  color: Colors.transparent,
                  child: Text(
                    showHour
                        ? IntlLocalizations.of(context).hours(hours)
                        : IntlLocalizations.of(context).days(days),
                    style: TextStyle(
                      color: taskColor,
                    ),
                  ))),
        ),
      ],
    );
  }

  void onDetailCheck(bool status) {
    setState(() {
      // if (status) {
      //   taskBean.taskDetailComplete++;
      //   if (taskBean.taskDetailComplete == taskBean.taskDetailNum) {
      //     taskBean.overallProgress = 1.0;
      //     taskBean.finishDate = DateTime.now().toIso8601String();
      //   }
      // } else {
      //   taskBean.taskDetailComplete--;
      //   taskBean.overallProgress = 0.0;
      // }
    });
  }
}

// class TaskInfoWidget extends StatelessWidget {
//   final int index;
//   final double space;
//   final TaskBean taskBean;
//   final VoidCallback onDelete;
//   final VoidCallback onEdit;
//   final bool isCardChangeWithBg;
//   final bool isExisting;
//
//   TaskInfoWidget(
//     this.index, {
//     this.space = 20,
//     this.taskBean,
//     this.onDelete,
//     this.onEdit,
//     this.isCardChangeWithBg = false,
//     this.isExisting = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final iconColor = isCardChangeWithBg
//         ? Theme.of(context).primaryColor
//         : ColorBean.fromBean(taskBean.taskIconBean.colorBean);
//     final textColor = getTextColor(context);
//     final taskIconData = IconBean.fromBean(taskBean.taskIconBean.iconBean);
//
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: <Widget>[
//         Container(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: <Widget>[
//               //完成标识或开始时间点
//               Expanded(
//                 flex: 2,
//                 child: Container(
//                   margin: EdgeInsets.only(top: 16),
//                   alignment: Alignment.bottomLeft,
//                   //任务已完成且该条目不存在
//                   child: taskBean.overallProgress >= 1.0 && !isExisting
//                       ? Hero(
//                     tag: "task_complete$index",
//                     child: Icon(
//                       Icons.check_circle,
//                       size: 24,
//                       color: Colors.greenAccent,
//                     ),
//                   )
//                       : getStatusWidget(context, iconColor),
//                 ),
//               ),
//               Expanded(
//                 flex: 8,
//                 //任务名
//                 child: Container(
//                   margin: EdgeInsets.only(top: 16),
//                   child: Hero(
//                     tag: "task_title$index",
//                     child: Material(
//                       color: Colors.transparent,
//                       child: Text(
//                         "${taskBean.taskName} ",
//                         style: TextStyle(
//                             color: textColor,
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               //任务图标
//               Expanded(
//                 flex:4,
//                 child: Container(
//                   margin: EdgeInsets.only(top: 16),
//                   child: Hero(
//                     tag: "task_icon$index",
//                     child: Container(
//                         width: 42,
//                         height: 42,
//                         decoration: BoxDecoration(
//                             border: Border.all(
//                               color: iconColor,
//                             ),
//                             shape: BoxShape.circle),
//                         child: Icon(
//                           taskIconData,
//                           color: iconColor,
//                         )),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         //时间
//         getStatusWidget(context,iconColor),
//         _item(,taskBean.),
//
//         // Row(
//         //   children: <Widget>[
//         //     //扩展按钮
//         //     Expanded(
//         //       child: Container(
//         //         alignment: Alignment.centerRight,
//         //         child: Container(
//         //             width: 42,
//         //             height: 42,
//         //             margin: EdgeInsets.only(top: 16),
//         //             child: space == 20
//         //                 ? SizedBox()
//         //                 : Hero(
//         //                     tag: "task_more$index",
//         //                     child: Material(
//         //                         color: Colors.transparent,
//         //                         child: PopMenuBt(
//         //                           iconColor: iconColor,
//         //                           onDelete: onDelete,
//         //                           onEdit: onEdit,
//         //                           taskBean: taskBean,
//         //                         )))),
//         //       ),
//         //     )
//         //   ],
//         // ),
//         SizedBox(
//           height: space,
//         ),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             //是否需要在云端更新
//             taskBean.getNeedUpdateToCloud(taskBean) ? Hero(
//               tag: "task_syn$index",
//               child: Material(
//                 color: Colors.transparent,
//                 child: Text(
//                   "(${IntlLocalizations.of(context).notSynced})",
//                   style: TextStyle(
//                     color: textColor,
//                       fontSize: 12,),
//                 ),
//               ),
//             ) : Container(),
//
//
//             //子任务数
//             Container(
//               margin: EdgeInsets.only(top: 5),
//               alignment: Alignment.bottomLeft,
//               child: Hero(
//                 tag: "task_items$index",
//                 child: Material(
//                   color: Colors.transparent,
//                   child: Text(
//                     "${IntlLocalizations.of(context).itemNumber(taskBean.taskDetailNum)}",
//                     style: TextStyle(fontSize: 10,color: textColor),
//                   ),
//                 ),
//               ),
//             ),
//             //完成率
//             Container(
//               alignment: Alignment.centerRight,
//               child: Hero(
//                 tag: "task_progress$index",
//                 child: Material(
//                     color: Colors.transparent,
//                     child: Text(
//                       "${(taskBean.overallProgress * 100).toInt()}%",
//                       style:
//                           TextStyle(fontSize: 10, fontWeight: FontWeight.bold,color: textColor),
//                     )),
//               ),
//             ),
//             //进度条
//             Hero(
//               tag: "task_progressbar$index",
//               child: Container(
//                 height: 10,
//                 margin: EdgeInsets.only(top: 12, bottom: 10),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.all(Radius.circular(10)),
//                   child: LinearProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation(iconColor),
//                     value: taskBean.overallProgress,
//                     backgroundColor: Color.fromRGBO(224, 224, 224, 1),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   //任务完成比
//   Widget _item(String city,List<TaskDetailBean> detailList){
//     return ExpansionTile(
//       title: Text(city,style: TextStyle(color:Colors.black54,fontSize: 20),),
//       children: detailList.map((taskDetail)=>_buildSub(taskDetail)).toList(),
//     );
//   }
//
//   Widget _buildSub(TaskDetailBean taskDetail){
//     return FractionallySizedBox(
//       widthFactor: 1,
//       child: Container(
//         height: 50,
//         margin: EdgeInsets.only(bottom: 5),
//         decoration: BoxDecoration(color:Colors.lightBlueAccent),
//         child: Text(taskDetail.taskDetailName),
//       ),
//     );
//   }
//
//   Widget getStatusWidget(BuildContext context, Color taskColor) {
//     final startDate = taskBean.startDate ?? "";
//     final deadLine = taskBean.deadLine ?? "";
//     final now = DateTime.now();
//     if (startDate.isNotEmpty && deadLine.isNotEmpty) {
//       final begin = DateTime.parse(startDate);
//       final end = DateTime.parse(deadLine);
//
//       ///如果当前时间小于设置的开始时间
//       if (now.isBefore(begin)) {
//         return getBeginIcon(begin, now, context, taskColor);
//       }
//
//       ///如果当前时间在设置的起止时间内
//       if (now.isAfter(begin) && now.isBefore(end)) {
//         return getEndIcon(end, now, context, taskColor);
//       }
//     } else if (startDate.isNotEmpty) {
//       final begin = DateTime.parse(startDate);
//       if (now.isBefore(begin)) {
//         return getBeginIcon(begin, now, context, taskColor);
//       }
//     } else if (deadLine.isNotEmpty) {
//       final end = DateTime.parse(deadLine);
//       if (now.isBefore(end)) {
//         return getEndIcon(end, now, context, taskColor);
//       }
//     }
//     return SizedBox();
//   }
//
//   Widget getEndIcon(
//       DateTime end, DateTime now, BuildContext context, Color taskColor) {
//     int days = end.difference(now).inDays;
//     int hours = end.difference(now).inHours;
//     bool showHour = days == 0;
//     return Row(
//       children: <Widget>[
//         Hero(
//             tag: "time_icon$index",
//             child: Icon(
//               Icons.timelapse,
//               color: taskColor,
//             )),
//         Expanded(
//           child: Hero(
//               tag: "time_text$index",
//               child: Material(
//                 color: Colors.transparent,
//                 child: Text(
//                   showHour
//                       ? IntlLocalizations.of(context).hours(hours)
//                       : IntlLocalizations.of(context).days(days),
//                   style: TextStyle(color: taskColor,),
//                 ),
//               )),
//         ),
//       ],
//     );
//   }
//
//   Color getTextColor(BuildContext context){
//     final textColor = taskBean.textColor;
//     if(textColor != null) return ColorBean.fromBean(textColor);
//     return DefaultTextStyle.of(context).style.color;
//   }
//
//   Widget getBeginIcon(
//       DateTime begin, DateTime now, BuildContext context, Color taskColor) {
//     int days = begin.difference(now).inDays;
//     int hours = begin.difference(now).inHours;
//     bool showHour = days == 0;
//     return Row(
//       children: <Widget>[
//         Hero(
//             tag: "time_icon$index",
//             child: Icon(
//               Icons.timer,
//               color: taskColor,
//             )),
//         Expanded(
//           child: Hero(
//               tag: "time_text$index",
//               child: Material(
//                   color: Colors.transparent,
//                   child: Text(
//                     showHour
//                         ? IntlLocalizations.of(context).hours(hours)
//                         : IntlLocalizations.of(context).days(days),
//                     style: TextStyle(
//                       color: taskColor,
//                     ),
//                   ))),
//         ),
//       ],
//     );
//   }
// }
