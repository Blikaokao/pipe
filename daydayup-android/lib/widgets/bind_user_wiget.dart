import 'package:flutter/material.dart';

double btnHeight = 60;
double borderWidth = 2;

class BindUserWidget extends StatefulWidget {
  String title;
  String cancelBtnTitle;
  String okBtnTitle;
  VoidCallback cancelBtnTap;
  VoidCallback okBtnTap;
  TextEditingController phone;
  TextEditingController userName;
  BindUserWidget(
      {@required this.title,
        this.cancelBtnTitle = "Cancel",
        this.okBtnTitle = "Ok",
        this.cancelBtnTap,
        this.okBtnTap,
        this.phone,
        this.userName
      });

  @override
  _BindUserWidgetState createState() =>
      _BindUserWidgetState();
}

class _BindUserWidgetState extends State<BindUserWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 20),
        height: 200,
        width: 10000,
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
                alignment: Alignment.center,
                child: Text(
                  widget.title,
                )),
            Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextField(
                style: TextStyle(color: Colors.black87),
                controller: widget.phone,
                decoration: InputDecoration(
                    prefixIcon:Icon(Icons.phone),
                    hintText: "用户账号",
                    hintStyle: TextStyle(
                      fontSize: 15
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    )),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextField(
                style: TextStyle(color: Colors.black87),
                controller: widget.userName,
                decoration: InputDecoration(
                    prefixIcon:Icon(Icons.person),
                    hintText: "用户备注",
                    hintStyle: TextStyle(
                        fontSize: 15
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    )),
              ),
            ),
            Container(
              // color: Colors.red,
              height: btnHeight,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(
                children: [
                  // Container(
                  //   // 按钮上面的横线
                  //   width: double.infinity,
                  //   color: Colors.blue,
                  //   height: borderWidth,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          widget.phone.text = "";
                          widget.userName.text = "";
                          widget.cancelBtnTap();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          widget.cancelBtnTitle,
                          style: TextStyle(fontSize: 22, color: Colors.blue),
                        ),
                      ),
                      // Container(
                      //   // 按钮中间的竖线
                      //   width: borderWidth,
                      //   color: Colors.blue,
                      //   height: btnHeight - borderWidth - borderWidth,
                      // ),
                      ElevatedButton(
                          onPressed: () {
                            widget.okBtnTap();
                            Navigator.of(context).pop();
                            widget.userName.text = "";
                            widget.phone.text = "";
                          },
                          child: Text(
                            widget.okBtnTitle,
                            style: TextStyle(fontSize: 22, color: Colors.white),
                          )),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

