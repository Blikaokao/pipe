class UserBean{
  int id;
  int type;
  String userName;
  String phone;

  static UserBean fromMap(Map<String, dynamic> map){
    UserBean userBean = new UserBean();
    userBean.id = map['userId'];
    userBean.type = map['type'];
    userBean.userName = map['names'];
    userBean.phone = map['phone'];
    return userBean;
  }

  static List<UserBean> fromMapList(dynamic mapList){
    List<UserBean> list = List.filled(mapList.length, null);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    list.sort((a,b)=> a.type.compareTo(b.type));
    return list;
  }


}
