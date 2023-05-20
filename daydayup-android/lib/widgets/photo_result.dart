import 'package:flutter/material.dart';
import 'package:todo_list/config/provider_config.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';
import 'package:todo_list/model/all_model.dart';

class PhotoResult extends StatelessWidget {
  final _imgPath;
  EditTaskPageModel model;
  PhotoResult(this._imgPath, this.model);

  @override
  Widget build(BuildContext context) {
    model.taskType = "2";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff5B90E7),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    new MaterialPageRoute(builder: (context) {
                  return ProviderConfig.getInstance().getMainPage();
                }), (router) => router == null);
              },
              child: Text(
                "取消",
                style: TextStyle(color: Colors.white),
              ))
        ],
        title: Text("日程添加"),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 300,
              child: ClipRect(
                child: PhotoView(
                  backgroundDecoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  imageProvider: _imgPath != null
                      ? (Image.file(File(_imgPath))).image
                      : Icon(Icons.add),
                ),
              ),
            ),
            Expanded(
                child:
            SingleChildScrollView(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ProviderConfig.getInstance().getAddTaskWidget(model))),
          ],
        ),
        // )
      ),
    );
  }
}
