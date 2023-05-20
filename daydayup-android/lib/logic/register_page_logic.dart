import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/widgets/net_loading_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterPageLogic{

  final RegisterPageModel _model;

  RegisterPageLogic(this._model);

  // String validatorUserName(String userName) {
  //   final context = _model.context;
  //   _model.isUserNameOk = false;
  //   if (userName.isEmpty) {
  //     return IntlLocalizations.of(context).usernameCantBeEmpty;
  //   } else if (userName.contains(" ")) {
  //     return IntlLocalizations.of(context).userNameContainEmpty;
  //   } else {
  //     _model.userName = userName;
  //     _model.isUserNameOk = true;
  //     debugPrint("用户名通过");
  //     _model.refresh();
  //     return null;
  //   }
  // }

  String validatorVerifyCode(String verifyCode) {
    final context = _model.context;
    _model.isVerifyCodeOk = false;
    if (verifyCode.isEmpty) {
      return IntlLocalizations.of(context).verifyCodeCantBeEmpty;
    } else if (verifyCode.contains(" ")) {
      return IntlLocalizations.of(context).verifyCodeContainEmpty;
    } else {
      _model.verifyCode = verifyCode;
      _model.isVerifyCodeOk = true;
      debugPrint("验证码通过");
      _model.refresh();
      return null;
    }
  }

  String validatorPhone(String phone) {
    final context = _model.context;
    _model.isPhoneOk = false;
    //手机号正则
    Pattern pattern =
        r'^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$';
    RegExp regex = new RegExp(pattern);
    if (phone.isEmpty)
      return IntlLocalizations.of(context).phoneCantBeEmpty;
    else if (!regex.hasMatch(phone))
      return IntlLocalizations.of(context).phoneIncorrectFormat;
    else {
      _model.isPhoneOk = true;
      _model.phone = phone;
      debugPrint("手机号输入格式正确");
      _model.refresh();
      return null;
    }
  }

  String validateRePassword(String rePassword) {
    _model.isRePasswordOk = false;
    final context = _model.context;
    if (rePassword.isEmpty) {
      return IntlLocalizations.of(context).confirmPasswordCantBeEmpty;
    } else if (_model.password != rePassword) {
      return IntlLocalizations.of(context).twoPasswordsNotSame;
    } else if(rePassword.contains(" ")){
      return IntlLocalizations.of(context).confirmPasswordContainEmpty;
    }
    else {
      _model.rePassword = rePassword;
      _model.isRePasswordOk = true;
      debugPrint("密码2通过");
      _model.refresh();
      return null;
    }
  }

  String validatePassword(String password) {
    _model.isPasswordOk = false;
    final context = _model.context;
    if (password.isEmpty) {
      return  IntlLocalizations.of(context).passwordCantBeEmpty;
    } else if (password.length < 6) {
      return IntlLocalizations.of(context).passwordTooShort;
    } else if (password.length > 20) {
      return IntlLocalizations.of(context).passwordTooLong;
    } else {
      _model.password = password;
      _model.isPasswordOk = true;
      debugPrint("密码通过");
      _model.refresh();
      return null;
    }
  }

  void _validate(){
    bool b1 = _model.phoneKey?.currentState?.validate();
    // bool b2 = _model.userNameKey?.currentState?.validate();
    bool b3 = _model.rePasswordKey?.currentState?.validate();
    bool b4 = _model.passwordKey?.currentState?.validate();
    bool b5 = _model.verifyCodeKey?.currentState?.validate();
    debugPrint("$b1 - "
        // "$b2"
        " - $b3 - $b4 - $b5");
  }

  void onSubmit(){
    final model = _model;
    final context = _model.context;
    _validate();
    if(
    // !model.isUserNameOk ||
        !model.isPhoneOk || !model.isVerifyCodeOk || !model.isPasswordOk || !model.isRePasswordOk){
      _showTextDialog(IntlLocalizations.of(context).wrongParams, context);
      return;
    }
    showDialog(context: context, builder: (ctx){
      return NetLoadingWidget();
    });
    _registerPhone(model, context);
  }

  ///手机号验证
  void _registerPhone(RegisterPageModel model, BuildContext context) {
       final encryptPassword = model.password;
    ApiService.instance.postRegister(
      params: {
        "passwd": encryptPassword,
        "phone": model.phone,
        // "accountType": "0",
        // "username": model.userName,
        "code": model.verifyCode,
      },
      success: (RegisterBean bean){
        Fluttertoast.showToast(
            msg: "注册成功",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.lightBlueAccent,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.of(context).pushAndRemoveUntil(
            new MaterialPageRoute(
                builder: (context){
                  return ProviderConfig.getInstance().getLoginPage(isFirst: true);
                }),
                (router) => router == null);
      },
      failed: (RegisterBean bean){
        Navigator.of(context).pop();
        // _showTextDialog(bean.description, context);
      },
      error: (msg){
        Navigator.of(context).pop();
        _showTextDialog(msg, context);
      },
      token: _model.cancelToken,
    );
  }

  void _showTextDialog(String text, BuildContext context) {
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

}