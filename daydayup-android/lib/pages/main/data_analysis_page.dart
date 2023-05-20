import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/model/analysis_page_model.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:todo_list/widgets/bar_chart_sample7.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/widgets/pie_chart.dart';
import 'package:todo_list/widgets/radar_chart_sample1.dart';

class DataAnalysisPage extends StatelessWidget {
  AnalysisPageModel model;
  GlobalModel globalModel;
  CancelToken cancelToken = CancelToken();


  @override
  Widget build(BuildContext context) {
    globalModel = Provider.of<GlobalModel>(context);
    model = Provider.of<AnalysisPageModel>(context)
      ..setContext(context,globalModel);

    return Container(
      // decoration: model.logic.getBackground(globalModel),
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("images/bg_blue.png"),
        fit: BoxFit.cover,
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text("数据统计"),
        ),
        body: Container(
          height: double.infinity,
          padding: EdgeInsets.only(top: 40),
          decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage("images/task_list_bg.png"),
            //   fit: BoxFit.fill,
            // ),
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50))),
          child: ListView(
            children: [
              PieChartSample1(model.eventStatusList),
              BarChartSample7(model.taskNumList, globalModel.allName),
              RadarChartSample1(model.taskTypeList),
            ],
          ),
        ),
      ),
    );
  }
}
