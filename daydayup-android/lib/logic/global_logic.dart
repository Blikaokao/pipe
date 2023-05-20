import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:todo_list/config/all_types.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/custom_image_cache_manager.dart';
import 'package:todo_list/json/theme_bean.dart';
import 'package:todo_list/json/weather_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/shared_util.dart';
import 'package:todo_list/utils/theme_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_list/widgets/net_loading_widget.dart';

class GlobalLogic{ //全局逻辑

  final GlobalModel _model;

  GlobalLogic(this._model);


  //当为夜间模式时候，白色替换为灰色
  Color getWhiteInDark(){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.grey : Colors.white;
  }

  //当为夜间模式时候，白色背景替换为特定灰色
  Color getBgInDark(){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.grey[800] : Colors.white;
  }

  //当为夜间模式时候，主题色背景替换为灰色
  Color getPrimaryGreyInDark(BuildContext context){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.grey : Theme.of(context).primaryColor;
  }

  //当为夜间模式时候，主题色背景替换为特定灰色
  Color getPrimaryInDark(BuildContext context){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.grey[800] : Theme.of(context).primaryColor;
  }

  //当为夜间模式时候，黑色替换为白色
  Color getbwInDark(){
    final themeType = _model.currentThemeBean.themeType;
    return themeType == MyTheme.darkTheme ? Colors.white : Colors.black;
  }

  ///获取当前的语言code
  Future getCurrentLanguageCode() async{
    final list = await SharedUtil.instance.getStringList(Keys.currentLanguageCode);
    if (list == null) return;
    if (list == _model.currentLanguageCode) return;
    _model.currentLanguageCode = list;
  }

  ///获取当前的语言
  Future getCurrentLanguage() async{
    final currentLanguage = await SharedUtil.instance.getString(Keys.currentLanguage);
    if (currentLanguage == null) return;
    if (currentLanguage == _model.currentLanguage) return;
    _model.currentLanguage = currentLanguage;
  }

  ///获取当前的主题数据
  Future getCurrentTheme() async{
    final theme = await SharedUtil.instance.getString(Keys.currentThemeBean);
    if(theme == null) return;
    ThemeBean themeBean = ThemeBean.fromMap(jsonDecode(theme));
    if(themeBean.themeType == MyTheme.random){
      themeBean.colorBean = ColorBean.fromColor(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    } else if(themeBean.themeType == _model.currentThemeBean.themeType) return;
    _model.currentThemeBean = themeBean;
  }

  ///根据数据来决定显示什么主题
  void chooseTheme(){
    //未自动开启 未设置夜间时间段
    if(!_model.enableAutoDarkMode) return;
    if(_model.autoDarkModeTimeRange.isEmpty) return;


    //设置夜间模式
    final times = _model.autoDarkModeTimeRange.split('/');
    if(times.length < 2) return;
    final start = int.parse(times[0]);
    final end = int.parse(times[1]);
    final time = DateTime.now();
    if(time.hour < start || time.hour > end){
      final String languageCode = _model.currentLanguageCode[0];
      _model.currentThemeBean = ThemeBean(
        themeName: languageCode == 'zh' ? '不见五指' : 'dark',
        colorBean: ColorBean.fromColor(MyThemeColor.darkColor),
        themeType: MyTheme.darkTheme,
      );
    }

  }

  ///获取app的名字
  Future getAppName() async{
    final appName = await SharedUtil.instance.getString(Keys.appName);
    if(appName == null) return;
    if(appName == _model.appName) return;
    _model.appName = appName;
  }
  ///获取app的名字
  Future getCurrentUser() async{
    final id  = await SharedUtil.instance.getInt(Keys.id);
    final phone = await SharedUtil.instance.getString(Keys.account);
    if(id == null) return;
    _model.currentId = id;
    _model.userId = id;
    _model.phone = phone;
  }

  ///获取多人角色名称
  Future getAllRoles() async{
    final allNames = await SharedUtil.instance.getStringList(Keys.allNames);
    final allIds = await SharedUtil.instance.getStringList(Keys.allIds);
    if(allNames == null || allIds == null) return;
    else {

      for(String name in allNames){
        _model.allName.add(name);
      }
      for(String id in allIds){
        _model.allId.add(int.parse(id));
      }
    }

  }

  ///获取拥有课程角色名称
  Future setHasClass() async{
    final hasCourse = await SharedUtil.instance.getStringList(Keys.hasCourse);

    if(hasCourse == null) return;
    else {
      for(String id in hasCourse){
        _model.hasCourse.add(int.parse(id));
      }

    }

  }


  ///是否开启背景渐变
  Future getIsBgGradient()async{
    final isBgGradient = await SharedUtil.instance.getBoolean(Keys.backgroundGradient);
    if(isBgGradient == null) return;
    if(isBgGradient == _model.isBgGradient) return;
    _model.isBgGradient = isBgGradient;
  }

  ///获取导航栏的类型
  Future getCurrentNavHeader()async{
    final currentNavHeader = await SharedUtil.instance.getString(Keys.currentNavHeader);
    if(currentNavHeader == null) return;
    if(currentNavHeader == _model.currentNavHeader) return;
    _model.currentNavHeader = currentNavHeader;
  }

  ///获取当前导航栏头部选择网络图片时的图片地址
  Future getCurrentNetPicUrl()async{
    final currentNetPicUrl = await SharedUtil.instance.getString(Keys.currentNetPicUrl);
    if(currentNetPicUrl == null) return;
    if(currentNetPicUrl == _model.currentNavHeader) return;
    _model.currentNetPicUrl = currentNetPicUrl;
  }

  ///是否开启主页背景跟随任务卡片颜色
  Future getIsBgChangeWithCard() async {
    final isBgChangeWithCard = await SharedUtil.instance.getBoolean(Keys.backgroundChangeWithCard);
    _model.isBgChangeWithCard = isBgChangeWithCard;
  }

  ///是否开启任务卡片颜色跟随背景
  Future getIsCardChangeWithBg() async {
    final isCardChangeWithBg = await SharedUtil.instance.getBoolean(Keys.cardChangeWithBackground);
    _model.isCardChangeWithBg = isCardChangeWithBg;
  }

  ///是否开启主页的卡片左右无限循环
  Future getEnableInfiniteScroll() async{
    final enableInfiniteScroll = await SharedUtil.instance.getBoolean(Keys.enableInfiniteScroll);
    _model.enableInfiniteScroll = enableInfiniteScroll;
  }

  ///是否开启首页动画
  Future getEnableSplashAnimation() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account =  prefs.getString(Keys.account) ?? "default";
    _model.enableSplashAnimation = prefs.getBool(Keys.enableSplashAnimation + account)??true;
  }

  ///是否开启自动黑夜模式
  Future getAutoDarkMode() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String account =  prefs.getString(Keys.account) ?? "default";
    _model.enableAutoDarkMode = prefs.getBool(Keys.autoDarkMode + account)??false;
    _model.autoDarkModeTimeRange = prefs.getString(Keys.autoDarkModeTimeRange + account) ?? '';
  }

  ///获取当前的位置,拿到天气
  Future getCurrentPosition() async{
    final currentPosition = await SharedUtil.instance.getString(Keys.currentPosition);
    if(currentPosition == null) return;
    if(currentPosition == _model.currentPosition) return;
    _model.currentPosition = currentPosition;
  }

  ///是否开启天气
  Future getEnableWeatherShow() async{
    final enableWeatherShow = await SharedUtil.instance.getBoolean(Keys.enableWeatherShow);
    _model.enableWeatherShow = enableWeatherShow;
  }

  ///用于判断是否进入登录页面
  Future getLoginState() async{
    final hasLogged = await SharedUtil.instance.getBoolean(Keys.hasLogged);
    _model.goToLogin = !hasLogged;
  }

  ///是否开启主页背景为网络图片
  Future getEnableNetPicBgInMainPage() async{
    final enableNetPicBgInMainPage = await SharedUtil.instance.getBoolean(Keys.enableNetPicBgInMainPage);
    _model.enableNetPicBgInMainPage = enableNetPicBgInMainPage;
  }

  ///获取当前主页背景图片的url
  Future getCurrentMainPageBgUrl() async{
    final currentMainPageBgUrl = await SharedUtil.instance.getString(Keys.currentMainPageBackgroundUrl);
    if(currentMainPageBgUrl == null) return;
    if(currentMainPageBgUrl == _model.currentMainPageBgUrl) return;
    _model.currentMainPageBgUrl = currentMainPageBgUrl;
  }

  ///每日壁纸 12h 刷新
  Future getRefreshDailyPicTime() async{
    final time = await SharedUtil.instance.getString(Keys.everyDayPicRefreshTime);
    final now = DateTime.now();
    if(time == null) {
      SharedUtil.instance.saveString(Keys.everyDayPicRefreshTime, now.toIso8601String());
      return;
    }
    final date = DateTime.parse(time);
    if(date.difference(now).inHours > 12){
      SharedUtil.instance.saveString(Keys.everyDayPicRefreshTime, now.toIso8601String());
      CustomCacheManager().removeFile(NavHeadType.DAILY_PIC_URL);
    }
  }

  void getWeatherNow(String position,{BuildContext context, LoadingController controller}){
    ApiService.instance.getWeatherNow(success : (WeatherBean weatherBean){
      _model.weatherBean = weatherBean;
      _model.enableWeatherShow = true;
      SharedUtil.instance.saveString(Keys.currentPosition, position);
      SharedUtil.instance.saveBoolean(Keys.enableWeatherShow, true);
      _model.refresh();
      controller?.setFlag(LoadingFlag.success);

    },failed : (WeatherBean weatherBean){
      controller?.setFlag(LoadingFlag.error);
    }, error : (error){
      controller?.setFlag(LoadingFlag.error);

    }, params : {
      "key": "d381a4276ed349daa3bf63646f12d8ae",
      "location": position,
      "lang":_model.currentLocale.languageCode
    }, token: CancelToken());
  }

  bool isDarkNow(){
    return _model.currentThemeBean.themeType == MyTheme.darkTheme;
  }

  void setRoles(List<UserBean> userBeans){
    _model.allName.clear();
    _model.allId.clear();
    List<String> allIds = [];
    for(UserBean user in userBeans){
      _model.allId.add(user.id);
      allIds.add(user.id.toString());
      if(user.type == 0){
        _model.currentId = user.id;
        _model.userId = user.id;
      }
      _model.allName.add(user.userName);
    }
    SharedUtil.instance.saveStringList(Keys.allNames, _model.allName);
    SharedUtil.instance.saveStringList(Keys.allIds, allIds);
  }



  addAndSaveHasCourse(int hasCourseId){
     _model.hasCourse.add(hasCourseId);
     List<String> hasCourseList = [];
     for(int i in _model.hasCourse){
       hasCourseList.add(i.toString());
     }
     SharedUtil.instance.saveStringList(Keys.hasCourse, hasCourseList);
  }


  String getUserName(int id){
    for(int i=0;i<_model.allId.length;i++){
      if(_model.allId[i]==id){
        return _model.allName[i];
      }
    }
  }

}