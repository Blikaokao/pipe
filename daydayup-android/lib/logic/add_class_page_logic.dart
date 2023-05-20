import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/api_strategy.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:intl/src/intl/date_format.dart';
class AddClassPageLogic {
  final AddClassPageModel _model;
  int rowIndex = 0;
  CancelToken cancelToken = CancelToken();

  AddClassPageLogic(this._model);

  String thisLine(int day,int lesson){
    if(_model.classBean.classes[day].lessons.length == 0){
      return "";
    }
    String detail = _model.classBean.classes[day].getLesson(lesson);
    return detail;
  }

  void setClassLength(int length){
    _model.classLength = length;
  }

  void setRestLength(int length){
    _model.restLength = length;
  }

  void TimeSlotGenerate(){
    if(_model.isTimeSame){
      for(int i=0;i<10;i++){
        String startTime;
        String endTime;
        //生成开始时间
        if(i!=0){
          startTime = DateFormat('HH:mm').format(DateTime(2022,5,7,int.parse(_model.timeEndList[i-1].split(":")[0]),int.parse(_model.timeEndList[i-1].split(":")[1])).add(Duration(minutes: _model.restLength)));
          _model.timeStartList[i]=startTime;
        }
        endTime = DateFormat('HH:mm').format(DateTime(2022,5,7,int.parse(_model.timeStartList[i].split(":")[0]),int.parse(_model.timeStartList[i].split(":")[1])).add(Duration(minutes: _model.classLength)));
        //生成结束时间
        _model.timeEndList[i]=endTime;
      }
    }
  }
  void setClassTime(int index,String startTime,String endTime)
  {
    _model.timeStartList[index] = startTime;
    _model.timeEndList[index] = endTime;
    _model.refresh();
  }

  String getTimeSlot(int index){

    String startTime = _model.timeStartList[index];
    String endTime = _model.timeEndList[index];
    return startTime+'-'+endTime;
  }

}
