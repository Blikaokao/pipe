import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/lunar_calendar/GetLunar.dart';
import 'package:todo_list/model/all_model.dart';
import 'package:todo_list/utils/date_picker_util.dart';

class AllCalenderWidget extends StatefulWidget {
  final AllMainPageModel allMainPageModel;
  AllCalenderWidget(this.allMainPageModel);
  @override
  _AllCalenderWidgetState createState() => _AllCalenderWidgetState();
}

class _AllCalenderWidgetState extends State<AllCalenderWidget> {
  PageController _pageController;
  ValueNotifier<List<TaskBean>> _selectedEvents; //需要局部刷新的量
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );
  CalendarFormat _calendarFormat = CalendarFormat.week;

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

  bool get canClearSelection => _selectedDays.isNotEmpty;

  List<TaskBean> _getEventsForDay(DateTime day) {
    return widget.allMainPageModel.kEvents[day] ?? [];
  }

  List<TaskBean> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDays.clear();
      _selectedDays.add(selectedDay);
      _focusedDay.value = focusedDay;
    });

    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }

  @override
  Widget build(BuildContext context) {
    CalendarStyle calendarStyle = CalendarStyle();
    final margin = calendarStyle.cellMargin;
    final padding = calendarStyle.cellPadding;
    final alignment = calendarStyle.cellAlignment;
    final duration = const Duration(milliseconds: 250);

    return Column(children: [
      ValueListenableBuilder<DateTime>(
        valueListenable: _focusedDay, //监听对象
        builder: (context, value, _) {
          return _CalendarHeader(
            //日历头部
            focusedDay: value,
            clearButtonVisible: canClearSelection,
            onTodayButtonTap: () {
              setState(() => _focusedDay.value = DateTime.now());
            },
            onClearButtonTap: () {
              setState(() {
                _selectedDays.clear();
                _selectedEvents.value = [];
              });
            },
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
      TableCalendar<TaskBean>(
        /****************新添************************/
        daysOfWeekHeight: 25,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
          weekendStyle: TextStyle(color: Colors.grey, fontSize: 18),
        ),
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
                duration: duration,
                margin: margin,
                padding: padding,
                decoration: const BoxDecoration(
                  color: const Color(0xFF1E60E0),
                  shape: BoxShape.circle,
                ),
                alignment: alignment,
                child: Column(
                  children: [
                    Text(
                        _day.day < 10
                            ? "0" + _day.day.toString()
                            : _day.day.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(GetLunar.getLunar(_day.year, _day.month, _day.day),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ));
          },
          outsideBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
                duration: duration,
                margin: margin,
                padding: padding,
                decoration: calendarStyle.outsideDecoration,
                alignment: alignment,
                child: Column(
                  children: [
                    Text(
                        _day.day < 10
                            ? "0" + _day.day.toString()
                            : _day.day.toString(),
                        style: TextStyle(
                            color: const Color(0xffB7B7B7),
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(GetLunar.getLunar(_day.year, _day.month, _day.day),
                        style: TextStyle(
                          color: const Color(0xffB7B7B7),
                          fontSize: 12,
                          // fontWeight: FontWeight.bold)
                        )),
                  ],
                ));
          },
          // 禁用
          disabledBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
                duration: duration,
                margin: margin,
                padding: padding,
                decoration: calendarStyle.disabledDecoration,
                alignment: alignment,
                child: Column(
                  children: [
                    Text(
                        _day.day < 10
                            ? "0" + _day.day.toString()
                            : _day.day.toString(),
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFB7B7B7))),
                    Text(GetLunar.getLunar(_day.year, _day.month, _day.day),
                        style: TextStyle(
                            fontSize: 12.0,
                            // fontWeight: FontWeight.bold,
                            color: const Color(0xFFB7B7B7))),
                  ],
                ));
          },
          todayBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
                duration: duration,
                margin: margin,
                padding: padding,
                decoration: const BoxDecoration(
                    color: const Color(0xFF88CBFC), shape: BoxShape.circle),
                alignment: alignment,
                child: Column(
                  children: [
                    Text(
                      _day.day < 10
                          ? "0" + _day.day.toString()
                          : _day.day.toString(),
                      style: const TextStyle(
                          color: const Color(0xFFFAFAFA),
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      GetLunar.getLunar(_day.year, _day.month, _day.day),
                      style: const TextStyle(
                        color: const Color(0xFFFAFAFA),
                        fontSize: 12.0,
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ));
          },

          defaultBuilder: (_ctx, _day, _focusDay) {
            return AnimatedContainer(
                // margin: EdgeInsets.all(1),
                duration: const Duration(milliseconds: 250),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      _day.day < 10
                          ? "0" + _day.day.toString()
                          : _day.day.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      GetLunar.getLunar(_day.year, _day.month, _day.day),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        // fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ));
          },
        ),
        /****************以上新添************************/

        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay.value,
        headerVisible: false,
        selectedDayPredicate: (day) => _selectedDays.contains(day),
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        onDaySelected: _onDaySelected,
        onCalendarCreated: (controller) => _pageController = controller,
        onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
      ),
      const SizedBox(height: 8.0),

      //事件列表
      Expanded(
        child: Container(
            padding: EdgeInsets.only(top: 20, left: 15, right: 10),
            height: 1000,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            ),
            child: ValueListenableBuilder<List<TaskBean>>(
              valueListenable: _selectedEvents, //监听被选中的事件列表
              builder: (context, value, _) {
                widget.allMainPageModel.selectedTasks = _selectedEvents.value;
                return TimeTable(widget.allMainPageModel);
              },
            )),
      )
    ]);
  }
}

///日历头部
class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    this.focusedDay,
    this.onLeftArrowTap,
    this.onRightArrowTap,
    this.onTodayButtonTap,
    this.onClearButtonTap,
    this.clearButtonVisible,
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
          if (clearButtonVisible)
            IconButton(
              icon: Icon(
                Icons.clear,
                size: 20.0,
                color: Colors.white,
              ),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

class TimeTable extends StatefulWidget {
  final AllMainPageModel model;
  TimeTable(this.model);
  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  int rowsCount = 24;
  double cellWidth = 80;
  double cellHeight = 50;
  ScrollController leftController;
  ScrollController topController;
  ScrollController rowController;
  List<ScrollController> columnsController = [];
  LinkedScrollControllerGroup _verticalControllers;
  LinkedScrollControllerGroup _horizontalControllers;
  int columnsCount;

  @override
  void initState() {
    super.initState();
    _verticalControllers = LinkedScrollControllerGroup();
    _horizontalControllers = LinkedScrollControllerGroup();
    leftController = _verticalControllers?.addAndGet();
    topController = _horizontalControllers?.addAndGet();
    rowController = _horizontalControllers?.addAndGet();
  }

  @override
  Widget build(BuildContext context) {
    columnsCount = widget.model.globalModel.allName
            .length /*> 4
        ? widget.model.globalModel.allName.length
        : 4*/
        ;
    for (var i = 0; i < columnsCount; i++) {
      ScrollController columnController = _verticalControllers?.addAndGet();
      if (columnController != null) {
        columnsController.add(columnController);
      }
    }

    return _bodyWidget();
  }

  Widget _bodyWidget() {
    return Row(children: [
      Container(
        width: cellWidth,
        height: (rowsCount - 1) * cellHeight,
        child: Column(children: [
          Container(
              decoration: BoxDecoration(
                  // color: Colors.blueGrey[100],
                  border: Border(
                      right: BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ))),
              padding: EdgeInsets.only(left: 5.0, right: 5.0),
              height: cellHeight,
              width: cellWidth,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      child: Text("  "),
                    ),
                    Container(
                        alignment: Alignment.bottomLeft, child: Text("  "))
                  ])),
          Expanded(
            child: ListView.builder(
              controller: leftController,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(0),
              itemBuilder: (context, index) {
                return Container(
                    decoration: BoxDecoration(
                        // color: Colors.blueGrey[100],
                        border: Border(
                      bottom: BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                      right: BorderSide(
                        color: Colors.blue,
                        width: 1,
                      ),
                    )),
                    height: cellHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("${index + 1}" + ":00"),
                      ],
                    ));
              },
              itemCount: rowsCount,
            ),
          ),
        ]),
      ),
      Expanded(
          child: Column(children: [
        Container(
          height: cellHeight,
          child: ListView.builder(
            controller: topController,
            padding: EdgeInsets.all(0),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                  decoration: BoxDecoration(
                      // color: Colors.blueGrey[100],
                      border: Border(
                    bottom: BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  )),
                  width: widget.model.globalModel.allName.length >= 4
                      ? cellWidth * 0.8
                      : 4 *
                          cellWidth *
                          0.8 /
                          widget.model.globalModel.allName.length,
                  child: Center(
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: BorderRadius.circular(18.0),
                            // ),
                            maximumSize: Size(
                                widget.model.globalModel.allName.length >= 4
                                    ? cellWidth
                                    : 4 *
                                        cellWidth /
                                        widget.model.globalModel.allName.length,
                                cellHeight),
                            side: BorderSide(
                                width: 2,
                                color: widget
                                    .model.logic.taskItemColor[index % 4]),
                          ),
                          child: Text(
                            index >= widget.model.globalModel.allName.length
                                ? ""
                                : widget.model.globalModel.allName[index],
                            overflow: TextOverflow.ellipsis,
                          ))));
            },
            itemCount: columnsCount,
          ),
        ),
        Expanded(
            child: ListView.builder(
          controller: rowController,
          padding: EdgeInsets.all(0),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            List<TaskBean> list = widget.model.logic.getPerDayTask(index);
            //获得的用户列表
            return Container(
              width: widget.model.globalModel.allName.length >= 4
                  ? cellWidth * 0.8
                  : 4 *
                      cellWidth *
                      0.8 /
                      widget.model.globalModel.allName.length,
              //每个用户的事件栏
              child: ListView(
                controller: columnsController[index],
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: EdgeInsets.all(2),
                children: widget.model.logic.getPerDayTaskContainer(
                    widget.model.globalModel.allName.length >= 4
                        ? cellWidth
                        : 4 *
                            cellWidth /
                            widget.model.globalModel.allName.length,
                    cellHeight,
                    list,
                    index),
              ),
            );
          },
          itemCount: columnsCount,
        ))
      ]))
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    leftController?.dispose();
    topController?.dispose();
    rowController?.dispose();
    for (var controller in columnsController) {
      controller.dispose();
    }
  }
}
