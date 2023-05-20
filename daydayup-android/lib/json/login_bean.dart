import 'package:todo_list/config/api_service.dart';

///登录信息(描述、状态码、token、username,头像url)
class LoginBean{


  // String description;
  // int status;
  // String token;
  // String username;
  // // String avatarUrl;
  int code;
  String msg;
  List<UserBean> userBeans;

  static LoginBean fromMap(Map<String, dynamic> map) {
    LoginBean loginBean = new LoginBean();
    // loginBean.description = map['description'];
    // loginBean.status = map['status'];
    // loginBean.token = map['token'];
    // loginBean.username = map['username'];
    // loginBean.avatarUrl = map['avatarUrl'];
    loginBean.code = map['code'];
    loginBean.msg = map['msg'];
    if(loginBean.msg == null){
      loginBean.userBeans = UserBean.fromMapList(map['data']);
    }else{
      loginBean.userBeans = null;
    }
    return loginBean;
  }

  static List<LoginBean> fromMapList(dynamic mapList) {
    List<LoginBean> list = List.filled(mapList.length, null);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

}
