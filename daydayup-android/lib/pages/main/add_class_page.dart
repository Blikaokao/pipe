import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/config/floating_border.dart';
import 'package:todo_list/config/local_calender_service.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:provider/provider.dart';
import 'package:todo_list/pages/main/set_class_time.dart';
import 'package:intl/src/intl/date_format.dart';


class AddClassPage extends StatefulWidget {
  bool add;
  AddClassPage(this.add);
  @override
  State<StatefulWidget> createState() => AddClassPageState();
}

class AddClassPageState extends State<AddClassPage> {
  GlobalModel globalModel;
  AddClassPageModel model;
  var colorOutList = [
    const Color(0xffA3DCFD),
    const Color(0xffFFCAD0),
    const Color(0xffB6E8C4),
    const Color(0xffFFE191),
    const Color(0xffC8B1DF),
  ];
  var colorInList = [
    const Color(0x26A3DCFD),
    const Color(0x26FFCAD0),
    const Color(0x26B6E8C4),
    const Color(0x26FFE191),
    const Color(0x26C8B1DF),
  ];


  var weekList = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];


  var dateList = [];
  var currentWeekIndex = 0;

  @override
  void initState() {
    super.initState();

    var monday = 1;
    var mondayTime = DateTime.now();

    //获取本周星期一是几号
    while (mondayTime.weekday != monday) {
      mondayTime = mondayTime.subtract(new Duration(days: 1));
    }

    mondayTime.year; //2020 年
    mondayTime.month; //6(这里和js中的月份有区别，js中是从0开始，dart则从1开始，我们无需再进行加一处理) 月
    mondayTime.day; //6 日
    // nowTime.hour ;//6 时
    // nowTime.minute ;//6 分
    // nowTime.second ;//6 秒
    for (int i = 0; i < 7; i++) {
      dateList.add(
          mondayTime.month.toString() + "/" + (mondayTime.day + i).toString());
      if ((mondayTime.day + i) == DateTime.now().day) {
        setState(() {
          currentWeekIndex = i + 1;
        });
      }
    }
    // print('Recent monday '+DateTime.now().day.toString());
  }


  @override
  Widget build(BuildContext context) {
    globalModel = Provider.of<GlobalModel>(context);
    model = Provider.of<AddClassPageModel>(context);
    model.logic.TimeSlotGenerate();
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/bg_blue.png"),
            fit: BoxFit.cover,
          )),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          actions:[
            widget.add?IconButton(
              onPressed: (){
                showDialog<Null>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      title: new Text(
                        '是否将此课程表添加到日程？',
                        style: TextStyle(
                          fontSize: 18
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('确定',style: TextStyle(color:Colors.red),),
                          onPressed: () async {//添加课表
                            globalModel.hasCourse.add(globalModel.currentId);

                            //获取本周周一
                            var monday = 1;
                            var mondayTime = DateTime.now();
                            while (mondayTime.weekday != monday) {
                              mondayTime = mondayTime.subtract(new Duration(days: 1));
                            }
                            DateTime startDate;
                            DateTime deadLine;
                            List<TaskBean> taskBeans = [];
                            for(int i=0;i<7;i++){

                                for(int j=0;j<10;j++) {
                                  String taskName = model.classBean.classes[i].getLesson(j);
                                  String taskNameNull = taskName.replaceAll(" ", "");
                                  if (taskNameNull.isNotEmpty) {
                                    TaskBean taskBean = TaskBean();
                                    taskBean.taskName = model.classBean.classes[i].getLesson(j) ;
                                    taskBean.uniqueId = globalModel.currentId;
                                    taskBean.period = 7;
                                    taskBean.eventType = 1;
                                    taskBean.account =
                                        globalModel.logic.getUserName(
                                            globalModel.currentId);
                                    startDate = DateTime(
                                        mondayTime.year, mondayTime.month,
                                        mondayTime.day, int.parse(
                                        model.timeStartList[j].split(":")[0]),
                                        int.parse(
                                            model.timeStartList[j].split(":")[1]));
                                    deadLine = DateTime(
                                        mondayTime.year, mondayTime.month,
                                        mondayTime.day, int.parse(
                                        model.timeEndList[j].split(":")[0]),
                                        int.parse( model.timeEndList[j].split(
                                            ":")[1]));
                                    taskBean.startDate = startDate.toString();
                                    taskBean.deadLine = deadLine.toString();
                                    taskBean.detailList = [];
                                    taskBean.eventId =
                                    await LocalCalenderService.instance.add(
                                        taskBean.taskName,
                                        DateFormat('yyyy-MM-dd HH:mm:ss')
                                            .format(startDate),
                                        DateFormat('yyyy-MM-dd HH:mm:ss')
                                            .format(deadLine),
                                        "所属者:" + globalModel.logic.getUserName(
                                            globalModel.currentId),
                                        alert: -1);
                                    taskBeans.add(taskBean);
                                  }
                                }

                                mondayTime = mondayTime.add(new Duration(days: 1));


                            }
                            postCreateTask(taskBeans);

                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) {
                                      return ProviderConfig.getInstance().getMainPage();
                                    }),
                                    (router) => router == null);
                          },
                        ),
                        new FlatButton(
                          child: new Text('取消'),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) {
                                      return ProviderConfig.getInstance().getMainPage();
                                    }),
                                    (router) => router == null);
                          },
                        ),
                      ],
                    );
                  },
                ).then((val) {
                  print(val);
                });

              },
              icon: Icon(Icons.done)):Container()
          ],
          title: Text(
            globalModel.logic.getUserName(globalModel.currentId)+"的课程表",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: Image.asset("images/home.png"),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) {
                      return ProviderConfig.getInstance().getMainPage();
                    }),
                    (router) => router == null);
          },
        ),
        bottomNavigationBar: BottomAppBar(
            color: const Color(0xff5B90E7),
            shape: CustomNotchedShape(context),
            child: Row(
              children: [
                IconButton(
                    icon: Image.asset(
                      "images/month_calendar.png",
                      width: 30,
                    ),
                    onPressed: () {}),
                SizedBox(),
                IconButton(
                  icon: Image.asset(
                    "images/my_set.png",
                    width: 30,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.spaceAround,
            )),
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(
            //   child:
            GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 8,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8, childAspectRatio: 1 / 1),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.all(Radius.circular(2)) ,
                        color: const Color(0xBFffffff),
                      ),
                      child: Center(
                        child: index == 0
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("星期",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black87)),
                            Container(height: 5),
                            Text("日期", style: TextStyle(fontSize: 12)),
                          ],
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(weekList[index - 1],
                                style: TextStyle(
                                    fontSize: 14,
                                    color: index == currentWeekIndex
                                        ? Colors.lightBlue
                                        : const Color(0xff34465A))),
                            Container(height: 5),
                            Text(dateList[index - 1],
                                style: TextStyle(
                                    fontSize: 12,
                                    color: index == currentWeekIndex
                                        ? Colors.lightBlue
                                        : const Color(0xff40556D))),
                          ],
                        ),
                      ),
                    );
                  }),
            // ),
            Expanded(
              child:
              SingleChildScrollView(
                child: Row(
                  children: [

                      Expanded(
                        flex: 1,
                        child: GridView.builder(
                            shrinkWrap: true,
                            // physics:ClampingScrollPhysics(),
                            itemCount: 10,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1, childAspectRatio: 1 / 4),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: (){

                                  Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (context) {
                                    return SetClassTimePage(model);
                                  }));
                                },
                                child: Container(
                                  // width: 25,
                                  // height:s 80,
                                    child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            (index + 1).toInt().toString(),
                                            style: TextStyle(
                                                color: const Color(0xff1F2F41),
                                                fontSize: 15),
                                          ),
                                          Text(
                                            model.timeStartList[index],
                                            style: TextStyle(
                                                color: const Color(0xff34465A),
                                                fontSize: 10),
                                          ),
                                          Text(
                                            model.timeEndList[index],
                                            style: TextStyle(
                                                color: const Color(0xff34465A),
                                                fontSize: 10),
                                          )
                                        ]
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xBFFFFFFF),
                                      // border: Border.all(color: Colors.black12, width: 0.5),
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.black12, width: 0.5),
                                        right: BorderSide(
                                            color: Colors.black12, width: 0.5),
                                      ),
                                    )
                                ),
                              );
                            }),
                      ),
                    Expanded(
                      flex: 7,
                      child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: 70,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7, childAspectRatio: 1 / 4),
                          itemBuilder: (BuildContext context, int index) {

                            int weekDay = index%7;
                            int lesson = index~/7;
                            String detail = model.logic.thisLine(weekDay,lesson);
                            String detailNull = detail.replaceAll(" ", "");
                            return Container(
                              child: Stack(
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xF2ffffff),

                                            )),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: const Color(0xF2ffffff),

                                            )),
                                      ),
                                    ],
                                  ),

                                  detailNull.isEmpty?GestureDetector(
                                    onTap: (){
                                      showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (_) {
                                            return  EditClassContentWidget("");
                                          });
                                    },
                                      child: Container(),
                                  ): GestureDetector(
                                    onTap: (){
                                      showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (_) {
                                            return  EditClassContentWidget(detail);
                                          });
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(right: 3,bottom: 3),
                                        padding: EdgeInsets.only(left: 4.0,top: 4.0),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: colorOutList[index % 5],
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0x40000000),  //底色,阴影颜色
                                              offset: Offset(2, 2), //阴影位置,从什么位置开始
                                              blurRadius: 2,  // 阴影模糊层度
                                              spreadRadius: 0,  //阴影模糊大小
                                            )],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                                            color: Colors.white,
                                          ),
                                          child: Container(
                                            color: colorInList[index % 5],
                                            child: Center(
                                              child: Text(
                                                detail,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: const Color(0xff373737),
                                                    fontSize: 11,
                                                    letterSpacing: 1),
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                  )

                                ],
                              ),
                            );
                          }),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void postCreateTask(List<TaskBean> taskBeans, {bool isSubmitOldTask = false}) async {

    ApiService.instance.postCreateTask(
      globalModel.currentId,
      success: (UploadTaskBean bean) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) {
                  return ProviderConfig.getInstance().getMainPage();
                }),
                (router) => router == null);
      },
      failed: (UploadTaskBean bean) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) {
                  return ProviderConfig.getInstance().getMainPage();
                }),
                (router) => router == null);
      },
      error: (msg) {

      },
      taskBeans: taskBeans,
      // token: token,
      cancelToken: CancelToken(),
    );
  }


}


class EditClassContentWidget extends StatelessWidget {
  String className;
  final TextEditingController classNameInput = TextEditingController();
  EditClassContentWidget(this.className){
    classNameInput.text = className;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      padding: EdgeInsets.only(left:20,right: 20),
      height:200,
      child: ListView(
        // mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: (){}, child: Text("删除",style:TextStyle(color: Colors.red))),
            ],
          ),
          Padding(
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: TextField(
            style: TextStyle(color: Colors.black87),
            controller: classNameInput,
            decoration: InputDecoration(
                prefixIcon:Icon(Icons.import_contacts),
                hintText: "课程信息",
                hintStyle: TextStyle(
                    fontSize: 15
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                )),
          ),
          ),

           Container(
             child:Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 OutlinedButton(onPressed: (){}, child: Text("取消")),
                 ElevatedButton(onPressed: (){}, child: Text("确定")),
               ],
             )
           ),

        ],
      ),
    );
  }
}
