import 'package:flutter/material.dart';

class AlertPickerWidget extends StatefulWidget {
  final callback;
  AlertPickerWidget(this.callback);
  @override
  _AlertPickerWidgetState createState() => _AlertPickerWidgetState();
}

class _AlertPickerWidgetState extends State<AlertPickerWidget> {

  // List<int> slot = [0,5,15,30,60,120,1440,2880,10080];
  List<String> slotText = ["日程发生时","5分钟前","15分钟前","30分钟前","1小时前","2小时前","1天前","2天前","7天前"];
  int groupvalue = 0;
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: List.generate(
        slotText.length,
        (index) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
            slotText[index]
        ),
        Radio(
          ///此单选框绑定的值 必选参数
          value: index,
          ///当前组中这选定的值  必选参数
          groupValue: groupvalue,
          ///点击状态改变时的回调 必选参数
          onChanged: (v) {
            setState(() {
              widget.callback(v);
              groupvalue = v;
            });
          },
        ),
      ],
    )
    )
    );
  }
}
