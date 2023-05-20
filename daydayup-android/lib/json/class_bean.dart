
class ClassBean{

  int code;
  String msg;
  List<DayClass> classes;

  static ClassBean fromMap(Map<String, dynamic> map) {
    ClassBean classBean = new ClassBean();
    // loginBean.description = map['description'];
    // loginBean.status = map['status'];
    // loginBean.token = map['token'];
    // loginBean.username = map['username'];
    // loginBean.avatarUrl = map['avatarUrl'];
    classBean.code = map['code'];
    classBean.msg = map['msg'];
    if(map["data"] == "fail"){
      classBean = null;
    }else{
      classBean.classes = fromClassList(map['data']);
    }
    return classBean;
  }

  static List<DayClass>  fromClassList(List lists){
     List<DayClass> classes = [];
      for (int i = 0; i < lists.length; i++) {
        DayClass dayClass = DayClass();
        dayClass.setLessons(lists[i]);
        classes.add(dayClass);
      }

      return classes;
  }
  
}



class DayClass{
    List<String> lessons;

    setLessons(List<dynamic> mapList) {
       this.lessons = [];
     for (int i = 0; i < mapList.length; i++) {
       this.lessons.add(mapList[i]);
     }
   }

    List<String> getLessons(){
      return this.lessons;
    }

    setLesson(int index,String detail){
      this.lessons[index] = detail;
    }

    getLesson(int index){
      if(this.lessons.length>index)
      return this.lessons[index];
      else{
        return "";
      }
    }
    addLesson(String detail){
      if(this.lessons==null){
        this.lessons = [];
      }
      this.lessons.add(detail);
    }
}


