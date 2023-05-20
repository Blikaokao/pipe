import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/json/task_icon_bean.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:circle_list/circle_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_list/pages/navigator/settings/setting_page.dart';
import 'package:todo_list/widgets/import_class_dialog.dart';
import 'package:todo_list/widgets/photo_input.dart';
import 'package:todo_list/widgets/speech_input.dart';
import 'package:todo_list/widgets/text_input_widget.dart';
class BottomShowWidget extends StatefulWidget {
  //弹窗组件
  final VoidCallback onExit;
  final List<TaskIconBean> taskIconBeans;

  BottomShowWidget({this.onExit, this.taskIconBeans});

  @override
  _BottomShowWidgetState createState() => _BottomShowWidgetState();
}

class _BottomShowWidgetState extends State<BottomShowWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  List<String> _children;
  List<String> _childrenName;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = new Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
    _controller.forward();
    _children = [
      "images/import.png",
      "images/import.png",
      "images/import.png",
      "images/text.png",
      "images/voice.png",
      "images/picture.png",
    ];
    _childrenName = [
      "导入",
      "导入",
      "导入",
      "文本",
      "语音",
      "图片",
    ];
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    debugPrint("BottomShowWidget销毁");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final minSize = min(size.height, size.width);
    final circleSize = minSize;
    final Offset circleOrigin = Offset((size.width - circleSize) / 2, 0);
    final globalModel = Provider.of<GlobalModel>(context);

    return WillPopScope(
      onWillPop: () {
        doExit(context, _controller);
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          doExit(context, _controller);
        },
        child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0),
          body: Container(
            width: size.width,
            height: size.height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: 20,
                  left: size.width / 2 - 28,
                  child: AnimatedBuilder(
                      animation: _animation,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.2),
                            shape: BoxShape.circle),
                      ),
                      builder: (ctx, child) {
                        return Transform.scale(
                          scale: (max(size.height, size.width) / 28) *
                              (_animation.value),
                          child: child,
                        );
                      }),
                ),
                Positioned(
                  left: circleOrigin.dx,
                  top: circleOrigin.dy,
                  child: AnimatedBuilder(
                    animation: _animation,
                    child: CircleList(
                      rotateMode: RotateMode.stopRotate,
                      origin: Offset(0, -min(size.height, size.width) / 2 + 20),
                      showInitialAnimation: true,
                      children: List.generate(_children.length, (index) {
                        return IconButton(
                          onPressed: () {
                            // doExit(context, _controller);
                            if (index == 4) {
                              //语音录入
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_) => SpeechInput()).then((v) {
                                doExit(context, _controller);
                              });
                            } //图片输入
                            else if (index == 5) {
                              //
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_) =>PhotoInput()
                              ).then((v) {
                                doExit(context, _controller);
                              });
                            }//文本输入
                            else if (index == 3) {
                              //
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_) =>TextInputWidget()).then((v) {
                                doExit(context, _controller);
                              });
                            } else if (index == 0) {
                              //
                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (_)=>
                                     Container(
                                        height: 250,
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
                                              child: Text("导入课表",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20
                                                  )),
                                              onPressed: () {
                                                //导入课表
                                                showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return ImportClassDialog(
                                                        contentWidget: ImportClassDialogContent(
                                                          cancelBtnTitle: "取消",
                                                          okBtnTitle: "确定",
                                                          title: "导入课表",
                                                          okBtnTap: () {

                                                          },
                                                          cancelBtnTap: () {},
                                                        ),
                                                      );
                                                    }).then((v) {
                                                     Navigator.of(context).pop();
                                                });
                                              },),
                                            Divider(),
                                            TextButton(
                                              child: Text("导入钉钉日程",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20
                                                  )),
                                              onPressed: (){},
                                            ),
                                            Divider(),
                                            TextButton(
                                              child: Text("导入腾讯会议",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20
                                                  )),
                                              onPressed: (){},
                                            ),
                                            Divider(),
                                            TextButton(
                                              child: Text("导入本地日历",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20
                                                  )),
                                              onPressed: (){},
                                            ),
                                          ],
                                        ))
                              ).then((v) {
                                doExit(context, _controller);
                              });
                            }
                            // Navigator.of(context).push(
                            //   new CupertinoPageRoute(
                            //     builder: (ctx) {
                            //       return ProviderConfig.getInstance()
                            //           .getEditTaskPage(
                            //         _children[index],
                            //       );
                            //     },
                            //   ),
                            // );
                          },
                          // tooltip: _children[index].taskName,
                          icon:
                          Container(

                            child: Column(
                              children: [
                                Image.asset(
                                  _children[index],
                                ),
                                // Text(
                                //   _childrenName[index],
                                //   style: TextStyle(
                                //     color:const Color(0xff3464B1),
                                //     // fontSize: 15
                                //     // fontSize:,
                                //   ),
                                // ),
                              ],
                            ),
                          )
                        );
                      }),
                      // innerCircleColor: Theme.of(context).primaryColorLight,
                      innerCircleColor:const Color(0xff3464B1),
                      outerCircleColor: globalModel.logic.getBgInDark(),
                      innerCircleRotateWithChildren: false,
                      centerWidget: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (ctx) {
                                  return buildSettingListView(
                                      context, globalModel);
                                }).then((v) {
                              doExit(context, _controller);
                            });
                            debugPrint("点击");
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            height: MediaQuery.of(context).size.width / 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFECF3FA),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 40,
                              color: Colors.transparent,
                              child: Center(
                                child: Image.asset(
                                  "images/logo.png",
                                  width: 60,
                                  height: 60,
                                ),
                              )
                              // Icon(
                              //   Image.asset("images/logo.png"),
                              //   color: Colors.white,
                              //   size: 40,
                              // ),
                            ),
                          )),
                    ),
                    builder: (ctx, child) {
                      return Transform.translate(
                          offset: Offset(
                              0,
                              MediaQuery.of(context).size.height -
                                  (_animation.value) * circleSize),
                          child: Transform.scale(
                              scale: _animation.value, child: child));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future doExit(BuildContext context, AnimationController controller) async {
    widget?.onExit();
    await controller.reverse();
    Navigator.of(context).pop();
  }
}
