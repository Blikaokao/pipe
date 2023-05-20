import 'package:flutter/material.dart';
class ChooseAddModeWidget extends StatefulWidget {
  List<Widget> widgetContent;
  ChooseAddModeWidget(this.widgetContent);
  @override
  _ChooseAddModeWidgetState createState() => _ChooseAddModeWidgetState();
}

class _ChooseAddModeWidgetState extends State<ChooseAddModeWidget> {
  int index = 0;

  void onTapCallBack(int index)
  {
    setState(() {
      this.index=index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      height: 300,
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               ModeButton(0, "关联",index==0, onTapCallBack),
               ModeButton(1, "创建",index==1, onTapCallBack),
             ],
           ),
           widget.widgetContent[index]

         ],

      )
    );
  }

}

class ModeButton extends StatefulWidget {
  final int index;
  final String mode;
  bool isChoosen;
  final Function onTapCallBack;
  ModeButton(this.index,this.mode,this.isChoosen,this.onTapCallBack);

  @override
  _ModeButtonState createState() => _ModeButtonState();
}

class _ModeButtonState extends State<ModeButton> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
            color: widget.isChoosen?Colors.blue:Colors.white,
          border: Border.all(color: Colors.blue,width: 1.0)
        ),
        child: Center(
          child: Text(
            widget.mode,
            style: TextStyle(
              color:widget.isChoosen?Colors.white:Colors.blue,
            ),
          ),
        )
      ),
      onTap: (){
        setState(() {
          widget.onTapCallBack(widget.index);
          widget.isChoosen=!widget.isChoosen;
        });
      },
    );
  }
}

