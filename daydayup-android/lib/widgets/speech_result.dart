import 'package:flutter/material.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/widgets/add_task_widget.dart';
class SpeechResult extends StatelessWidget {
  final String speechContext;
  final EditTaskPageModel model;
  // TaskBean taskBean;
  SpeechResult(this.speechContext,this.model);
  // SpeechResult(this.speechContext,this.taskBean);

  @override
  Widget build(BuildContext context) {
    model.taskType = "3";
    TextEditingController speechResController = TextEditingController();
    TextEditingController eventController = TextEditingController();
    speechResController.text = speechContext;
    eventController.text = "开会";
    return Container(
      padding: EdgeInsets.all(30),
      height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
      child:ListView(

        children: [
          // //识别内容
          // TextField(
          //   controller: speechResController,
          //   enabled: false,
          //   minLines:1,
          // ),
         ProviderConfig.getInstance().getAddTaskWidget(model)
         //  //time
         //  Row(
         //    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         //    children: [
         //      ElevatedButton(
         //          onPressed: (){},
         //          child: Text("今天")
         //      ),
         //      ElevatedButton(
         //          onPressed: (){},
         //          child: Text("明天")
         //      ),
         //      ElevatedButton(
         //          onPressed: (){},
         //          child: Text("设置日期")
         //      ),
         //      ElevatedButton(
         //          onPressed: (){},
         //          child: Text("没有日期")
         //      ),
         //
         //    ],
         //  ),
         //  //event
         //  TextField(
         //    controller: eventController,
         //    enabled: true,
         //    minLines: 1,
         //  ),
         // //子任务
         //  //添加闹钟
         //  Row(
         //    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         //    children: [
         //      //闹钟
         //      IconButton(
         //        onPressed: (){},
         //        icon: Icon(Icons.alarm_add),
         //      ),
         //      IconButton(
         //      onPressed: (){},
         //          icon: Icon(Icons.repeat)
         //      ),
         //      IconButton(
         //          onPressed:(){},
         //          icon: Icon(Icons.photo)
         //      )
         //
         //    ],
         //  ),
         //  //提交任务
         //  Row(
         //    mainAxisAlignment: MainAxisAlignment.end,
         //    children: [
         //      ElevatedButton(
         //          onPressed: (){
         //
         //          },
         //          child: Text(
         //            "完成"
         //          ))
         //    ],
         //  )

        ],
      )




    );
  }
}
