import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/config/floating_border.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/model/all_main_page_model.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:todo_list/widgets/all_calendar_widget.dart';
import 'month_calendar_page.dart';

class AllMainPage extends StatelessWidget {

  Widget build(BuildContext context) {
    final model = Provider.of<AllMainPageModel>(context);
    final globalModel = Provider.of<GlobalModel>(context);
    final size = MediaQuery.of(context).size;

    model.setContext(context, globalModel: globalModel);
    globalModel.setAllMainPageModel(model);


    return Container(
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
            title: Text("掌舵者"),
          ),

          floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
          floatingActionButton:
          FloatingActionButton(
            child: Image.asset("images/home.png"),
            onPressed: () {
              //!!!!!!!!!
              //改成命名路由！！！
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProviderConfig.getInstance().getMainPage();
              }));
            },
          ),
          body:AllCalenderWidget(model),
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
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              )),
        ),
      );
  }
}
