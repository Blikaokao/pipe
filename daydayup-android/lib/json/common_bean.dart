///描述+状态码
class CommonBean {

  // String description;
  // int status;
  String msg;
  int code;
  String data;

  static CommonBean fromMap(Map<String, dynamic> map) {
    CommonBean commonBean = new CommonBean();
    commonBean.msg = map['msg'];
    commonBean.code = map['code'];
    commonBean.data = map['data'];
    return commonBean;
  }

  static List<CommonBean> fromMapList(dynamic mapList) {
    List<CommonBean> list = List.filled(mapList.length, null);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }

}
