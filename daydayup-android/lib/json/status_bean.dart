///状态信息
class StatusBean{

  int code;
  String msg;
  List<num> eventStatus = [];

  static StatusBean fromMap(Map<String, dynamic> map) {
    StatusBean statusBean = new StatusBean();

    statusBean.code = map['code'];
    statusBean.msg = map['msg'];
    if(map["data"] == "fail"){
      statusBean.eventStatus = null;
    }else{
      print("&&&&&&&&&&&&&&&&&&&");
      print(map['data']['todo']);
      statusBean.eventStatus.add(map['data']['todo']);
      statusBean.eventStatus.add(map['data']['done']);
      statusBean.eventStatus.add(map['data']['outTime']);
      // print(map['data']['todo']);
    }
    return statusBean;
  }


}
