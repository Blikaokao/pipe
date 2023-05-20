import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/json/task_bean.dart';

class AllClassBean {

  String msg;
  int code;
  List<TaskBean> taskList;

  static AllClassBean fromMap(Map<String, dynamic> map) {
    AllClassBean  allClassBean = new AllClassBean();
    // cloudTaskBean.description = map['description'];
    // cloudTaskBean.status = map['status'];

    allClassBean.msg = map['msg'];
    allClassBean.code = map['code'];
    if(map['data']==null){
      allClassBean.taskList = [];
    }
    else allClassBean.taskList = TaskBean.fromNetMapList(map['data']);

    return allClassBean;
  }

  ClassBean setTaskToClass(){
    ClassBean classBean = ClassBean();
    classBean.classes = [];
    List<List<TaskBean>> taskBeanLists = [];
    for(int i=0;i<7;i++){
      taskBeanLists.add([]);
      for(TaskBean bean in this.taskList){
        DateTime startTime = DateTime.parse(bean.startDate);
        int weekDay = startTime.weekday-1;
        if(weekDay==i){
          taskBeanLists[i].add(bean);
        }
      }

      if(taskBeanLists[i].length==0){
        classBean.classes.add(DayClass());
        classBean.classes[i].lessons = [];
      }
      else classBean.classes.add(sortOneDayLessons(taskBeanLists[i]));

    }
    return classBean;
  }

  int compareElement(TaskBean a, TaskBean b) =>
      DateTime.parse(a.startDate).isAfter(DateTime.parse(b.startDate)) ? -1 : 1;

  DayClass sortOneDayLessons(List<TaskBean> taskBeans){
    taskBeans.sort(compareElement);
    DayClass dayClass = DayClass();
    for(TaskBean taskBean in taskBeans){
      dayClass.addLesson(taskBean.taskName);
    }
    return dayClass;
  }


}
