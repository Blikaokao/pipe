///每个人的任务类型统计
class TaskTypeBean{

  int code;
  String msg;
  List<num> taskTypeList = [];

  static TaskTypeBean fromMap(Map<String, dynamic> map) {
    TaskTypeBean taskTypeBean = new TaskTypeBean();

    taskTypeBean.code = map['code'];
    taskTypeBean.msg = map['msg'];
    if(map["data"] == "fail"){
      taskTypeBean.taskTypeList = null;
    }else{
      Map<String,dynamic> dataMap =  map['data'];
      taskTypeBean.taskTypeList.add(dataMap['voice']);
      taskTypeBean.taskTypeList.add(dataMap['photo']);
      taskTypeBean.taskTypeList.add(dataMap['text']);
    }
    return taskTypeBean;
  }

}
