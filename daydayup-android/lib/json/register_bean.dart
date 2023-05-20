import 'package:todo_list/config/api_service.dart';

class RegisterBean{



  int code;
  String msg;
  UserBean userBean;


  static RegisterBean fromMap(Map<String, dynamic> map) {
    RegisterBean diaryBase = new RegisterBean();
    diaryBase.msg = map['msg'];
    // diaryBase.token = map['token'];
    // diaryBase.userBean = UserBean.fromMap(map['data']);
    // diaryBase.avatarUrl = map['avatarUrl'];
    diaryBase.code = map['code'];
    if(diaryBase.code==200){
      diaryBase.userBean = UserBean.fromMap(map['data']);
    }
    return diaryBase;
  }

  static List<RegisterBean> fromMapList(dynamic mapList) {
    List<RegisterBean> list = List.filled(mapList.length, null);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

}


