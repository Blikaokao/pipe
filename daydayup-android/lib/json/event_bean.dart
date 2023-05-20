///登录信息(描述、状态码、token、username,头像url)
class EventBean{

  int code;
  String msg;
  List<Event> events;

  static EventBean fromMap(Map<String, dynamic> map) {
    EventBean eventBean = new EventBean();
    // loginBean.description = map['description'];
    // loginBean.status = map['status'];
    // loginBean.token = map['token'];
    // loginBean.username = map['username'];
    // loginBean.avatarUrl = map['avatarUrl'];
    eventBean.code = map['code'];
    eventBean.msg = map['msg'];
    if(map["data"] == "fail"){
      eventBean.events = null;
    }else{
      eventBean.events = Event.fromMapList(map['data']);
    }
    return eventBean;
  }


}

class Event{
  String startDate;
  String deadLine;
  String taskName;

  static Event fromMap(Map<String, dynamic> map) {
    Event event = new Event();

    event.startDate = map['startDate'];
    event.deadLine = map['deadLine'];
    event.taskName = map['taskName'];

    return event;
  }

  static List<Event> fromMapList(List<dynamic> mapList) {
    List<Event> events = List.filled(mapList.length, null);
    for (int i = 0; i < mapList.length; i++) {
      events[i] = fromMap(mapList[i]);
    }
    return events;
  }


}

class EventType{
  static const int NORMAL=0;
  static const int CLASSTYPE=1;
  static const int CIRCULAR=2;
}
