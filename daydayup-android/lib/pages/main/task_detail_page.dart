import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/global_model.dart';
import 'package:todo_list/widgets/task_info_widget.dart';
import 'package:todo_list/model/task_detail_page_model.dart';

class TaskDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final globalModel = Provider.of<GlobalModel>(context);
    final model = Provider.of<TaskDetailPageModel>(context)
      ..setContext(context, globalModel);

    globalModel.setTaskDetailPageModel(model);
    // final taskColor = globalModel.isCardChangeWithBg
    //     ? Theme.of(context).primaryColor
    //     : ColorBean.fromBean(model.taskBean.taskIconBean.colorBean);
    final taskColor = Theme.of(context).primaryColor;

    // final textColor = model.logic.getTextColor(context);

    final int heroTag = model.heroTag;
    final size = MediaQuery.of(context).size;
    // final bgUrl = model.taskBean.backgroundUrl;
    final opacity = 1.0;
    final enableOpacity = false;

    List<Widget> list = [];
    list.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
              onPressed: (){model.logic.editTask(context);}, child: Text("编辑",style: TextStyle(color: Colors.black,fontWeight:FontWeight.normal),)),
          TextButton(onPressed: (){model.logic.deleteTask();}, child: Text("删除",style: TextStyle(color: Colors.black,fontWeight:FontWeight.normal))),
        ],
      )
    );
    List<String> itemNameList = ["所属日程","提醒","重复","备注"];
    String alertString;
    String repeatString;
    List<String> slotText = ["日程发生时","5分钟前","15分钟前","30分钟前","1小时前","2小时前","1天前","2天前","7天前"];
    if(model.taskBean.alert!=null){
      switch(model.taskBean.alert){
        case 0: alertString =  slotText[0];break;
        case 5: alertString =  slotText[1];break;
        case 15: alertString =  slotText[2];break;
        case 30: alertString =  slotText[3];break;
        case 60: alertString =  slotText[4];break;
        case 120: alertString =  slotText[5];break;
        case 1440: alertString =  slotText[6];break;
        case 2880: alertString =  slotText[7];break;
        case 10080: alertString =  slotText[8];break;
        default: alertString =  model.taskBean.alert.toString() +"分钟前";
      }
    }else{
      alertString = "无";
    }

    List<String> repeatText = ["仅一次","每天","每周","每两周","每月","每年"];
    if(model.taskBean.period!=null){
      switch(model.taskBean.period){
        case 0: repeatString =  "无";break;
        case 1: repeatString =  repeatText[1];break;
        case 7: repeatString =  repeatText[2];break;
        case 14: repeatString =  repeatText[3];break;
        case 30: repeatString =  repeatText[4];break;
        case 365: repeatString =  repeatText[5];break;
      }
    }else{
      repeatString = "无";
    }

    //备注
    String detailString = "";
    if(model.taskBean.detailList!=null&&model.taskBean.detailList.isNotEmpty){
      int i=1;
      for(TaskDetailBean taskDetailBean in model.taskBean.detailList){
        detailString=detailString+"${i}."+taskDetailBean.taskDetailName+"\n";
      }
    }else{
      detailString = "无";
    }
    List<String> itemContent = [
      globalModel.logic.getUserName(model.taskBean.uniqueId),
      alertString,
      repeatString,
      detailString,
    ];
    list.add(
      Container(
        width: 600,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              //渐变位置
              begin: Alignment.topCenter, //右上
              end: Alignment.bottomCenter, //左下
              //渐变颜色[始点颜色, 结束颜色]
              colors: [
                const Color(0x40A5E3FF),
                const Color(0x40B2D6FC),
                const Color(0x40A4C8FD)
              ],
            ),
            borderRadius: BorderRadius.circular(20) // 边色与边宽度
            ),
        margin: EdgeInsets.only(
            left: 20, top: size.width > size.height ? 0 : 20, right: 20),
        child: TaskInfoWidget(
          true,
          //任务卡简介
          heroTag,
          taskBean: model.taskBean,
          // isCardChangeWithBg: globalModel.isCardChangeWithBg,
          isExisting: model.isExiting,
        ),
      )
    );
    list.addAll(List.generate(
        4,
        (index) => Container(
          margin: EdgeInsets.only(
              left: 20, top: size.width > size.height ? 0 : 20, right: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffB7B7B7),
                      offset: Offset(6.0, 0.0), //阴影x轴偏移量
                      blurRadius: 10, //阴影模糊程度
                    )
                  ]),
              padding: EdgeInsets.only(top: 10),
              child: ListTile(
                title: Text(
                    itemNameList[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18
                  ),
                ),
                subtitle: Text(itemContent[index]),
              ),
            )));

    return WillPopScope(
      onWillPop: () {
        model.logic.exitPage();
        return Future.value(false);
      },
      child: Stack(
        children: <Widget>[
          Hero(
            tag: "task_bg$heroTag",
            child: Container(
                decoration: BoxDecoration(
              color: globalModel.logic
                  .getBgInDark()
                  .withOpacity(enableOpacity ? opacity : 1.0),
              borderRadius: BorderRadius.circular(15.0),
              // image: bgUrl == null
              //     ? null
              //     : DecorationImage(
              //         image: getProvider(bgUrl),
              //         colorFilter: new ColorFilter.mode(
              //             Colors.black.withOpacity(
              //               enableOpacity ? opacity : 1.0,
              //             ),
              //             BlendMode.dstATop),
              //         fit: BoxFit.cover,
              //       ),
            )),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                "日程详情",
                style: TextStyle(color: Colors.black),
              ),
              iconTheme: IconThemeData(color: taskColor),
              leading: model.isAnimationComplete && !model.isExiting
                  ? IconButton(
                      icon: Icon(Platform.isAndroid
                          ? Icons.arrow_back
                          : Icons.arrow_back_ios),
                      color: Colors.black,
                      onPressed: model.logic.exitPage,
                    )
                  : SizedBox(),
              elevation: 0,
              backgroundColor: Colors.transparent,
              // actions: <Widget>[
              //   Hero(
              //       tag: "task_more$heroTag",
              //       child: Material(
              //           color: Colors.transparent,
              //           child: PopMenuBt(
              //             iconColor: taskColor,
              //             taskBean: model.taskBean,
              //             onDelete: () => model.logic.deleteTask(mainPageModel),
              //             // onEdit: () => model.logic.editTask(mainPageModel),
              //           ))),
              // ],
            ),
            //使用NotificationListener可以去掉android上默认Listview的水波纹效果
            body: ListView(
              children: list
                // Expanded(
                //   child: Container(
                //     margin: EdgeInsets.only(top: 20),
                //     child: !model.isExiting
                //         ? NotificationListener<OverscrollIndicatorNotification>(
                //             onNotification: (overScroll) {
                //               overScroll.disallowGlow();
                //               return true;
                //             },
                //             child: ListView(//子任务
                //               children: List.generate(
                //                 model?.taskBean?.detailList?.length ?? 0,
                //                 (index) {
                //                   TaskDetailBean taskDetailBean =
                //                       model.taskBean.detailList[index];
                //                   return Container(
                //                     margin: EdgeInsets.only(
                //                         bottom: index ==
                //                                 model.taskBean.detailList
                //                                         .length -
                //                                     1
                //                             ? 20
                //                             : 0,
                //                         left: 50,
                //                         right: 50),
                //                     // child: TaskDetailItem(
                //                     //   index: index,
                //                     //   showAnimation:
                //                     //       model.doneTaskPageModel == null,
                //                     //   itemProgress: taskDetailBean.itemProgress,
                //                     //   itemName: taskDetailBean.taskDetailName,
                //                     //   iconColor: taskColor,
                //                     //   textColor: textColor,
                //                     //   onProgressChanged: (progress) {
                //                     //     model.logic.refreshProgress(
                //                     //         taskDetailBean,
                //                     //         progress,
                //                     //         mainPageModel);
                //                     //     model.refresh();
                //                     //   },
                //                     //   onChecked: (progress) {
                //                     //     model.logic.refreshProgress(
                //                     //         taskDetailBean,
                //                     //         progress,
                //                     //         mainPageModel);
                //                     //     model.refresh();
                //                     //   },
                //                     // ),
                //                   );
                //                 },
                //               ),
                //             ))
                //         : SizedBox(),
                //   ),
                // )
            ),
          ),
        ],
      ),
    );
  }
}
