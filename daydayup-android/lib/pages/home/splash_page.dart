import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/model/global_model.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<GlobalModel>(context);

    //开屏动画
    return Scaffold(
      body: Container(
        child: FlareActor(
          "flrs/todo_splash.flr",
          animation: "run", //animation表示动画的初始节点
          fit: BoxFit.cover,
          callback: (animation) {
            Navigator.of(context).pushAndRemoveUntil(
                new MaterialPageRoute(builder: (context) {
              return getHomePage(model.goToLogin);
            }), (router) => router == null);
          },
        ),
      ),
    );
  }

  /*
  * 相当于创建一个实例
  * 然后调用里面的方法
  * 构建widget  notifier
  * */
  Widget getHomePage(bool goToLogin) {
    return goToLogin
        ? ProviderConfig.getInstance().getLoginPage(isFirst: true)
        : ProviderConfig.getInstance().getMainPage();
  }
}
