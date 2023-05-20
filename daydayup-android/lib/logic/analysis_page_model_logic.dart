import 'dart:convert';

import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/model/analysis_page_model.dart';


class AnalysisPageModelLogic {
  final AnalysisPageModel _model;
  CancelToken cancelToken = CancelToken();
  AnalysisPageModelLogic(this._model);

  Future getData(){

      int id = _model.globalModel.userId;
       ApiService.instance.getAllStatus(
        params: {'id': id},
        success: (StatusBean statusBean) {
          _model.eventStatusList = statusBean.eventStatus;
          _model.refresh();
        },
        token: cancelToken,
      );

       ApiService.instance.getAllType(
        params:{
          'id':id,
        },
        success: (TaskTypeBean bean){
          _model.taskTypeList = bean.taskTypeList;
          _model.refresh();
        },
      );
       ApiService.instance.getTasksCount(
          params: _model.globalModel.allId,
          success: (TaskNumBean bean){
            _model.taskNumList = bean.taskNumList;
            _model.refresh();
          }
      );
    }
}

