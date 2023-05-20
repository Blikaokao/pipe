///每个人的任务数量
class TaskNumBean{

  int code;
  String msg;
  List<num> taskNumList = [];

  static TaskNumBean fromMap(Map<String, dynamic> map) {
    TaskNumBean taskNumBean = new TaskNumBean();

    taskNumBean.code = map['code'];
    taskNumBean.msg = map['msg'];
    if(map["data"] == "fail"){
      taskNumBean.taskNumList = null;
    }else{
      List list = map['data'];
      for (num i in list){
        taskNumBean.taskNumList.add(i);
      }
      // taskNumBean.taskNumList.addAll(map['data'] as List<num>);
    }
    return taskNumBean;
  }


}
