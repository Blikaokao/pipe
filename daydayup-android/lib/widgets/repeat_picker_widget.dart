import 'package:flutter/material.dart';

class RepeatPickerWidget extends StatefulWidget {
  final callback;
  RepeatPickerWidget(this.callback);
  @override
  _RepeatPickerWidgetState createState() => _RepeatPickerWidgetState();
}

class _RepeatPickerWidgetState extends State<RepeatPickerWidget> {
  List<String> repeatText = ["仅一次","每天","每周","每两周","每月","每年"];

  int groupValue = 0;
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: List.generate(
            repeatText.length,
                (index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex:3,
                  child:
                  Text(
                    repeatText[index],
                    style:TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Expanded(
                  flex:1,
                  child:
                  Radio(
                    ///此单选框绑定的值 必选参数
                    value: index,
                    ///当前组中这选定的值  必选参数
                    groupValue: groupValue,
                    ///点击状态改变时的回调 必选参数
                    onChanged: (v) {
                      setState(() {
                        widget.callback(v);
                        groupValue = v;
                      });
                    },
                  ),
                ),

              ],
            )
        )
    );
  }
}
