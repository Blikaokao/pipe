import 'package:flutter/material.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/widgets/add_task_widget.dart';
class EventsChooseWidget extends StatefulWidget {
  @override
  _EventsChooseWidgetState createState() => _EventsChooseWidgetState();
}

class _EventsChooseWidgetState extends State<EventsChooseWidget> {
  EditTaskPageModel editTaskPageModel;
  GlobalModel globalModel;
  List<AddTaskWidget> addTaskWidgets = [];


  void onTapCallBack(int newIndex){
    setState(() {
      print("点击"+newIndex.toString());
      editTaskPageModel.index = newIndex;
      editTaskPageModel.refresh();
    });
  }

  void onDeleteCallBack(int newIndex){
    setState(() {
      print("删除"+newIndex.toString());
      editTaskPageModel.flag[editTaskPageModel.index] = false;
      int k=0;
      for(bool i in editTaskPageModel.flag){
        if(i) editTaskPageModel.index = k;
        k++;
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    editTaskPageModel =  Provider.of<EditTaskPageModel>(context);
    globalModel = Provider.of<GlobalModel>(context);
    editTaskPageModel.setContext(context);
    editTaskPageModel.setGlobalModel(globalModel);
    editTaskPageModel.setMainPageModel(globalModel.mainPageModel);

    addTaskWidgets = List.generate(editTaskPageModel.eventsNum, (index) => AddTaskWidget(index:index,editTaskPageModel: editTaskPageModel));

    return
       Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(editTaskPageModel.eventsNum, (index){
                  if (editTaskPageModel.eventsNum==1){
                    return Container();
                  }
                  return  editTaskPageModel.flag[index]?TitleButton(index, index==editTaskPageModel.index,onTapCallBack, onDeleteCallBack):Container();
                }),
              ),
            ),
            Container(
              child: addTaskWidgets[editTaskPageModel.index],
            )

          ],
        ),
       );
  }
}


class TitleButton extends StatefulWidget {
  int index;
  bool isChoosen;
  Function onTapCallBack;
  Function onDeleteCallBack;
  TitleButton(this.index,this.isChoosen,this.onTapCallBack,this.onDeleteCallBack);
  @override
  _TitleButtonState createState() => _TitleButtonState();
}

class _TitleButtonState extends State<TitleButton> {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 35,
      color: widget.isChoosen?Colors.blueAccent:Colors.white,
     child: Row(
       children: [
         GestureDetector(
         child: Container(
           width: 120,
           height: 30,
           child:Center(
             child: Text("事项"+(widget.index+1).toString(),style: TextStyle(color:widget.isChoosen?Colors.white:Colors.blueAccent,fontSize: 18,fontWeight: FontWeight.bold,letterSpacing: 2),),
           ),
           color: Colors.transparent,
         ),
         onTap: () {
           setState(() {
             widget.onTapCallBack(widget.index);
             widget.isChoosen=!widget.isChoosen;
             print(widget.isChoosen?widget.index.toString()+"被选":widget.index.toString()+"没被选");
           });
         }
         ,
       ),
         GestureDetector(
           child:Icon(Icons.close,color: widget.isChoosen?Colors.white:Colors.blueAccent,),
           onTap: () {widget.onDeleteCallBack(widget.index);print(widget.isChoosen?widget.index.toString()+"被选":widget.index.toString()+"没被选");},
         )
       ],

     )
    );
  }
}


