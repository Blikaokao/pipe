import 'package:flutter/material.dart';

class TagPickerWidget extends StatefulWidget {
  final callback;
  TagPickerWidget(this.callback);
  @override
  _TagPickerWidgetState createState() => _TagPickerWidgetState();
}

class _TagPickerWidgetState extends State<TagPickerWidget> {

  List<String> Tags = ["Ⅰ 重要且紧急","Ⅱ 重要不紧急","Ⅲ 不重要紧急","Ⅳ 不重要不紧急"];
  List<Color> TagColors = [Colors.red,Colors.orange,Colors.green,Colors.blue];

  int groupValue = 0;
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: List.generate(
            Tags.length,
                (index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                   flex:3,
                    child:
                    Text(
                      Tags[index],
                      style:TextStyle(
                        fontSize: 20,
                        color:TagColors[index],
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
