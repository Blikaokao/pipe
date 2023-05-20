import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
class TextInputWidget extends StatefulWidget {

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  DateTime startTime = null;
  DateTime deadLine = null;
  String taskName = "";

  final iconColor = const Color(0xff5B90E7);
  final bgColor = const Color(0xff5B90E7);
  TextEditingController todoTextController = TextEditingController();
  var childs = <Widget>[];
  EditTaskPageModel model = EditTaskPageModel();

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    todoTextController.dispose();
  }

  //从文本中提取时间和事件
  taskPicker() async {
    CancelToken cancelToken = CancelToken();
    Map<String,dynamic> params = {
      "text":todoTextController.text,
    };

    ApiService.instance.postByText(
      success: (EventBean bean) {
        Fluttertoast.showToast(
            msg: "提取完成",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0
        );
        List<Event> events = bean.events;
        model.eventsNum = events.length;
        model.flag = List.generate(model.eventsNum, (index) => true);
        model.tasks = List.generate(model.eventsNum, (index) => TaskBean());
        if(events.length>0){
          model.startDates.clear();
          model.deadLines.clear();
          model.currentTaskNames.clear();
        }
        for(int i=0;i<events.length;i++){
          Event event = events[i];
          event.startDate!=""? model.startDates.add(DateTime.parse(event.startDate)):model.startDates.add(null);
          event.deadLine!=""? model.deadLines.add(DateTime.parse(event.deadLine)):model.deadLines.add(null);
          event.taskName!=""? model.currentTaskNames.add(event.taskName):model.currentTaskNames.add("");
        }

        model.refresh();

        // _text = res["result"];
      },
      failed: (EventBean bean) {

      },
      error: (msg) {
        // Navigator.of(_model.context).pop();
        // _showTextDialog(msg);
      },
      params: params,
      token: cancelToken,
    );


  }

  @override
  Widget build(BuildContext context) {
    model.taskType = "1";
    return Container(
        padding: EdgeInsets.all(30),
        height: 900,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child:
        SingleChildScrollView(
          padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextField(
              controller: todoTextController,
              maxLines: 4,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Colors.transparent)
                  ),

                  labelText:"识别文本",
                  labelStyle: TextStyle(color: Colors.grey),
                  //编辑任务图标
                  // prefixIcon: GestureDetector(
                  //   onTap:() => _model.logic.onIconPress(_model.taskIcon.iconBean,_model.taskIcon.colorBean),
                  //   child: Icon(
                  //     iconData,
                  //     color: iconColor,
                  //   ),
                  // ),
                  suffixIcon: GestureDetector(
                    onTap: taskPicker,
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.withOpacity(0.4)),
                      child: Icon(
                        Icons.arrow_upward,
                        color: todoTextController.text.isNotEmpty?bgColor:Colors.grey.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                  )),
            ),
          ProviderConfig.getInstance().getAddTaskWidget(model),
          ]),
        ));
  }
}
