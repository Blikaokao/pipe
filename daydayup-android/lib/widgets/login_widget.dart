import 'package:flutter/material.dart';
import 'package:todo_list/i10n/localization_intl.dart';
import 'package:todo_list/model/login_page_model.dart';

import 'bottom_to_top_widget.dart';

class LoginWidget extends StatelessWidget {
  final LoginPageModel loginPageModel;

  const LoginWidget({Key key, @required this.loginPageModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final primaryColor = Theme.of(context).primaryColor;
    final primaryColorLight = Theme.of(context).primaryColorLight;
    // final primaryColorDark = Theme.of(context).primaryColorDark;
    final size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(left: 40, right: 40),
      child: Form(
        key: loginPageModel.formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                BottomToTopWidget(
                  child: TextFormField(
                    validator: (phone) =>
                        loginPageModel.logic.validatorPhone(phone),
                    keyboardType: TextInputType.text,
                    controller: loginPageModel.emailController,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(textBaseline: TextBaseline.alphabetic),
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder( //未选中时候的颜色
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Color(0xffF0F3F4),),
                        ),
                        focusedBorder: OutlineInputBorder( //选中时外边框颜色
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(color: Color(0xffF0F3F4),),
                        ),

                        fillColor: const Color(0xffF0F3F4),
                        filled: true,
                        hintText: IntlLocalizations.of(context).inputPhone,
                        labelText: IntlLocalizations.of(context).phone,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        prefixIcon: Icon(
                          Icons.phone,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () => Future.delayed(
                            Duration(milliseconds: 100),
                            () => loginPageModel.emailController?.clear(),
                          ),
                        )),
                  ),
                  index: 0,
                ),
                SizedBox(
                  height: 10,
                ),
                BottomToTopWidget(
                  child: TextFormField(
                    validator: (password) =>
                        loginPageModel.logic.validatePassword(password),
                    controller: loginPageModel.passwordController,
                    keyboardType: TextInputType.text,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(textBaseline: TextBaseline.alphabetic),
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder( //未选中时候的颜色
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xffF0F3F4),),
                      ),
                      focusedBorder: OutlineInputBorder( //选中时外边框颜色
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Color(0xffF0F3F4),),
                      ),
                      fillColor: const Color(0xffF0F3F4),
                      filled: true,
                      hintText: IntlLocalizations.of(context).inputPassword,
                      labelText: IntlLocalizations.of(context).password,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      prefixIcon: Icon(
                        Icons.lock,
                      ),

                      suffixIcon: FlatButton(
                        highlightColor: primaryColorLight,
                        colorBrightness: Brightness.dark,
                        splashColor: Colors.grey,
                        onPressed: loginPageModel.logic.onForget,
                        child: Text(
                          IntlLocalizations.of(context).forget,
                          style: TextStyle(color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    obscureText: true,
                  ),
                  index: 1,
                ),
                SizedBox(
                  height: 20,
                ),
                BottomToTopWidget(
                  index: 2,
                  child: Container(
                    height: 60,
                    width: size.width - 80,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("images/login_bt.png"),
                          fit: BoxFit.fitHeight,
                        )),
                    child: FlatButton(
                      // color: primaryColor,
                      // highlightColor: primaryColorLight,
                      colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      child: Text(
                        IntlLocalizations.of(context).logIn,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.0)),
                      onPressed: loginPageModel.logic.onLogin,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                BottomToTopWidget(
                  index: 2,
                  child: Container(
                    height: 60,
                    width: size.width - 80,
                    child: FlatButton(
                      // color: primaryColor.withOpacity(0.3),
                      // highlightColor: primaryColorLight,
                      // colorBrightness: Brightness.dark,
                      splashColor: Colors.grey,
                      child: Text(
                        IntlLocalizations.of(context).haveNoAccount,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      // shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(40.0),
                      //     side: BorderSide(color: primaryColorDark)),
                      onPressed: loginPageModel.logic.onRegister,
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // loginPageModel.isFirst ? BottomToTopWidget(
                //     child: FlatButton(
                //       color: primaryColor,
                //       highlightColor: primaryColorLight,
                //       colorBrightness: Brightness.dark,
                //       splashColor: Colors.grey,
                //       child: Text(IntlLocalizations.of(context).skip),
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(20.0)),
                //       onPressed: loginPageModel.logic.onSkip,
                //     ),
                //     index: 3) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
