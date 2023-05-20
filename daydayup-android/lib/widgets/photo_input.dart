import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/model/edit_task_page_model.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
class PhotoInput extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();
  var imagePath;
  EditTaskPageModel model = EditTaskPageModel();

  @override
  Widget build(BuildContext context) {
    final globalModel = Provider.of<GlobalModel>(context);
    model.setGlobalModel(globalModel);
    final mainPageModel = globalModel.mainPageModel;
    model.setMainPageModel(mainPageModel);
    return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            TextButton(
              child: Text("相机",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25)),
              onPressed: ()async{
                final XFile image = await _picker.pickImage(source: ImageSource.camera);
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
                }else
                //裁剪图片
                Navigator.of(context).push(new CupertinoPageRoute(builder: (ctx) {
                  return ProviderConfig.getInstance().getImageCropperPage(image,model: model);
                })).then((v){
                  Navigator.of(model.context).pop();
                });
              },
            ),
            Divider(),
            TextButton(
              child: Text("相册",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 25)),
              onPressed: ()async{
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
                //裁剪图片
               else Navigator.of(context).push(new CupertinoPageRoute(builder: (ctx) {
                  return ProviderConfig.getInstance().getImageCropperPage(image,model: model);
                })).then((v){
                  Navigator.of(model.context).pop();
                });

              },
            ),
          ],
        ));
  }




}
