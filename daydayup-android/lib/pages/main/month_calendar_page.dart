import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_list/config/floating_border.dart';
import 'package:todo_list/config/provider_config.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/lunar_calendar/GetLunar.dart';
import 'package:todo_list/pages/navigator/nav_page.dart';
import 'package:todo_list/utils/date_picker_util.dart';

class MonthCalendarPage extends StatefulWidget {
  final LinkedHashMap<DateTime, List<TaskBean>> events;
  MonthCalendarPage(this.events);
  @override
  _MonthCalendarPageState createState() => _MonthCalendarPageState();
}

class _MonthCalendarPageState extends State<MonthCalendarPage> {
  List<TaskBean> _getEventsForDay(DateTime day) {
    return widget.events[day] ?? [];
  }

  PageController _pageController;
  ValueNotifier<List<TaskBean>> _selectedEvents; //需要局部刷新的量
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _rangeStart;
  DateTime _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDays.add(_focusedDay.value);
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  bool get canClearSelection =>
      _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("images/bg_blue.png"),
        fit: BoxFit.cover,
      )),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              "掌舵者",
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
                        color: Colors.white,
                        width: 30,
                      ),
                      onPressed: () {}),
                  SizedBox(),
                  IconButton(
                    icon: Image.asset(
                      "images/my_set.png",
                      width: 30,
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return NavPage();
                      }));
                    },
                  ),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              )),
          body: Column(
            children: [
              ValueListenableBuilder<DateTime>(
                valueListenable: _focusedDay, //监听对象
                builder: (context, value, _) {
                  return _CalendarHeader(
                    //日历头部
                    focusedDay: value,
                    // clearButtonVisible: canClearSelection,
                    onTodayButtonTap: () {
                      setState(() => _focusedDay.value = DateTime.now());
                    },
                    // onClearButtonTap: () {
                    //   setState(() {
                    //     _rangeStart = null;
                    //     _rangeEnd = null;
                    //     _selectedDays.clear();
                    //     _selectedEvents.value = [];
                    //   });
                    // },
                    onLeftArrowTap: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    onRightArrowTap: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                  );
                },
              ),
              Expanded(
                  child: Container(
                color: Colors.white,
                child: TableCalendar(
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay.value,
                    headerVisible: false,
                    // onRangeSelected: _onRangeSelected,
                    onCalendarCreated: (controller) =>
                        _pageController = controller,
                    onPageChanged: (focusedDay) =>
                        _focusedDay.value = focusedDay,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() => _calendarFormat = format);
                      }
                    },
                    daysOfWeekHeight: 25,
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: const Color(0xFF4674BF),fontSize: 18),
                      weekendStyle: TextStyle(color: const Color(0xFF4674BF),fontSize: 18),
                    ),
                    eventLoader: _getEventsForDay,
                    availableCalendarFormats: {
                      CalendarFormat.month: 'Month',
                    },
                    calendarFormat: CalendarFormat.month,
                    shouldFillViewport: true,
                    calendarStyle: CalendarStyle(
                      cellAlignment: Alignment.topCenter,
                    ),
                    calendarBuilders: CalendarBuilders(
                        disabledBuilder: (_ctx, _day, _focusDay) {
                      return AnimatedContainer(
                        margin: EdgeInsets.all(1),
                        // decoration: BoxDecoration(
                        //   border: Border.all(color: Colors.grey),
                        // ),
                        duration: const Duration(milliseconds: 250),
                        alignment: Alignment.topCenter,
                        child:
                        Column(
                          children: [
                            Text(
                              _day.day >= 10
                                  ? _day.day.toString()
                                  : "0" + _day.day.toString(),
                              style: TextStyle(
                                  color: const Color(0xffCBCBCB),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Text(
                              GetLunar.getLunar(_day.year, _day.month, _day.day),
                              style: TextStyle(
                                  color: const Color(0xffCBCBCB),
                                  // fontWeight: FontWeight.bold,
                                  // fontSize: 20
                              ),
                            ),
                          ],
                        )
                      );
                    }, outsideBuilder: (_ctx, _day, _focusDay) {
                      return AnimatedContainer(
                        margin: EdgeInsets.all(1),
                        // decoration: BoxDecoration(
                        //   border: Border.all(color: Colors.grey),
                        // ),
                        duration: const Duration(milliseconds: 250),
                        alignment: Alignment.topCenter,
                        child:
                        Column(
                          children: [
                            Text(
                              _day.day >= 10
                                  ? _day.day.toString()
                                  : "0" + _day.day.toString(),
                              style: TextStyle(
                                  color: const Color(0xffCBCBCB),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Text(
                              GetLunar.getLunar(_day.year, _day.month, _day.day),
                              style: TextStyle(
                                  color: const Color(0xffCBCBCB),
                                  // fontWeight: FontWeight.bold,
                                  // fontSize: 20
                              ),
                            ),
                          ],
                        )
                      );
                    },
                        todayBuilder: (_ctx, _day, _focusDay) {
                      return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          alignment: Alignment.topCenter,
                          child: Container(
                            // height:45,
                            // decoration: const BoxDecoration(
                            //     color: const Color(0xFF9FA8DA),
                            //     // shape: BoxShape.circle
                            // ),
                            child:
                            Column(
                              children: [
                                Container(
                                  height:25,
                                  decoration: const BoxDecoration(
                                    color: const Color(0xFF9FA8DA),
                                    shape: BoxShape.circle
                                  ),
                                  child:
                                  Text(
                                    _day.day >= 10
                                        ? _day.day.toString()
                                        : "0" + _day.day.toString(),
                                    style: const TextStyle(
                                      color: const Color(0xFFFAFAFA),
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  GetLunar.getLunar(_day.year, _day.month, _day.day),
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    // fontSize: 18.0,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          ));
                    },
                        defaultBuilder: (_ctx, _day, _focusDay) {
                      return AnimatedContainer(
                        margin: EdgeInsets.all(1),
                        // decoration: BoxDecoration(
                        //   border: Border.all(color: Colors.grey),
                        // ),
                        duration: const Duration(milliseconds: 250),
                        alignment: Alignment.topCenter,
                        child:
                        Column(
                          children: [
                            Text(
                              _day.day >= 10
                                  ? _day.day.toString()
                                  : "0" + _day.day.toString(),
                              style: TextStyle(
                                  color: const Color(0xff686767),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                            Text(
                              GetLunar.getLunar(_day.year, _day.month, _day.day),
                              style: TextStyle(
                                  color: Colors.black54,
                                  // fontWeight: FontWeight.bold,
                                  // fontSize: 15
                              ),
                            ),
                          ],
                        )
                      );
                    },
                        markerBuilder: (_ctx, _date, _events) {
                      List<Color> colors = [
                        const Color(0x99ACC8E8),
                        const Color(0XFFACC8E8),
                        const Color(0XFFE8CBCE),
                        const Color(0XFFF3D074),
                        const Color(0XFF96C58E)];
                      return LayoutBuilder(builder: (context, constraints) {
                        return Container(
                            padding: EdgeInsets.only(top: 45),
                            child: ListView.builder(
                                itemCount: _events.length,
                                itemExtent: constraints.maxHeight / 5,
                                itemBuilder: (BuildContext context, int index) {
                                  return
                                    Container(
                                      margin: EdgeInsets.all(2),
                                      color: colors[(_events[index].uniqueId)%5],
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child:Text(
                                          _events[index].taskName,
                                          style: TextStyle(
                                              color: const Color(0xff686767),
                                              overflow: TextOverflow.clip,
                                              fontSize: 12
                                          )),
                                      ),
                                    );
                                }));
                      });
                    }
                    )),
              ))
            ],
          )),
    ));
  }
}

///日历头部
class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  // final VoidCallback onClearButtonTap;
  // final bool clearButtonVisible;

  const _CalendarHeader({
    this.focusedDay,
    this.onLeftArrowTap,
    this.onRightArrowTap,
    this.onTodayButtonTap,
    // this.onClearButtonTap,
    // this.clearButtonVisible,
  });

  @override
  Widget build(BuildContext context) {
    // final headerText = DateFormat.yMMM().format(focusedDay);
    final year = DateFormat.y().format(focusedDay);
    final month = DateFormat.M().format(focusedDay);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        children: [
          const SizedBox(width: 10.0),
          Icon(
            Icons.apps,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 10.0),
          SizedBox(
            width: 150.0,
            child: Text(
              year + " | " + month,
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ),
          IconButton(
            icon: Image.asset("images/calendar_today.png"),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          // if (clearButtonVisible)
          //   IconButton(
          //     icon: Icon(
          //       Icons.clear,
          //       size: 20.0,
          //       color: Colors.white,
          //     ),
          //     visualDensity: VisualDensity.compact,
          //     onPressed: onClearButtonTap,
          //   ),
          const Spacer(),
          // IconButton(
          //   icon: Icon(Icons.chevron_left),
          //   onPressed: onLeftArrowTap,
          // ),
          // IconButton(
          //   icon: Icon(Icons.chevron_right),
          //   onPressed: onRightArrowTap,
          // ),
        ],
      ),
    );
  }
}
