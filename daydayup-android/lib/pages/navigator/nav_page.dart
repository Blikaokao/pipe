import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/config/all_types.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/custom_image_cache_manager.dart';
import 'package:todo_list/config/floating_border.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:todo_list/pages/main/month_calendar_page.dart';
import 'package:todo_list/pages/navigator/language_page.dart';
import 'package:todo_list/pages/navigator/settings/setting_page.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/widgets/custom_cache_image.dart';
import 'package:todo_list/widgets/nav_head.dart';
import 'package:todo_list/widgets/weather_widget.dart';

import '../main/background/image_page.dart';

class NavPage extends StatelessWidget {
  List<num> eventStatusList;
  List<num> taskTypeList;
  List<num> taskNumList;
  CancelToken cancelToken = CancelToken();
  GlobalModel globalModel;
  LinkedHashMap<DateTime, List<TaskBean>> kEvents;
  NavPage({this.kEvents});
  @override
  Widget build(BuildContext context) {
    globalModel = Provider.of<GlobalModel>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.lerp(Colors.white, Colors.blue, 0.8),
        title: Text(
          "个人",
          style: TextStyle(color: Colors.black),
        ),
        // backgroundColor: Colors.transparent,
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Image.asset("images/home.png"),
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
              new MaterialPageRoute(builder: (context) {
            return ProviderConfig.getInstance().getMainPage();
          }), (router) => router == null);
        },
      ),
      bottomNavigationBar: BottomAppBar(
          color: const Color(0xff5B90E7),
          shape: CustomNotchedShape(context),
          child: Row(
            children: [
              IconButton(
                  icon: Image.asset(
                    "images/month_calendar.png",
                    width: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return MonthCalendarPage(
                          globalModel.mainPageModel.kEvents == null
                              ? kEvents
                              : globalModel.mainPageModel.kEvents);
                    }));
                  }),
              SizedBox(),
              IconButton(
                icon: Image.asset(
                  "images/my_set.png",
                  width: 30,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          )),
      body: ListView(
        padding: EdgeInsets.only(top: 20, left: 10, right: 10),
        children: <Widget>[
          // getNavHeader(globalModel, context),

          Container(
              height: 130,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: Offset.fromDirection(20, 0),
                      blurRadius: 20, //阴影范围
                      spreadRadius: 1, //阴影浓度
                      color: Colors.grey, //阴影颜色
                    ),
                  ],
                  gradient: LinearGradient(
                    //渐变位置
                    begin: Alignment.topCenter, //右上
                    end: Alignment.bottomCenter, //左下
                    //渐变颜色[始点颜色, 结束颜色]
                    colors: [
                      const Color(0xffA5E3FF),
                      const Color(0xffB2D6FC),
                      const Color(0xffA4C8FD)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30) // 边色与边宽度
                  ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    "images/avatar.png",
                    height: 120,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, top: 19),
                    width: 200,
                    height: 130,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  globalModel.allName[0].length > 10
                                      ? globalModel.allName[0].substring(0, 10)
                                      : globalModel.allName[0],
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    height: 0,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ],
                            )),
                        Expanded(
                          child: TextButton(
                              onPressed: () {
                                final TextEditingController controller =
                                    TextEditingController();
                                controller.text = globalModel.allName[0];
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text('用户名称修改'),
                                          content: TextField(
                                            style: TextStyle(
                                                color: Colors.black87),
                                            controller: controller,
                                            decoration: InputDecoration(
                                                hintText: "新的用户名",
                                                hintStyle:
                                                    TextStyle(fontSize: 15),
                                                prefixIcon:
                                                    Icon(Icons.person_rounded),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                ),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                )),
                                          ),
                                          actions: [
                                            OutlinedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('取消')),
                                            ElevatedButton(
                                                onPressed: () {
                                                  // ApiService.instance.postResetName(
                                                  //   params: {
                                                  //     "id": globalModel.userId,
                                                  //     "name": controller.text,
                                                  //     "type": 0,
                                                  //   },
                                                  //   success: (CommonBean bean) {
                                                  //     _model.loadingController.setFlag(LoadingFlag.success);
                                                  //   },
                                                  //   failed: (CommonBean bean) {
                                                  //     _model.loadingController.setFlag(LoadingFlag.error);
                                                  //   },
                                                  //   error: (msg) {
                                                  //     _model.loadingController.setFlag(LoadingFlag.error);
                                                  //   },
                                                  //   token: _model.cancelToken,
                                                  // );
                                                },
                                                child: Text('确定')),
                                          ],
                                        ));
                              },
                              child: Text(
                                "完善用户信息",
                                style: TextStyle(
                                  height: 0,
                                  color: const Color(0xff848484),
                                ),
                              )),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.orangeAccent,
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(18.0),
                              // ),
                              side: BorderSide(
                                  width: 2, color: Colors.yellowAccent),
                            ),
                            onPressed: () {},
                            child: Text(
                              "成就",
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )),

          Container(
            margin: EdgeInsets.only(top: 20),
            // padding: EdgeInsets.only(top: 10),
            height: 140,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.circular(30), // 边色与边宽度
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: Image.asset(
                    "images/synchronization.png",
                    width: 200,
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      width: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "跨平台与多设备功能",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "支持Android、Windows、Mac、oppo手表、oppo平板电脑等平台",
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xff848484),
                            ),
                            maxLines: 3,
                          )
                        ],
                      ),
                    )),
              ],
            ),
          ),

          globalModel.enableWeatherShow
              ? WeatherWidget(
                  globalModel: globalModel,
                )
              : SizedBox(),

          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffB7B7B7),
                    offset: Offset(6.0, 0.0), //阴影x轴偏移量
                    blurRadius: 10, //阴影模糊程度
                  )
                ]),
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(top: 10),
            child: ListTile(
              title: Text(IntlLocalizations.of(context).myAccount),
              leading: Icon(Icons.account_circle),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () async {
                final account =
                    await SharedUtil.instance.getString(Keys.account);
                if (account == "default" || account == null) {
                  Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
                    return ProviderConfig.getInstance().getLoginPage();
                  }));
                } else {
                  Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
                    return ProviderConfig.getInstance().getAccountPage();
                  }));
                }
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffB7B7B7),
                    offset: Offset(6.0, 0.0), //阴影x轴偏移量
                    blurRadius: 10, //阴影模糊程度
                  )
                ]),
            padding: EdgeInsets.only(top: 10),
            child: ListTile(
              title: Text("数据统计"
                  // IntlLocalizations.of(context).dataAnalysis
                  ),
              leading: Icon(Icons.data_saver_off),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
                  return ProviderConfig.getInstance().getDataAnalysisPage();
                }));
              },
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffB7B7B7),
                    offset: Offset(6.0, 0.0), //阴影x轴偏移量
                    blurRadius: 10, //阴影模糊程度
                  )
                ]),
            padding: EdgeInsets.only(top: 10),
            child: ListTile(
              title: Text(IntlLocalizations.of(context).doneList),
              leading: Icon(Icons.done_all),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
                  return ProviderConfig.getInstance().getDoneTaskPage();
                }));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffB7B7B7),
                    offset: Offset(6.0, 0.0), //阴影x轴偏移量
                    blurRadius: 10, //阴影模糊程度
                  )
                ]),
            padding: EdgeInsets.only(top: 10),
            child: ListTile(
              title: Text(IntlLocalizations.of(context).languageTitle),
              leading: Icon(Icons.language),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
                  return LanguagePage();
                }));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffB7B7B7),
                    offset: Offset(6.0, 0.0), //阴影x轴偏移量
                    blurRadius: 10, //阴影模糊程度
                  )
                ]),
            padding: EdgeInsets.only(top: 10),
            child: ListTile(
              title: Text(IntlLocalizations.of(context).changeTheme),
              leading: Icon(Icons.color_lens),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
                  return ProviderConfig.getInstance().getThemePage();
                }));
              },
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffB7B7B7),
                    offset: Offset(6.0, 0.0), //阴影x轴偏移量
                    blurRadius: 10, //阴影模糊程度
                  )
                ]),
            padding: EdgeInsets.only(top: 10),
            child: ListTile(
              title: Text(IntlLocalizations.of(context).feedbackWall),
              leading: Icon(Icons.subtitles),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
                  return ProviderConfig.getInstance().getFeedbackWallPage();
                }));
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffB7B7B7),
                    offset: Offset(6.0, 0.0), //阴影x轴偏移量
                    blurRadius: 10, //阴影模糊程度
                  )
                ]),
            padding: EdgeInsets.only(top: 10),
            child: ListTile(
              title: Text(IntlLocalizations.of(context).appSetting),
              leading: Icon(Icons.settings),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                Navigator.push(context, CupertinoPageRoute(builder: (ctx) {
                  return SettingPage();
                }));
              },
            ),
          )
        ],
      ),
    );
  }

  Widget getNavHeader(GlobalModel model, context) {
    final size = MediaQuery.of(context).size;
    final netImageHeight = max(size.width, size.height) / 4;
    if (model.currentNavHeader == NavHeadType.meteorShower) {
      return NavHead();
    } else {
      final url = model.currentNetPicUrl;
      bool isDailyPic = model.currentNavHeader == NavHeadType.dailyPic;
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(CupertinoPageRoute(builder: (ctx) {
            return ImagePage(
              imageUrls: [isDailyPic ? NavHeadType.DAILY_PIC_URL : url],
            );
          }));
        },
        child: Hero(
            tag: "tag_0",
            child: Container(
                height: netImageHeight,
                child: CustomCacheImage(
                  url: isDailyPic ? NavHeadType.DAILY_PIC_URL : url,
                  cacheManager: isDailyPic ? CustomCacheManager() : null,
                ))),
      );
    }
  }

  _getData() {
    int id = globalModel.userId;
    ApiService.instance.getAllStatus(
      params: {'id': id},
      success: (StatusBean statusBean) {
        eventStatusList = statusBean.eventStatus;
      },
      token: cancelToken,
    );

    ApiService.instance.getAllType(
      params: {
        'id': id,
      },
      success: (TaskTypeBean bean) {
        taskTypeList = bean.taskTypeList;
      },
    );
    ApiService.instance.getTasksCount(
        params: globalModel.allId,
        success: (TaskNumBean bean) {
          taskNumList = bean.taskNumList;
        });
  }
}
