import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info/package_info.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/api_strategy.dart';
import 'package:todo_list/config/local_calender_service.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/database/database.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/items/new_task_item.dart';
import 'package:todo_list/json/common_bean.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/json/update_info_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/date_picker_util.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/utils/theme_util.dart';
import 'package:todo_list/widgets/edit_dialog.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';
import 'package:todo_list/widgets/update_dialog.dart';

class MainPageLogic {
  final MainPageModel _model;

  CancelToken cancelToken = CancelToken();
  List<Color> taskItemColor = [
    const Color(0XFFACC8E8),
    const Color(0XFFE8CBCE),
    const Color(0XFFF3D074),
    const Color(0XFF96C58E),
  ];

  MainPageLogic(this._model);

  ///获得任务卡片列表
  List<Widget> getCards(context, List<TaskBean> selectedEvents) {
    if (selectedEvents.isNotEmpty)
      return List.generate(selectedEvents.length, (index) {
        Color taskcolor = taskItemColor[index % taskItemColor.length];
        final taskBean = selectedEvents[index];

        return GestureDetector(
          child: TaskItem(taskcolor, taskBean.id, taskBean,
              // onEdit: () => _model.logic.editTask(taskBean),//编辑
              onDelete: () => //删除
                  showDialog(
                      context: _model.context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text(
                              "${IntlLocalizations.of(_model.context).doDelete}${taskBean.taskName}"),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _model.logic.deleteTask(taskBean);
                                  selectedEvents.remove(taskBean);
                                },
                                child: Text(
                                  IntlLocalizations.of(_model.context).delete,
                                  style: TextStyle(color: Colors.redAccent),
                                )),
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  IntlLocalizations.of(_model.context).cancel,
                                  style: TextStyle(color: Colors.green),
                                )),
                          ],
                        );
                      })),
          //进入详情页
          onTap: () {
            _model.currentTapIndex = index;
            Future.delayed(Duration(milliseconds: 400), () {
              _model.canHideWidget = true;
              _model.refresh();
            });
            Navigator.of(context).push(new PageRouteBuilder(
                pageBuilder: (ctx, anm, anmS) {
                  return ProviderConfig.getInstance()
                      .getTaskDetailPage(taskBean.id, taskBean);
                },
                opaque: !_model.enableTaskPageOpacity,
                transitionDuration: Duration(milliseconds: 800)));
          },
        );
      });
    return [getEmptyWidget(_model.globalModel)];
  }

  ///获得图标+文字
  Widget getIconText({Icon icon, String text, VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.grey.withOpacity(0.2)),
        child: Row(
          children: <Widget>[
            icon,
            SizedBox(
              width: 4,
            ),
            Text(text),
          ],
        ),
      ),
    );
  }

  ///获取任务Map{date[task1,task2……],}
  Future getTasks() async {
    // final tasks = await DBProvider.db.getTasks();
    // if (tasks == null) return;
    // if(synFlag == SynFlag.failSynced) return;
    int id = _model.globalModel.currentId;
    if (id == null) {
      id = _model.globalModel.allId[0];
    }

    ApiService.instance.getTasks(
      params: {
        'id': id.toString(),
      },
      success: (CloudTaskBean bean) async {
        final tasks = bean.taskList;
        _model.tasks.clear();
        _model.tasks.addAll(tasks);

        final _kEventSource = Map<DateTime, List<TaskBean>>();
        DateTime dateTime;
        for (TaskBean event in _model.tasks) {
          dateTime = DateTime.parse(event.startDate);
          dateTime = DateTime.utc(dateTime.year, dateTime.month, dateTime.day);

          if (_kEventSource.containsKey(dateTime)) {
            //存在
            _kEventSource[dateTime].add(event);
            _kEventSource[dateTime]
                .sort((a, b) => a.startDate.compareTo(b.startDate));
          }
          //不存在，插入新元素
          else
            _kEventSource.putIfAbsent(dateTime, () => [event]);
        }
        _model.kEvents = LinkedHashMap<DateTime, List<TaskBean>>(
          equals: isSameDay,
          hashCode: getHashCode,
        )..addAll(_kEventSource);

        // List<TaskBean> needUpdateTasks = [];
        // List<TaskBean> needCreateTasks = [];
        // for (var task in tasks) {
        //   final uniqueId = task.uniqueId;
        //   final localTask = await DBProvider.db.getTaskByUniqueId(uniqueId);
        //   ///如果本地没有查到这个task，就需要在本地重新创建
        //   if(localTask == null){
        //     needCreateTasks.add(task);
        //   } else {
        //     task.id = localTask[0].id;
        //     // task.backgroundUrl = localTask[0].backgroundUrl;
        //     // task.textColor = localTask[0].textColor;
        //     needUpdateTasks.add(task);
        //   }
        // }
        // await DBProvider.db.updateTasks(needUpdateTasks);
        // await DBProvider.db.createTasks(needCreateTasks);
        // widget.mainPageModel.logic.getTasks().then((v){
        //   // widget.mainPageModel.needSyn = false;
        //   widget.mainPageModel.refresh();
        // });
        // setState(() {
        //   synFlag = SynFlag.noNeedSynced;
        // });noNeedSynced
        _model.refresh();
      },
      failed: (CloudTaskBean bean) {
        // setState(() {
        //
        // });
      },
      error: (msg) {
        // setState(() {
        //   synFlag = SynFlag.failSynced;
        // });
      },
      token: cancelToken,
    );

    //
    // _model.tasks.clear();
    // _model.tasks.addAll(tasks);
  }

  // ///修改内存中的任务
  //  getEvents(){
  //   final _kEventSource = Map<DateTime, List<TaskBean>> ();
  //   for(TaskBean event in _model.tasks){
  //       _kEventSource[event.createDate].add(event);
  //   }
  //   _model.kEvents = LinkedHashMap<DateTime, List<TaskBean>>(
  //     equals: isSameDay,
  //     hashCode: getHashCode,
  //   )..addAll(_kEventSource);
  // }

  ///获得当前用户的用户名
  Future getCurrentUserName() async {
    final currentUserName =
        await SharedUtil.instance.getString(Keys.currentUserName);
    if (currentUserName == null) return;
    if (currentUserName == _model.currentUserName) return;
    _model.currentUserName = currentUserName;
  }

  // Future getCurrentTransparency() async{
  //   final transparency = await SharedUtil.instance.getDouble(Keys.currentTransparency);
  //   if (transparency == null) return;
  //   if (transparency == _model.currentTransparency) return;
  //   _model.currentTransparency = transparency;
  // }
  //
  // Future getEnableCardPageOpacity() async{
  //   final enable = await SharedUtil.instance.getBoolean(Keys.enableCardPageOpacity);
  //   if (enable == null) return;
  //   _model.enableTaskPageOpacity = enable;
  // }

  ///获取主页背景
  Decoration getBackground(GlobalModel globalModel) {
    bool isBgGradient = globalModel.isBgGradient;
    bool isBgChangeWithCard = globalModel.isBgChangeWithCard;
    bool enableBg = globalModel.enableNetPicBgInMainPage;
    final bgUrl = globalModel.currentMainPageBgUrl;

    return enableBg
        ? BoxDecoration(
            image: DecorationImage(
            image: bgUrl.startsWith('http')
                ? CachedNetworkImageProvider(bgUrl)
                : FileImage(File(bgUrl)),
            fit: BoxFit.cover,
          ))
        : BoxDecoration(
            gradient: isBgGradient
                ? LinearGradient(
                    colors: _getGradientColors(isBgChangeWithCard),
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)
                : null,
            color: _getBgColor(isBgGradient, isBgChangeWithCard),
          );
  }

  List<Color> _getGradientColors(bool isBgChangeWithCard) {
    final context = _model.context;
    if (!isBgChangeWithCard) {
      return [
        Theme.of(context).primaryColorLight,
        Theme.of(context).primaryColor,
        Theme.of(context).primaryColorDark,
      ];
    } else {
      return [
        ThemeUtil.getInstance().getLightColor(getCurrentCardColor()),
        getCurrentCardColor(),
        ThemeUtil.getInstance().getDarkColor(getCurrentCardColor()),
      ];
    }
  }

  Color _getBgColor(bool isBgGradient, bool isBgChangeWithCard) {
    if (isBgGradient) {
      return null;
    }
    final context = _model.context;
    final primaryColor = Theme.of(context).primaryColor;
    return isBgChangeWithCard ? getCurrentCardColor() : primaryColor;
  }

  Color getCurrentCardColor() {
    final context = _model.context;
    final primaryColor = Theme.of(context).primaryColor;
    int index = _model.currentCardIndex;
    int taskLength = _model.tasks.length;
    if (taskLength == 0) return primaryColor;
    if (index > taskLength - 1) return primaryColor;
    return Theme.of(context).primaryColor;
    // return ColorBean.fromBean(_model.tasks[index].taskIconBean.colorBean);
  }

  ///删除任务的弹框
  void deleteTask(TaskBean taskBean) async {
    // final account =
    //     await SharedUtil.instance.getString(Keys.account) ?? 'default';
    // if (account == "defalut") {
    //   _deleteDataBaseTask(taskBean);
    // } else {
    //   if (taskBean.uniqueId == null) {
    //     _deleteDataBaseTask(taskBean);
    //   } else
    //     {
    // final token = await SharedUtil.instance.getString(Keys.token);
    showDialog(
        context: _model.context,
        builder: (ctx) {
          return NetLoadingWidget();
        });

    ApiService.instance.postDeleteTask(
      success: (CommonBean bean) {
        if (taskBean.eventId != -1) {
          LocalCalenderService.instance.del(taskBean.eventId);
        }
        Navigator.of(_model.context).pop();
        _model.logic.getTasks();
        // _deleteDataBaseTask(taskBean);
      },
      failed: (CommonBean bean) {
        Navigator.of(_model.context).pop();
        // if (bean.description.contains("任务不存在")) {
        //   _deleteDataBaseTask(taskBean);
        // } else {
        //   _showTextDialog(bean.description);
        // }
      },
      error: (msg) {
        Navigator.of(_model.context).pop();
        _showTextDialog(msg);
      },
      params: {
        // "token": token,
        // "account": account,
        // "uniqueId": taskBean.uniqueId,
        "id": taskBean.id.toString()
      },
      token: _model.cancelToken,
    );
    // }
    // }
  }

  ///从数据库删除
  void _deleteDataBaseTask(TaskBean taskBean) {
    DBProvider.db.deleteTask(taskBean.id).then((a) {
      getTasks().then((value) {
        _model.refresh();
      });
    });
  }

  ///编辑任务
  // void editTask(TaskBean taskBean) {
  //   Navigator.of(_model.context).push(
  //     new CupertinoPageRoute(
  //       builder: (ctx) {
  //         return ProviderConfig.getInstance()
  //             .getEditTaskPage(taskBean.taskIconBean, taskBean: taskBean);
  //       },
  //     ),
  //   );
  // }

  ///当任务列表为空时显示的内容
  Widget getEmptyWidget(GlobalModel globalModel) {
    final context = _model.context;
    final size = MediaQuery.of(context).size;
    final theMin = min(size.width, size.height) / 2;
    return Container(
      margin: EdgeInsets.only(top: 40),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        "svgs/empty_list.svg",
        // color: globalModel.logic.getWhiteInDark(),
        color: Colors.blue,
        width: theMin,
        height: theMin,
        semanticsLabel: 'empty list',
      ),
    );
  }

  // ///无论是网络头像还是asset头像，最后将转换为本地文件头像
  // Future getCurrentAvatar() async {
  //   switch (_model.currentAvatarType) {
  //
  //     ///头像为默认头像的时候，将asset转换为file，方便imageCrop与之后的suggestion直接用到file
  //     case CurrentAvatarType.defaultAvatar:
  //       final path = await FileUtil.getInstance()
  //           .copyAssetToFile("images/", "icon.png", "/avatar/", "icon.png");
  //       _model.currentAvatarUrl = path;
  //       _model.currentAvatarType = CurrentAvatarType.local;
  //       SharedUtil().saveString(Keys.localAvatarPath, path);
  //       SharedUtil().saveInt(Keys.currentAvatarType, CurrentAvatarType.local);
  //       break;
  //     case CurrentAvatarType.local:
  //       final path = await SharedUtil().getString(Keys.localAvatarPath) ?? "";
  //       File file = File(path);
  //       if (file.existsSync()) {
  //         _model.currentAvatarUrl = file.path;
  //       } else {
  //         final avatarPath = await FileUtil.getInstance()
  //             .copyAssetToFile("images/", "icon.png", "/avatar/", "icon.png");
  //         SharedUtil().saveString(Keys.localAvatarPath, avatarPath);
  //         _model.currentAvatarUrl = avatarPath;
  //       }
  //       break;
  //     case CurrentAvatarType.net:
  //       final net = await SharedUtil().getString(Keys.netAvatarPath);
  //       FileUtil.getInstance().downloadFile(
  //         url: net,
  //         filePath: "/avatar/",
  //         fileName: net.split('/').last ?? "avatar.png",
  //         onComplete: (path) {
  //           _model.currentAvatarUrl = path;
  //           _model.currentAvatarType = CurrentAvatarType.local;
  //           SharedUtil().saveString(Keys.localAvatarPath, path);
  //           SharedUtil()
  //               .saveInt(Keys.currentAvatarType, CurrentAvatarType.local);
  //           _model.refresh();
  //         },
  //       );
  //       break;
  //   }
  // }

  Widget getAvatarWidget() {
    switch (_model.currentAvatarType) {
      case CurrentAvatarType.defaultAvatar:
        return Image.asset(
          "images/icon.png",
          fit: BoxFit.cover,
        );
        break;
      case CurrentAvatarType.local:
        File file = File(_model.currentAvatarUrl);
        return Image.file(
          file,
          fit: BoxFit.fill,
        );
        break;
      case CurrentAvatarType.net:
        return Container(
          height: 60,
          width: 60,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(
                Theme.of(_model.context).primaryColorLight),
          ),
        );
        break;
    }
    return Image.asset(
      "images/icon.png",
      fit: BoxFit.cover,
    );
  }

  Future getAvatarType() async {
    // final currentAvatarType =
    //     await SharedUtil.instance.getInt(Keys.currentAvatarType);
    // if (currentAvatarType == null) return;
    // if (currentAvatarType == _model.currentAvatarType) return;
    // _model.currentAvatarType = currentAvatarType;
  }

  void onAvatarTap() {
    Navigator.of(_model.context).push(new CupertinoPageRoute(builder: (ctx) {
      return ProviderConfig.getInstance().getAvatarPage(mainPageModel: _model);
    }));
  }

  void onUserNameTap() {
    final context = _model.context;
    showDialog(
        context: context,
        builder: (ctx) {
          return EditDialog(
            title: IntlLocalizations.of(context).customUserName,
            hintText: IntlLocalizations.of(context).inputUserName,
            positiveWithPop: false,
            onValueChanged: (text) {
              _model.currentEditingUserName = text;
            },
            initialValue: _model.currentUserName,
            onPositive: () async {
              if (_model.currentEditingUserName.isEmpty) {
                _showTextDialog(
                    IntlLocalizations.of(context).userNameCantBeNull);
                return;
              }
              final account = await SharedUtil.instance.getString(Keys.account);
              if (account == "default" || account == null) {
                _model.currentUserName = _model.currentEditingUserName;
                SharedUtil.instance
                    .saveString(Keys.currentUserName, _model.currentUserName);
                Navigator.of(context).pop();
                _model.refresh();
              } else {
                _changeUserName(account, _model.currentEditingUserName);
              }
            },
          );
        });
  }

  ///展示圆角弹窗
  void _showTextDialog(String text) {
    final context = _model.context;
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Text(text),
          );
        });
  }

  void _changeUserName(String account, String userName) async {
    final context = _model.context;
    // final token = await SharedUtil.instance.getString(Keys.token);
    _showLoadingDialog(context);
    ApiService.instance.changeUserName(
      success: (bean) async {
        _model.currentUserName = _model.currentEditingUserName;
        SharedUtil.instance
            .saveString(Keys.currentUserName, _model.currentUserName);
        Navigator.of(context).pop();
        _model.refresh();
        Navigator.pop(context);
      },
      error: (msg) {
        Navigator.of(context).pop();
        _showTextDialog(msg);
      },
      failed: (CommonBean commonBean) {
        Navigator.of(context).pop();
        // _showTextDialog(commonBean.description);
      },
      params: {
        "account": account,
        // "token": token,
        "userName": userName
      },
      token: _model.cancelToken,
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return NetLoadingWidget();
        });
  }

  ///点击搜索按钮
  void onSearchTap() {
    Navigator.of(_model.context).push(new CupertinoPageRoute(builder: (ctx) {
      return ProviderConfig.getInstance().getSearchPage();
    }));
  }

  ///检查更新
  void checkUpdate(GlobalModel globalModel) {
    if (Platform.isIOS) return;
    final context = _model.context;
    CancelToken cancelToken = CancelToken();
    ApiService.instance.checkUpdate(
      success: (UpdateInfoBean updateInfo) async {
        final packageInfo = await PackageInfo.fromPlatform();
        bool needUpdate = UpdateInfoBean.needUpdate(
            packageInfo.version, updateInfo.appVersion);
        if (needUpdate) {
          showDialog(
              context: context,
              builder: (ctx2) {
                return UpdateDialog(
                  version: updateInfo.appVersion,
                  updateUrl: updateInfo.downloadUrl,
                  updateInfo: updateInfo.updateInfo,
                  updateInfoColor: globalModel.logic.getBgInDark(),
                  backgroundColor:
                      globalModel.logic.getPrimaryGreyInDark(context),
                );
              });
        }
      },
      error: (msg) {},
      params: {
        "language": globalModel.currentLocale.languageCode,
        "appId": "001"
      },
      token: cancelToken,
    );
  }

  ///在云端更新一个任务
  void postUpdateTask(TaskBean taskBean) async {
    final account = await SharedUtil.instance.getString(Keys.account);
    if (account == 'default') return;
    // final token = await SharedUtil.instance.getString(Keys.token);

    ApiService.instance.postUpdateTask(
      success: (CommonBean bean) {
        // taskBean.needUpdateToCloud = 'false';
        DBProvider.db.updateTask(taskBean);
      },
      failed: (CommonBean bean) {
        // taskBean.needUpdateToCloud = 'true';
        // _model.needSyn = true;
        _model.refresh();
        DBProvider.db.updateTask(taskBean);
      },
      error: (msg) {
        // taskBean.needUpdateToCloud = 'true';
        // _model.needSyn = true;
        _model.refresh();
        DBProvider.db.updateTask(taskBean);
      },
      taskBean: taskBean,
      // token: token,
      cancelToken: _model.cancelToken,
    );
  }

  ///在云端创建一个任务
  void postCreateTask(List<TaskBean> taskBeans) async {
    showDialog(
        context: _model.context,
        builder: (ctx) {
          return NetLoadingWidget();
        });
    // final token = await SharedUtil.instance.getString(Keys.token);
    ApiService.instance.postCreateTask(
      _model.globalModel.currentId,
      success: (UploadTaskBean bean) {
        _model.refresh();
        // taskBean.needUpdateToCloud = 'false';
        // taskBean.uniqueId = bean.uniqueId;
        // DBProvider.db.updateTask(taskBean);
      },
      failed: (UploadTaskBean bean) {
        // taskBean.needUpdateToCloud = 'true';
        // _model.needSyn = true;
        _model.refresh();
        // DBProvider.db.updateTask(taskBean);
      },
      error: (msg) {
        // taskBean.needUpdateToCloud = 'true';
        // _model.needSyn = true;
        _model.refresh();
        // DBProvider.db.updateTask(taskBean);
      },
      taskBeans: taskBeans,
      // token: token,
      cancelToken: _model.cancelToken,
    );
  }

  void onBackGroundTap(GlobalModel globalModel) {
    //形参未被使用？？
    // Navigator.of(_model.context).push(
    //     new CupertinoPageRoute(builder: (ctx) {
    //   return ProviderConfig.getInstance().getNetPicturesPage(
    //     useType: NetPicturesUseType.mainPageBackground,
    //   );
    // }));
  }

  //修改！
  void changeUserId(int index) async {
    _model.globalModel.currentId = _model.globalModel.allId[index];
    _model.currentUserName = _model.globalModel.allName[index];
    _model.order = index;
    await _model.logic.getTasks();
    _model.refresh();
  }

  int getOrder() {
    for (int i = 0; i < _model.globalModel.allId.length; i++) {
      if (_model.globalModel.currentId == _model.globalModel.allId[i]) {
        return i;
      }
    }
    return 0;
  }

  void searchCalendar(String searchName) async {
    await ApiService.instance.searchCalender(
        params: {
          "searchName": searchName,
          "id": _model.globalModel.userId.toString(),
        },
        success: (List<TaskBean> taskBeans) {
          print("====main_page_logic====" + taskBeans.toString() + "========");
          _model.taskSearchBeans = taskBeans;
          _model.refresh();
        });
  }

  void addNewUser(String newUser) async {
    await ApiService.instance.postCreateChild(
        params: {
          "name": newUser,
          "id": _model.globalModel.userId.toString(),
          "phone": _model.globalModel.phone,
        },
        success: (UserBean userBean) {
          _model.globalModel.allName.add(newUser);
          _model.globalModel.allId.add(userBean.id);
          SharedUtil.instance
              .saveStringList(Keys.allNames, _model.globalModel.allName);
          List<String> allIds = [];
          for (int i in _model.globalModel.allId) {
            allIds.add(i.toString());
          }
          SharedUtil.instance.saveStringList(Keys.allIds, allIds);
          _model.globalModel.refresh();
          //请求
          _model.refresh();
        });
  }

  void bindUser(String userName, String phone) async {
    await ApiService.instance.postBindUser(
        params: {
          "name": userName,
          "id": _model.globalModel.userId.toString(),
          "phone": phone,
        },
        success: (UserBean userBean) {
          _model.globalModel.allName.add(userName);
          _model.globalModel.allId.add(userBean.id);
          SharedUtil.instance
              .saveStringList(Keys.allNames, _model.globalModel.allName);
          List<String> allIds = [];
          for (int i in _model.globalModel.allId) {
            allIds.add(i.toString());
          }
          SharedUtil.instance.saveStringList(Keys.allIds, allIds);
          //请求
          _model.globalModel.refresh();
          _model.refresh();
        });
  }
}
