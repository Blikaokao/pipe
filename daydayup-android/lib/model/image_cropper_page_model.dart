import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/logic/image_cropper_logic.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/model/main_page_model.dart';
import 'package:image_picker/image_picker.dart';

class ImageCropperPageModel extends ChangeNotifier{

  ImageCropperPageLogic logic;
  EditTaskPageModel model;
  BuildContext context;
  CancelToken cancelToken = CancelToken();

  //当前头像的类型
  int currentAvatarType = CurrentAvatarType.local;
  //当前的头像url,比如本地的就是本地路径，网络就是网络地址
  String currentAvatarUrl;

  final cropKey = GlobalKey<CropState>();

  ImageCropperPageModel(XFile file,this.model){
    logic = ImageCropperPageLogic(this);
    logic.saveAndGetAvatarFile(file);
  }


  void setContext(BuildContext context){
    if(this.context == null){
      this.context = context;
    }
  }

  @override
  void dispose(){
    cropKey?.currentState?.dispose();
    cancelToken?.cancel();
    super.dispose();
    debugPrint("AvatarPageModel销毁了");
  }

  void refresh(){
    notifyListeners();
  }

}
