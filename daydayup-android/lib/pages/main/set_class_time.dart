import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/model/add_class_page_model.dart';
import 'package:intl/src/intl/date_format.dart';

class SetClassTimePage extends StatefulWidget {
  final AddClassPageModel model;
  SetClassTimePage(this.model);
  @override
  _SetClassTimePageState createState() => _SetClassTimePageState();
}

class _SetClassTimePageState extends State<SetClassTimePage> {
  List<Widget> eveningClass = [];
  List<Widget> morningClass = [];
  List<Widget> afternoonClass = [];
  AddClassPageModel model;

  void refresh(){
    setState(() {
      morningClass = List.generate(4,
              (index) => ListTile(
            title: Text('第${index+1}节课'),
            trailing: Container(
                width: 200,
                child:TextButton(
                    child:Text(model.logic.getTimeSlot(index)),
                    onPressed: (){
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (_) {
                            return  ClassSectionTime(index,model.timeStartList[index],model.timeEndList[index],model.logic.setClassTime,refresh);
                          });
                    }
                )),
          )
      );
      afternoonClass =List.generate(4,
              (index) => ListTile(
            title: Text('第${index+5}节课'),
            trailing: Container(
                width: 200,
                child:TextButton(
                    child:Text(model.logic.getTimeSlot(index+4)),
                    onPressed: (){
                      showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (_) {
                            return  ClassSectionTime(index+4,model.timeStartList[index+4],model.timeEndList[index+4],model.logic.setClassTime,refresh);
                          });
                    }
                )),
          )
      );
      eveningClass = List.generate(2,
            (index) =>
            ListTile(
                title: Text('第${index+9}节课'),
                trailing: Container(
                  width: 200,
                  child:TextButton(
                      child:Text(model.logic.getTimeSlot(index+8)),
                      onPressed: (){
                        showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (_) {
                              return  ClassSectionTime(index+8,model.timeStartList[index+8],model.timeEndList[index+8],model.logic.setClassTime,refresh);
                            });
                      }
                  ),
                )
            ),
      );

    });
  }
  @override
  Widget build(BuildContext context) {
    model = widget.model;
    morningClass = List.generate(4,
            (index) => ListTile(
          title: Text('第${index+1}节课'),
          trailing: Container(
              width: 200,
              child:TextButton(
                  child:Text(model.logic.getTimeSlot(index)),
                  onPressed: (){
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (_) {
                          return  ClassSectionTime(index,model.timeStartList[index],model.timeEndList[index],model.logic.setClassTime,refresh);
                        });
                  }
              )),
        )
    );
    List<Widget> afternoonClass =List.generate(4,
            (index) => ListTile(
          title: Text('第${index+5}节课'),
          trailing: Container(
              width: 200,
              child:TextButton(
                  child:Text(model.logic.getTimeSlot(index+4)),
                  onPressed: (){
                    showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (_) {
                          return  ClassSectionTime(index+4,model.timeStartList[index+4],model.timeEndList[index+4],model.logic.setClassTime,refresh);
                        });
                  }
              )),
        )
    );
    eveningClass = List.generate(2,
          (index) =>
          ListTile(
              title: Text('第${index+9}节课'),
              trailing: Container(
                width: 200,
                child:TextButton(
                    child:Text(model.logic.getTimeSlot(index+8)),
                    onPressed: (){
                      showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return  ClassSectionTime(index+8,model.timeStartList[index+8],model.timeEndList[index+8],model.logic.setClassTime,refresh);
                          });
                    }
                ),
              )
          ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("课程时间设置"),
        actions: [
          IconButton(onPressed: (){},icon: Icon(Icons.done))
        ],
      ),
      body:ListView(
            children: [
              ListTile(
                title: Text("每节课时长相同",style: TextStyle(fontSize: 18),),
                subtitle: Text("支持一键设置"),
                trailing: Switch(
                    value:model.isTimeSame,
                    onChanged: (value){
                      setState(() {
                        model.isTimeSame = !model.isTimeSame;
                      });
                    }
                ),
              ),
              ListTile(
                title: Text("每节课时长",style: TextStyle(fontSize: 18),),
                // trailing: Container(),
              ),
              ListTile(
                title: Text("课间休息时长",style: TextStyle(fontSize: 18),),
                // trailing: Container(),
              ),
              Divider(),
              Text("上午",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
              Container(
                height: 300,
                child: Column(
                  children: morningClass,
                ),
              ),
              Divider(),
              Text("下午",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
              Container(
                height: 300,
                child: Column(
                  children: afternoonClass,
                ),
              ),
              Divider(),
              Text("晚上",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold),),
              Container(
                height: 300,
                child: Column(
                  children: eveningClass,
                ),
              ),

            ],
          ),
    );
  }
}


class ClassSectionTime extends StatefulWidget {
  int index;
  String startDate;
  String endDate;
  Function callBack;
  Function refresh;
  ClassSectionTime(this.index,this.startDate,this.endDate,this.callBack,this.refresh);
  @override
  _ClassSectionTimeState createState() => _ClassSectionTimeState();
}

class _ClassSectionTimeState extends State<ClassSectionTime> {
  @override
  Widget build(BuildContext context) {
    DateTime selectedStartDate;
    DateTime selectedEndDate;
    final startDate = DateTime(2022,5,7,int.parse(widget.startDate.split(":")[0]),int.parse(widget.startDate.split(":")[1]));
    final endDate = DateTime(2022,5,7,int.parse(widget.endDate.split(":")[0]),int.parse(widget.endDate.split(":")[1]));
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
      height: 350,
      child:Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(onPressed: (){ Navigator.of(context).pop();}, child: Text("取消",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),),
                ElevatedButton(onPressed: (){
                  widget.callBack(widget.index,DateFormat('HH:mm').format(selectedStartDate),DateFormat('HH:mm').format(selectedEndDate));
                  widget.refresh();
                  Navigator.of(context).pop();
                  }, child: Text("确定",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),),),
              ],
            ),
          ),
          Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("上课时间",style: TextStyle(fontSize: 18,),),
                Text("下课时间",style: TextStyle(fontSize: 18,),),
              ],
            ),
          ),
          Container(
            height: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height:350,
                  width: 150,
                  child:  CupertinoDatePicker(
                      use24hFormat: true,
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: startDate,
                      onDateTimeChanged: (_date) => selectedStartDate = _date),
                ),

                Container(
                  height:350,
                  width: 150,
                  child:  CupertinoDatePicker(
                      use24hFormat: true,
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: endDate,
                      onDateTimeChanged: (_date) => selectedEndDate = _date),
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}

