import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/api_strategy.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:image_crop/image_crop.dart';
import 'package:todo_list/model/image_cropper_page_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';
import 'package:todo_list/widgets/photo_result.dart';

class ImageCropperPageLogic {
  final ImageCropperPageModel _model;
  ImageCropperPageLogic(this._model);

  void saveAndGetAvatarFile(XFile file) async {
    _model.currentAvatarType = CurrentAvatarType.local;
    _model.currentAvatarUrl = file.path;
    _model.refresh();
  }

  void onSaveTap() async {
    final croppedFile = await ImageCrop.cropImage(
      file: File(_model.currentAvatarUrl),
      area: _model.cropKey.currentState.area,
    );
    List<int> fileBytes = await croppedFile.readAsBytes();
    String photo = base64Encode(fileBytes);
    if(isAddClass()){
      uploadClassTable(photo);

    }else{
      uploadPhoto(photo,croppedFile.path);
    }
    // String param = Uri.encodeQueryComponent(photo);

  }

  bool isAddClass(){
    return _model.model==null;
  }


  //上传图片请求
  void uploadClassTable(String photo) async{
    final context = _model.context;
    _showLoadingDialog(context);
    Map<String,dynamic> params = {
      "img": photo,
    };
    CancelToken cancelToken = CancelToken();

    ApiService.instance.getClassTable(
      success: (ClassBean bean) {
        Navigator.of(_model.context).pushAndRemoveUntil(
            new MaterialPageRoute(builder: (context) {
              return ProviderConfig.getInstance().getAddClassPage(true,classBean:bean);
            }), (router) => router == null);

      },
      failed: (ClassBean bean) {
        // Navigator.of(_model.context).pop();
        // if (bean.description.contains("任务不存在")) {
        //   _deleteDataBaseTask(taskBean);
        // } else {
        //   _showTextDialog(bean.description);
        // }
      },
      error: (msg) {
        // Navigator.of(_model.context).pop();
        // _showTextDialog(msg);
      },
      params: params,
      token: cancelToken,
    );

  }

  //上传图片请求
  void uploadPhoto(String photo,String filePath) async{
    final context = _model.context;
    _showLoadingDialog(context);
    Map<String,dynamic> params = {
      "img": photo,
    };
    CancelToken cancelToken = CancelToken();

    ApiService.instance.postByPhoto(
      success: (EventBean bean) {
        List<Event> events = bean.events;
        _model.model.eventsNum = events.length;
        _model.model.flag = List.generate( _model.model.eventsNum, (index) => true);
        _model.model.tasks = List.generate( _model.model.eventsNum, (index) => TaskBean());
        if(events.length>0){
          _model.model.startDates.clear();
          _model.model.deadLines.clear();
          _model.model.currentTaskNames.clear();
        }
        for(int i=0;i<events.length;i++){
          Event event = events[i];
          event.startDate!=""?  _model.model.startDates.add(DateTime.parse(event.startDate)): _model.model.startDates.add(null);
          event.deadLine!=""?  _model.model.deadLines.add(DateTime.parse(event.deadLine)): _model.model.deadLines.add(null);
          event.taskName!=""?  _model.model.currentTaskNames.add(event.taskName): _model.model.currentTaskNames.add("");
        }
        _model.model.refresh();
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(
                builder: (context){
                  return PhotoResult(filePath, _model.model);
                }),
                (router) => router == null);
        // showModalBottomSheet(
        //     backgroundColor: Colors.transparent,
        //     context: context,
        //     builder:(_)=>PhotoResult(filePath,_model.model)
        // ).then((v){
        //   Navigator.of(context).pop();
        // });
        // Event event  = bean.event;
        // if (event.startDate!= "") {
        //   model.startDate = DateTime.parse(event.startDate);
        // }
        // if (event.deadLine!= "") {
        //   model.deadLine = DateTime.parse(event.deadLine);
        // }
        // if (event.taskName != "") {
        //   model.currentTaskName =event.taskName;
        // }
        // model.refresh();
        // _text = res["result"];
      },
      failed: (EventBean bean) {
        // Navigator.of(_model.context).pop();
        // if (bean.description.contains("任务不存在")) {
        //   _deleteDataBaseTask(taskBean);
        // } else {
        //   _showTextDialog(bean.description);
        // }
      },
      error: (msg) {
        // Navigator.of(_model.context).pop();
        // _showTextDialog(msg);
      },
      params: params,
      token: cancelToken,
    );

  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx){
      return NetLoadingWidget();
    });
  }

  void _showTextDialog(String text){
    final context = _model.context;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(20.0))),
            content: Text(
                text),
          );
        });
  }

  ImageProvider getAvatarProvider() {
    final avatarType = _model.currentAvatarType;
    final url = _model.currentAvatarUrl;
    switch (avatarType) {
      case CurrentAvatarType.defaultAvatar:
        return AssetImage("images/icon.png");
        break;
      case CurrentAvatarType.local:
        File file = File(url);
        if (file.existsSync()) {
          return FileImage(file);
        } else {
          return AssetImage("images/icon.png");
        }
        break;
      case CurrentAvatarType.net:
        return NetworkImage(url);
        break;
    }
    return AssetImage("images/icon.png");
  }
}
