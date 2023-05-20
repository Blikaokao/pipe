import 'package:flutter/material.dart';
import 'package:todo_list/model/all_model.dart';
import 'dart:math';
import 'package:provider/provider.dart';
class AddTaskWidget extends StatelessWidget {
  int index = -1;
  EditTaskPageModel _model;
  AddTaskWidget({int index,EditTaskPageModel editTaskPageModel}){
    if(index!=null){
      this.index = index;
    }
   this._model = editTaskPageModel;
  }

  GlobalModel globalModel;

  @override
  Widget build(BuildContext context) {

    final textColor = Colors.black;
    final hintTextColor =  Colors.grey;
    final bgColor = Colors.white;
    final TextEditingController taskName = TextEditingController();
    if(index==-1){
      this._model = Provider.of<EditTaskPageModel>(context);
      globalModel = Provider.of<GlobalModel>(context);
      this._model.setContext(context);
      this._model.setGlobalModel(globalModel);
      this._model.setMainPageModel(globalModel.mainPageModel);
    }
      taskName.text = index==-1? _model.oldTaskBean.taskName:_model.currentTaskNames[index];

      ///需要修改
      final iconColor = const Color(0xff5B90E7);
      // _model.logic.scrollToEndWhenEdit();
      return SingleChildScrollView(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          // height: 300,
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.only(
          //     topLeft: Radius.circular(25),
          //     topRight: Radius.circular(25),
          //   ),
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //time
              Container(
                height: 40,
                margin: EdgeInsets.only(left: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      flex: 10,
                      child: _model.logic.getIconText(
                          icon: Icon(
                            Icons.timer,
                            //颜色要改！！！
                            color: iconColor,
                          ),
                          text: _model.logic.getStartTimeText(),
                          onTap: () => _model.logic.pickStartTime(globalModel)),
                    ),
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                      flex: 10,
                      child: _model.logic.getIconText(
                          icon: Icon(
                            Icons.timelapse,
                            //颜色要改！！！
                            color: iconColor,
                          ),
                          text: _model.logic.getEndTimeText(),
                          onTap: () => _model.logic.pickEndTime(globalModel)

                        //() => _model.logic.pickEndTime(globalModel),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),

              //任务名
              Form(
                autovalidateMode: AutovalidateMode.always,
                child: TextFormField(
                  controller:  TextEditingController.fromValue(TextEditingValue(
                    // 设置内容
                      text: taskName.text,
                      // 保持光标在最后
                      selection: TextSelection.fromPosition(TextPosition(
                          affinity: TextAffinity.downstream,
                          offset: taskName.text.length)))),
                  style: TextStyle(
                      color: textColor, textBaseline: TextBaseline.alphabetic),
                  textAlign: TextAlign.start,
                  validator: (text) {
                    index==-1?_model.oldTaskBean.taskName = text:
                    _model.currentTaskNames[index] = text;
                    return null;
                    // return " ";
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.transparent)),

                    labelText: "代办事项",
                    labelStyle: TextStyle(color: hintTextColor),
                    // border: InputBorder.none,
                    // hintText: "代办事项",
                    // _model.logic.getHintTitle(),
                    // hintStyle: TextStyle(color: hintTextColor),
                  ),
                  maxLines: 1,
                ),
              ),

              SizedBox(
                height: 20,
              ),

              //子任务展示栏
              Container(
                // margin: EdgeInsets.only(left: , right: 50),
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overScroll) {
                    overScroll.disallowGlow();
                    return true;
                  },
                  child: ReorderableListView(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    onReorder: (oldIndex, newIndex) {
                      debugPrint("old:$oldIndex   new$newIndex");
                      _model.logic.moveTaskDetail(oldIndex, newIndex);
                    },
                    children: List.generate(_model.taskDetails.length, (index) {
                      return Dismissible(
                        background: Container(
                          alignment: Alignment.centerLeft,
                          color: iconColor,
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        secondaryBackground: Container(
                          alignment: Alignment.centerRight,
                          color: iconColor,
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        key: ValueKey(index + Random().nextDouble()),
                        onDismissed: (d) => _model.logic.removeItem(index),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 10, top: 10),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: iconColor,
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Text(
                                  _model.taskDetails[index].taskDetailName,
                                  style: TextStyle(
                                    color: Color.fromRGBO(130, 130, 130, 1),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              //子任务输入栏
              TextField(
                controller: _model.textEditingController
                  ..addListener(_model.logic.editListener),
                // autofocus: _model.taskDetails.isEmpty,
                style: TextStyle(
                    color: textColor, textBaseline: TextBaseline.alphabetic),
                decoration: InputDecoration(
                    hintText: "添加子任务",
                    //IntlLocalizations.of(context).addTask,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: hintTextColor,
                    ),
                    prefixIcon: Icon(Icons.device_hub),
                    //编辑任务图标
                    // prefixIcon: GestureDetector(
                    //   onTap:() => _model.logic.onIconPress(_model.taskIcon.iconBean,_model.taskIcon.colorBean),
                    //   child: Icon(
                    //     iconData,
                    //     color: iconColor,
                    //   ),
                    // ),
                    suffixIcon: GestureDetector(
                      onTap: _model.logic.submitOneItem,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _model.canAddTaskDetail
                                ? iconColor
                                : Colors.grey.withOpacity(0.4)),
                        child: Icon(
                          Icons.arrow_upward,
                          color: bgColor,
                          size: 20,
                        ),
                      ),
                    )),
              ),
              //添加闹钟
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child:
                    Row(
                      children: [
                        //闹钟
                        Expanded(
                          flex: _model.logic.getAlertText()==""?1:2,
                          child:
                          IconButton(
                              onPressed: () =>_model.logic.pickAlertTime(),
                              icon: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.alarm_add,
                                      color: _model.logic.getAlertText()==""?Colors.black:const Color(0xff5B90E7),
                                    ),
                                    _model.logic.getAlertText()==""?Container():
                                    Text(
                                      _model.logic.getAlertText(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:const Color(0xff5B90E7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                              onPressed: () =>_model.logic.pickTag(),
                              icon: Icon(
                                Icons.report,
                                color:_model.logic.getTagColor(),
                              )
                          ),
                        ),
                        Expanded(
                          flex: _model.logic.getRepeatText()==""?1:2,
                          child: IconButton(
                              onPressed: () =>_model.logic.pickRepeat(),
                              icon:
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.repeat,
                                      color: _model.logic.getRepeatText()==""?Colors.black:const Color(0xff5B90E7),
                                    ),
                                    _model.logic.getRepeatText()==""?Container():
                                    Text(
                                      _model.logic.getRepeatText(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:const Color(0xff5B90E7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ),
                        ),
                        Expanded(child: IconButton(onPressed: () {}, icon: Icon(Icons.photo)),)
                      ],
                    ),
                  ),

                  // IconButton(
                  //   icon: Icon(
                  //     Icons.check,
                  //     color: iconColor,
                  //     size: 35,
                  //   ),
                  //   tooltip: IntlLocalizations.of(context).submit,
                  //   onPressed: _model.logic.onSubmitTap,
                  // )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed:  (){
                      if(index!=-1){
                        _model.currentTaskNames[index] = taskName.text;

                      }else{
                        _model.oldTaskBean.taskName = taskName.text;
                      }
                      _model.logic.onSubmitTap();
                    },
                    child: Text(
                        "完成"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      primary: const Color(0xff5B90E7),
                    ),
                  ),
                ],
              )
            ],
          ));
    }
}
