import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalCalenderService {
  factory LocalCalenderService() => _getInstance();

  static LocalCalenderService get instance => _getInstance();
  static LocalCalenderService _instance;
  // static const
  var calenderchannel;

  LocalCalenderService._internal() {
    ///初始化
    if(calenderchannel==null){
      calenderchannel = const MethodChannel('calender');
      Permission.calendar.request().then((value){});
    }

  }

  static LocalCalenderService _getInstance() {
    if (_instance == null) {
      _instance = new LocalCalenderService._internal();
    }
    return _instance;
  }

  ///增
  Future<int> add(String title,String startTime,String endTime,String description,{int alert}) async{
    try{
      //dtstart:事件开始时间，以从公元纪年开始计算的协调世界时毫秒数表示。
      //id:事件所属的日历的id
      var param = {"title":title,"dtstart":startTime,"endtime":endTime,"description":description,"alert":alert};
      int result = await calenderchannel.invokeMethod('add',param);
      return result;
    } on PlatformException catch(e){
      print('添加错误');
      return null;
    }
  }

  ///删
  Future<void> del(int eventId) async{
    try{
      //dtstart:事件开始时间，以从公元纪年开始计算的协调世界时毫秒数表示。
      //id:事件所属的日历的id
      var param = {"id":eventId.toString()};
      var result = await calenderchannel.invokeMethod('del',param);
    } on PlatformException catch(e){
      print('删除错误');
    }

  }

  ///改
  Future<void> update(int eventId,String title,String startTime,String endTime,{int alert}) async{
    try{
      //dtstart:事件开始时间，以从公元纪年开始计算的协调世界时毫秒数表示。
      //id:事件所属的日历的id
      var param = {"id":eventId,"newtitle":"YYYYYYYYYYYYYY"};
      var result = await calenderchannel.invokeMethod('update',param);
      print(result);
    } on PlatformException catch(e){
      print('修改错误');
    }
  }

  ///查
  Future<void> search() async{
    try{
      //dtstart:事件开始时间，以从公元纪年开始计算的协调世界时毫秒数表示。
      //id:事件所属的日历的id
      var result = await calenderchannel.invokeMethod('search');
      print(result);
    } on PlatformException catch(e){
      print('查找错误');
    }
  }

}