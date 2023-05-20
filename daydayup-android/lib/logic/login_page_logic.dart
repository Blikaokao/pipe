import 'package:flutter/cupertino.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/api_strategy.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/database/database.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/json/login_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/utils/my_encrypt_util.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';

class LoginPageLogic {
  final LoginPageModel _model;

  LoginPageLogic(this._model);

  void onExit() {//退出
    _model.currentAnimation = "move_out";
    _model.showLoginWidget = false;
    _model.refresh();
  }

  String validatorPhone(String email) {
    final context = _model.context;
    _model.isPhoneOk = false;
    Pattern pattern =
        r'^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$';
    RegExp regex = new RegExp(pattern);
    if (email.isEmpty)
      return IntlLocalizations.of(context).phoneCantBeEmpty;
    else if (!regex.hasMatch(email))
      return IntlLocalizations.of(context).phoneIncorrectFormat;
    else {
      _model.isPhoneOk = true;
      return null;
    }
  }

  String validatePassword(String password) {
    final context = _model.context;
    _model.isPasswordOk = false;
    if (password.isEmpty) {
      return IntlLocalizations.of(context).passwordCantBeEmpty;
    } else if (password.length < 6) {
      return IntlLocalizations.of(context).passwordTooShort;
    } else if (password.length > 20) {
      return IntlLocalizations.of(context).passwordTooLong;
    } else {
      _model.isPasswordOk = true;
      return null;
    }
  }

  void onLogin() {
    final context = _model.context;
    _model.formKey.currentState.validate();
    if (!_model.isPhoneOk || !_model.isPasswordOk) {
      _showDialog(IntlLocalizations.of(context).checkYourEmailOrPassword, context);
      return;
    }
    showDialog(context: _model.context, builder: (ctx){
      return NetLoadingWidget();
    });//展示网络加载弹框
    _onLoginRequest(context);
  }

  void onForget() {
    Navigator.of(_model.context).push(new CupertinoPageRoute(builder: (ctx) {
      return ProviderConfig.getInstance().getResetPasswordPage(isReset: false);
    }));
  }

  void onRegister() {
    Navigator.of(_model.context).push(new CupertinoPageRoute(builder: (ctx) {
        return ProviderConfig.getInstance().getRegisterPage();
    }));
  }

  void onSkip(){
    SharedUtil.instance.saveBoolean(Keys.hasLogged, true);
    Navigator.of(_model.context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) {
            return ProviderConfig.getInstance().getMainPage();
        }), (router) => router == null);
  }


  void _showDialog(String text, BuildContext context) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            content: Text(text),
          );
        });
  }

  void _onLoginRequest(BuildContext context) {

    final account = _model.emailController.text;
    final password = _model.passwordController.text;
    // final encryptPassword = EncryptUtil.instance.encrypt(password);//将密码进行加密

    ApiService.instance.login(
      params: {
        "phone": "$account",
        "passwd": "$password"
      },
      success: (LoginBean loginBean) {
        List<UserBean> users = loginBean.userBeans;
        int i;
        for(i=0;i<users.length;i++){
          if(users[i].type==0){
            break;
          }
        }
        //更新本地缓存
          SharedUtil.instance.saveInt(Keys.id, users[i].id).then((value){
          SharedUtil.instance.saveString(Keys.phone, users[i].phone);

          SharedUtil.instance.saveString(Keys.currentUserName, users[i].userName);

          SharedUtil.instance.saveBoolean(Keys.hasLogged, true);
          GlobalModel model = Provider.of<GlobalModel>(context,listen: false);
          model.phone =  users[i].phone;
          model.userId =  users[i].id;
          model.logic.setRoles(loginBean.userBeans);
          model.logic.setHasClass();

          // if(loginBean.avatarUrl != null){
          //   SharedUtil.instance.saveString(Keys.netAvatarPath, ApiStrategy.baseUrl + loginBean.avatarUrl);
          //   SharedUtil.instance.saveInt(Keys.currentAvatarType, CurrentAvatarType.net);
          // }
        }).then((v){
          // DBProvider.db.updateAccount(account).then((v){
            //设置用户名

            Navigator.of(context).pushAndRemoveUntil(
                new MaterialPageRoute(
                    builder: (context){
                      return ProviderConfig.getInstance().getMainPage();
                    }),
                    (router) => router == null);
          }
          // );
        // }
        );

      },
      failed: (LoginBean loginBean) {
        Navigator.of(context).pop();
        _showDialog(
            "登录失败 账号不存在或密码错误",
            // loginBean.description,
            context);
      },
      error: (msg) {
        Navigator.of(context).pop();
        _showDialog(msg, context);
      },
      token: _model.cancelToken,
    );
  }
}
