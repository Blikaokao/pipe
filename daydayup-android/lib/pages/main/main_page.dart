import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/floating_border.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:todo_list/model/main_page_model.dart';
import 'package:todo_list/pages/navigator/nav_page.dart';
import 'package:todo_list/widgets/add_person_dialog.dart';
import 'package:todo_list/widgets/animated_floating_button.dart';
import 'package:todo_list/widgets/bind_user_wiget.dart';
import 'package:todo_list/widgets/choose_add_mode_widget.dart';
import 'package:todo_list/widgets/date_picker.dart';
import 'package:todo_list/widgets/searchIow.dart';

import 'month_calendar_page.dart';

class MainPage extends StatelessWidget {
  Widget build(BuildContext context) {
    final model = Provider.of<MainPageModel>(context);
    final globalModel = Provider.of<GlobalModel>(context);
    // final size = MediaQuery.of(context).size;
    // final canHideWidget = model.canHideWidget;
    model.setContext(context, globalModel: globalModel);
    globalModel.setContext(context);
    globalModel.setMainPageModel(model);

    //下拉菜单
    List<DropdownMenuItem<int>> dropButtonItems = [];

    //数组的构造函数
    /*
    *  List.generate(length,item)
    * */
    dropButtonItems.addAll(List.generate(
        model.globalModel.allId.length,
        (index) => DropdownMenuItem(
              value: index,
              child: Container(
                  width: MediaQuery.of(context).size.width / 4, //占四分之一的屏幕宽度
                  child: Text(
                    model.globalModel.allName[index],
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    // style: TextStyle(
                    //   color: Colors.white,
                    // )
                  )),
            )));

    dropButtonItems.add(DropdownMenuItem(
      value: -1,
      child: Container(
          width: MediaQuery.of(context).size.width / 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.group, color: Colors.grey),
              Text(
                "总览",
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )),
    ));

    dropButtonItems.add(DropdownMenuItem(
      value: -2, //应该是用来响应选项改变时的 item的值（被选中的值）
      child: Container(
          width: MediaQuery.of(context).size.width / 4,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.person_add, color: Colors.grey),
              Text(
                "添加角色",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width / 25,
                ),
              ),
            ],
          )),
    ));

    /*
    * GestureDetector专门的手势动作捕捉
    * 针对哪个对象进行捕捉动作   child
    * */
    return GestureDetector(
      // onLongPress: () => model.logic.onBackGroundTap(globalModel), //长按进入背景设置页
      // onLongPress: () => model.logic.onAvatarTap(),
      child: Container(
        // decoration: model.logic.getBackground(globalModel),
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("images/bg_blue.png"),
          fit: BoxFit.cover,
        )),

        child: Scaffold(
          backgroundColor: Colors.transparent,
          key: model.scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              //把用户放在左边  去除掉了标题
              children: [
                Image.asset(
                  "images/role.png",
                  width: 30,
                ),
                Container(
                  child: DropdownButton(
                      underline: Container(height: 0),
                      value: model.logic.getOrder(),
                      icon: Image.asset(
                        "images/role_pick.png",
                        width: 20,
                      ),
                      onChanged: (T) async {
                        //下拉菜单item点击之后的回调
                        if (T >= 0) {
                          model.logic.changeUserId(T);
                        } else if (T == -1) {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return ProviderConfig.getInstance()
                                .getAllMainPageModel();
                          }));
                        } else {
                          TextEditingController _userName =
                              TextEditingController();
                          TextEditingController _phone =
                              TextEditingController();
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return RenameDialog(
                                  contentWidget: ChooseAddModeWidget([
                                    BindUserWidget(
                                      cancelBtnTitle: "取消",
                                      okBtnTitle: "确定",
                                      title: "请填写关联用户的信息",
                                      okBtnTap: () {
                                        model.logic.bindUser(
                                            _userName.text, _phone.text);
                                      },
                                      userName: _userName,
                                      phone: _phone,
                                      cancelBtnTap: () {},
                                    ),
                                    RenameDialogContent(
                                      cancelBtnTitle: "取消",
                                      okBtnTitle: "确定",
                                      title: "请输入创建角色的名称",
                                      okBtnTap: () {
                                        model.logic.addNewUser(_userName.text);
                                      },
                                      vc: _userName,
                                      cancelBtnTap: () {},
                                    )
                                  ]),
                                );
                              });
                        }
                      },
                      items: dropButtonItems),
                ),
              ],
            ),
            actions: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (globalModel.hasCourse.contains(globalModel.currentId))
                      IconButton(
                          icon: Image.asset(
                            "images/course_flag.png",
                            width: 30,
                          ),

                          /*
                           * 课程表图标 绑定一个点击函数
                           * 发起了一个请求
                           * */
                          onPressed: () {
                            ApiService.instance.getClasses(
                              params: {
                                'userId': globalModel.currentId.toString(),
                              },
                              success: (AllClassBean bean) {
                                Navigator.of(context).push(new PageRouteBuilder(
                                  pageBuilder: (ctx, anm, anmS) {
                                    return ProviderConfig.getInstance()
                                        .getAddClassPage(false,
                                            classBean: bean.setTaskToClass());
                                  },
                                ));
                              },
                            );
                          }),

                    /*
                    * 原先下拉菜单的位置 改成搜索框
                    * 发送一个请求
                    * */
                    IconButton(
                      icon: Padding(
                        padding: EdgeInsets.only(left: 3),
                        child: Icon(
                          Icons.search,
                          size: 22,
                        ),
                      ),
                      /*
                         * 点击之后进行页面的覆盖
                         * */
                      onPressed: () {
                        //页面跳转  直接转到搜索框的页面
                        showSearch(
                            context: context,
                            delegate: searchBarDelegate(model));
                      },
                    ),

                    /* Image.asset(
                      "images/role.png",
                      width: 30,
                    ),
                    DropdownButton(
                        underline: Container(height: 0),
                        value: model.logic.getOrder(),
                        icon: Image.asset(
                          "images/role_pick.png",
                          width: 20,
                        ),
                        onChanged: (T) async {
                          //下拉菜单item点击之后的回调
                          if (T >= 0) {
                            model.logic.changeUserId(T);
                          } else if (T == -1) {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return ProviderConfig.getInstance()
                                  .getAllMainPageModel();
                            }));
                          } else {
                            TextEditingController _userName =
                                TextEditingController();
                            TextEditingController _phone =
                                TextEditingController();
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return RenameDialog(
                                    contentWidget: ChooseAddModeWidget([
                                      BindUserWidget(
                                        cancelBtnTitle: "取消",
                                        okBtnTitle: "确定",
                                        title: "请填写关联用户的信息",
                                        okBtnTap: () {
                                          model.logic.bindUser(
                                              _userName.text, _phone.text);
                                        },
                                        userName: _userName,
                                        phone: _phone,
                                        cancelBtnTap: () {},
                                      ),
                                      RenameDialogContent(
                                        cancelBtnTitle: "取消",
                                        okBtnTitle: "确定",
                                        title: "请输入创建角色的名称",
                                        okBtnTap: () {
                                          model.logic
                                              .addNewUser(_userName.text);
                                        },
                                        vc: _userName,
                                        cancelBtnTap: () {},
                                      )
                                    ]),
                                  );
                                });
                          }
                        },
                        items: dropButtonItems),*/
                  ],
                ),
              ),
              // !canHideWidget
              //     ? IconButton(
              //         icon: Icon(
              //           Icons.search,
              //           size: 28,
              //           color: globalModel.logic.getWhiteInDark(),
              //         ),
              //         onPressed: () => model.logic.onSearchTap(),
              //       )
              //     : Container()
            ],
          ),
          // drawer: Drawer(
          //   child: NavPage(),
          // ),
          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: AnimatedFloatingButton(
            //动画悬浮按钮
            bgColor: globalModel.isBgChangeWithCard
                ? model.logic.getCurrentCardColor()
                : null,
          ),

          //中间的日历部分
          body: TableComplexExample(model),

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
                          return MonthCalendarPage(model.kEvents);
                        }));
                      }),
                  SizedBox(),
                  IconButton(
                    icon: Image.asset(
                      "images/my_set.png",
                      width: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return NavPage(kEvents: model.kEvents);
                      }));
                    },
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              )),
        ),
      ),
    );
  }
}
