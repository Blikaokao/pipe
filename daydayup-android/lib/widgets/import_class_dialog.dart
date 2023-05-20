import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:fluttertoast/fluttertoast.dart';

double borderWidth = 2;
class ImportClassDialogContent extends StatefulWidget {
  String title;
  String cancelBtnTitle;
  String okBtnTitle;
  VoidCallback cancelBtnTap;
  VoidCallback okBtnTap;
  ImportClassDialogContent(
      {@required this.title,
      this.cancelBtnTitle = "Cancel",
      this.okBtnTitle = "Ok",
      this.cancelBtnTap,
      this.okBtnTap,
      });

  @override
  _ImportClassDialogContentState createState() =>
      _ImportClassDialogContentState();
}

class _ImportClassDialogContentState extends State<ImportClassDialogContent> {

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 300,
        decoration: BoxDecoration(
          // color: const Color(0xff88c3ff),
            borderRadius: BorderRadius.circular(40),
          image: DecorationImage(
            image: AssetImage("images/import_class_bg.png"),
            fit: BoxFit.fill
          )
        ),
        child: Column(
          children: [
            Spacer(),
            Text(
              widget.title,
              style: TextStyle(
                  fontSize: 20,
              ),
            ),
            Spacer(),
            Container(
              color: Colors.blue,
              height: borderWidth,
            ),
            TextButton(
                onPressed: () async{
                  final ImagePicker _picker = ImagePicker();
                  final XFile image = await _picker.pickImage(source: ImageSource.gallery);
                  if(image==null){
                    Fluttertoast.showToast(
                        msg: "请选择一张照片",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                  }
                  else
                  Navigator.of(context).push(new CupertinoPageRoute(builder: (ctx) {
                    return ProviderConfig.getInstance().getImageCropperPage(image);
                  })).then((v){
                    Navigator.of(context).pop();
                  });
                },
                child: Text(
                  "图片导入",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                )),
            Divider(),
            TextButton(onPressed: () {}, child: Text("Excel表格导入",style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),)), Divider(),
            TextButton(onPressed: () {}, child: Text("教务系统导入",style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),)), Divider(),
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Image.asset("images/cancel.png",width: 30,)
              // Text(
              //   widget.cancelBtnTitle,
              //   style: TextStyle(fontSize: 18, color: Colors.blue),
              // ),
            ),
          ],
        ));
  }
}

class ImportClassDialog extends AlertDialog {
  ImportClassDialog({Widget contentWidget})
      : super(
          content: contentWidget,
          contentPadding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
              ),
        );
}
