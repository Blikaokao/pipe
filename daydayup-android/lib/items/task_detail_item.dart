import 'dart:async';

import 'package:flutter/material.dart';
import 'package:todo_list/json/task_bean.dart';

class TaskDetailItem extends StatefulWidget {
  final bool isDone;
  final TaskDetailBean taskDetailBean;
  final Function onChecked;

  TaskDetailItem(this.taskDetailBean, this.onChecked, this.isDone);

  @override
  _TaskDetailItemState createState() => _TaskDetailItemState();
}

class _TaskDetailItemState extends State<TaskDetailItem>
    with SingleTickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {

    return  Container(
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                //单选框
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    value: widget.isDone||widget.taskDetailBean.itemProgress == 1,
                    onChanged: (value) {
                      setState(() {
                        widget.onChecked(value);
                        if (value) {
                          widget.taskDetailBean.itemProgress = 1;
                        } else {
                          widget.taskDetailBean.itemProgress = 0;
                        }
                      });

                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ),
                //任务描述
                Expanded(
                    flex: 8,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if ( widget.taskDetailBean.itemProgress == 1) {
                            widget.taskDetailBean.itemProgress = 0;
                          } else {
                            widget.taskDetailBean.itemProgress = 1;
                          }
                          if (widget.onChecked != null) {
                            widget.onChecked(widget.taskDetailBean.itemProgress == 1);
                          }
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.only(
                            left: 5,
                          ),
                          child: Text("${widget.taskDetailBean.taskDetailName}", style: TextStyle(color: Theme.of(context).primaryColor),)),
                    )),
                // Expanded(
                //     flex: 1,
                //     child: progressShow
                //         ? SizedBox()
                //         : Text(
                //             "${(currentProgress * 100).toInt()}%",
                //             style: TextStyle(fontSize: 8,color: widget.textColor,),
                //           )),
                // Expanded(
                //     flex: 1,
                //     child: IconButton(
                //         icon: Icon(
                //           progressShow
                //               ? Icons.arrow_drop_up
                //               : Icons.arrow_drop_down,
                //           color: Colors.grey,
                //         ),
                //         onPressed: () {
                //           setState(() {
                //             progressShow = !progressShow;
                //           });
                //         }))
              ],
            ),
            // progressShow ? getProgressWidget(context) : SizedBox(),
          ],
        ),
      );
  }

  // Row getProgressWidget(BuildContext context) {
  //   return Row(
  //     children: <Widget>[
  //       Expanded(
  //         flex: 6,
  //         child: Container(
  //           margin: EdgeInsets.only(left: 22),
  //           height: 5,
  //           child: Slider(
  //               activeColor: widget.iconColor ?? Theme.of(context).primaryColor,
  //               value: currentProgress,
  //               onChanged: (value) {
  //                 setState(() {
  //                   currentProgress = value;
  //                 });
  //                 if (widget.onProgressChanged != null) {
  //                   widget.onProgressChanged(value);
  //                 }
  //               }),
  //         ),
  //       ),
  //       SizedBox(
  //         width: 20,
  //       ),
  //       Expanded(
  //         flex: 2,
  //         child: Text(
  //           "${(currentProgress * 100).toInt()}%",
  //           style: TextStyle(fontSize: 8,color: widget.textColor,),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

