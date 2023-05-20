import 'package:flutter/material.dart';
import 'package:image_crop/image_crop.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/model/image_cropper_page_model.dart';

class ImageCropperWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ImageCropperPageModel>(context);
    model.setContext(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("图片裁剪"),
        actions: [
          IconButton(onPressed: model.logic.onSaveTap, icon: Icon(Icons.done))
        ],
      ),
      body: Stack(
        children: <Widget>[
          Hero(
            tag: "avatar",
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(20),
                child: Crop(
                  key: model.cropKey,
                  image: model.logic.getAvatarProvider(),
                  maximumScale: 1.0,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
